local function Find(steps,id,kind)
    for i,s in ipairs(steps) do
        if s.kind==kind then for _,q in ipairs(s.quests or {}) do if q==id then return i,s end end end
    end
end
local function Signature(s)
    if not s then return 'finished' end
    return s.kind..':'..(s.kind=='manual' and s.title or table.concat(s.quests or {},','))
end
migrationCases=0
for _,side in ipairs({'Alliance','Horde'}) do
    faction=side
    for _,key in ipairs({'dalaran','sm'}) do
        for _,classID in ipairs({1,2,8,9}) do
            class=classID
            for _,legacy in ipairs({false,true}) do
                local old=OLD.BuildCatalogGuide(key,side,legacy).steps
                for i=1,#old+1 do
                    local db={guide=key,index=i,skipped={[i]=true},catalogRevision=not legacy and 1 or nil,
                        turnedIn={[123]=true},options={arrow=true,autoAccept=true,autoTurnIn=true}}
                    G.Init(db)
                    if i>#old then assert(db.index==#G.steps+1,'Finished state lost')
                    elseif old[i].kind~='manual' then
                        assert(Signature(G.steps[db.index])==Signature(old[i]),key..' cursor '..i)
                        assert(db.skipped[db.index],'Skip lost')
                    elseif key=='sm' then assert(Signature(G.steps[db.index])==Signature(old[i]))
                    else assert(db.index==1,'Unmatched manual checkpoint must restart safely') end
                    assert(db.turnedIn[123] and db.options.arrow and db.options.autoAccept and db.options.autoTurnIn)
                    local index=db.index;G.Init(db);assert(db.index==index,'Repeated migration')
                    assert(db.routeUpgradeBackups[key..':'..side].index==i)
                    migrationCases=migrationCases+1
                end
            end
        end
    end
    class=8;G.Init({guide='dalaran'})
    local main=side=='Alliance' and {92456,92489,92457,92458} or {96986,96988,96987,96984}
    assert(#G.OverviewRows(false)==4,'Expected four dungeon quests for each faction')
    for _,id in ipairs(main) do
        local a=assert(Find(G.steps,id,'accept'));local c=assert(Find(G.steps,id,'complete'));local t=assert(Find(G.steps,id,'turnin'))
        assert(a<c and c<t,'Dungeon quest order')
        assert(G.QuestFits(G.questCatalog[id],side,true),'Wrong faction')
    end
    for _,s in ipairs(G.steps) do for _,id in ipairs(s.quests or s.checklist or {}) do
        assert(G.QuestFits(G.questCatalog[id],side,true),'Cross-faction quest '..id)
    end end
    if side=='Horde' then
        assert(Find(G.steps,93680,'turnin')<Find(G.steps,92434,'accept'))
        assert(Find(G.steps,545,'turnin')<Find(G.steps,92434,'accept'))
        assert(Find(G.steps,92434,'turnin')<Find(G.steps,96984,'accept'))
        local _,turn=Find(G.steps,96984,'turnin');assert(turn.where:find('Wordeen',1,true))
        assert(not Find(G.steps,97287,'accept') and not Find(G.steps,97287,'turnin'),'Do not route Horde into hostile city')
        assert(not G.wowheadQuests[97287].finish.pin,'Blocked follow-up must not supply a city waypoint')
    else
        local _,turn=Find(G.steps,92458,'turnin');assert(turn.where:find('Modera',1,true))
        assert(not Find(G.steps,92432,'accept'),'Breadcrumb must remain optional')
        assert(Find(G.steps,92459,'accept') and Find(G.steps,92459,'turnin'))
    end
    local _,pickup=Find(G.steps,side=='Alliance' and 92458 or 96984,'accept')
    assert(pickup.pin.mapID==1421 and math.abs(pickup.pin.x-.686)<.000001,'Modera exterior pin')
    G.Init({guide='sm'})
    assert((Find(G.steps,96800,'accept')~=nil)==(side=='Alliance'),'Past Due faction')
end
faction='Alliance'
local old=OLD.BuildCatalogGuide('dalaran','Alliance').steps
local cursor=Find(old,92489,'complete')
G.Init({guide='wc',routeProgress={['dalaran:Alliance']={index=cursor,skipped={[cursor]=true},catalogRevision=1}}})
G.SelectGuide('dalaran');assert(Signature(G.steps[G.db.index])==Signature(old[cursor]))
G.SelectFaction('Horde');G.SelectFaction('Alliance');assert(Signature(G.steps[G.db.index])==Signature(old[cursor]))
assert(not G.db.options.arrow and not G.db.options.autoAccept and not G.db.options.autoTurnIn)
assert(G.wowheadDungeons.excavation.range=='26-31')
local pending=0
for _,e in pairs(G.catalog) do if e.unpublished then pending=pending+1 end end
assert(pending==5,'Unverified future routes must not become playable guides')
print('PASS: '..migrationCases..' old cursor/skip cases, inactive routes, faction switches, quest coverage, key order and default-off settings')
