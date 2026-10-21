local _, G = ...
-- Forever records checked on 2026-10-03. Sources and beta limits are in README.
local names = {
    [65]="The Defias Brotherhood", [132]="The Defias Brotherhood",
    [135]="The Defias Brotherhood", [141]="The Defias Brotherhood",
    [142]="The Defias Brotherhood", [155]="The Defias Brotherhood",
    [166]="The Defias Brotherhood", [214]="Red Silk Bandanas",
    [168]="Collecting Memories", [167]="Oh Brother...",
    [2040]="Underground Assault", [373]="The Unsent Letter",
    [92742]="Testing the Wells", [92744]="Murloc Gills",
    [92745]="The State of the Mines", [92747]="Moonbrook Espionage",
    [92748]="Explosive Consultation", [92749]="A Dynamite Plan",
    [92750]="Detonation at a Distance", [92751]="Detonation at a Distance",
    [92752]="Explosive Consultation", [92753]="Destruction in Deadmines",
    [92819]="Destruction in Deadmines", [1654]="The Test of Righteousness",
}
for id, name in pairs(names) do G.names[id] = name end
local chains = {
    {65,132,135,141,142,155,166},
    {92742,92744,92745,92747,92748,92749,92750,92751,92752,92753,92819},
}
for _, chain in ipairs(chains) do
    for i=1,#chain-1 do G.successors[chain[i]] = chain[i+1] end
end

local gryan = {zone="Westfall", x=.562, y=.476}
local alba = {zone="Westfall", x=.524, y=.530}
local riell = {zone="Westfall", x=.566, y=.474}
local steps = {}
local function Add(phase, title, kind, quests, where, text, pin)
    steps[#steps+1] = {phase=phase, title=title, kind=kind, quests=quests,
        where=where, text=text, pin=pin}
end
local function Defias(title, kind, id, where, text, pin)
    Add("Defias chain", title, kind, {id}, where, text, pin)
end
local function Toxic(title, kind, id, where, text, pin)
    Add("Toxic Soil", title, kind, {id}, where, text, pin)
end

Defias("Start The Defias Brotherhood", "accept", 65,
    "Westfall / Sentinel Hill / Gryan Stoutmantle",
    "This Alliance route includes both prerequisite chains. Accept The Defias Brotherhood from Gryan at level 14 or above. If you already have a later part, the guide recognizes it. This first part sends you to Wiley in Lakeshire.", gryan)
Defias("Speak to Wiley in Lakeshire", "accept", 132,
    "Redridge Mountains / Lakeshire inn / upstairs",
    "Turn in the first part to Wiley the Black upstairs at the inn. Accept his follow-up and carry Wiley's Note back to Gryan.",
    {zone="Redridge Mountains", x=.270, y=.450})
Defias("Bring Wiley's note to Gryan", "accept", 135,
    "Westfall / Sentinel Hill / Gryan Stoutmantle",
    "Turn in Wiley's delivery and accept the next part. Gryan now sends you to Mathias Shaw in Stormwind.", gryan)
Defias("Ask Mathias Shaw about the Defias", "accept", 141,
    "Stormwind / Old Town / SI:7 / upstairs",
    "Give Wiley's Note to Mathias Shaw. Accept the follow-up with Shaw's Report for Gryan. Use the building's stairs to reach Shaw.")
Defias("Return Shaw's report", "accept", 142,
    "Westfall / Sentinel Hill / Gryan Stoutmantle",
    "Turn in Shaw's Report and accept the part that asks you to intercept the Defias Messenger.", gryan)
Defias("Intercept the Defias Messenger", "complete", 142,
    "Westfall / Moonbrook and the roads toward the northern mines",
    "Find and kill the Defias Messenger, then loot A Mysterious Message. Check the live quest marker near Moonbrook's blacksmith first. Older routes describe a patrol along the roads toward Gold Coast Quarry and Jangolode Mine.")
Defias("Deliver the messenger's message", "turnin", 142,
    "Westfall / Sentinel Hill / Gryan Stoutmantle",
    "Give Gryan A Mysterious Message. The next quest comes from the Defias Traitor nearby.", gryan)
