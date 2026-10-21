local _, G = ...
-- Forever quest records checked on 2026-10-04. Sources are in README.
local names = {
    [865]="Raptor Horns", [959]="Trouble at the Docks",
    [1491]="Smart Drinks", [1486]="Deviate Hides",
    [1487]="Deviate Eradication", [6981]="The Glowing Shard",
    [3370]="In Nightmares",
}
for id, name in pairs(names) do G.names[id] = name end
G.successors[865] = 1491
G.successors[6981] = 3370

local mebok = {zone="The Barrens", x=.624, y=.376}
local docks = {zone="The Barrens", x=.630, y=.376}
local cave = {zone="The Barrens", x=.464, y=.337}
local falla = {zone="The Barrens", x=.482, y=.328}
local steps = {}
local function Add(phase, title, kind, quests, where, text, pin)
    steps[#steps+1] = {phase=phase, title=title, kind=kind, quests=quests,
        where=where, text=text, pin=pin}
end

Add("Prepare", "Alliance: prepare for Wailing Caverns", "manual", nil,
    "The Barrens / Ratchet",
    "This Alliance route covers five shared dungeon quests, the Smart Drinks prerequisite and the Darnassus follow-up. Level 15 meets all pickup minimums. Bring a dungeon group. Ratchet is neutral. Avoid Horde settlements on your journey. Click Next when ready.", docks)
Add("Prepare", "Pick up Trouble at the Docks", "accept", {959},
    "Ratchet / Crane Operator Bigglefuzz / docks",
    "Accept Trouble at the Docks. Bigglefuzz needs the stolen bottle of 99-Year-Old Port from Mad Magglish in the outer caverns.", docks)
Add("Prepare", "Start Raptor Horns", "accept", {865},
    "Ratchet / Mebok Mizzyrix / near the bank",
    "Accept Raptor Horns from Mebok. This prerequisite unlocks Smart Drinks. If Smart Drinks is already in your log or completed, the guide passes these prerequisite steps.", mebok)
Add("Prepare", "Collect five intact horns", "complete", {865},
    "The Barrens / Raptor Grounds",
    "Kill Sunscale Scytheclaws and loot five Intact Raptor Horns. Search the Raptor Grounds southeast of the Crossroads, near 57, 53. Stay outside the Horde settlement.",
    {zone="The Barrens", x=.570, y=.530})
Add("Prepare", "Return the horns", "turnin", {865},
    "Ratchet / Mebok Mizzyrix",
    "Turn in Raptor Horns to Mebok before picking up his dungeon quest.", mebok)
Add("Prepare", "Pick up Smart Drinks", "accept", {1491},
    "Ratchet / Mebok Mizzyrix",
    "Accept Smart Drinks. Collect six Wailing Essence from ectoplasm creatures while clearing the caverns.", mebok)
Add("Prepare", "Find Nalpak above the cave entrance", "accept", {1486},
    "Wailing Caverns / small cave above the skull-shaped entrance",
    "Climb the hill behind the entrance and drop onto the ledge above its left eye as you face the skull. Nalpak and Ebru are in the small cave there. Accept Deviate Hides from Nalpak. Loot deviate beasts for 20 hides.", cave)
Add("Prepare", "Pick up Deviate Eradication", "accept", {1487},
    "Wailing Caverns / Ebru / same small cave as Nalpak",
    "Accept Deviate Eradication. You need seven kills of each type: Deviate Ravager, Deviate Viper, Deviate Shambler and Deviate Dreadfang.", cave)
Add("Outer caves", "Find Mad Magglish", "complete", {959},
    "Wailing Caverns / outer tunnels before the instance portal",
    "Search the side alcoves for Mad Magglish. Check along the right wall first. He can be stealthed, so look closely near the rocks. Kill him and loot the 99-Year-Old Port. If he is absent, check the other nearby alcoves or wait for his respawn.")
Add("Dungeon", "Enter with your group", "manual", nil,
    "Wailing Caverns / instance portal",
    "Check your four pickups below. Keep looting beasts for hides and ectoplasms for essence throughout the run. Follow your group's path through the dungeon. Click Next after entering.")
