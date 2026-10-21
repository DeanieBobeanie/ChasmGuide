local _, G = ...
local overview = "https://www.wowhead.com/forever/guide/dungeons/every-dungeon-quest-location"
for id,name in pairs(G.wowheadNames) do if not G.names[id] then G.names[id]=name end end

-- Apply verified NPC positions to the existing steps without changing their order.
-- A shared waypoint must only be replaced on the matching NPC step, never a boss objective.
local function MatchNPC(where)
    local found
    for _,npc in pairs(G.wowheadNPCs) do
        if where and where:find(npc.name,1,true) then
            if found then return nil end
            found=npc
        end
    end
    return found
end
local function UpdateLocation(at)
    if not at then return end
    local npc=MatchNPC(at.where)
    if npc then
        at.pin=npc.pin; at.locationSource=npc.source; at.area=npc.area
        -- Generated records previously embedded coordinates in their text as well.
        at.where=at.where:gsub(" / %d+%.?%d*, %d+%.?%d*$","")
    end
end
for id,q in pairs(G.questCatalog) do
    UpdateLocation(q.start); UpdateLocation(q.finish)
    local info=G.wowheadQuests[id]
    if info and info.pickup and info.pickup.source~="Bundled quest database" then
        q.start=info.pickup
    end
    if info and info.finish then q.finish=info.finish end
end
local seen={}
local function StepLocation(step)
    local location
    for _,id in ipairs(step.quests or {}) do
        local info=G.wowheadQuests[id]
        local at
        if info then
            if step.kind=="accept" then at=info.pickup else at=info.finish end
        end
        -- Grouped pickups need one common, verified destination.
        if not at or not at.pin or at.source=="Bundled quest database" then return end
        if location and (location.pin.mapID~=at.pin.mapID or location.pin.zone~=at.pin.zone
            or location.pin.x~=at.pin.x or location.pin.y~=at.pin.y) then return end
        location=at
    end
    return location
end
local function UpdateGuide(guide)
    if not guide or seen[guide] then return end
    seen[guide]=true
    for _,step in ipairs(guide.steps or {}) do
        if step.kind=="accept" or step.kind=="turnin" then
            UpdateLocation(step)
            local at=StepLocation(step)
            if at then step.pin=at.pin; step.locationSource=at.source; step.area=at.area end
        end
        if step.pin and not step.pin.mapID then
            for _,npc in pairs(G.wowheadNPCs) do
                if npc.pin.zone==step.pin.zone then step.pin.mapID=npc.pin.mapID; break end
            end
        end
    end
    for _,route in pairs(guide.routes or {}) do UpdateGuide(route) end
end
for _,guide in pairs(G.guides) do UpdateGuide(guide) end
for key,entry in pairs(G.wowheadEntrances) do
    if entry.pin then G.catalog[key].entrance=entry.pin end
end

local shares={yes="Yes",no="No",prereq="Conditional (Pre)",drop="Own drop required",
    escort="Group escort",object="Interact with the quest item",unknown="Unverified"}
local colors={yes="82d6a0",no="ef9292",prereq="e1c27a",drop="e1c27a",escort="e1c27a",object="e1c27a",unknown="aaaaaa"}
local effort={green="Low",gold="Medium",red="High",unknown="Unverified"}
local function HasIDs(t)
    for _,id in ipairs(t or {}) do if id>0 then return true end end
    return false
end
local function HasPrerequisites(id,info)
    local q=G.questCatalog[id]
    return (info and (info.pre or HasIDs(info.requires) or HasIDs(info.chain) or HasIDs(info.accepted) or info.requirementNote))
        or (q and (HasIDs(q.all) or HasIDs(q.any)))