Defias("Accept the traitor escort", "accept", 155,
    "Westfall / Sentinel Hill / Defias Traitor near the tower",
    "Accept The Defias Brotherhood from the Defias Traitor. Gather help before starting. If he is away escorting another group, wait for him to return.", gryan)
Defias("Protect the Defias Traitor", "complete", 155,
    "Westfall / Sentinel Hill to Moonbrook",
    "Stay close and defend the traitor until he reveals the hideout. Watch the enemies around Moonbrook's fountain. Wait for the escort objective to complete, then return to Gryan.")
Defias("Accept the VanCleef quest", "accept", 166,
    "Westfall / Sentinel Hill / Gryan Stoutmantle",
    "Turn in the completed escort and accept the final Defias Brotherhood quest. Check that its objective asks for Edwin VanCleef's head.", gryan)
Add("Prepare", "Pick up Red Silk Bandanas", "accept", {214},
    "Westfall / Sentinel Hill tower / Scout Riell",
    "Accept Red Silk Bandanas from Scout Riell after turning in the escort. You need ten silk bandanas from Defias enemies in the dungeon.", riell)

Toxic("Start Testing the Wells", "accept", 92742,
    "Westfall / Sentinel Hill inn / Alba Fairmoon",
    "Accept Testing the Wells from Alba and keep the Well Water Sample Kit. This begins the Forever chain for Destruction in Deadmines.", alba)
Toxic("Sample both farm wells", "complete", 92742,
    "Westfall / Molsen Farm, 46.2, 38.3 / Jansen Stead, 56.7, 18.7",
    "Use the Well Water Sample Kit at both farm wells. Check that both water samples are collected before returning to Alba.")
Toxic("Return the samples and accept Murloc Gills", "accept", 92744,
    "Westfall / Sentinel Hill inn / Alba Fairmoon",
    "Turn in Testing the Wells and accept Murloc Gills.", alba)
Toxic("Collect seven Longshore Murloc Gills", "complete", 92744,
    "Westfall / shoreline",
    "Kill and loot murlocs along the coast until you have seven Longshore Murloc Gills. Return to Alba when the objective is complete.")
Toxic("Accept The State of the Mines", "accept", 92745,
    "Westfall / Sentinel Hill inn / Alba Fairmoon",
    "Turn in Murloc Gills and accept The State of the Mines.", alba)
Toxic("Disrupt both mining camps", "complete", 92745,
    "Westfall / Jangolode Mine and Gold Coast Quarry",
    "Kill four Kobold Diggers in Jangolode Mine and six Riverpaw Miners in Gold Coast Quarry. Both objectives must be complete.")
Toxic("Accept Moonbrook Espionage", "accept", 92747,
    "Westfall / Sentinel Hill inn / Alba Fairmoon",
    "Turn in The State of the Mines and accept Moonbrook Espionage.", alba)
Toxic("Collect the suspicious supplies", "complete", 92747,
    "Westfall / Moonbrook buildings and entrance tunnels",
    "Collect eight Suspicious Industrial Supplies from crates around Moonbrook. Search the buildings and schoolhouse first; crates also appear in the tunnels toward the Deadmines.")
Toxic("Ask Alba about explosives", "accept", 92748,
    "Westfall / Sentinel Hill inn / Alba Fairmoon",
    "Turn in Moonbrook Espionage and accept Explosive Consultation. Travel to Sprite Jumpsprocket in Stormwind's Dwarven District.", alba)
Toxic("Meet Sprite Jumpsprocket", "accept", 92749,
    "Stormwind / Dwarven District / engineering shop",
    "Turn in Explosive Consultation to Sprite Jumpsprocket and accept A Dynamite Plan. Check the live objective for the exact dynamite type before buying or crafting any.")
Toxic("Supply Sprite with dynamite", "complete", 92749,
    "Stormwind / crafting, trading or auction house",
    "Obtain ten of the dynamite named in your live quest objective. October 1 beta reports say Rough Dynamite replaced Coarse Dynamite, while older quest text still says Coarse. If Sprite already offers Detonation at a Distance, accept it to continue.")
