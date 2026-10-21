local addonName, G = ...
local frame, content, scroll, note, title, location, body, status, following, previous, nextButton, auto, pin
local dungeonMenu, factionMenu, settings, openMenu
local panel, minimize, guidePanel, overviewPanel, refreshOverview, overviewTab, guideTab, progress
local difficulty, infoFrame, infoPicker, infoBody, infoContent, infoScroll, infoPin, infoURL
local infoQuest, infoTarget, infoCursor
local WIDTH, HEIGHT, COMPACT_WIDTH, COMPACT_HEIGHT = 410, 490, 220, 34
local GUIDE_WIDTH, GUIDE_HEIGHT = 460, 550
G.ui = {}
local function Say(text)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffe1c27aChasm Guide:|r "..text) end
end
local function Text(parent, template)
    local label=parent:CreateFontString(nil,"OVERLAY",template or "GameFontHighlight")
    label:SetJustifyH("LEFT"); label:SetJustifyV("TOP"); label:SetWordWrap(true)
    return label
end
local function Button(parent,label,width,fn)
    local button=CreateFrame("Button",nil,parent)
    local caption=button:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    caption:SetPoint("CENTER"); button:SetFontString(caption)
    button:SetNormalFontObject("GameFontHighlightSmall"); button:SetDisabledFontObject("GameFontDisableSmall")
    button:SetNormalTexture("Interface\\Buttons\\WHITE8X8"); button:GetNormalTexture():SetVertexColor(.13,.16,.21,1)
    button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8"); button:GetHighlightTexture():SetVertexColor(.18,.22,.27,.35)
    button:SetPushedTexture("Interface\\Buttons\\WHITE8X8"); button:GetPushedTexture():SetVertexColor(.09,.12,.16,1)
    button:SetSize(width,26); button:SetText(label); button:SetScript("OnClick",fn)
    return button
end
local function Backdrop(parent)
    parent:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    parent:SetBackdropColor(.035,.045,.06,.98); parent:SetBackdropBorderColor(.28,.32,.38,1)
end
local function SavePosition()
    local px,py=UIParent:GetCenter()
    -- Keep the saved position in the original full-size center format.
    -- Both views share a top-left corner, including after dragging or reloading.
    G.db.position={x=frame:GetLeft()+WIDTH/2-px,y=frame:GetTop()-HEIGHT/2-py}
end
local function Dimensions()
    if G.db.view=="guide" then return GUIDE_WIDTH,math.min(GUIDE_HEIGHT,UIParent:GetHeight()-24) end
    return math.min(940,UIParent:GetWidth()-24),math.min(740,UIParent:GetHeight()-24)
end
local function Layout()
    local width,height=Dimensions()
    local left,top=frame:GetLeft(),frame:GetTop()
    frame:ClearAllPoints()
    frame:SetSize(G.db.minimized and COMPACT_WIDTH or width,G.db.minimized and COMPACT_HEIGHT or height)
    -- Clamp explicitly after expansion so even an old compact position remains reachable.
    left=math.max(0,math.min(left,UIParent:GetWidth()-frame:GetWidth()))
    top=math.max(frame:GetHeight(),math.min(top,UIParent:GetHeight()))
    frame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",left,top)
    panel:SetSize(width,height); panel:SetShown(not G.db.minimized)
    guidePanel:SetSize(GUIDE_WIDTH,height-114); guidePanel:SetShown(G.db.view=="guide")
    overviewPanel:SetShown(G.db.view=="overview")
    overviewTab:SetEnabled(G.db.view~="overview"); guideTab:SetEnabled(G.db.view~="guide")
    dungeonMenu:SetWidth(width-172)
    note:SetWidth(width-304)
    minimize:SetText(G.db.minimized and "+" or "-")
    if openMenu then openMenu:Hide(); openMenu=nil end
    SavePosition()
end
function G.SetMinimized(value)
    if not frame or not G.db then return end
    G.db.minimized=value and true or false
    if G.db.minimized and infoFrame then infoFrame:Hide() end
    Layout()