steps[#steps].checklist = {959,1491,1486,1487}
Add("Dungeon", "Defeat the four Fang leaders", "manual", nil,
    "Wailing Caverns / both main branches",
    "Defeat Lady Anacondra, Lord Cobrahn, Lord Pythas and Lord Serpentis. All four must die before the Naralex escort can start. Alliance does not need the Horde quest Leaders of the Fang. Click Next after checking all four with your group.")
Add("Dungeon", "Finish the eradication kills", "complete", {1487},
    "Wailing Caverns / deviate creature packs",
    "Check all four kill counters before leaving these branches. Finish seven Ravagers, seven Vipers, seven Shamblers and seven Dreadfangs. If your group cannot finish a counter this run, Next skips this step without marking the quest complete.")
Add("Dungeon", "Escort the Disciple of Naralex", "manual", nil,
    "Wailing Caverns / return to the disciple near the instance entrance",
    "After the four Fang leaders are dead, speak to the Disciple of Naralex and start his escort. Stay with him and defend him through the ritual waves until Mutanus appears. Click Next after your group defeats Mutanus the Devourer.")
Add("Dungeon", "Loot and use the Glowing Shard", "accept", {6981},
    "Wailing Caverns / Mutanus the Devourer",
    "Loot the Glowing Shard from Mutanus and right-click it in your bags to accept The Glowing Shard. Keep it for the journey to Ratchet and Falla Sagewind.")
Add("Dungeon", "Check your Wailing Essence", "complete", {1491},
    "Wailing Caverns / ectoplasm creatures",
    "You need six Wailing Essence. Check the quest counter and kill more ectoplasms if needed. Both the outer caves and the instance have suitable creatures. Use Next if you need to finish this on another visit.")
Add("Dungeon", "Check your 20 hides", "complete", {1486},
    "Wailing Caverns / deviate beasts inside and outside the instance",
    "Collect 20 Deviate Hides. One run may not provide enough. Farm remaining beasts with your group or keep the quest for another visit. Use Next to continue to other turn-ins if you are short.")
Add("Turn in", "Leave the instance", "manual", nil,
    "Wailing Caverns / return to the outer entrance",
    "Confirm you looted Mutanus before leaving. Check the port, essence, hide and kill objectives below. Click Next when you are back outside the instance.")
steps[#steps].checklist = {959,1491,1486,1487,6981}
Add("Turn in", "Return to Ebru", "turnin", {1487},
    "Wailing Caverns / small cave above the skull entrance",
    "Turn in Deviate Eradication to Ebru. If any kill counter is unfinished, keep the quest and click Next to visit the other quest givers.", cave)
Add("Turn in", "Give Nalpak the hides", "turnin", {1486},
    "Wailing Caverns / Nalpak / same small cave as Ebru",
    "Turn in Deviate Hides when you have all 20. If you still need hides, click Next and return to Nalpak after collecting the rest.", cave)
Add("Turn in", "Return the stolen port", "turnin", {959},
    "Ratchet / Crane Operator Bigglefuzz",
    "Give Bigglefuzz the 99-Year-Old Port to complete Trouble at the Docks.", docks)
Add("Turn in", "Deliver the Wailing Essence", "turnin", {1491},
    "Ratchet / Mebok Mizzyrix",
    "Turn in Smart Drinks to Mebok with six Wailing Essence. If it is unfinished, use Next to continue the shard chain.", mebok)
Add("Shard chain", "Ask Sputtervalve about the shard", "complete", {6981},
    "Ratchet / Sputtervalve / near the flight master",
    "Talk to Sputtervalve and choose his dialogue about the Glowing Shard. He may have no quest marker for it. Finish the conversation before going to Falla. This completes the Ratchet objective, not the quest turn-in.",
    {zone="The Barrens", x=.630, y=.372})
Add("Shard chain", "Take the shard to Falla Sagewind", "turnin", {6981},
    "The Barrens / hilltop above Wailing Caverns",
    "Find Falla at the hilltop camp near 48.2, 32.8 and turn in The Glowing Shard. She is above the caverns, separate from Nalpak and Ebru's small cave.", falla)
Add("Shard chain", "Accept the Alliance follow-up", "accept", {3370},
    "The Barrens / Falla Sagewind",
    "Accept In Nightmares from Falla and keep the Nightmare Shard. The Alliance quest sends you to Mathrengyl Bearwalker in Darnassus.", falla)
Add("Shard chain", "Deliver the Nightmare Shard", "turnin", {3370},
    "Darnassus / Cenarion Enclave / Mathrengyl Bearwalker",
    "Travel to Darnassus and find Mathrengyl Bearwalker in the Cenarion Enclave. Turn in In Nightmares and choose your reward. Check any unfinished dungeon turn-ins on the guide's end screen.")

G.guides.wc = {
    title="Wailing Caverns", faction="Alliance", steps=steps,
    finalQuests={959,1491,1486,1487,3370},
}
