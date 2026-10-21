local _, G = ...
local arrow, icon, label, distanceText, target, lastKey, tomtomUID, tomtomOwner

local function RemoveTomTom()
    if tomtomUID and tomtomOwner and type(tomtomOwner.RemoveWaypoint) == "function" then
        pcall(tomtomOwner.RemoveWaypoint, tomtomOwner, tomtomUID)
    end
    tomtomUID, tomtomOwner = nil, nil
end

function G.ClearNavigation()
    RemoveTomTom()
    target, lastKey = nil, nil
    if arrow then arrow:Hide() end
end

function G.SyncNavigation(force)
    local step = G.steps and G.steps[G.db.index]
    if not G.db.options.arrow or not step or not step.pin then G.ClearNavigation(); return end
    local pin = step.pin
    local mapID = pin.mapID or G.ResolveMap(pin.zone)
    local key = table.concat({G.db.guide, G.routeFaction or "", G.db.index, mapID or 0,
        pin.x, pin.y, G.db.options.useTomTom and "tomtom" or "builtin"}, ":")
    if key == lastKey and not force then return end
    RemoveTomTom()
    lastKey = key
    target = {mapID=mapID, x=pin.x, y=pin.y, title=step.title, zone=pin.zone}
    if G.db.options.useTomTom and TomTom and type(TomTom.AddWaypoint) == "function" and mapID then
        local ok, uid = pcall(TomTom.AddWaypoint, TomTom, mapID, pin.x, pin.y,
            {title="Chasm Guide: "..step.title, persistent=false, minimap=true, world=true,
             crazy=true, cleardistance=0, arrivaldistance=10})
        if ok and uid then
            tomtomUID, tomtomOwner = uid, TomTom
            if type(TomTom.SetCrazyArrow) == "function" then pcall(TomTom.SetCrazyArrow, TomTom, uid, 10, step.title) end
        end
    end
    if arrow then arrow:SetShown(not tomtomUID) end
end

local function WorldPoint(map, position)
    if not C_Map or not C_Map.GetWorldPosFromMapPos or not map or not position then return end
    local ok, continent, pos = pcall(C_Map.GetWorldPosFromMapPos, map, position)
    if not ok or not pos or not pos.GetXY then return end
    local x, y = pos:GetXY()
    if issecretvalue and (issecretvalue(x) or issecretvalue(y)) then return end
    if type(x) == "number" and type(y) == "number" then return continent, x, y end
end

function G.NavigationVector()
    if not target or not target.mapID or not C_Map or not CreateVector2D then return end
    if G.Safe(IsInInstance) then return end
    local map = G.Safe(C_Map.GetBestMapForUnit, "player")
    local pos = map and G.Safe(C_Map.GetPlayerMapPosition, map, "player")
    local pc, px, py = WorldPoint(map, pos)
    local tc, tx, ty = WorldPoint(target.mapID, CreateVector2D(target.x, target.y))
    local facing = G.Safe(GetPlayerFacing)
    if not pc or pc ~= tc or type(facing) ~= "number" then return end
    local dx, dy = tx-px, ty-py
    -- World X points north and world Y points west. Facing is counterclockwise from north.
    local bearing = math.atan2(dy, dx)
    return bearing-facing, math.sqrt(dx*dx+dy*dy)
end

function G.CreateNavigation()
    arrow = CreateFrame("Frame", "ChasmGuideArrow", UIParent, "BackdropTemplate")
    arrow:SetSize(220, 110)
    arrow:SetClampedToScreen(true)
    arrow:SetMovable(true); arrow:EnableMouse(true); arrow:RegisterForDrag("LeftButton")
    local p = G.db.arrowPosition or {x=0,y=220}
    arrow:SetPoint("CENTER", UIParent, "CENTER", p.x or 0, p.y or 220)
    arrow:SetScript("OnDragStart", function(self) self:StartMoving() end)
    arrow:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x,y=self:GetCenter(); local px,py=UIParent:GetCenter()
        G.db.arrowPosition={x=x-px,y=y-py}
    end)
    icon = arrow:CreateTexture(nil, "ARTWORK")
    icon:SetSize(36,36); icon:SetPoint("TOP",0,-2)
    icon:SetTexture("Interface\\Minimap\\MinimapArrow")
    label = arrow:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    label:SetPoint("TOP",0,-44); label:SetWidth(216); label:SetWordWrap(true)
    distanceText = arrow:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    distanceText:SetPoint("TOP",0,-82); distanceText:SetWidth(216)
    local elapsedTotal=0
    arrow:SetScript("OnUpdate", function(_,elapsed)
        elapsedTotal=elapsedTotal+elapsed
        if elapsedTotal < .1 or not target then return end
        elapsedTotal=0
        label:SetText(target.title)
        local ok, angle, yards = pcall(G.NavigationVector)
        if ok and angle and yards then
            icon:Show(); icon:SetRotation(angle)
            distanceText:SetText(yards < 10 and "At waypoint" or string.format("%.0f yd",yards))
        else
            icon:Hide()
            distanceText:SetText(string.format("%s  %.1f, %.1f", target.zone or "Map",target.x*100,target.y*100))
        end
    end)
    arrow:Hide()
end