end
function G.SetView(view)
    G.db.view=view=="guide" and "guide" or "overview"
    G.db.minimized=false; G.db.hidden=false
    Layout(); frame:Show(); G.Render()
end
-- Paged dropdowns work across clients without a dropdown library.
function G.CreateDropdown(parent,width,choices,onSelect)
    local picker=Button(parent,"",width,function() end)
    local menu=CreateFrame("Frame",nil,parent,"BackdropTemplate")
    menu:SetFrameStrata("DIALOG"); menu:SetSize(width,278)
    menu:SetPoint("TOPLEFT",picker,"BOTTOMLEFT",0,-2); menu:SetClampedToScreen(true)
    Backdrop(menu); menu:EnableMouse(true); menu:EnableMouseWheel(true)
    local rows,offset,items={},0,{}
    local function Refresh()
        items=choices(); offset=math.max(0,math.min(offset,math.max(0,#items-8)))
        for i,row in ipairs(rows) do
            local item=items[offset+i]; row:SetShown(item~=nil)
            if item then row:SetText(item.label); row.value=item.value end
        end
    end
    for i=1,8 do
        local row=Button(menu,"",width-12,function(self) menu:Hide(); openMenu=nil; onSelect(self.value) end)
        row:SetPoint("TOPLEFT",6,-6-(i-1)*28); rows[i]=row
    end
    local up=Button(menu,"Previous",(width-18)/2,function() offset=offset-8; Refresh() end)
    up:SetPoint("BOTTOMLEFT",6,8)
    local down=Button(menu,"Next",(width-18)/2,function() offset=offset+8; Refresh() end)
    down:SetPoint("BOTTOMRIGHT",-6,8)
    menu:SetScript("OnMouseWheel",function(_,delta) offset=offset-delta*3; Refresh() end)
    picker:SetScript("OnClick",function()
        if openMenu==menu then menu:Hide(); openMenu=nil; return end
        if openMenu then openMenu:Hide() end
        offset=0; Refresh(); menu:Show(); openMenu=menu
    end)
    menu:Hide(); picker.menu, picker.rows = menu, rows
    return picker
end
function G.Render()
    if not frame or not G.db then return end
    dungeonMenu:SetText(G.title.."  v")
    factionMenu:SetText((G.db.factionSelection=="Auto" and "My faction" or G.db.factionSelection).."  v")
    auto:SetChecked(G.db.auto)
    local y=-12
    local function Place(label,text,gap)
        label:ClearAllPoints(); label:SetPoint("TOPLEFT",content,"TOPLEFT",2,y)
        label:SetWidth(400); label:SetText(text); y=y-label:GetStringHeight()-(gap or 14)
    end
    local step=G.steps[G.db.index]
    if step then
        Place(title,step.title)
        local where=step.where
        if step.pin then where=where..string.format("\n%s: %.1f, %.1f",step.pin.zone,step.pin.x*100,step.pin.y*100) end
        Place(location,where); Place(body,step.text); Place(status,G.StatusLines(step))
        local nextStep=G.steps[G.db.index+1]
        Place(following,nextStep and "Next: "..nextStep.title or "Final step")
        note:SetText(string.format("%s / %d of %d",G.routeFaction,G.db.index,#G.steps))
        difficulty:SetText(string.upper(step.phase).."  /  STEP "..G.db.index)
        pin:SetEnabled(step.pin~=nil); nextButton:SetEnabled(true)
    else
        local missing=0
        for _,id in ipairs(G.guide.finalQuests or {}) do if G.QuestState(id)~="turned" then missing=missing+1 end end
        Place(title,"You reached the end of the guide"); Place(location,G.title.." / "..G.routeFaction)
        Place(body,missing==0 and (G.guide.endText or "All required quest turn-ins in this guide are confirmed.") or
            string.format("%d final turn-ins are not confirmed. Use Back to review or restart this guide.",missing))
        local optional={}
        for _,id in ipairs(G.guide.optionalQuests or {}) do optional[#optional+1]=(G.names[id] or tostring(id))..": "..G.QuestState(id) end
        Place(status,table.concat(optional,"\n")); Place(following,"")
        note:SetText("Guide finished"); difficulty:SetText("GUIDE COMPLETE"); pin:SetEnabled(false); nextButton:SetEnabled(false)
    end
    if G.routeFaction~=G.Safe(UnitFactionGroup,"player") then Place(following,"Previewing the other faction. Quest automation is paused.")
    elseif not C_QuestLog or not C_QuestLog.IsOnQuest then Place(following,"Quest tracking is unavailable. Use Next to advance manually.") end
    content:SetHeight(math.max(80,-y))
    progress:SetWidth(420*math.min(1,math.max(0,(G.db.index-1)/#G.steps)))
    if G.db.view=="overview" then local w,h=Dimensions(); refreshOverview(w,h-114) end
    local cursor=G.db.guide..":"..G.routeFaction..":"..G.db.index
    if G.ui.cursor~=cursor then scroll:SetVerticalScroll(0); G.ui.cursor=cursor end
    previous:SetEnabled(G.db.index>1)
    if G.SyncNavigation then G.SyncNavigation() end
    if infoFrame and infoFrame:IsShown() then G.RefreshQuestInfo() end
end
function G.Refresh()
    if not G.db then return end
    G.Advance(); G.Render()
end
local function Check(parent,key,label,y)
    local check=CreateFrame("CheckButton",nil,parent,"UICheckButtonTemplate")
    check:SetSize(26,26); check:SetPoint("TOPLEFT",16,y)
    local caption=Text(parent,"GameFontHighlightSmall")
    caption:SetPoint("LEFT",check,"RIGHT",4,0); caption:SetWidth(405); caption:SetText(label)
    check:SetScript("OnClick",function(self)
        G.db.options[key]=self:GetChecked() and true or false
        if G.SyncNavigation then G.SyncNavigation(true) end
    end)
    G.ui.options[key]=check
    return check
end
function G.RefreshQuestInfo()
    if not infoFrame then return end
    local route=G.db.guide..":"..G.routeFaction
    local choices=G.QuestInfoChoices()
    local valid=false
    for _,choice in ipairs(choices) do if choice.value==infoQuest then valid=true end end
    if infoCursor~=route then infoScroll:SetVerticalScroll(0) end
    if infoCursor~=route or not valid then infoQuest=nil end
    infoCursor=route
    local text,url
    if infoQuest then text,infoTarget,url=G.QuestInfoText(infoQuest)
    else text,infoTarget,url=G.DungeonInfoText() end
    infoPicker:SetText(infoQuest and (G.names[infoQuest] or tostring(infoQuest)).."  v" or "Dungeon overview / choose a quest  v")
    infoBody:SetText(text); infoContent:SetHeight(math.max(80,infoBody:GetStringHeight()+16))
    infoPin:SetEnabled(infoTarget and infoTarget.pin~=nil)
    infoPin:SetText(infoQuest and "Pin pickup" or "Pin entrance")
    -- Avoid resetting the user's selection while they copy the source address.
    if infoURL:GetText()~=url then infoURL:SetText(url) end
end
function G.OpenQuestInfo(selectedID)
    if not infoFrame then
        infoFrame=CreateFrame("Frame","ChasmGuideQuestInfo",UIParent,"BackdropTemplate")
        infoFrame:SetSize(450,550); infoFrame:SetPoint("CENTER",UIParent,"CENTER",-180,0)
        infoFrame:SetFrameStrata("DIALOG"); infoFrame:SetClampedToScreen(true)
        infoFrame:SetMovable(true); infoFrame:EnableMouse(true); Backdrop(infoFrame)
        local drag=CreateFrame("Frame",nil,infoFrame); drag:SetPoint("TOPLEFT"); drag:SetPoint("TOPRIGHT",-32,0)
        drag:SetHeight(36); drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
        drag:SetScript("OnDragStart",function() infoFrame:StartMoving() end)
        drag:SetScript("OnDragStop",function() infoFrame:StopMovingOrSizing() end)
        local heading=Text(drag,"GameFontNormal"); heading:SetPoint("TOPLEFT",16,-12); heading:SetText("DUNGEON AND QUEST INFO")
        local close=CreateFrame("Button",nil,infoFrame,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",0,0)
        close:SetScript("OnClick",function() infoFrame:Hide(); if openMenu then openMenu:Hide(); openMenu=nil end end)
        infoPicker=G.CreateDropdown(infoFrame,418,function()
            local choices={{value=0,label="Dungeon overview and entrance"}}
            for _,choice in ipairs(G.QuestInfoChoices()) do choices[#choices+1]=choice end
            return choices
        end,function(value)
            infoQuest=value~=0 and value or nil
            G.RefreshQuestInfo(); infoScroll:SetVerticalScroll(0)
        end)
        infoPicker:SetPoint("TOPLEFT",16,-40)
        infoScroll=CreateFrame("ScrollFrame",nil,infoFrame,"UIPanelScrollFrameTemplate")
        infoScroll:SetPoint("TOPLEFT",16,-76); infoScroll:SetPoint("BOTTOMRIGHT",-34,108)
        infoContent=CreateFrame("Frame",nil,infoScroll); infoContent:SetSize(394,300); infoScroll:SetScrollChild(infoContent)
        infoBody=Text(infoContent,"GameFontHighlightSmall"); infoBody:SetPoint("TOPLEFT",2,-8); infoBody:SetWidth(386)
        infoPin=Button(infoFrame,"Pin location",110,function() Say(G.Pin(infoTarget)) end)
        infoPin:SetPoint("BOTTOMLEFT",16,72)
        local help=Text(infoFrame,"GameFontDisableSmall"); help:SetPoint("BOTTOMLEFT",16,46)
        help:SetText("Wowhead source: click the address, then Ctrl+C")
        infoURL=CreateFrame("EditBox",nil,infoFrame,"InputBoxTemplate"); infoURL:SetSize(408,24)
        infoURL:SetPoint("BOTTOMLEFT",22,16); infoURL:SetAutoFocus(false)
        infoURL:SetScript("OnMouseUp",function(self) self:HighlightText() end)
        infoURL:SetScript("OnEditFocusGained",function(self) self:HighlightText() end)
        infoURL:SetScript("OnEscapePressed",function(self) self:ClearFocus(); infoFrame:Hide() end)
        infoURL:SetScript("OnEnterPressed",function(self) self:ClearFocus() end)
        G.ui.infoPicker,G.ui.infoPin=infoPicker,infoPin
    end
    infoCursor=G.db.guide..":"..G.routeFaction
    local step=G.steps[G.db.index]
    if type(selectedID)=="number" then infoQuest=selectedID~=0 and selectedID or nil
    else infoQuest=step and (step.quests or step.checklist or {})[1] or nil end
    G.RefreshQuestInfo(); infoScroll:SetVerticalScroll(0); infoFrame:Show()
end
function G.OpenSettings()
    if not settings then
        G.ui.options={}
        settings=CreateFrame("Frame","ChasmGuideSettings",UIParent,"BackdropTemplate")
        settings:SetSize(470,410); settings:SetPoint("CENTER"); settings:SetFrameStrata("DIALOG")
        settings:SetClampedToScreen(true); settings:EnableMouse(true); Backdrop(settings)
        local heading=Text(settings,"GameFontNormalLarge"); heading:SetPoint("TOPLEFT",20,-18); heading:SetText("Chasm Guide configuration")
        local close=CreateFrame("Button",nil,settings,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",0,0)
        close:SetScript("OnClick",function() settings:Hide(); if openMenu then openMenu:Hide(); openMenu=nil end end)
        Check(settings,"arrow","Show waypoint arrow and follow the current guide step",-54)
        Check(settings,"useTomTom","Use TomTom when installed, otherwise use the built-in arrow",-86)
        Check(settings,"autoAccept","Automatically accept quests",-132)
        Check(settings,"autoTurnIn","Automatically turn in completed quests",-164)
        Check(settings,"selectAllQuests","Select all eligible quest entries at an NPC, one at a time",-196)
        Check(settings,"includeTrivial","Include low-level quests",-228)
        local scope=G.CreateDropdown(settings,280,function()
            return {{value="all",label="Any quest"},{value="guide",label="Current guide quests only"}}
        end,function(value) G.db.options.questScope=value; G.ui.scope:SetText(value=="all" and "Any quest  v" or "Current guide quests only  v") end)
        scope:SetPoint("TOPLEFT",20,-271); G.ui.scope=scope
        local help=Text(settings,"GameFontDisableSmall"); help:SetPoint("TOPLEFT",20,-310); help:SetWidth(430)
        help:SetText("Arrow, acceptance and turn-ins start off. Hold Shift to pause quest automation. Reward choices, branching dialogue and money costs wait for you. Quests with multiple rewards still need your click on Complete Quest.")
    end
    for key,check in pairs(G.ui.options) do check:SetChecked(G.db.options[key]) end
    G.ui.scope:SetText(G.db.options.questScope=="all" and "Any quest  v" or "Current guide quests only  v")
    settings:Show()
end
local function CreateUI()
    if G.db.view~="guide" and G.db.view~="overview" then G.db.view="overview" end
    frame=CreateFrame("Frame","ChasmGuideFrame",UIParent,"BackdropTemplate")
    -- Use the legacy dimensions only to restore the saved top-left corner.
    frame:SetSize(G.db.minimized and COMPACT_WIDTH or WIDTH,G.db.minimized and COMPACT_HEIGHT or HEIGHT)
    frame:SetClampedToScreen(true); frame:SetMovable(true); frame:EnableMouse(true); Backdrop(frame)
    local p=G.db.position or {x=-220,y=110}
    frame:SetPoint("TOPLEFT",UIParent,"CENTER",(p.x or 0)-WIDTH/2,(p.y or 0)+HEIGHT/2)
    local drag=CreateFrame("Frame",nil,frame); drag:SetPoint("TOPLEFT"); drag:SetPoint("TOPRIGHT",-64,0)
    drag:SetHeight(34); drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart",function() frame:StartMoving() end)
    drag:SetScript("OnDragStop",function() frame:StopMovingOrSizing(); SavePosition() end)
    local heading=Text(drag,"GameFontNormal"); heading:SetPoint("TOPLEFT",16,-11); heading:SetText("CHASM GUIDE")
    minimize=Button(frame,"-",24,function() G.SetMinimized(not G.db.minimized) end)
    minimize:SetPoint("TOPRIGHT",-32,-4)
    minimize:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT"); GameTooltip:SetText(G.db.minimized and "Expand guide" or "Minimize guide"); GameTooltip:Show()
    end)
    minimize:SetScript("OnLeave",function() GameTooltip:Hide() end)
    minimize:HookScript("OnClick",function() GameTooltip:Hide() end)
    local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",0,0)
    close:SetScript("OnClick",function() G.db.hidden=true; frame:Hide(); if infoFrame then infoFrame:Hide() end; if openMenu then openMenu:Hide(); openMenu=nil end end)
    panel=CreateFrame("Frame",nil,frame); panel:SetPoint("TOPLEFT")
    factionMenu=G.CreateDropdown(panel,120,function()
        return {{value="Auto",label="My faction"},{value="Alliance",label="Alliance"},{value="Horde",label="Horde"}}
    end,function(value) G.SelectFaction(value); G.SetView("overview") end)
    factionMenu:SetPoint("TOPRIGHT",-20,-42)
    dungeonMenu=G.CreateDropdown(panel,288,function()
        local choices={}
        for _,key in ipairs(G.catalogOrder) do local e=G.catalog[key]; choices[#choices+1]={value=key,label=e.title..(e.unpublished and " *" or "")} end
        return choices
    end,function(value) G.SelectGuide(value); G.SetView("overview") end)
    dungeonMenu:SetPoint("TOPLEFT",20,-42); G.ui.dungeons,G.ui.factions=dungeonMenu,factionMenu
    overviewTab=Button(panel,"Quest overview",132,function() G.SetView("overview") end); overviewTab:SetPoint("TOPLEFT",20,-78)
    guideTab=Button(panel,"Guide",86,function() G.SetView("guide") end); guideTab:SetPoint("LEFT",overviewTab,"RIGHT",8,0)
    overviewTab:SetDisabledFontObject("GameFontNormalSmall"); guideTab:SetDisabledFontObject("GameFontNormalSmall")
    note=Text(panel,"GameFontDisableSmall"); note:SetPoint("TOPLEFT",260,-86)
    G.ui.overviewTab,G.ui.guideTab=overviewTab,guideTab
    guidePanel=CreateFrame("Frame",nil,panel); guidePanel:SetPoint("TOPLEFT",0,-114)
    difficulty=Text(guidePanel,"GameFontNormalSmall"); difficulty:SetPoint("TOPLEFT",20,-4); difficulty:SetWidth(310)
    local infoButton=Button(guidePanel,"Details",76,function() G.OpenQuestInfo() end); infoButton:SetPoint("TOPRIGHT",-20,3)
    G.ui.infoButton=infoButton
    local track=guidePanel:CreateTexture(nil,"BACKGROUND"); track:SetColorTexture(.12,.15,.19,1); track:SetSize(420,3); track:SetPoint("TOPLEFT",20,-27)
    progress=guidePanel:CreateTexture(nil,"ARTWORK"); progress:SetColorTexture(.76,.63,.37,1); progress:SetHeight(3); progress:SetPoint("TOPLEFT",20,-27)
    scroll=CreateFrame("ScrollFrame",nil,guidePanel,"UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",20,-38); scroll:SetPoint("BOTTOMRIGHT",-36,98)
    content=CreateFrame("Frame",nil,scroll); content:SetSize(404,300); scroll:SetScrollChild(content)
    title=Text(content,"GameFontNormalLarge"); location=Text(content,"GameFontHighlightSmall")
    body=Text(content); status=Text(content,"GameFontHighlightSmall"); following=Text(content,"GameFontDisableSmall")
    previous=Button(guidePanel,"<  Back",100,function() G.Back(); G.Render() end); previous:SetPoint("BOTTOMLEFT",20,54)
    pin=Button(guidePanel,"Map pin",104,function() Say(G.Pin(G.steps[G.db.index])) end); pin:SetPoint("BOTTOM",0,54)
    nextButton=Button(guidePanel,"Next  >",100,function() G.Next(); G.Render() end); nextButton:SetPoint("BOTTOMRIGHT",-20,54)
    auto=CreateFrame("CheckButton",nil,guidePanel,"UICheckButtonTemplate"); auto:SetSize(26,26); auto:SetPoint("BOTTOMLEFT",16,15)
    auto:SetScript("OnClick",function(self) G.db.auto=self:GetChecked() and true or false; G.Refresh() end)
    local caption=Text(guidePanel,"GameFontHighlightSmall"); caption:SetPoint("LEFT",auto,"RIGHT",2,0); caption:SetText("Auto-advance")
    local config=Button(guidePanel,"Settings",94,G.OpenSettings); config:SetPoint("BOTTOMRIGHT",-20,15)
    overviewPanel,refreshOverview=G.CreateOverview(panel,Text,Button,Backdrop,Say); overviewPanel:SetPoint("TOPLEFT",0,-114)
    G.ui.guidePanel,G.ui.overviewPanel=guidePanel,overviewPanel
    G.SetMinimized(G.db.minimized)
    G.CreateNavigation()
    if G.db.hidden then frame:Hide() end
end
local events=CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent",function(_,event,arg)
    if event=="ADDON_LOADED" then
        if arg~=addonName then return end
        ChasmGuideDB=type(ChasmGuideDB)=="table" and ChasmGuideDB or {}
        G.Init(ChasmGuideDB); CreateUI(); events:UnregisterEvent("ADDON_LOADED")
        for _,name in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","PLAYER_LEVEL_UP","ZONE_CHANGED_NEW_AREA","QUEST_LOG_UPDATE","QUEST_TURNED_IN","UI_SCALE_CHANGED","DISPLAY_SIZE_CHANGED",
            "GOSSIP_SHOW","GOSSIP_CLOSED","QUEST_GREETING","QUEST_DETAIL","QUEST_PROGRESS","QUEST_COMPLETE"}) do events:RegisterEvent(name) end
        G.Render(); return
    end
    if event=="QUEST_TURNED_IN" and G.names[arg] then G.db.turnedIn[arg]=true end
    if event=="UI_SCALE_CHANGED" or event=="DISPLAY_SIZE_CHANGED" then Layout(); G.Render(); return end
    if event=="PLAYER_ENTERING_WORLD" or event=="ZONE_CHANGED_NEW_AREA" then G.ClearNavigation() end
    G.Automate(event); G.Refresh()
end)
SLASH_CHASMGUIDE1="/cguide"
SLASH_CHASMGUIDE2="/chasmguide"
SlashCmdList.CHASMGUIDE=function(message)
    if not G.db then return end
    message=(message or ""):lower():match("^%s*(.-)%s*$")
    local aliases={ironforge="thanes",hot="thanes",shadowfang="sfk",shadowfen="sfk",dm="deadmines",vc="deadmines",["dead mines"]="deadmines",
        wailing="wc",["wailing caverns"]="wc",stockades="stockade",gnomer="gnomeregan",temple="st",["dire maul"]="diremaul",scholo="scholomance",strat="stratholme"}
    message=aliases[message] or message
    if G.guides[message] then G.SelectGuide(message); G.SetView("overview")
    elseif message=="config" or message=="settings" or message=="options" then G.OpenSettings()
    elseif message=="info" or message=="quests" or message=="overview" then G.SetView("overview")
    elseif message=="details" then G.OpenQuestInfo()
    elseif message=="guide" then G.SetView("guide")
    elseif message=="guides" then G.SetView("overview")
    elseif message=="expand" then G.SetMinimized(false); frame:Show(); G.db.hidden=false; G.Render()
    elseif message=="minimize" then G.SetMinimized(true); frame:Show(); G.db.hidden=false
    elseif message=="next" then G.Next(); G.Render()
    elseif message=="back" then G.Back(); G.Render()
    elseif message=="restart" then G.Restart(); G.SetMinimized(false); G.Render(); frame:Show(); G.db.hidden=false
    elseif message=="pin" then Say(G.Pin(G.steps[G.db.index]))
    elseif message=="alliance" or message=="horde" or message=="auto" then G.SelectFaction(message:sub(1,1):upper()..message:sub(2)); G.SetView("overview")
    elseif message=="resetpos" then
        G.SetMinimized(false); frame:ClearAllPoints(); frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
        SavePosition(); frame:Show(); G.db.hidden=false
    elseif message=="help" then Say("Choose a dungeon to open the quest table. /cguide overview shows pickups, sharing, prerequisites, effort and difficulty. Start guide resumes your route; /cguide details opens quest details. Click - to minimize or + to expand. /cguide config opens settings. Commands: guides, minimize, expand, next, back, pin, restart, resetpos. Hold Shift to pause quest automation.")
    else G.db.hidden=not G.db.hidden; frame:SetShown(not G.db.hidden) end
end
