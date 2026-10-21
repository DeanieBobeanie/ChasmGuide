local function Find(steps,id,kind)
    for i,s in ipairs(steps) do
        if s.kind==kind then for _,q in ipairs(s.quests or {}) do if q==id then return i,s end end end
    end
end
local faction,class='Alliance',8
UnitFactionGroup=function() return faction end
UnitClass=function() return 'Class','CLASS',class end
local active,ready,done={},{},{}
C_QuestLog={IsOnQuest=function(id) return active[id] end, IsComplete=function(id) return ready[id] end,
    IsQuestFlaggedCompleted=function(id) return done[id] end}
for _,side in ipairs({'Alliance','Horde'}) do
    faction=side; G.Init({guide='diremaul'})
    G.db.options.questScope='guide'; G.db.options.autoAccept=true; G.db.options.autoTurnIn=true
    local pre=Find(G.steps,5527,'turnin')
    assert(pre and pre<Find(G.steps,5526,'accept'),'Felvine prerequisite must precede pickup')
    for _,id in ipairs({5527,5526,7463}) do
        for _,kind in ipairs({'accept','complete','turnin'}) do assert(Find(G.steps,id,kind)) end
        assert(G.AutomationAllowed(id,'autoAccept') and G.AutomationAllowed(id,'autoTurnIn'))
        G.db.index=Find(G.steps,id,'accept'); G.db.auto=true
        active[id]=true; G.Advance(); assert(G.steps[G.db.index].kind=='complete')
        ready[id]=true; G.Advance(); assert(G.steps[G.db.index].kind=='turnin')
        done[id]=true; G.Advance(); assert(G.db.index>Find(G.steps,id,'turnin'))
    end
    active,ready,done={},{},{}
    class=1; G.Init({guide='diremaul'}); assert(not Find(G.steps,7463,'accept'),'Mage quest must stay class restricted')
    class=8
end
faction='Horde'; G.Init({guide='rfk'})
assert(Find(G.steps,6522,'accept') and Find(G.steps,6522,'turnin'))
faction='Alliance'; G.Init({guide='rfk'}); assert(not Find(G.steps,6522,'accept'))
print('PASS: new catalog quests, prerequisites, faction/class filters, scoped automation and quest progression')

-- Check every catalog overview quest that applies to this character has guided steps.
for _,side in ipairs({'Alliance','Horde'}) do
    faction=side
    for _,classID in ipairs({1,2,8,9}) do
        class=classID
        for _,key in ipairs(G.catalogOrder) do
            G.Init({guide=key})
            if G.guide.catalog and not G.catalog[key].unpublished then
                for _,row in ipairs(G.OverviewRows(false)) do
                    if G.QuestFits(G.questCatalog[row.id],side,true) then
                        assert(Find(G.steps,row.id,'accept'),key..' missing '..row.id)
                    end
                end
            end
            for _,row in ipairs(G.OverviewRows(true)) do G.QuestInfoText(row.id) end
            G.DungeonInfoText()
        end
    end
end
print('PASS: catalog overview/route agreement for both factions and four class selections')

-- Compare each upgraded cursor with its old step, including the entrance and finished states.
local function Same(a,b)
    return a.kind==b.kind and a.title==b.title and (a.quests or {})[1]==(b.quests or {})[1]
end
for _,key in ipairs({'diremaul','rfk','bfd'}) do
    for _,side in ipairs({'Alliance','Horde'}) do
        faction=side; class=side=='Alliance' and 2 or 8
        local old=G.BuildCatalogGuide(key,side,true).steps
        for index=1,#old+1 do
            local db={guide=key,index=index,auto=false,skipped={[2]=true,[#old]=true},turnedIn={[166]=true}}
            G.Init(db)
            if index<=#old then assert(Same(old[index],G.steps[db.index]),'Current step changed on upgrade')
            else assert(db.index==#G.steps+1,'Finished guide reopened') end
            assert(db.skipped[2] and db.skipped[#G.steps] and db.turnedIn[166] and not db.auto)
            local migrated=db.index
            G.Init(db); assert(db.index==migrated,'Migration ran twice on reload')
            G.SelectGuide('wc'); G.SelectGuide(key); assert(db.index==migrated,'Saved route lost its revision')
        end
        G.Init({guide='wc',auto=false,guides={[key]={index=#old,auto=false,skipped={}}}})
        G.SelectGuide(key); assert(G.db.index==#G.steps,'Inactive legacy guide did not migrate')
        local opposite=side=='Alliance' and 'Horde' or 'Alliance'
        G.Init({guide='wc',auto=false,routeProgress={[key..':'..side]={index=#old,auto=false,skipped={}}}})
        G.SelectFaction(opposite); G.SelectGuide(key); G.SelectFaction(side)
        assert(G.db.index==#G.steps,'Inactive faction route did not migrate')
    end
end
print('PASS: every old cursor, finished guides, skips, turn-ins, inactive saves, faction changes and repeated reloads')

faction='Alliance';class=2;G.Init({guide='thanes'})
for _,id in ipairs({96394,96403}) do
    local index,step=Find(G.steps,id,'accept')
    local _,pickup=G.QuestInfoText(id)
    assert(step.pin and step.pin.mapID==pickup.pin.mapID and step.pin.x==pickup.pin.x and step.pin.y==pickup.pin.y)
    G.db.index=index; G.db.options.arrow=true; G.db.options.useTomTom=true
    local last
    TomTom={AddWaypoint=function(_,map,x,y) last={map=map,x=x,y=y}; return {} end,RemoveWaypoint=function() end}
    G.SyncNavigation(true)
    assert(last and last.map==pickup.pin.mapID and last.x==pickup.pin.x and last.y==pickup.pin.y)
    G.ClearNavigation()
end
local _,mapPickup=Find(G.steps,96391,'accept')
assert(mapPickup.pin.x==.770 and mapPickup.pin.y==.600,'Item pickup must retain its drop location, not the turn-in NPC')
G.Init({})
for _,key in ipairs({'arrow','useTomTom','autoAccept','autoTurnIn','selectAllQuests'}) do assert(not G.db.options[key]) end
print('PASS: Hall of Thanes pickup pins reach TomTom, item pickups stay separate, settings remain default off')
