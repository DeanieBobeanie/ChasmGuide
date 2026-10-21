local _, G = ...
local handled = {}
local lastNPC

function G.AutomationAllowed(id, action)
    local options = G.db and G.db.options
    if not options or not options[action] then return false end
    if G.Safe(IsShiftKeyDown) or G.Safe(InCombatLockdown) then return false end
    if type(id) ~= "number" or id <= 0 then return false end
    if G.routeFaction and G.routeFaction ~= G.Safe(UnitFactionGroup, "player") then return false end
    if options.questScope == "all" then return true end
    for _, step in ipairs(G.steps or {}) do
        for _, quest in ipairs(step.quests or {}) do
            if id == quest then return true end
        end
    end
    return false
end

-- Only quest entries are selected. Gossip options and reward choices remain manual.
function G.Automate(event)
    if not G.db then return end
    if event == "GOSSIP_CLOSED" then handled={}; lastNPC=nil; return end
    if event == "GOSSIP_SHOW" then
        local npc=G.Safe(UnitGUID,"npc")
        if npc~=lastNPC then handled={}; lastNPC=npc end
        local api = C_GossipInfo or {}
        local active = G.Safe(api.GetActiveQuests) or {}
        local available = G.Safe(api.GetAvailableQuests) or {}
        local candidates = {}
        for _, q in ipairs(active) do
            if q.isComplete and G.AutomationAllowed(q.questID, "autoTurnIn") and not handled["turn:"..q.questID] then
                candidates[#candidates+1] = {id=q.questID, fn=api.SelectActiveQuest}
            end
        end
        for _, q in ipairs(available) do
            if not q.isTrivial or G.db.options.includeTrivial then
                local record=G.questCatalog and G.questCatalog[q.questID]
                local branch=record and #record.exclusive>0
                if not branch and G.AutomationAllowed(q.questID, "autoAccept") and not handled["accept:"..q.questID] then
                    candidates[#candidates+1] = {id=q.questID, fn=api.SelectAvailableQuest}
                end
            end
        end
        -- Multiple quests stay visible unless the user explicitly enables the queue.
        if #candidates == 1 or (#candidates > 1 and G.db.options.selectAllQuests) then
            local q = candidates[1]
            G.Safe(q.fn, q.id)
        end
        return
    end
    if event == "QUEST_GREETING" then
        local options=G.db.options
        if G.Safe(IsShiftKeyDown) or G.Safe(InCombatLockdown) or G.routeFaction~=G.Safe(UnitFactionGroup,"player") then return end
        local function AllowedTitle(title,action)
            if not options[action] or type(title)~="string" or handled["title:"..title] then return false end
            if options.questScope=="all" then return true end
            for _,step in ipairs(G.steps) do
                for _,id in ipairs(step.quests or {}) do if G.names[id]==title then return true end end
            end
            return false
        end
        local candidates={}
        if type(GetActiveTitle)=="function" then
            for i=1,G.Safe(GetNumActiveQuests) or 0 do
                local ok,title,complete=pcall(GetActiveTitle,i)
                if ok and complete and AllowedTitle(title,"autoTurnIn") then
                    candidates[#candidates+1]={fn=SelectActiveQuest,index=i,title=title}
                end
            end
        end
        for i=1,G.Safe(GetNumAvailableQuests) or 0 do
            local title=G.Safe(GetAvailableTitle,i)
            local trivial=G.Safe(GetAvailableQuestInfo,i)
            if AllowedTitle(title,"autoAccept") and (not trivial or options.includeTrivial) then
                candidates[#candidates+1]={fn=SelectAvailableQuest,index=i,title=title}
            end
        end
        if #candidates==1 or (#candidates>1 and options.selectAllQuests) then
            local q=candidates[1]; handled["title:"..q.title]=true; G.Safe(q.fn,q.index)
        end
        return
    end
    local id = G.Safe(GetQuestID)
    if event == "QUEST_DETAIL" then
        if G.AutomationAllowed(id, "autoAccept") and not handled["accept:"..id] then
            handled["accept:"..id]=true
            G.Safe(AcceptQuest)
        end
    elseif event == "QUEST_PROGRESS" then
        if G.AutomationAllowed(id, "autoTurnIn") and G.Safe(IsQuestCompletable) then
            local cost = G.Safe(GetQuestMoneyToGet)
            if type(cost) == "number" and cost == 0 then G.Safe(CompleteQuest) end
        end
    elseif event == "QUEST_COMPLETE" then
        if not G.AutomationAllowed(id, "autoTurnIn") then return end
        local choices, cost = G.Safe(GetNumQuestChoices), G.Safe(GetQuestMoneyToGet)
        if type(choices) ~= "number" or type(cost) ~= "number" or cost > 0 then return end
        if not handled["turn:"..id] and choices<=1 then
            handled["turn:"..id]=true
            G.Safe(GetQuestReward, choices)
        end
    end
end
