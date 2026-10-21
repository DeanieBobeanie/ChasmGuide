local _, G = ...
-- New Forever quest records checked on 2026-10-04; see README sources.
local names={
    [95697]="Changing Tastes",[95663]="Dragonmaw Rumors",[95682]="Open the Maw",
    [95664]="Elder Knowledge",[98823]="Earthen Echo",[98815]="Highland Hides",
    [95772]="Songblade Search",[95795]="Fallen in the Fen",[95646]="Horrors in the Highland",
    [95737]="Seeking Caitlin",[95647]="Lost in the Thicket Things",[95809]="Heartwoven",
    [95810]="Lost Relic Carry",[98824]="Prehistoric Prism",
    [92456]="A Green Sample",[92489]="Power Overwhelming",[96987]="Opportunistic Education",
    [96988]="Source of Power",[96986]="The Grave Knight",
}
for id,name in pairs(names) do G.names[id]=name end
for id,nextID in pairs({[95664]=98823,[95772]=95795,[95647]=95809,[95810]=98824}) do
    G.successors[id]=nextID
end
local function Build(faction)
    local steps={}
    local function Add(phase,title,kind,id,where,text,zone,x,y)
        steps[#steps+1]={phase=phase,title=title,kind=kind,quests=id and {id} or nil,where=where,text=text,
            pin=zone and {zone=zone,x=x,y=y} or nil}
    end
    Add("Prepare","Prepare for Excavation Site","manual",nil,"Wetlands / hills above Whelgar's Excavation Site",
        "Gather a dungeon group. Quests start at 24, but Wowhead's updated overview recommends levels 26-32 and lists the final boss at 31. Use Quest info for the difficulty tables and beta source differences.")
    if faction=="Alliance" then
        Add("Prepare","Check the Highland Hides prerequisite","manual",nil,"Menethil Harbor / James Halloran",
            "Ask James Halloran about Highland Hides. Wowhead's guide names Daily Delivery as a prerequisite, but quest-page reports instead name Young Crocolisk Skins and call the delivery optional. Check James's available quests before making the detour. Click Next to continue.","Wetlands",.086,.556)
        Add("Prepare","Accept Highland Hides","accept",98815,"Menethil Harbor / James Halloran",
            "Accept the quest for four Thicket Raptor Hides.","Wetlands",.080,.550)
        Add("Prepare","Optional: Seeking Caitlin","manual",nil,"Ashenvale / Llana",
            "If you are in Ashenvale, Llana offers the breadcrumb Seeking Caitlin at 35.0, 48.6. Deliver it to Caitlin in Menethil. You can go directly to Caitlin without this detour.","Ashenvale",.350,.486)
        steps[#steps].checklist={95737}
        Add("Prepare","Accept Lost in the Thicket Things","accept",95647,"Menethil Harbor / Caitlin Grassman",
            "Ask Caitlin about her missing husband Ardin.","Wetlands",.118,.586)
        Add("Prepare","Accept Songblade Search","accept",95772,"Lakeshire / Dorin Songblade",
            "Dorin asks you to find his brother Daewyn at the excavation.","Redridge Mountains",.256,.466)
        Add("Prepare","Check the Greenwarden prerequisite","manual",nil,"Wetlands / Rethiel the Greenwarden",
            "Complete the chain starting with The Greenwarden from First Mate Fitzsimmons through Blisters on The Land. Then return to Rethiel for the dungeon quest.","Wetlands",.562,.406)
        Add("Prepare","Accept Horrors in the Highland","accept",95646,"Wetlands / Rethiel the Greenwarden",
            "Accept the quest for a Horrible Rootcore.","Wetlands",.562,.406)
    else
        Add("Prepare","Accept Changing Tastes","accept",95697,"Orgrimmar / The Drag / Borstan",
            "Accept Borstan's quest for four Thicket Raptor Meat.","Orgrimmar",.575,.534)
        Add("Prepare","Check Dragonmaw Rumors","manual",nil,"Wetlands / hills above the Dragonmaw camp",
            "If you have Dragonmaw Rumors, deliver it to the Deathstalker Agent near the dungeon approach. Its starting NPC is not verified here. Ask the agent directly about Open the Maw if you do not have the breadcrumb.")
        steps[#steps].checklist={95663}
        Add("Prepare","Accept Open the Maw","accept",95682,"Wetlands / Deathstalker Agent near the dungeon approach",
            "Speak to the agent in the hills and accept Open the Maw. Follow your live quest marker if her beta position differs.")
    end
    Add("Dungeon","Enter the Excavation Site","manual",nil,"Wetlands / above Whelgar's Excavation Site",
        "Follow the uphill road from 47.8, 56.3 toward the meeting stone and entry at 53.4, 65.3. Enter with your group, loot the raptors and check quest objects as you go. Click Next inside.","Wetlands",.478,.563)
    if faction=="Alliance" then
        Add("Dungeon","Collect four Thicket Raptor Hides","complete",98815,"Excavation Site / Thicket Raptors","Loot four hides for James Halloran.")
        Add("Dungeon","Collect the Horrible Rootcore","complete",95646,"Excavation Site / Highland Horror","Kill a Highland Horror and loot its root core.")
        Add("Dungeon","Find Daewyn Songblade","turnin",95772,"Excavation Site / Daewyn Songblade","Find Dorin's brother and finish Songblade Search at his body.")
        Add("Dungeon","Accept Fallen in the Fen","accept",95795,"Excavation Site / Daewyn Songblade","Accept the follow-up to report Daewyn's fate to Dorin in Lakeshire.")
        Add("Dungeon","Find Ardin Grassman","turnin",95647,"Excavation Site / Ardin Grassman","Find Ardin and learn what happened. Finish Caitlin's search quest with him.")
        Add("Dungeon","Accept Heartwoven","accept",95809,"Excavation Site / Ardin Grassman","Accept Heartwoven and keep the Reed-woven Heart for Caitlin.")
    else
        Add("Dungeon","Collect four Thicket Raptor Meat","complete",95697,"Excavation Site / Thicket Raptors","Loot four pieces of meat for Borstan.")
        Add("Dungeon","Clear the Dragonmaw forces","complete",95682,"Excavation Site / Dragonmaw forces","Kill two Dragonmaw Saboteurs and four Warders. Loot a Dragonmaw Dispatch.")
    end
    Add("Dungeon","Defeat the Relic Guardian","manual",nil,"Excavation Site / final boss",
        "Defeat the Relic Guardian with your group and loot the Titan Relic. Use it to start your faction's quest. Keep the relic for its follow-up.")
    local relic=faction=="Alliance" and 95810 or 95664
    Add("Dungeon","Accept "..names[relic],"accept",relic,"Excavation Site / Titan Relic in your bags",
        "Right-click the Titan Relic and accept the quest. Check your dungeon objectives before leaving.")
    if faction=="Alliance" then
        Add("Turn in","Deliver the relic to Whelgar","turnin",95810,"Wetlands / Prospector Whelgar","Return to Whelgar at the excavation site with the Titan Relic.")
        Add("Turn in","Accept Prehistoric Prism","accept",98824,"Wetlands / Prospector Whelgar","Accept the delivery to High Explorer Magellas. Check that you have the relic before travelling.")
        Add("Turn in","Return the root core","turnin",95646,"Wetlands / Rethiel the Greenwarden","Deliver the Horrible Rootcore.","Wetlands",.562,.406)
        Add("Turn in","Return the raptor hides","turnin",98815,"Menethil Harbor / James Halloran","Deliver four Thicket Raptor Hides.","Wetlands",.080,.550)
        Add("Turn in","Deliver the Reed-woven Heart","turnin",95809,"Menethil Harbor / Caitlin Grassman","Give Caitlin the heart from Ardin and choose your reward.","Wetlands",.118,.586)
        Add("Turn in","Report Daewyn's fate","turnin",95795,"Lakeshire / Dorin Songblade","Finish Fallen in the Fen with Dorin.","Redridge Mountains",.256,.466)
        Add("Turn in","Deliver the prism to Magellas","turnin",98824,"Ironforge / Hall of Explorers / High Explorer Magellas","Finish Prehistoric Prism and select your reward.")
    else
        Add("Turn in","Return to the Deathstalker Agent","turnin",95682,"Wetlands / Deathstalker Agent / hills near the entrance","Deliver the dispatch and finish Open the Maw.")
        Add("Turn in","Return the raptor meat","turnin",95697,"Orgrimmar / Borstan","Deliver four Thicket Raptor Meat.","Orgrimmar",.575,.534)
        Add("Turn in","Deliver the relic to Bashana","turnin",95664,"Thunder Bluff / Elder Rise / Bashana Runetotem","Ask Bashana about the Titan Relic and finish Elder Knowledge.")
        Add("Turn in","Accept Earthen Echo","accept",98823,"Thunder Bluff / Bashana Runetotem","Accept Earthen Echo. Verify that the Titan Relic is in your bags before leaving. Beta reports have described missing relics; check the live quest before changing it.")
        Add("Turn in","Take the relic to Muln","turnin",98823,"Mulgore / Skywatcher Plateau / Muln Earthfury","Travel to the plateau in northwest Mulgore and give Muln the Titan Relic.")
    end
    return {title="Excavation Site: Wetlands",faction=faction,steps=steps,
        finalQuests=faction=="Alliance" and {98815,95646,95795,95809,98824} or {95682,95697,98823}}
end
G.guides.excavation=Build("Alliance")
G.guides.excavation.routes={Horde=Build("Horde")}

-- Dalaran has server-recorded quests, but its opening date and entrances may change.
G.catalog.dalaran.unpublished=nil
G.catalog.dalaran.quests={92456,92489,96987,96988,96986}
local dalaran={
    {92456,"Alliance","Stormwind / Shylamiir","Fel Infused Blossom from the central garden"},
    {92489,"Alliance","Stormwind / High Sorcerer Andromath","Arcanic Enigma, the mana elemental"},
    {96987,"Horde","Dalaran / sewer entrance / Rexxie Copperclutch","The Founding of Dalaran"},
    {96988,"Horde","Undercity / Doctor Martin Felben","Six Cracked Sentry Cores"},
    {96986,"Horde","Tarren Mill / Melisara","Atrexis the Grave Knight"},
}
for _,row in ipairs(dalaran) do
    local id,faction,where,objectives=row[1],row[2],row[3],row[4]
    G.questCatalog[id]={name=names[id],level=24,races=faction=="Alliance" and 4294967373 or 8589934770,
        classes=0,start={where=where,kind="Npc"},finish={where=where,kind="Npc"},objectives=objectives,
        all={},any={},exclusive={},skill={},rep={}}
end
