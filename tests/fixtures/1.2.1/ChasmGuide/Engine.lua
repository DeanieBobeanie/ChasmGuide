local _, G = ...

-- Quest IDs distinguish the five quests that share the name Hidden Enemies.
function G.Safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, ...)
    if not ok or (issecretvalue and issecretvalue(value)) then return nil end
    return value
end

function G.QuestState(id, seen)
    seen = seen or {}
    if seen[id] then return "missing" end
    seen[id] = true
    local api = C_QuestLog or {}
    if (G.db and G.db.turnedIn[id]) or G.Safe(api.IsQuestFlaggedCompleted, id) then return "turned" end
    local nextID = G.successors[id]
    if nextID and G.QuestState(nextID, seen) ~= "missing" then return "turned" end
    if G.Safe(api.IsOnQuest, id) then
        if G.Safe(api.IsComplete, id) then return "ready" end
        return "active"
    end
    return "missing"
end

function G.IsDone(step)
    if step.kind == "manual" then return false end
    for _, id in ipairs(step.quests or {}) do
        local status = G.QuestState(id)
        if step.kind == "accept" and status == "missing" then return false end
        if step.kind == "complete" and status ~= "ready" and status ~= "turned" then return false end
        if step.kind == "turnin" and status ~= "turned" then return false end
    end
    return true
end

