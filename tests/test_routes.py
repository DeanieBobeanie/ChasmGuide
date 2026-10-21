from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("G={}; SlashCmdList={}; CreateFrame=function() return {RegisterEvent=function() end, SetScript=function() end} end")
addon = root / 'ChasmGuide'
files = [line for line in (addon / 'ChasmGuide.toc').read_text().splitlines() if line.endswith('.lua')]
for name in files:
    lua.execute('(function(...)\n' + (addon / name).read_text(encoding='utf-8-sig') + "\nend)('ChasmGuide',G)")
print(f'PASS: TOC loads all {len(files)} files in native Lua 5.1', flush=True)
lua.execute((Path(__file__).parent / 'regression.lua').read_text())