Toxic("Accept Detonation at a Distance", "accept", 92750,
    "Stormwind / Dwarven District / Sprite Jumpsprocket",
    "Turn in A Dynamite Plan if required and accept Detonation at a Distance. Sprite sends you to Stormwind Intelligence for a remote detonator.")
Toxic("Collect the remote detonator kit", "accept", 92751,
    "Stormwind / Old Town / SI:7 / Jasper Fel",
    "Turn in Detonation at a Distance to Jasper Fel. Accept the second quest with the same name and take the Remote Detonator Kit back to Sprite.")
Toxic("Take the kit to Sprite", "accept", 92752,
    "Stormwind / Dwarven District / Sprite Jumpsprocket",
    "Deliver the Remote Detonator Kit. Accept Explosive Consultation, the return trip to Alba, and keep the Extra-Destructive Explosives.")
Add("Prepare", "Collect Wilder's two quests", "accept", {168,167},
    "Stormwind / Dwarven District / Wilder Thistlenettle",
    "Accept Collecting Memories and Oh Brother... from Wilder. Their minimum levels are 14 and 15. Both objectives are in the undead side tunnels before the instance portal. Stormwind coordinates differ across published maps, so use the NPC name and district.")
Add("Prepare", "Collect Underground Assault", "accept", {2040},
    "Stormwind / Dwarven District / Shoni the Shilent",
    "Accept Underground Assault from Shoni at level 15 or above. It asks for the Gnoam Sprecklesprocket from Sneed's Shredder.")
Add("Prepare", "Optional paladin quest preparation", "manual", nil,
    "Paladins / level 20 / Jordan Stilwell outside Ironforge",
    "For The Test of Righteousness, finish the Tome of Valor chain and accept Jordan's material-collection quest before the run. Deadmines supplies the Whitestone Oak Lumber. Other classes can click Next. This guide covers the Deadmines portion; the class chain also visits other zones.")
Toxic("Accept Destruction in Deadmines", "accept", 92753,
    "Westfall / Sentinel Hill inn / Alba Fairmoon",
    "Turn in the return trip of Explosive Consultation and accept Destruction in Deadmines. Confirm the Extra-Destructive Explosives are in your bags before leaving.", alba)
Add("Outer mines", "Gather your party at Moonbrook", "manual", nil,
    "Westfall / Moonbrook / building leading underground",
    "Bring a five-player group, usually around levels 18 to 22. Tell them you need the undead side tunnels before entering the instance. Follow the mine passages to that branch, then click Next.")
Add("Outer mines", "Collect the miners' cards and badge", "complete", {168,167},
    "Deadmines outer tunnels / undead branch / before the portal",
    "Loot undead miners for four Miners' Union Cards. Find Foreman Thistlenettle in the same branch and loot his badge. Finish both objectives before entering the instance.")
Add("Dungeon", "Check your quests and enter", "manual", nil,
    "Deadmines / instance portal",
    "Confirm the dungeon quests below and keep collecting silk bandanas throughout the run. Paladins should have their lumber quest. Enter the instance, then click Next.")