local function LoadGuide()
    local db = G.db
    G.guide = G.guides[db.guide]
    local faction = db.factionSelection ~= "Auto" and db.factionSelection or G.Safe(UnitFactionGroup, "player")
    faction = faction == "Horde" and "Horde" or "Alliance"
    G.routeFaction = faction
    -- Earlier versions showed the Horde Lordaeron route to Alliance characters.
    -- Its saved step numbers cannot be reused for the new Alliance route.
    if db.guide == "lordaeron" and faction == "Alliance" and not db.lordaeronAllianceRoute then
        db.lordaeronLegacyProgress = {index=db.index, skipped=db.skipped, auto=db.auto}
        db.index, db.skipped, db.auto = 1, {}, true
        db.lordaeronAllianceRoute = 1
    end
    if G.guide.routes and G.guide.routes[faction] then G.guide = G.guide.routes[faction]
    elseif G.BuildCatalogGuide and (G.guide.catalog or G.guide.faction ~= faction) then
        G.guide = G.BuildCatalogGuide(db.guide, faction)
    end
    G.title, G.steps = G.guide.title, G.guide.steps
    db.skipped = type(db.skipped) == "table" and db.skipped or {}
    -- Version 1.2.1 adds catalog quests before the final entrance checkpoint.
    -- Retain the current quest, skipped steps and finished state on older saves.
    if G.guide.catalog and db.catalogRevision ~= 1 then
        local old = G.BuildCatalogGuide(db.guide, faction, true).steps
        local added = #G.steps - #old
        if added > 0 then
            local index = math.floor(tonumber(db.index) or 1)
            if index >= #old then db.index = index + added end
            local skipped = {}
            for i,value in pairs(db.skipped) do
                skipped[type(i)=="number" and i>=#old and i+added or i]=value
            end
            db.skipped = skipped
        end
    end
    db.catalogRevision = G.guide.catalog and 1 or nil
    db.index = math.max(1, math.min(#G.steps + 1, math.floor(tonumber(db.index) or 1)))
    if db.auto == nil then db.auto = true end
end

function G.Init(db)
    G.db = db
    -- Version 1 saved the RFC cursor at the top level. Preserve it on upgrade.
    db.version = 2
    db.guide = G.guides[db.guide] and db.guide or "rfc"
    db.guides = type(db.guides) == "table" and db.guides or {}
    db.turnedIn = type(db.turnedIn) == "table" and db.turnedIn or {}
    db.options = type(db.options) == "table" and db.options or {}
    local defaults={arrow=false,useTomTom=false,autoAccept=false,autoTurnIn=false,
        selectAllQuests=false,includeTrivial=false,questScope="all"}
    for k,v in pairs(defaults) do if db.options[k]==nil then db.options[k]=v end end
    if db.options.questScope~="guide" then db.options.questScope="all" end
    if db.factionSelection~="Alliance" and db.factionSelection~="Horde" then db.factionSelection="Auto" end
    db.routeProgress=type(db.routeProgress)=="table" and db.routeProgress or {}
    LoadGuide()
end

local function SaveRoute()
    local db=G.db
    local progress={index=db.index,skipped=db.skipped,auto=db.auto,catalogRevision=db.catalogRevision}
    db.routeProgress[db.guide..":"..G.routeFaction]=progress
    if G.routeFaction==G.Safe(UnitFactionGroup,"player") then db.guides[db.guide]=progress end
end

local function RestoreRoute(key,faction)
    local db=G.db
    local saved=db.routeProgress[key..":"..faction]
    if not saved and faction==G.Safe(UnitFactionGroup,"player") then saved=db.guides[key] end
    saved=saved or {}
    db.guide,db.index,db.skipped,db.auto=key,saved.index,saved.skipped,saved.auto
    db.catalogRevision=saved.catalogRevision
    LoadGuide()
end

function G.SelectFaction(selection)
    if selection~="Auto" and selection~="Alliance" and selection~="Horde" then return false end
    SaveRoute()
    G.db.factionSelection=selection
    local faction=selection=="Auto" and G.Safe(UnitFactionGroup,"player") or selection
    RestoreRoute(G.db.guide,faction)
    G.Advance()
    return true
end

function G.SelectGuide(key)
    if not G.guides[key] then return false end
    local db = G.db
    if db.guide ~= key then
        SaveRoute()
        RestoreRoute(key,G.routeFaction)
    end
    G.Advance()
    return true
end

function G.Advance()
    if not G.db.auto then return end
    while G.steps[G.db.index] and G.IsDone(G.steps[G.db.index]) do
        G.db.index = G.db.index + 1
    end
end

function G.Next()
    local step = G.steps[G.db.index]
    if not step then return end
    if step.kind ~= "manual" and not G.IsDone(step) then G.db.skipped[G.db.index] = true end
    G.db.index = G.db.index + 1
    G.Advance()
end

function G.Back()
    G.db.auto = false
    G.db.index = math.max(1, G.db.index - 1)
end

function G.Restart()
    G.db.index, G.db.skipped, G.db.auto = 1, {}, true
    G.Advance()
end

function G.StatusLines(step)
    local lines = {}
    local labels = { missing = "Not in quest log", active = "In progress", ready = "Ready to turn in", turned = "Turned in" }
    for _, id in ipairs(step.quests or step.checklist or {}) do
        local state = G.QuestState(id)
        local color = (state == "turned" or state == "ready") and "|cff82d6a0" or "|cffe1c27a"
        lines[#lines + 1] = color .. (G.names[id] or tostring(id)) .. ": " .. labels[state] .. "|r"
        if G.QuestInfoSummary then lines[#lines+1]=G.QuestInfoSummary(id) end
        if state == "active" and step.quests then
            local objectives = G.Safe((C_QuestLog or {}).GetQuestObjectives, id)
            for _, objective in ipairs(objectives or {}) do
                if not (issecretvalue and issecretvalue(objective.text)) and type(objective.text) == "string" then lines[#lines + 1] = "  " .. objective.text end
            end
        end
    end
    return table.concat(lines, "\n")
end

-- Resolve maps within the player's current world, without assuming beta map IDs.
function G.ResolveMap(zone)
    if not C_Map then return nil end
    local current = G.Safe(C_Map.GetBestMapForUnit, "player")
    local info = current and G.Safe(C_Map.GetMapInfo, current)
    local visited = {}
    while info and not visited[info.mapID] do
        visited[info.mapID] = true
        if info.name == zone then return info.mapID end
        if not info.parentMapID or info.parentMapID == 0 then break end
        local parent = G.Safe(C_Map.GetMapInfo, info.parentMapID)
        if not parent then break end
        info = parent
    end
    local maps = info and G.Safe(C_Map.GetMapChildrenInfo, info.mapID, nil, true)
    for _, map in ipairs(maps or {}) do
        if map.name == zone then return map.mapID end
    end
end

function G.Pin(step)
    if not step or not step.pin then return "This step uses written directions." end
    local pin = step.pin
    local mapID = pin.mapID or G.ResolveMap(pin.zone)
    if not mapID or not C_Map or not G.Safe(C_Map.CanSetUserWaypointOnMap, mapID) then
        return "Map pin unavailable. Use the location and coordinates in the guide."
    end
    if not UiMapPoint or not UiMapPoint.CreateFromCoordinates then return "Map pins are unavailable on this client." end
    local point = G.Safe(UiMapPoint.CreateFromCoordinates, mapID, pin.x, pin.y)
    if not point then return "The client could not place this map pin." end
    local ok = type(C_Map.SetUserWaypoint)=="function" and pcall(C_Map.SetUserWaypoint, point)
    if not ok then return "The client could not place this map pin." end
    if C_SuperTrack then G.Safe(C_SuperTrack.SetSuperTrackedUserWaypoint, true) end
    return "Map pin set. Open your map to see it."
end
