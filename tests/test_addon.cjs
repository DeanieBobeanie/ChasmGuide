const fs = require('fs');
const path = require('path');
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = require('fengari');
const parser = require('luaparse');
const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
function run(source) {
  if (lauxlib.luaL_dostring(L, to_luastring(source)) !== lua.LUA_OK) {
    throw new Error(to_jsstring(lua.lua_tostring(L, -1)));
  }
}
run(`unpack=table.unpack; G = {}; active = {}; ready = {}; completed = {}; playerFaction = 'Horde'
UnitFactionGroup = function() return playerFaction end
C_QuestLog = {
 IsOnQuest = function(id) return active[id] == true end,
 IsComplete = function(id) return ready[id] == true end,
 IsQuestFlaggedCompleted = function(id) return completed[id] == true end,
 GetQuestObjectives = function(id) return {{text = "Enemies slain: 3/8", finished = false}} end,
}
function reset() active = {}; ready = {}; completed = {}; G.Init({}) end
`);
const dir = path.resolve('ChasmGuide');
for (const name of ['Data.lua', 'Lordaeron.lua', 'Thanes.lua', 'Shadowfang.lua', 'Deadmines.lua', 'WailingCaverns.lua', 'CatalogData.lua', 'SupplementalData.lua', 'Excavation.lua', 'Catalog.lua', 'WowheadData.lua', 'DungeonUpdate.lua', 'Dalaran.lua', 'QuestInfo.lua', 'Overview.lua', 'Engine.lua', 'Automation.lua', 'Navigation.lua']) {
  const source = fs.readFileSync(path.join(dir, name), 'utf8');
  parser.parse(source, {luaVersion: '5.1'});
  run(`(function(...)\n${source}\nend)('ChasmGuide', G)`);
}
run(`
reset()
assert(#G.steps == 21)
G.Advance(); assert(G.db.index == 1, "Missing quests must block auto-advance")
active[5722] = true; G.Advance(); assert(G.db.index == 1, "Both pickups are required")
active[5723] = true; G.Advance(); assert(G.db.index == 2)
active[5725] = true; active[5726] = true; G.Advance(); assert(G.db.index == 4)
ready[5726] = true; G.Advance(); assert(G.db.index == 5)
assert(G.QuestState(5726) == "ready", "Ready is not turned in")
active[5727] = true; G.Advance(); assert(G.db.index == 6)
assert(G.QuestState(5726) == "turned", "Successor proves earlier turn-in")
ready[5727] = true; active[5728] = true; active[5761] = true
G.Advance(); assert(G.db.index == 9, "Entrance checkpoint requires user")
G.Next(); assert(G.db.index == 10)
ready[5723] = true; active[5724] = true; ready[5761] = true
ready[5728] = true; ready[5725] = true
G.Advance(); assert(G.db.index == 15, "Exit checkpoint requires user")
G.Next(); assert(G.db.index == 16, "Ready quest must still be turned in")
completed[5761] = true; G.Advance(); assert(G.db.index == 17)
active[5729] = true; G.Advance(); assert(G.db.index == 18)
active[5730] = true; G.Advance(); assert(G.db.index == 19)
completed[5730] = true; completed[5723] = true; completed[5724] = true
G.Advance(); assert(G.db.index == 21)
completed[5725] = true; G.Advance(); assert(G.db.index == 22)
G.Back(); assert(G.db.index == 21 and not G.db.auto)
G.Advance(); assert(G.db.index == 21, "Review must remain paused on completed steps")
reset(); G.Next(); assert(G.db.index == 2 and G.db.skipped[1])
G.Restart(); assert(G.db.index == 1 and not next(G.db.skipped))
active[5723] = true; assert(G.StatusLines(G.steps[10]):find("3/8", 1, true))
active[5723] = nil; assert(G.QuestState(5723) == "missing", "Abandoned quest must not stay active")
local saved = {index=12, auto=false, skipped={[4]=true}, turnedIn={[5726]=true}}
G.Init(saved); assert(G.db.index == 12 and G.db.skipped[4] and G.QuestState(5726) == "turned")
local oldAPI = C_QuestLog; C_QuestLog = nil
reset(); assert(not G.IsDone(G.steps[1])); G.Next(); assert(G.db.index == 2)
C_QuestLog = oldAPI
assert(G.Safe(function() error("API unavailable") end) == nil)
-- Updated package supplies this pin.
C_Map = {
 GetBestMapForUnit = function() return 100 end,
 GetMapInfo = function(id)
   if id == 100 then return {mapID=100, name="Durotar", parentMapID=1} end
   return {mapID=1, name="Azeroth", parentMapID=0}
 end,
 GetMapChildrenInfo = function() return {{mapID=200, name="Thunder Bluff"}} end,
 CanSetUserWaypointOnMap = function(id) return id == 200 end,
 SetUserWaypoint = function(point) lastPin=point; return true end,
}
UiMapPoint = {CreateFromCoordinates=function(id,x,y) return {mapID=id,x=x,y=y} end}
C_SuperTrack = {SetSuperTrackedUserWaypoint=function(value) tracked=value end}
assert(G.ResolveMap("Thunder Bluff") == 200)
-- Map IDs now come from metadata; checked separately.
assert(G.Pin(G.steps[2]):find("unavailable",1,true))
print("PASS: full quest run, pickup groups, turn-ins, successor inference, manual checkpoints, review, skip, restart, saved state, abandonment, API fallback, map pins")

-- Upgrade a version 1 saved game, then switch guides and reload.
reset()
G.Init({version=1, index=12, auto=false, skipped={[4]=true}, turnedIn={[5726]=true}})
assert(G.db.guide == "rfc" and G.db.index == 12 and G.db.version == 2)
assert(G.SelectGuide("lordaeron") and G.db.index == 1 and #G.steps == 24)
G.Next(); assert(G.db.index == 2 and G.db.skipped[1])
G.SelectGuide("rfc"); assert(G.db.index == 12 and not G.db.auto and G.db.skipped[4])
G.SelectGuide("lordaeron"); assert(G.db.index == 2 and G.db.skipped[1] and not G.db.skipped[4])
local persisted = G.db
G.Init(persisted); assert(G.db.guide == "lordaeron" and G.db.index == 2)
assert(not G.SelectGuide("unknown") and G.db.guide == "lordaeron")
G.SelectGuide("rfc"); assert(G.db.index == 12)

-- Play the Ruins route, skip the optional crest, and complete the full head chain.
reset(); G.SelectGuide("lordaeron")
for _, id in ipairs({92401,92422,92421,95216}) do active[id]=true end
G.Advance(); assert(G.db.index == 5)
G.Next(); assert(G.db.index == 6)
ready[95216]=true; active[97288]=true; ready[92401]=true; ready[92422]=true; ready[92421]=true
G.Advance(); assert(G.db.index == 11, "Crest pickup remains reviewable")
G.Next(); assert(G.db.index == 12 and G.db.skipped[11])
G.Next(); assert(G.db.index == 13)
completed[92421]=true; completed[95216]=true
G.Advance(); assert(G.db.index == 15)
active[97289]=true; G.Advance(); assert(G.db.index == 16 and G.QuestState(97288) == "turned")
active[97290]=true; G.Advance(); assert(G.db.index == 17)
active[97291]=true; G.Advance(); assert(G.db.index == 18)
ready[97291]=true; G.Advance(); assert(G.db.index == 19)
active[97292]=true; G.Advance(); assert(G.db.index == 20)
ready[97292]=true; G.Advance(); assert(G.db.index == 21, "Serum requires a turn-in")
completed[97292]=true; G.Advance(); assert(G.db.index == 22)
G.Next(); assert(G.db.index == 23, "Optional crest turn-in can be skipped")
completed[92422]=true; completed[92401]=true; G.Advance(); assert(G.db.index == 25)
for _, id in ipairs(G.guide.finalQuests) do assert(G.QuestState(id) == "turned") end
assert(G.QuestState(95204) == "missing", "Optional crest must not be falsely completed")
G.Restart(); assert(G.db.index == 5, "Restart recognizes completed quest chains")
for key, guide in pairs(G.guides) do
  if guide.catalog then guide=G.BuildCatalogGuide(key,playerFaction) end
  for _, step in ipairs(guide.steps) do
    assert(step.title and step.text and step.where)
    for _, id in ipairs(step.quests or step.checklist or {}) do assert(G.names[id]) end
  end
end
print("PASS: version 1 migration, independent guide progress, saved reload, full Ruins run, five-part Torment chain, optional crest, guide data")

playerFaction = 'Alliance'; reset(); G.SelectGuide('thanes')
assert(#G.steps == 19 and G.guide.faction == 'Alliance')
G.Advance(); assert(G.db.index == 1)
active[96391]=true; G.Advance(); assert(G.db.index == 2)
active[96393]=true; G.Advance(); assert(G.db.index == 3)
assert(G.QuestState(96391) == 'turned', 'Incursion proves map turn-in')
G.Next(); assert(G.db.index == 4)
active[96394]=true; active[96403]=true; G.Advance(); assert(G.db.index == 6)
G.Next(); assert(G.db.index == 7, 'Must collect quest before Faldrim')
active[96395]=true; G.Advance(); assert(G.db.index == 8)
ready[96395]=true; G.Advance(); assert(G.db.index == 9)
completed[96395]=true; G.Advance(); assert(G.db.index == 10)
ready[96394]=true; G.Advance(); assert(G.db.index == 11)
G.Next(); assert(G.db.index == 12); G.Next(); assert(G.db.index == 13)
ready[96393]=true; ready[96403]=true; G.Advance(); assert(G.db.index == 15)
active[98423]=true; G.Advance(); assert(G.db.index == 16)
G.Next(); assert(G.db.index == 17)
completed[96403]=true; completed[96394]=true; G.Advance(); assert(G.db.index == 19)
completed[96393]=true; G.Advance(); assert(G.db.index == 19, 'Both Magni turn-ins required')
completed[98423]=true; G.Advance(); assert(G.db.index == 20)
for _,id in ipairs(G.guide.finalQuests) do assert(G.QuestState(id)=='turned') end
G.SelectGuide('rfc'); G.db.index=2; G.db.auto=false
G.SelectGuide('lordaeron'); G.db.index=8; G.db.auto=false
G.SelectGuide('thanes'); assert(G.db.index==20)
G.SelectGuide('rfc'); assert(G.db.index==2 and not G.db.auto)
G.SelectGuide('lordaeron'); assert(G.db.index==8 and not G.db.auto)
local reload = G.db; G.Init(reload); assert(G.db.guide=='lordaeron' and G.db.index==8)

playerFaction='Horde'; reset(); G.SelectGuide('thanes')
assert(#G.steps==12 and G.guide.faction=='Horde' and #G.guide.finalQuests==2)
for _,step in ipairs(G.steps) do
  for _,id in ipairs(step.quests or step.checklist or {}) do
    assert(id==96403 or id==96395, 'Horde must not receive Alliance quests')
  end
end
G.Next(); active[96403]=true; G.Advance(); assert(G.db.index==3)
G.Next(); active[96395]=true; G.Advance(); assert(G.db.index==5)
ready[96395]=true; completed[96395]=true; G.Advance(); assert(G.db.index==7)
G.Next(); G.Next(); G.Next(); assert(G.db.index==10)
ready[96403]=true; G.Advance(); assert(G.db.index==11)
G.Next(); completed[96403]=true; G.Advance(); assert(G.db.index==13)
for _,id in ipairs(G.guide.finalQuests) do assert(G.QuestState(id)=='turned') end
playerFaction='Alliance'; reset()
print('PASS: complete Hall of Thanes Alliance and Horde routes, prerequisites, both Magni turn-ins, three-guide persistence')
`);
// UI smoke checks use lightweight mocks. They do not establish in-game compatibility.
run(`
playerFaction='Horde'; reset(); G.SelectGuide('sfk')
assert(#G.steps==17 and G.guide.faction=='Horde')
active[1013]=true; active[1098]=true; active[1014]=true
G.Advance(); assert(G.db.index==4)
G.Next(); G.Next(); G.Next(); assert(G.db.index==7)
ready[1098]=true; G.Advance(); assert(G.db.index==7, 'Vincent requires an actual turn-in')
completed[1098]=true; G.Advance(); assert(G.db.index==8)
G.Next(); G.Next(); G.Next(); assert(G.db.index==11)
G.Advance(); assert(G.db.index==11, 'Missing book must block progression')
ready[1013]=true; G.Advance(); assert(G.db.index==12)
G.Next(); assert(G.db.index==13)
G.Advance(); assert(G.db.index==13, 'Arugal head is required')
ready[1014]=true; G.Advance(); assert(G.db.index==14)
G.Next(); assert(G.db.index==15)
completed[1014]=true; G.Advance(); assert(G.db.index==16)
completed[1013]=true; G.Advance(); assert(G.db.index==17)
G.Next(); assert(G.db.index==18)
for _,id in ipairs(G.guide.finalQuests) do assert(G.QuestState(id)=='turned') end
assert(G.QuestState(1740)=='missing', 'Optional class quest must not be falsely completed')
G.SelectGuide('rfc'); G.db.index=2; G.db.auto=false
G.SelectGuide('thanes'); G.db.index=7; G.db.auto=false
G.SelectGuide('lordaeron'); G.db.index=9; G.db.auto=false
G.SelectGuide('sfk'); assert(G.db.index==18)
G.Init(G.db); assert(G.db.guide=='sfk' and G.db.index==18)
G.SelectGuide('rfc'); assert(G.db.index==2 and not G.db.auto)
G.SelectGuide('thanes'); assert(G.db.index==7 and not G.db.auto)
G.SelectGuide('lordaeron'); assert(G.db.index==9 and not G.db.auto)
reset(); G.SelectGuide('sfk'); G.Next(); assert(G.db.skipped[1])
G.Restart(); assert(G.db.index==1 and not next(G.db.skipped))
playerFaction='Alliance'; reset(); G.SelectGuide('sfk')
assert(#G.steps==12 and #G.guide.finalQuests==0 and G.guide.endText)
for i,step in ipairs(G.steps) do
  assert(step.kind=='manual' and not step.quests and not step.checklist)
  G.Advance(); assert(G.db.index==i, 'Alliance must not wait for Horde or class quests')
  G.Next()
end
assert(G.db.index==13)
reset()
print('PASS: Shadowfang Horde quest run, Vincent turn-in, book/head checks, optional class steps, Alliance route, four-guide saved progress')
`);
run(`
objects = {}; SlashCmdList = {}; DEFAULT_CHAT_FRAME = {AddMessage=function() end}
local methods = {}
function methods:SetSize(w,h) self.width=w; self.height=h end
function methods:SetWidth(w) self.width=w end
function methods:SetHeight(h) self.height=h end
function methods:GetWidth() return rawget(self,"width") or 1920 end
function methods:GetHeight() return rawget(self,"height") or 1080 end
function methods:GetLeft() return 100 end
function methods:GetTop() return 1000 end
function methods:GetText() return rawget(self,"text") or "" end
function methods:GetNormalTexture() return CreateFrame("Texture") end
function methods:GetHighlightTexture() return CreateFrame("Texture") end
function methods:GetPushedTexture() return CreateFrame("Texture") end
function methods:IsShown() return self.shown end
function methods:HookScript(event,fn) end

function methods:SetScript(event, fn) self.scripts[event] = fn end
function methods:CreateFontString() return CreateFrame("FontString") end
function methods:CreateTexture() return CreateFrame("Texture") end
function methods:SetText(text) self.text=text end
function methods:SetPoint(...) self.point={...} end
function methods:GetStringHeight() return self.text and math.ceil(#self.text / 48) * 14 or 0 end
function methods:GetCenter() return 0,0 end
function methods:SetChecked(v) self.checked=v end
function methods:GetChecked() return self.checked end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:SetShown(v) self.shown=v end
function CreateFrame(kind, name)
 local obj = setmetatable({scripts={},shown=true}, {__index=function(_, key) return methods[key] or function() end end})
 table.insert(objects, obj)
 if name then _G[name]=obj end
 return obj
end
UIParent = CreateFrame("Frame")
`);
const ui = fs.readFileSync(path.join(dir, 'UI.lua'), 'utf8');
parser.parse(ui, {luaVersion:'5.1'});
run(`(function(...)\n${ui}\nend)('ChasmGuide', G)
local events
for _, obj in ipairs(objects) do if obj.scripts.OnEvent then events=obj end end
assert(events)
events.scripts.OnEvent(events, 'ADDON_LOADED', 'UnrelatedAddon')
assert(not ChasmGuideFrame)
events.scripts.OnEvent(events, 'ADDON_LOADED', 'ChasmGuide')
events.scripts.OnEvent(events, 'PLAYER_LOGIN')
for _, key in ipairs({"rfc", "lordaeron", "thanes", "sfk", "deadmines", "wc"}) do
  G.SelectGuide(key)
  for i=1,#G.steps+1 do G.db.index=i; G.Render() end
end
for _, alias in ipairs({'thanes', 'ironforge', 'hot'}) do
  SlashCmdList.CHASMGUIDE(alias); assert(G.db.guide == 'thanes')
end
playerFaction='Horde'; G.Init({guide='thanes'})
for i=1,#G.steps+1 do G.db.index=i; G.Render() end
G.Init({guide='lordaeron'})
for i=1,#G.steps+1 do G.db.index=i; G.Render() end
G.Init({guide='sfk'})
for i=1,#G.steps+1 do G.db.index=i; G.Render() end
for _,alias in ipairs({'sfk', 'shadowfang', 'shadowfen'}) do
  SlashCmdList.CHASMGUIDE(alias); assert(G.db.guide=='sfk')
end
playerFaction='Alliance'; G.Init({})
for _,alias in ipairs({'deadmines', 'dm', 'vc', 'dead mines'}) do
  SlashCmdList.CHASMGUIDE(alias); assert(G.db.guide=='deadmines')
end
for _,alias in ipairs({'wc', 'wailing', 'wailing caverns'}) do
  SlashCmdList.CHASMGUIDE(alias); assert(G.db.guide=='wc')
end
G.ui.dungeons.scripts.OnClick()
assert(G.ui.dungeons.rows[1].value=='rfc')
G.ui.dungeons.rows[1].scripts.OnClick(G.ui.dungeons.rows[1]); assert(G.db.guide=='rfc')
G.ui.factions.scripts.OnClick()
G.ui.factions.rows[3].scripts.OnClick(G.ui.factions.rows[3]); assert(G.routeFaction=='Horde')
G.SelectFaction('Auto')
SlashCmdList.CHASMGUIDE('lordaeron'); assert(G.db.guide == 'lordaeron')
SlashCmdList.CHASMGUIDE('rfc'); assert(G.db.guide == 'rfc')
SlashCmdList.CHASMGUIDE('guides')
SlashCmdList.CHASMGUIDE('restart')
SlashCmdList.CHASMGUIDE('next')
SlashCmdList.CHASMGUIDE('back')
SlashCmdList.CHASMGUIDE('pin')
SlashCmdList.CHASMGUIDE('help')
SlashCmdList.CHASMGUIDE('resetpos')
SlashCmdList.CHASMGUIDE(''); assert(G.db.hidden)
SlashCmdList.CHASMGUIDE(''); assert(not G.db.hidden)
events.scripts.OnEvent(events, 'QUEST_TURNED_IN', 5761)
assert(G.db.turnedIn[5761])
events.scripts.OnEvent(events, 'QUEST_TURNED_IN', 1098)
assert(G.db.turnedIn[1098])
print('PASS: Lua 5.1 syntax, addon lifecycle, all route displays, dungeon/faction dropdowns and aliases, scrollable body, quest event storage')
`);
run(`
playerFaction='Alliance'; reset(); G.SelectGuide('deadmines')
assert(G.guide.faction=='Alliance')
local function locate(title)
  for i,step in ipairs(G.steps) do if step.title==title then G.db.index=i; return step end end
  error('Missing step: '..title)
end
-- A character already at VanCleef and the explosives placement must skip prerequisite quests.
active[166]=true; active[92753]=true
for _,id in ipairs({65,132,135,141,142,155,92742,92744,92745,92747,92748,92749,92750,92751,92752}) do
  assert(G.QuestState(id)=='turned', 'Later chain part must prove earlier progress')
end
G.Advance(); assert(G.steps[G.db.index].title=='Pick up Red Silk Bandanas')
assert(G.QuestState(214)=='missing', 'VanCleef quest must not imply bandana pickup')
reset(); G.SelectGuide('deadmines')
locate("Collect Wilder's two quests")
active[168]=true; G.Advance(); assert(G.steps[G.db.index].quests[2]==167)
active[167]=true; G.Advance(); assert(G.steps[G.db.index].title=='Collect Underground Assault')
locate("Collect the miners' cards and badge")
ready[168]=true; G.Advance(); assert(G.steps[G.db.index].quests[2]==167)
ready[167]=true; G.Advance(); assert(G.steps[G.db.index].title=='Check your quests and enter')
locate('Defeat VanCleef and collect his head'); active[166]=true
G.Advance(); assert(G.steps[G.db.index].quests[1]==166, 'Killing alone cannot imply head looted')
ready[166]=true; G.Advance(); assert(G.steps[G.db.index].title=='Read An Unsent Letter')
active[373]=true; G.Advance(); assert(G.steps[G.db.index].title=='Finish collecting silk bandanas')
active[214]=true; ready[214]=true; G.Advance(); assert(G.steps[G.db.index].title=='Use the back exit')
G.Next(); active[92819]=true; G.Advance(); assert(G.steps[G.db.index].title=='Use the detonator')
assert(G.QuestState(92753)=='turned' and G.QuestState(92819)=='active')
ready[92819]=true; G.Advance(); assert(G.steps[G.db.index].title=='Finish Destruction in Deadmines')
G.Advance(); assert(G.steps[G.db.index].quests[1]==92819, 'Detonator objective still requires hand-in')
completed[92819]=true; G.Advance(); assert(G.steps[G.db.index].title=="Return VanCleef's head")
-- Drive every step through its quest states, including each same-name quest ID.
reset(); G.SelectGuide('deadmines')
local iterations=0
while G.steps[G.db.index] do
  iterations=iterations+1; assert(iterations<200)
  local step=G.steps[G.db.index]
  if step.kind=='manual' then
    local before=G.db.index; G.Advance(); assert(G.db.index==before); G.Next()
  else
    for _,id in ipairs(step.quests) do
      if step.kind=='accept' then active[id]=true
      elseif step.kind=='complete' then active[id]=true; ready[id]=true
      else completed[id]=true end
    end
    G.Advance()
  end
end
for _,id in ipairs({168,167,2040,166,214,373,92753,92819}) do assert(G.QuestState(id)=='turned') end
assert(G.QuestState(1654)=='missing', 'Paladin material reminder cannot complete the full class quest')
local endIndex=G.db.index
for _,key in ipairs({'rfc','lordaeron','thanes','sfk'}) do G.SelectGuide(key); G.db.index=3; G.db.auto=false end
G.SelectGuide('deadmines'); assert(G.db.index==endIndex)
G.Init(G.db); assert(G.db.guide=='deadmines' and G.db.index==endIndex)
for _,key in ipairs({'rfc','lordaeron','thanes','sfk'}) do G.SelectGuide(key); assert(G.db.index==3 and not G.db.auto) end
print('PASS: Deadmines '..#G.guides.deadmines.steps..' steps, both prerequisite chains, grouped objectives, head/letter, back-exit detonation and turn-in, optional paladin, five-guide persistence')
`);
run(`
playerFaction='Alliance'; reset()
local legacy = {guide='lordaeron', index=24, auto=false, skipped={[3]=true},
  turnedIn={[166]=true}, guides={deadmines={index=20,auto=false,skipped={[2]=true}}}}
G.Init(legacy)
assert(G.guide.faction=='Alliance' and #G.steps==15 and G.db.index==1)
assert(G.db.auto and not next(G.db.skipped))
assert(G.db.lordaeronLegacyProgress.index==24 and G.db.lordaeronLegacyProgress.skipped[3])
assert(G.db.turnedIn[166] and G.db.guides.deadmines.index==20)
local allowed = {[95250]=true,[95195]=true,[92415]=true,[95161]=true,[95189]=true}
for _,step in ipairs(G.steps) do
  for _,id in ipairs(step.quests or step.checklist or {}) do assert(allowed[id], 'Alliance must never track Horde quest IDs') end
  assert(not step.where:find('Apothecarium',1,true) and not step.where:find('Sepulcher',1,true))
end
G.Next(); assert(G.db.index==2)
active[95250]=true; G.Advance(); assert(G.db.index==3)
G.Next(); active[95195]=true; G.Advance(); assert(G.db.index==5)
G.Advance(); assert(G.db.index==5, 'Baron head must be looted')
ready[95250]=true; G.Advance(); assert(G.db.index==6)
G.Advance(); assert(G.db.index==6, 'Truman requires a hand-in')
completed[95250]=true; G.Advance(); assert(G.db.index==7)
G.Next(); active[92415]=true; G.Advance(); assert(G.db.index==9)
active[95189]=true; G.Advance(); assert(G.db.index==10)
ready[95195]=true; G.Advance(); assert(G.db.index==11)
G.Next(); completed[95195]=true; G.Advance(); assert(G.db.index==13)
active[95161]=true; G.Advance(); assert(G.db.index==14 and G.QuestState(92415)=='turned')
completed[95189]=true; G.Advance(); assert(G.db.index==15)
ready[95161]=true; G.Advance(); assert(G.db.index==15, 'Duskwood delivery requires turn-in')
completed[95161]=true; G.Advance(); assert(G.db.index==16)
for _,id in ipairs(G.guide.finalQuests) do assert(G.QuestState(id)=='turned') end
G.Init(G.db); assert(G.db.index==16, 'Alliance migration must run only once')
G.SelectGuide('deadmines'); assert(G.db.index==20 and not G.db.auto and G.db.skipped[2])
G.SelectGuide('lordaeron'); assert(G.db.index==16)
-- Inactive pre-update progress must migrate when the player opens the guide.
reset(); G.Init({guide='rfc',index=2,auto=false,guides={lordaeron={index=22,auto=false,skipped={[4]=true}}}})
assert(G.db.index==2); G.SelectGuide('lordaeron'); assert(G.db.index==1 and G.db.lordaeronLegacyProgress.index==22)
G.SelectGuide('rfc'); assert(G.db.index==2 and not G.db.auto)
-- The optional crest can be skipped without blocking required quest completion.
reset(); G.SelectGuide('lordaeron')
for _,id in ipairs({95250,95195,95161}) do completed[id]=true end
G.db.index=9; G.Next(); assert(G.db.skipped[9])
G.db.index=14; G.Next(); assert(G.db.index==16 and G.QuestState(95189)=='missing')
G.Render()
playerFaction='Horde'; G.Init({guide='lordaeron',index=20,auto=false,skipped={[4]=true}})
assert(#G.steps==24 and G.guide.faction=='Horde' and G.db.index==20 and G.db.skipped[4])
assert(not G.db.lordaeronAllianceRoute and not G.db.auto)
print('PASS: Alliance Lordaeron full run, five quest IDs, letter follow-up, optional crest, active/inactive migration, Horde and other-guide preservation')
`);
run(`
playerFaction='Alliance'; reset(); G.SelectGuide('wc')
assert(G.guide.faction=='Alliance' and #G.steps==25)
local allowed = {[865]=true,[959]=true,[1491]=true,[1486]=true,[1487]=true,[6981]=true,[3370]=true}
local seen={}
local function findStep(kind,id)
  for i,step in ipairs(G.steps) do
    if step.kind==kind then
      for _,quest in ipairs(step.quests or {}) do if quest==id then return i end end
    end
  end
  error('Missing step: '..kind..' '..id)
end
for _,step in ipairs(G.steps) do
  for _,id in ipairs(step.quests or step.checklist or {}) do
    assert(allowed[id], 'Alliance WC must not include Horde quest IDs'); seen[id]=true
  end
end
for id in pairs(allowed) do assert(seen[id]) end
assert(findStep('turnin',865)<findStep('accept',1491))
assert(findStep('complete',6981)<findStep('turnin',6981))
assert(findStep('turnin',6981)<findStep('accept',3370))
-- Having Smart Drinks proves the horns prerequisite is complete.
active[1491]=true; active[959]=true
G.Next(); assert(G.steps[G.db.index].quests[1]==1486)
assert(G.QuestState(865)=='turned')
-- Ratchet gossip cannot stand in for Falla's turn-in or the Alliance delivery.
reset(); G.SelectGuide('wc'); active[6981]=true; ready[6981]=true
G.db.index=findStep('complete',6981); G.Advance()
assert(G.db.index==findStep('turnin',6981))
active[3370]=true; G.Advance()
assert(G.db.index==findStep('turnin',3370))
assert(G.QuestState(6981)=='turned' and G.QuestState(3370)=='active')
ready[3370]=true; G.Advance(); assert(G.steps[G.db.index])
completed[3370]=true; G.Advance(); assert(not G.steps[G.db.index])
-- Skipped hides remain outstanding, even after reaching the guide end.
reset(); G.SelectGuide('wc'); active[1486]=true
G.db.index=findStep('complete',1486); local hidesIndex=G.db.index; G.Next()
assert(G.db.skipped[hidesIndex] and G.QuestState(1486)=='active')
for _,id in ipairs({959,1491,1487,3370}) do completed[id]=true end
G.db.index=#G.steps+1; G.Render()
local incompleteShown=false
for _,obj in ipairs(objects) do
  if type(obj.text)=='string' and obj.text:find('1 final turn%-ins are not confirmed') then incompleteShown=true end
end
assert(incompleteShown, 'End screen must report uncollected hides')
-- Complete a full run through the same APIs used by live quest events.
reset(); G.SelectGuide('wc')
local iterations=0
while G.steps[G.db.index] do
  iterations=iterations+1; assert(iterations<100)
  local step=G.steps[G.db.index]
  if step.kind=='manual' then
    local before=G.db.index; G.Advance(); assert(G.db.index==before); G.Next()
  else
    for _,id in ipairs(step.quests) do
      if step.kind=='accept' then active[id]=true
      elseif step.kind=='complete' then active[id]=true; ready[id]=true
      else completed[id]=true end
    end
    G.Advance()
  end
end
for _,id in ipairs(G.guide.finalQuests) do assert(G.QuestState(id)=='turned') end
local finished=G.db.index
for _,key in ipairs({'rfc','lordaeron','thanes','sfk','deadmines'}) do
  G.SelectGuide(key); G.db.index=3; G.db.auto=false; G.db.skipped[2]=true
end
G.SelectGuide('wc'); assert(G.db.index==finished)
G.Init(G.db); assert(G.db.guide=='wc' and G.db.index==finished)
for _,key in ipairs({'rfc','lordaeron','thanes','sfk','deadmines'}) do
  G.SelectGuide(key); assert(G.db.index==3 and not G.db.auto and G.db.skipped[2])
end
print('PASS: Alliance WC 25 steps, seven quest IDs, prerequisite inference, shard gossip/turn-in separation, Darnassus delivery, missing hides, six-guide persistence')
`);
run(`
playerFaction='Alliance'; reset(); G.SelectGuide('wc')
for _,key in ipairs({'arrow','useTomTom','autoAccept','autoTurnIn','selectAllQuests'}) do assert(G.db.options[key]==false) end
assert(G.db.options.questScope=='all')
G.OpenSettings()
assert(G.ui.options.arrow:GetChecked()==false)
G.ui.options.arrow:SetChecked(true); G.ui.options.arrow.scripts.OnClick(G.ui.options.arrow)
assert(G.db.options.arrow)
G.ui.options.arrow:SetChecked(false); G.ui.options.arrow.scripts.OnClick(G.ui.options.arrow)
assert(not G.db.options.arrow)
G.db.index=8; G.db.auto=false; G.db.skipped[2]=true
G.SelectFaction('Horde'); assert(G.routeFaction=='Horde' and G.db.index==1)
G.db.index=4; G.db.auto=false
G.SelectFaction('Alliance'); assert(G.db.index==8 and not G.db.auto and G.db.skipped[2])
G.SelectFaction('Horde'); assert(G.db.index==4)
G.Init(G.db); assert(G.routeFaction=='Horde' and G.db.index==4)
G.SelectFaction('Auto'); assert(G.routeFaction=='Alliance' and G.db.index==8)
-- Every catalog entry must render under either faction, including explicit data gaps.
local views=0
for _,faction in ipairs({'Alliance','Horde'}) do
  playerFaction=faction; reset()
  for _,key in ipairs(G.catalogOrder) do
    G.SelectGuide(key)
    assert(G.guide.faction==faction and #G.steps>0, key..' faction mismatch')
    for i,step in ipairs(G.steps) do
      assert(step.title and step.text and step.where)
      for _,id in ipairs(step.quests or step.checklist or {}) do assert(G.names[id], 'Unknown quest '..id) end
      if step.questRecord then assert(G.QuestFits(G.questCatalog[step.questRecord],faction,true)) end
      if step.pin then assert(step.pin.x>=0 and step.pin.x<=1 and step.pin.y>=0 and step.pin.y<=1) end
      G.db.index=i; G.Render()
    end
    G.db.index=#G.steps+1; G.Render(); views=views+1
    if G.catalog[key].unpublished then assert(#G.steps==1 and G.guide.endText:find('No verified')) end
  end
end
assert(views==56)
playerFaction='Alliance'; reset(); G.SelectGuide('excavation')
local aq={}; for _,s in ipairs(G.steps) do for _,id in ipairs(s.quests or {}) do aq[id]=true end end
assert(aq[98824] and aq[95795] and aq[95809] and not aq[98823] and not aq[95697])
G.SelectFaction('Horde')
local hq={}; for _,s in ipairs(G.steps) do for _,id in ipairs(s.quests or {}) do hq[id]=true end end
assert(hq[98823] and hq[95697] and not hq[98824] and not hq[98815])
print('PASS: default-off configuration, per-faction progress/reload, all 56 catalog routes, quest filters, valid pins, Excavation faction separation')
`);
run(`
playerFaction='Alliance'; reset(); G.SelectGuide('wc'); G.Automate('GOSSIP_CLOSED')
local id,choices,cost,shift,combat=999999,0,0,false,false
local calls={accept=0,complete=0,reward=0,select=0}
GetQuestID=function() return id end
GetNumQuestChoices=function() return choices end
GetQuestMoneyToGet=function() return cost end
IsQuestCompletable=function() return true end
IsShiftKeyDown=function() return shift end
InCombatLockdown=function() return combat end
AcceptQuest=function() calls.accept=calls.accept+1 end
CompleteQuest=function() calls.complete=calls.complete+1 end
GetQuestReward=function(choice) calls.reward=calls.reward+1; calls.choice=choice end
for _,event in ipairs({'QUEST_DETAIL','QUEST_PROGRESS','QUEST_COMPLETE'}) do G.Automate(event) end
assert(calls.accept+calls.complete+calls.reward==0)
G.db.options.autoAccept=true; G.Automate('QUEST_DETAIL'); G.Automate('QUEST_DETAIL')
assert(calls.accept==1, 'Accept any quest, once per interaction')
G.db.options.autoTurnIn=true; G.Automate('QUEST_PROGRESS'); G.Automate('QUEST_COMPLETE')
assert(calls.complete==1 and calls.reward==1 and calls.choice==0)
G.Automate('GOSSIP_CLOSED'); choices=1; G.Automate('QUEST_COMPLETE'); assert(calls.reward==2 and calls.choice==1)
G.Automate('GOSSIP_CLOSED'); choices=3; G.Automate('QUEST_COMPLETE'); assert(calls.reward==2,'Reward selection must wait')
choices=0; cost=100; G.Automate('QUEST_PROGRESS'); G.Automate('QUEST_COMPLETE')
assert(calls.complete==1 and calls.reward==2,'Money costs require player action')
cost=0; shift=true; G.Automate('QUEST_DETAIL'); assert(calls.accept==1)
shift=false; combat=true; G.Automate('QUEST_DETAIL'); assert(calls.accept==1)
combat=false; G.db.options.questScope='guide'; G.Automate('QUEST_DETAIL'); assert(calls.accept==1)
id=1486; G.Automate('QUEST_DETAIL'); assert(calls.accept==2)
G.Automate('GOSSIP_CLOSED'); G.SelectFaction('Horde'); G.Automate('QUEST_DETAIL'); assert(calls.accept==2)
G.SelectFaction('Auto'); G.db.options.questScope='all'; id=nil; G.Automate('QUEST_DETAIL'); assert(calls.accept==2)
local offers={{questID=999998},{questID=999999}}
C_GossipInfo={GetAvailableQuests=function() return offers end,GetActiveQuests=function() return {} end,
 SelectAvailableQuest=function(q) calls.select=calls.select+1; calls.selected=q end,
 SelectOption=function() error('Must never choose branching dialogue') end}
G.Automate('GOSSIP_SHOW'); assert(calls.select==0,'Multiple quest entries wait by default')
G.db.options.selectAllQuests=true; G.Automate('GOSSIP_SHOW'); assert(calls.select==1 and calls.selected==999998)
G.db.options.autoAccept=false; G.Automate('GOSSIP_SHOW'); assert(calls.select==1)
G.db.options.autoAccept=true; G.db.options.selectAllQuests=false; offers={{questID=999997,isTrivial=true}}
G.db.options.includeTrivial=false; G.Automate('GOSSIP_SHOW'); assert(calls.select==1)
G.db.options.includeTrivial=true; G.Automate('GOSSIP_SHOW'); assert(calls.select==2)
-- Legacy quest greetings use index selection; detail events still check quest IDs.
GetNumAvailableQuests=function() return 1 end; GetAvailableTitle=function() return 'A test quest' end
GetAvailableQuestInfo=function() return false end
SelectAvailableQuest=function(index) assert(index==1); calls.select=calls.select+1 end
G.Automate('QUEST_GREETING'); assert(calls.select==3)
G.Automate('QUEST_GREETING'); assert(calls.select==3,'Legacy duplicate protection')
print('PASS: global and guide-only automation, default off, manual rewards, costs, Shift/combat, duplicate events, multiple offers, trivial quests and legacy greetings')
`);
run(`
playerFaction='Alliance'; reset(); G.SelectGuide('wc'); G.ClearNavigation()
local added,removed=0,0
TomTom={AddWaypoint=function(self,map,x,y,options) added=added+1; assert(not options.persistent); return {id=added} end,
 RemoveWaypoint=function(self,uid) removed=removed+1 end,SetCrazyArrow=function() end}
G.db.index=2
local mapAPI=C_Map
C_Map={GetBestMapForUnit=function() return 1 end,GetMapInfo=function() return {mapID=1,name='The Barrens'} end}
G.SyncNavigation(); assert(added==0,'Navigation must start off')
G.db.options.arrow=true; G.db.options.useTomTom=true
G.SyncNavigation(); assert(added==1)
G.SyncNavigation(); assert(added==1,'No duplicate waypoint on refresh')
G.db.index=3; G.SyncNavigation(); assert(added==2 and removed==1)
G.db.index=9; G.SyncNavigation(); assert(removed==2,'No-pin step clears previous destination')
G.db.index=2; G.SyncNavigation(); assert(added==3)
G.db.options.arrow=false; G.SyncNavigation(); assert(removed==3)
-- Built-in direction uses world coordinates, supports cross-zone travel on one continent.
TomTom=nil; G.db.options.arrow=true; G.db.options.useTomTom=false
math.atan2=math.atan2 or math.atan
CreateVector2D=function(x,y) return {x=x,y=y,GetXY=function(self) return self.x,self.y end} end
local continent=1
C_Map.GetPlayerMapPosition=function() return CreateVector2D(0,0) end
C_Map.GetWorldPosFromMapPos=function(map,pos) return continent,CreateVector2D(pos.y*1000,pos.x*1000) end
GetPlayerFacing=function() return 0 end
IsInInstance=function() return false end
G.SyncNavigation(true)
local angle,distance=G.NavigationVector()
assert(angle and distance>0)
IsInInstance=function() return true end
assert(G.NavigationVector()==nil,'No outdoor arrow inside an instance')
IsInInstance=function() return false end
G.db.index=#G.steps+1; G.SyncNavigation(); assert(G.NavigationVector()==nil)
C_Map=mapAPI
print('PASS: arrow default off, TomTom ownership, waypoint changes, no-pin/end cleanup, built-in world direction and instance fallback')
`);

run(`
playerFaction='Alliance'; reset(); UIParent:SetSize(800,600)
for _,side in ipairs({'Alliance','Horde'}) do
 G.SelectFaction(side)
 for _,key in ipairs(G.catalogOrder) do
  G.SelectGuide(key); G.SetView('overview')
  for _,row in ipairs(G.OverviewRows(true)) do G.OpenQuestInfo(row.id) end
  G.OpenQuestInfo(0)
  G.SetMinimized(true); assert(G.db.minimized)
  G.SetMinimized(false); assert(not G.db.minimized)
  G.SetView('guide'); assert(G.db.view=='guide')
 end
end
print('PASS: new overview/details handlers for all dungeon/faction selections, minimize/expand and guide tabs at 800x600')
`);