end
function G.QuestInfoSummary(id)
    local info=G.wowheadQuests[id]
    local share=info and info.share or "unknown"
    local text="Share: |cff"..(colors[share] or colors.unknown)..(shares[share] or shares.unknown).."|r"
    if info and info.class then text=text.." ("..info.class.." only)" end
    text=text.." | Effort: "..(effort[info and info.effort or "unknown"] or "Unverified")
    if HasPrerequisites(id,info) then text=text.."\nPrerequisites: see Quest overview or Details"
    elseif info then text=text.."\nPrerequisites: none listed in the checked source"
    else text=text.."\nPrerequisites: not verified by Wowhead" end
    return text
end

local function RatingLabel(r)
    local text=(r.wing and r.wing~="" and r.wing..": " or "")..
        "Hard "..r.hard.." | Medium "..r.medium.." | At level "..r.normal
    if r.easy then text=text.." | Easy "..r.easy end
    return text
end
function G.DungeonDifficulty(key,full)
    local d=G.wowheadDungeons[key]
    if not d then return "Difficulty: not verified" end
    local lines={"|cffe1c27aDungeon difficulty (Wowhead)|r"}
    local playerLevel=G.Safe(UnitLevel,"player")
    for _,r in ipairs(d.ratings or {}) do
        lines[#lines+1]=RatingLabel(r)
        if full and type(playerLevel)=="number" and playerLevel>0 then
            local band=playerLevel<r.hard and "Below the guide's hard level" or
                (r.easy and playerLevel>=r.easy) and "Easy" or playerLevel>=r.normal and "At level" or
                playerLevel>=r.medium and "Medium" or "Hard"
            lines[#lines+1]="Your level "..playerLevel..": "..band.." ("..(r.wing and r.wing~="" and r.wing or "dungeon")..")"
        end
    end
    if d.range then lines[#lines+1]="Published range: "..d.range end
    if #(d.ratings or {})==0 then lines[#lines+1]="Difficulty bands not yet verified." end
    if full or key=="excavation" or key=="lordaeron" then lines[#lines+1]=d.note end
    return table.concat(lines,"\n")
end

function G.QuestInfoChoices()
    local ids,added={},{}
    local function Add(id)
        if added[id] then return end
        local info,q=G.wowheadQuests[id],G.questCatalog[id]
        if info and info.faction and info.faction~="Both" and info.faction~=G.routeFaction then return end
        if not (info and info.faction) and q and not G.QuestFits(q,G.routeFaction,false) then return end
        added[id]=true; ids[#ids+1]={value=id,label=(G.names[id] or tostring(id)).." (#"..id..")"}
    end
    for _,id in ipairs((G.wowheadDungeons[G.db.guide] or {}).quests or {}) do Add(id) end
    for _,id in ipairs(G.catalog[G.db.guide].quests or {}) do Add(id) end
    for _,step in ipairs(G.steps) do for _,id in ipairs(step.quests or step.checklist or {}) do Add(id) end end
    return ids
end

local stateLabel={turned="done",ready="ready to turn in",active="in progress",missing="not completed"}
local function QuestList(ids,accepted)
    local list={}
    for _,id in ipairs(ids or {}) do
        if id>0 then
            local state=G.QuestState(id)
            local done=state=="turned" or (accepted and state~="missing")
            list[#list+1]=(done and "|cff82d6a0" or "|cffe1c27a")..(G.names[id] or "Quest").." (#"..id.."): "..stateLabel[state].."|r"
        end
    end
    return table.concat(list,"\n")
end
local function LocationText(at)
    if not at then return "Not verified" end
    local text=at.where or "Not verified"
    if at.pin then text=text..string.format("\n%s: %.1f, %.1f",at.pin.zone,at.pin.x*100,at.pin.y*100) end
    if at.area then text=text.."\nNPC moves around this area; the pin is one recorded position." end
    return text
end
function G.QuestInfoText(id)
    local info,q=G.wowheadQuests[id],G.questCatalog[id]
    local lines={"|cffe1c27a"..(G.names[id] or "Quest").." (#"..id..")|r",G.QuestInfoSummary(id)}
    if info and info.level then lines[#lines+1]="Pickup level listed by guide: "..info.level end
    if info and info.databaseLevel then lines[#lines+1]="Minimum level on Wowhead quest page: "..info.databaseLevel end
    if info and info.databaseLevel and info.level and info.databaseLevel~=info.level then lines[#lines+1]="The guide and quest page list different levels; check the live quest offer." end
    if info and info.restriction then lines[#lines+1]=info.restriction end
    if info and info.profession then lines[#lines+1]="Profession: "..info.profession end
    if q and q.classes and q.classes~=0 and not (info and info.class) then lines[#lines+1]="Class restricted; check your trainer's quest line." end
    if info and info.share=="yes" then lines[#lines+1]="Recipients must meet level, faction, class and prerequisite requirements."
    elseif info and info.share=="prereq" then lines[#lines+1]="Wowhead marks Pre. Complete the requirements first; this marker does not guarantee the quest can be shared."
    elseif info and info.share=="escort" then lines[#lines+1]="Arrange acceptance with the whole party before starting the escort." end
    if info and info.shareSource then lines[#lines+1]="Sharing source: "..info.shareSource end
    if info and HasIDs(info.requires) then lines[#lines+1]="\nWowhead prerequisites:\n"..QuestList(info.requires) end
    if info and HasIDs(info.accepted) then lines[#lines+1]="\nMust first accept:\n"..QuestList(info.accepted,true) end
    if info and HasIDs(info.chain) then lines[#lines+1]="\nWowhead chain starts with (further steps follow):\n"..QuestList(info.chain) end
    if info and info.requirementNote then lines[#lines+1]="\nPrerequisite notes: "..info.requirementNote end
    if info and HasIDs(info.breadcrumb) then lines[#lines+1]="\nOptional breadcrumb:\n"..QuestList(info.breadcrumb) end
    -- Database dependencies are useful for intermediate quests but must not masquerade as Wowhead verification.
    if q and HasIDs(q.all) then lines[#lines+1]="\nBundled database: complete all\n"..QuestList(q.all) end
    if q and HasIDs(q.any) then lines[#lines+1]="\nBundled database: complete one\n"..QuestList(q.any) end
    local pickup=info and info.pickup or q and q.start
    lines[#lines+1]="\nPickup:\n"..LocationText(pickup)
    if pickup and pickup.source then lines[#lines+1]="Location source: "..pickup.source end
    local finish=info and info.finish or q and q.finish
    if finish then
        lines[#lines+1]="\nTurn-in:\n"..LocationText(finish)
        lines[#lines+1]="Turn-in source: "..(finish.source or finish.locationSource or "Bundled quest database")
    end
    if info and info.note then lines[#lines+1]="\nNote: "..info.note end
    if info and info.requirementSource then lines[#lines+1]="Requirement source: "..info.requirementSource end
    lines[#lines+1]="\nEffort describes quest preparation: Low = short preparation; Medium = extra travel or a short chain; High = a long or demanding chain. It is separate from dungeon combat difficulty."
    lines[#lines+1]="\nSources checked 5 October 2026. Unverified means the checked Wowhead guides do not establish the answer."
    return table.concat(lines,"\n"),pickup,(info and (info.shareSource or info.source)) or (G.wowheadDungeons[G.db.guide] or {}).source or overview
end

function G.DungeonInfoText()
    local key=G.db.guide
    local entry=G.wowheadEntrances[key]
    local lines={G.title.." / "..G.routeFaction,G.DungeonDifficulty(key,true)}
    if entry then lines[#lines+1]="\nEntrance:\n"..LocationText(entry).."\n"..entry.text
    elseif G.catalog[key].entrance then lines[#lines+1]="\nEntrance (bundled database):\n"..LocationText({where=G.title,pin=G.catalog[key].entrance}) end
    return table.concat(lines,"\n"),entry or {pin=G.catalog[key].entrance,where=G.title},(G.wowheadDungeons[key] or {}).source or overview
end
