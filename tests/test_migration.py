from pathlib import Path
import sys,json
root=Path(__file__).resolve().parents[1]
work=Path(__file__).resolve().parent
from lupa.lua51 import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute('''G={}; OLD={}; SlashCmdList={}
CreateFrame=function() return {RegisterEvent=function()end,SetScript=function()end} end
faction='Alliance'; class=8
UnitFactionGroup=function()return faction end
UnitClass=function()return 'Mage','MAGE',class end
UnitRace=function()return 'Human','Human',faction=='Alliance' and 1 or 2 end
UnitLevel=function()return 30 end
C_QuestLog={IsOnQuest=function()return false end,IsComplete=function()return false end,IsQuestFlaggedCompleted=function()return false end}
''')
for addon,ns in [(work/'fixtures/1.2.1/ChasmGuide','OLD'),(root/'ChasmGuide','G')]:
    for name in (addon/'ChasmGuide.toc').read_text().splitlines():
        if name.endswith('.lua'):
            lua.execute('(function(...)\n'+(addon/name).read_text(encoding='utf-8-sig')+"\nend)('ChasmGuide',"+ns+")")
lua.execute((work/'migration.lua').read_text())