steps[#steps].checklist = {166,214,2040,92753}
Add("Dungeon", "Clear Rhahk'Zor's room", "manual", nil,
    "Deadmines / first boss",
    "Defeat Rhahk'Zor and continue through the opened door with your party. Click Next when you reach the lumber area.")
Add("Dungeon", "Optional paladin lumber", "manual", nil,
    "Deadmines / lumber area / Goblin Woodcarvers",
    "Paladins on The Test of Righteousness should kill and loot Goblin Woodcarvers for Whitestone Oak Lumber. Check the item in your bags. Click Next when collected, or if the class quest does not apply.")
Add("Dungeon", "Recover the shredder's power supply", "complete", {2040},
    "Deadmines / Sneed's Shredder",
    "Defeat the shredder and Sneed, then loot the shredder for the Gnoam Sprecklesprocket. Check Underground Assault is ready before moving on.")
Toxic("Plant explosives at the foundry", "complete", 92753,
    "Deadmines / Gilnid's forge room",
    "Clear Gilnid's room. Move near the central forge and use the Extra-Destructive Explosives. Confirm Explosives placed in your log. You will detonate them with Alba outside after the run.")
Add("Dungeon", "Reach VanCleef's ship", "manual", nil,
    "Deadmines / Ironclad Cove",
    "Continue with your group through the remaining doors and onto the ship. Clear the route through Mr. Smite and Captain Greenskin. Keep looting Defias for silk bandanas. Click Next at VanCleef.")
Add("Dungeon", "Defeat VanCleef and collect his head", "complete", {166},
    "Deadmines / ship / Edwin VanCleef",
    "Defeat Edwin VanCleef and loot his head for The Defias Brotherhood. Also look for An Unsent Letter on his body before leaving.")
Add("Dungeon", "Read An Unsent Letter", "accept", {373},
    "Deadmines / VanCleef's loot / your bags",
    "Loot An Unsent Letter from VanCleef and use it to accept The Unsent Letter. It requires level 16 and sends you to Baros Alexston in Stormwind.")
Add("Dungeon", "Finish collecting silk bandanas", "complete", {214},
    "Deadmines / remaining Defias enemies",
    "Check that you have ten Red Silk Bandanas. Clear any remaining Defias needed before your group leaves.")
Add("Dungeon", "Use the back exit", "manual", nil,
    "Deadmines / passage beyond the ship / back exit",
    "Confirm the objectives below, then use the dungeon's back exit to meet Alba in the hills behind Moonbrook. Do not hearth away before her turn-in. Click Next outside.")
steps[#steps].checklist = {166,214,2040,92753,373}
Toxic("Meet Alba outside the dungeon", "accept", 92819,
    "Westfall / hills behind Moonbrook / Deadmines back exit",
    "Find Alba near the back exit, around 38.6, 83.6. Turn in the explosives-placement quest and accept the second Destruction in Deadmines quest. This one asks you to use the detonator.",
    {zone="Westfall", x=.386, y=.836})
Toxic("Use the detonator", "complete", 92819,
    "Westfall / Deadmines back exit / near Alba",
    "Interact with the detonator and let the event play. Wait for the Detonator used objective to complete.")
Toxic("Finish Destruction in Deadmines", "turnin", 92819,
    "Westfall / Deadmines back exit / Alba Fairmoon",
    "Speak to Alba again and turn in the final Destruction in Deadmines quest.")
Add("Turn in", "Return VanCleef's head", "turnin", {166},
    "Westfall / Sentinel Hill / Gryan Stoutmantle",
    "Turn in the final Defias Brotherhood quest to Gryan and choose your reward.", gryan)
Add("Turn in", "Give Riell the silk bandanas", "turnin", {214},
    "Westfall / Sentinel Hill tower / Scout Riell",
    "Turn in all ten Red Silk Bandanas to Scout Riell.", riell)
Add("Turn in", "Return Wilder's keepsakes", "turnin", {168,167},
    "Stormwind / Dwarven District / Wilder Thistlenettle",
    "Turn in Collecting Memories and Oh Brother... to Wilder. Both turn-ins must be confirmed.")
Add("Turn in", "Deliver the Gnoam Sprecklesprocket", "turnin", {2040},
    "Stormwind / Dwarven District / Shoni the Shilent",
    "Turn in Underground Assault to Shoni and choose your reward.")
Add("Turn in", "Deliver VanCleef's letter", "turnin", {373},
    "Stormwind / Cathedral Square / City Hall / Baros Alexston",
    "Turn in The Unsent Letter to Baros Alexston. His follow-up starts the Stockades storyline. This Deadmines guide ends after the letter delivery; it does not cover the later Seal of Wrynn chain.")
Add("Follow up", "Paladins: keep the lumber for Jordan", "manual", nil,
    "The Test of Righteousness / Jordan Stilwell",
    "Keep the Whitestone Oak Lumber. Jordan also needs his hammer from Shadowfang Keep, the refined ore shipment and the purified gem. Finish those objectives before returning to him outside Ironforge. Click Next to finish this dungeon guide.")

G.guides.deadmines = {
    title="The Deadmines", faction="Alliance", steps=steps,
    finalQuests={168,167,2040,166,214,373,92819},
}
