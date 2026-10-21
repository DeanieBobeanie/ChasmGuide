local _, G = ...
-- Additional quest records and prerequisites from the QuestieDB snapshot dated 2026-10-04.
local records = {
    [5526] = {["name"]="Shards of the Felvine",["level"]=56,["races"]=0,["classes"]=0,["start"]={["where"]="Moonglade / Rabine Saturna / 51.7, 45.1",["pin"]={["zone"]="Moonglade",["mapID"]=1450,["x"]=0.5169,["y"]=0.451},["kind"]="Npc"},["finish"]={["where"]="Moonglade / Rabine Saturna / 51.7, 45.1",["pin"]={["zone"]="Moonglade",["mapID"]=1450,["x"]=0.5169,["y"]=0.451},["kind"]="Npc"},["objectives"]="Sealed Reliquary of Purity",["all"]={},["any"]={5527},["exclusive"]={},["skill"]={},["rep"]={}},
    [5527] = {["name"]="A Reliquary of Purity",["level"]=56,["races"]=0,["classes"]=0,["start"]={["where"]="Moonglade / Rabine Saturna / 51.7, 45.1",["pin"]={["zone"]="Moonglade",["mapID"]=1450,["x"]=0.5169,["y"]=0.451},["kind"]="Npc"},["finish"]={["where"]="Moonglade / Rabine Saturna / 51.7, 45.1",["pin"]={["zone"]="Moonglade",["mapID"]=1450,["x"]=0.5169,["y"]=0.451},["kind"]="Npc"},["objectives"]="Reliquary of Purity",["all"]={},["any"]={},["exclusive"]={},["skill"]={},["rep"]={}},
    [7463] = {["name"]="Arcane Refreshment",["level"]=60,["races"]=0,["classes"]=128,["start"]={["where"]="Dire Maul / Lorekeeper Lydros",["kind"]="Npc"},["finish"]={["where"]="Dire Maul / Lorekeeper Lydros",["kind"]="Npc"},["objectives"]="Hydrospawn Essence",["all"]={},["any"]={},["exclusive"]={},["skill"]={},["rep"]={}},
}
for id,q in pairs(records) do
    if not G.questCatalog[id] then G.questCatalog[id]=q end
end
