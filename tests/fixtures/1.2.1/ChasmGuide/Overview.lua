local _, G = ...

local names = {yes="Yes",no="No",prereq="Pre",drop="Drop",escort="Escort",object="Item",unknown="?"}
local shareColors = {yes="82d6a0",no="ef9292",prereq="e1c27a",drop="e1c27a",escort="e1c27a",object="e1c27a",unknown="a1adbc"}
local efforts = {green="Low",gold="Med",red="High",unknown="?"}
local effortColors = {green="82d6a0",gold="e1c27a",red="ef9292",unknown="a1adbc"}
-- Landmarks from the supplied Wowhead table; coordinates still come from verified NPC maps.
local landmarks = {
    [962]="Thunder Bluff, Pools of Vision - Apothecary Zamah",
    [1491]="The Barrens, Ratchet - Mebok Mizzyrix",
    [959]="The Barrens, Ratchet - Crane Operator Bigglefuzz",
    [1486]="The Barrens, above WC entrance - Nalpak",
    [1487]="The Barrens, above WC entrance - Ebru",
    [914]="Thunder Bluff, Elder Rise - Nara Wildmane",
    [6981]="Wailing Caverns - drops from Mutanus the Devourer",
}
local function Paint(text,color) return "|cff"..color..text.."|r" end
local function Named(ids)
    local parts={}
    for _,id in ipairs(ids or {}) do if id>0 then parts[#parts+1]=G.names[id] or ("Quest #"..id) end end
    return table.concat(parts,", ")
end
function G.OverviewPrerequisite(id)
    local info,q=G.wowheadQuests[id] or {},G.questCatalog[id] or {}
    local lines={}
    local function Add(label,ids)
        local text=Named(ids); if text~="" then lines[#lines+1]=label..text end
    end
    Add("Pre: complete ",info.requires)
    Add("First accept: ",info.accepted)
    if id==914 then
        lines[#lines+1]="Pre: 5 quests, starting with The Forgotten Pools. Tonga Runetotem, Crossroads, The Barrens."
    else Add("Pre: chain starts with ",info.chain) end
    if info.requirementNote then lines[#lines+1]="Pre: "..info.requirementNote end
    if #lines==0 then
        Add("Pre (database): complete ",q.all)
        Add("Pre (database): complete one of ",q.any)
    end
    if #lines==0 and info.pre then lines[#lines+1]="Pre: requirements not yet verified." end
    local required=#lines>0
    Add("Optional breadcrumb: ",info.breadcrumb)
    return table.concat(lines,"\n"),required
end
function G.OverviewRows(includeChain)
    local dungeon=G.wowheadDungeons[G.db.guide] or {}
    local ids=dungeon.quests or {}
    if #ids==0 then ids=(G.catalog[G.db.guide] or {}).quests or {} end
    local rows,seen={},{}
    local function Add(id,chain)
        if seen[id] then return end
        seen[id]=true
        local info,q=G.wowheadQuests[id] or {},G.questCatalog[id] or {}
        if info.faction and info.faction~="Both" and info.faction~=G.routeFaction then return end
        if not info.faction and not G.QuestFits(q,G.routeFaction,false) then return end
        local at=info.pickup or q.start
        local starts=landmarks[id] or (at and at.where) or "Pickup not verified"
        if at and at.pin then starts=starts..string.format("\n/way %.1f %.1f",at.pin.x*100,at.pin.y*100) end
        local pre,required=G.OverviewPrerequisite(id)
        if pre~="" then starts=starts.."\n"..Paint(pre,"e1c27a") end
        if info.note then starts=starts.."\n"..Paint(info.note,"a1adbc") end
        local share=info.share or "unknown"
        local shareText=names[share] or "?"
        if required and share~="prereq" then shareText=shareText.." / Pre" end
        local side=info.faction
        if not side then
            local a,h=G.QuestFits(q,"Alliance",false),G.QuestFits(q,"Horde",false)
            side=a and h and "Both" or a and "Alliance" or h and "Horde" or "?"
        end
        local name=info.name or q.name or G.names[id] or ("Quest #"..id)
        local restrictions={}
        if info.class then restrictions[#restrictions+1]=info.class:gsub("^%l",string.upper).." only"
        elseif q.classes and q.classes~=0 then restrictions[#restrictions+1]="Class quest" end
        if info.profession then restrictions[#restrictions+1]=info.profession end
        if info.restriction then restrictions[#restrictions+1]=info.restriction end
        if chain then restrictions[#restrictions+1]="Chain step" end
        local state=G.QuestState(id)
        local status=({active="In quest log",ready="Ready to turn in",turned="Completed"})[state]
        if status then restrictions[#restrictions+1]=status end
        if #restrictions>0 then name=name.."\n"..Paint(table.concat(restrictions," / "),state=="turned" and "82d6a0" or "a1adbc") end
        local level=info.level or q.level
        rows[#rows+1]={id=id,name=name,level=level and (tostring(level)..(not info.level and "*" or "")) or "?",side=side,
            effort=Paint(efforts[info.effort or "unknown"] or "?",effortColors[info.effort or "unknown"] or "a1adbc"),
            share=Paint(shareText,shareColors[share] or "a1adbc"),starts=starts,pickup=at,chain=chain}
    end
    for _,id in ipairs(ids) do Add(id,false) end
    if includeChain then for _,choice in ipairs(G.QuestInfoChoices()) do Add(choice.value,true) end end
    return rows
end

function G.CreateOverview(parent,Text,Button,Backdrop,Say)
    local view=CreateFrame("Frame",nil,parent)
    local heading=Text(view,"GameFontNormalLarge"); heading:SetPoint("TOPLEFT",20,-8)
    local difficulty=Text(view,"GameFontHighlightSmall")
    local count=Text(view,"GameFontDisableSmall")
    local chain=CreateFrame("CheckButton",nil,view,"UICheckButtonTemplate"); chain:SetSize(24,24)
    local chainLabel=Text(view,"GameFontHighlightSmall"); chainLabel:SetPoint("LEFT",chain,"RIGHT",2,0); chainLabel:SetText("Include chain quests")
    chain:SetScript("OnClick",function(self) G.db.showChainQuests=self:GetChecked() and true or false; G.ui.overviewCursor=nil; G.Render() end)
    local header=CreateFrame("Frame",nil,view,"BackdropTemplate"); Backdrop(header); header:SetBackdropColor(.105,.13,.17,1)
    local labels={}
    for i,name in ipairs({"Quest","Level","Side","Effort","Share?","Starts"}) do labels[i]=Text(header,"GameFontNormalSmall"); labels[i]:SetText(name) end
    local scroll=CreateFrame("ScrollFrame",nil,view,"UIPanelScrollFrameTemplate")
    local content=CreateFrame("Frame",nil,scroll); content:SetSize(880,100); scroll:SetScrollChild(content)
    local rows={}
    local empty=Text(content); empty:SetPoint("TOPLEFT",10,-16)
    local legend=Text(view,"GameFontDisableSmall"); legend:SetPoint("BOTTOMLEFT",20,55)
    legend:SetText("Level = guide pickup level (* = database). Effort = preparation. Pre = prerequisites; sharing not guaranteed.\nDrop = own drop. Item = interact. ? = unverified. Click a row for details; right-click to pin its pickup.")
    local pin=Button(view,"Pin entrance",114,function() local _,at=G.DungeonInfoText(); Say(G.Pin(at)) end)
    pin:SetPoint("BOTTOMLEFT",20,16)
    local details=Button(view,"Dungeon info",118,function() G.OpenQuestInfo(0) end); details:SetPoint("LEFT",pin,"RIGHT",8,0)
    local start=Button(view,"Start guide  >",156,function() G.SetView("guide") end); start:SetPoint("BOTTOMRIGHT",-20,16)
    G.ui.overviewRows,G.ui.chain,G.ui.startGuide,G.ui.tableScroll=rows,chain,start,scroll
    local function Refresh(width,height)
        view:SetSize(width,height)
        local tableWidth=width-60
        local questWidth=math.floor(tableWidth*.235)
        local columns={{10,questWidth},{questWidth+22,38},{questWidth+70,58},{questWidth+138,48},{questWidth+196,64},{questWidth+270,tableWidth-questWidth-280}}
        heading:SetWidth(width-40); heading:SetText(G.title)
        difficulty:ClearAllPoints(); difficulty:SetPoint("TOPLEFT",20,-36); difficulty:SetWidth(width-40)
        difficulty:SetText(G.DungeonDifficulty(G.db.guide))
        local top=44+difficulty:GetStringHeight()
        count:ClearAllPoints(); count:SetPoint("TOPLEFT",20,-top-5)
        chain:ClearAllPoints(); chain:SetPoint("TOPRIGHT",-170,-top); chain:SetChecked(G.db.showChainQuests)
        header:ClearAllPoints(); header:SetPoint("TOPLEFT",20,-top-30); header:SetSize(tableWidth,30)
        for i,label in ipairs(labels) do label:ClearAllPoints(); label:SetPoint("TOPLEFT",columns[i][1],-9); label:SetWidth(columns[i][2]) end
        scroll:ClearAllPoints(); scroll:SetPoint("TOPLEFT",20,-top-60); scroll:SetPoint("BOTTOMRIGHT",-40,104)
        content:SetWidth(tableWidth)
        local data=G.OverviewRows(G.db.showChainQuests)
        G.ui.overviewData=data
        count:SetText(#data.." quests  /  Side: "..G.routeFaction.." or Both")
        local y=0
        for i,item in ipairs(data) do
            local row=rows[i]
            if not row then
                row=CreateFrame("Button",nil,content,"BackdropTemplate"); Backdrop(row)
                row:RegisterForClicks("LeftButtonUp","RightButtonUp"); row.cells={}
                for j=1,6 do row.cells[j]=Text(row,"GameFontHighlightSmall") end
                row:SetScript("OnEnter",function(self) self:SetBackdropColor(.15,.19,.23,1) end)
                row:SetScript("OnLeave",function(self) self:SetBackdropColor(unpack(self.shade)) end)
                row:SetScript("OnClick",function(self,button)
                    if button=="RightButton" then Say(G.Pin(self.item.pickup)) else G.OpenQuestInfo(self.item.id) end
                end)
                rows[i]=row
            end
            row.item=item; row.shade=i%2==1 and {.065,.08,.105,1} or {.085,.10,.13,1}
            row:SetBackdropColor(unpack(row.shade)); row:SetBackdropBorderColor(.14,.17,.21,1)
            row:ClearAllPoints(); row:SetPoint("TOPLEFT",0,-y)
            local height=40
            for j,key in ipairs({"name","level","side","effort","share","starts"}) do
                local cell=row.cells[j]; cell:ClearAllPoints(); cell:SetPoint("TOPLEFT",columns[j][1],-10)
                cell:SetWidth(columns[j][2]); cell:SetText(item[key]); height=math.max(height,cell:GetStringHeight()+20)
            end
            row:SetSize(tableWidth,height); row:Show(); y=y+height
        end
        for i=#data+1,#rows do rows[i]:Hide() end
        empty:SetWidth(tableWidth-20); empty:SetShown(#data==0)
        empty:SetText("No verified quests are listed for this dungeon and faction yet.\nDungeon info contains the published location and level range.")
        content:SetHeight(math.max(y,90))
        local cursor=G.db.guide..":"..G.routeFaction..":"..tostring(G.db.showChainQuests)
        if cursor~=G.ui.overviewCursor then scroll:SetVerticalScroll(0); G.ui.overviewCursor=cursor end
        legend:SetWidth(width-40)
        local _,at=G.DungeonInfoText(); pin:SetEnabled(at and at.pin~=nil)
        start:SetText(G.db.index>1 and "Resume guide  >" or "Start guide  >")
    end
    return view,Refresh
end
