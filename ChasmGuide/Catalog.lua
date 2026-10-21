local _, G = ...

function G.MaskHas(mask, index)
    return math.floor(mask / 2^(index-1)) % 2 == 1
end

function G.QuestFits(q, faction, checkClass)
    if not q then return false end
    local mask = q.races or 0
    if mask ~= 0 then
        local races = faction == "Alliance" and {1,3,4,7,33} or {2,5,6,8,34}
        local found = false
        for _, id in ipairs(races) do if G.MaskHas(mask,id) then found=true end end
        if not found then return false end
    end
    if checkClass and (q.classes or 0) ~= 0 and UnitClass then
        local _,_,classID = UnitClass("player")
        if classID and not G.MaskHas(q.classes,classID) then return false end
    end
    if checkClass and mask~=0 and faction==G.Safe(UnitFactionGroup,"player") and UnitRace then
        local _,_,raceID=UnitRace("player")
        if raceID and not G.MaskHas(mask,raceID) then return false end
    end
    return true
end

local function AddQuest(steps, id, kind, phase)
    local q = G.questCatalog[id]
    if not q then return end
    local at = kind == "turnin" and q.finish or q.start
    local verbs = {accept="Accept",complete="Complete",turnin="Turn in"}
    local text
    if kind == "accept" then
        text = (at.kind == "Item" and "Find the quest-starting item and use it. " or "Speak to the listed quest giver. ") ..
            "Minimum level "..q.level..". Check the live quest offer before travelling."
        if #q.skill > 0 then text=text.." This quest requires a profession. Use Next if it does not apply." end
        if #q.rep > 0 then text=text.." A reputation requirement applies." end
        if #q.exclusive > 0 then text=text.." This quest has alternatives. Choose your branch yourself; skip this quest if you chose another." end
        local requirements={}
        for _,pre in ipairs(q.all) do requirements[#requirements+1]=G.names[pre] or tostring(pre) end
        if #requirements>0 then text=text.." Prerequisites: "..table.concat(requirements,", ").."." end
        requirements={}
        for _,pre in ipairs(q.any) do if pre>0 then requirements[#requirements+1]=G.names[pre] or tostring(pre) end end
        if #requirements>0 then text=text.." Complete one of: "..table.concat(requirements," / ").."." end
    elseif kind == "complete" then
        text="Quest targets: "..q.objectives..". Use the live quest log for quantities and actions. Complete every objective before returning. Use Next if you are following another branch or need another run."
    else
        text="Return to the listed quest giver when the quest is ready. Reward choices stay manual. Use Next if this quest does not apply or is unfinished."
    end
    steps[#steps+1]={phase=phase,title=verbs[kind].." "..q.name,kind=kind,quests={id},
        where=kind=="complete" and "Follow the quest log objectives" or at.where,
        text=text,pin=kind~="complete" and at.pin or nil,questRecord=id}
end

function G.BuildCatalogGuide(key, faction, legacy, previous)
    local entry = G.catalog[key]
    local result={title=entry.title,faction=faction,steps={},finalQuests={},optionalQuests={},catalog=true}
    local steps=result.steps
    local entranceInfo=G.wowheadEntrances and G.wowheadEntrances[key]
    if entry.unpublished then
        steps[1]={phase="Not available",title="Quest route not yet published",kind="manual",where=entranceInfo and entranceInfo.where or entry.title,
            text="This announced Forever dungeon is listed for planning. Verified quest and waypoint data is not available in this package yet. No quest completion is claimed."}
        result.endText="No verified quest route is available for this dungeon yet."
        return result
    end
    steps[1]={phase="Prepare",title=entry.title.." / "..faction,kind="manual",where="Dungeon quest checklist",
        text="This checklist includes recorded dungeon quests and their prerequisites. Review pickups before your run. Quest chains can require more than one visit. Skip unavailable, repeatable or alternative quests with Next. Higher-level Forever changes may differ from the database."}
    local visited, pending={},{}
    local function Visit(id)
        if visited[id] or pending[id] then return end
        local q=G.questCatalog[id]
        if not G.QuestFits(q,faction,true) then return end
        pending[id]=true
        for _,pre in ipairs(q.all) do if pre>0 then Visit(pre) end end
        -- A single prerequisite can be guided. Multiple alternatives are left to the player.
        if #q.any==1 and q.any[1]>0 then Visit(q.any[1]) end
        pending[id]=nil; visited[id]=true
        AddQuest(steps,id,"accept","Quest chain")
        AddQuest(steps,id,"complete","Quest chain")
        AddQuest(steps,id,"turnin","Quest chain")
        result.optionalQuests[#result.optionalQuests+1]=id
    end
    for _,id in ipairs(entry.quests) do Visit(id) end
    -- Keep the old quest order. New overview quests follow the existing checklist.
    if not legacy then
        local roots=previous and G.previousOverviewQuests and G.previousOverviewQuests[key]
            or (G.wowheadDungeons and G.wowheadDungeons[key] or {}).quests or {}
        for _,id in ipairs(roots) do Visit(id) end
    end
    if #steps==1 then
        steps[1].text="No dungeon quests for this faction are recorded in this package. You can still join a group. Check the live quest log for class quests or new Forever additions."
    end
    steps[#steps+1]={phase="Dungeon",title="Dungeon entrance and final check",kind="manual",
        where=entry.entrance and entry.entrance.zone or entry.title,pin=entry.entrance,
        text=(entranceInfo and entranceInfo.text.." " or "The pin marks the outdoor approach where known. ").."Check remaining quests in your log and arrange any return run with your group. Next finishes this checklist; it does not confirm every quest is done."}
    result.endText="Checklist reviewed. Quests can be optional, mutually exclusive or repeatable. Check outstanding quests in your log."
    return result
end

for id,q in pairs(G.questCatalog) do G.names[id]=q.name end
for key,entry in pairs(G.catalog) do
    if not G.guides[key] then G.guides[key]={title=entry.title,catalog=true} end
end
