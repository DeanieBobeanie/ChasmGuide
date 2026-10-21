local _, G = ...
-- Forever quest records checked on 2026-10-03. See README for sources.
G.names[1013] = "The Book of Ur"
G.names[1098] = "Deathstalkers in Shadowfang"
G.names[1014] = "Arugal Must Die"
G.names[1740] = "The Orb of Soran'ruk"
G.names[1654] = "The Test of Righteousness"

local classPrep = {
    phase="Prepare", title="Optional class quest preparation", kind="manual",
    where="Warlocks / Doan Karhan / The Barrens, 49, 57",
    text="Warlocks at level 20 can accept The Orb of Soran'ruk from Doan Karhan near Camp Taurajo. Bring it if you want the large fragment during this run. Other classes can click Next. Class reminders advance manually because these quests also need items outside Shadowfang Keep.",
}
local gate = {
    phase="Dungeon", title="Open the courtyard gate", kind="manual",
    where="Shadowfang Keep / prison cells / Rethilgore",
    text="Defeat Rethilgore, open Deathstalker Adamant's cell and speak to him. Ask him to open the courtyard door, then follow him. Click Next once the door opens.",
}
local fragment = {
    phase="Dungeon", title="Optional warlock fragment", kind="manual",
    where="Shadowfang Keep / rooms beyond the courtyard ramp",
    text="If you have The Orb of Soran'ruk, kill and loot Shadowfang Darksouls for one Large Soran'ruk Fragment. Check the item in your bags before moving on. Click Next when collected, or if this quest does not apply to you.",
}
local middle = {
    phase="Dungeon", title="Clear the dining hall and chapel", kind="manual",
    where="Shadowfang Keep / Razorclaw, Baron Silverlaine and Commander Springvale",
    text="Follow your party through these rooms. Clear patrols before each boss. Interrupt Springvale's healing and keep his guards away from your healer. Click Next when you reach the route to the ramparts.",
}
local ramparts = {
    phase="Dungeon", title="Pass Odo and enter the upper keep", kind="manual",
    where="Shadowfang Keep / Odo the Blindwatcher",
    text="Kill Odo's bats before the boss. Continue toward Fenrus. Click Next at Fenrus's room.",
}
local nandos = {
    phase="Dungeon", title="Defeat Wolf Master Nandos", kind="manual",
    where="Shadowfang Keep / upper keep",
    text="Clear the wolves before Nandos and deal with new wolves during the fight. Continue to Arugal's chamber, then click Next.",
}
local classFinish = {
    phase="Follow up", title="Finish optional class quests elsewhere", kind="manual",
    where="Warlocks / The Barrens / Paladins / Ironforge",
    text="Warlocks also need three Soran'ruk Fragments from Twilight Acolytes in Blackfathom Deeps, then return all fragments to Doan Karhan. Paladins need the other materials in Jordan's Weapon Notes before returning to Jordan Stilwell. Collecting the Shadowfang item alone does not finish either quest. Click Next to finish this guide.",
}

local steps = {
    {phase="Prepare", title="Pick up The Book of Ur", kind="accept", quests={1013},
     pin={zone="Undercity", x=.530, y=.540},
     where="Undercity / Apothecarium / Keeper Bel'dugur",
     text="Accept The Book of Ur from Keeper Bel'dugur. It requires level 16. The three regular Horde dungeon quests have no prerequisite chain; you can collect all three at level 18."},
    {phase="Prepare", title="Pick up Deathstalkers in Shadowfang", kind="accept", quests={1098},
     pin={zone="Silverpine Forest", x=.430, y=.410},
     where="Silverpine Forest / The Sepulcher / High Executor Hadrec",
     text="Accept Deathstalkers in Shadowfang from High Executor Hadrec below the Sepulcher. It requires level 18. You will turn it in inside the dungeon."},
    {phase="Prepare", title="Pick up Arugal Must Die", kind="accept", quests={1014},
     pin={zone="Silverpine Forest", x=.440, y=.390},
     where="Silverpine Forest / The Sepulcher / Dalar Dawnweaver",
     text="Accept Arugal Must Die from Dalar Dawnweaver. It requires level 18. Save bag space for the final boss's head and the Book of Ur."},
    classPrep,
    {phase="Dungeon", title="Check your quests and enter", kind="manual", checklist={1013,1098,1014},
     where="Silverpine Forest / hill above Pyrewood Village",
     text="Head south from the Sepulcher and take the path up to the keep above Pyrewood Village. Bring a five-player group, preferably around level 23 or higher. Confirm the three quests below and enter. Click Next inside."},
    gate,
    {phase="Turn in", title="Find Deathstalker Vincent", kind="turnin", quests={1098},
     where="Shadowfang Keep / courtyard / just beyond the opened gate",
     text="Clear the enemies near Vincent's body, to the right as you enter the courtyard. Interact with his corpse and turn in Deathstalkers in Shadowfang here. Check that you received the reward before continuing."},
    fragment,
    middle,
    ramparts,
    {phase="Dungeon", title="Recover the Book of Ur", kind="complete", quests={1013},
     where="Shadowfang Keep / Fenrus the Devourer's room / bookshelves",
     text="Defeat Fenrus and the enemies that appear afterward. Look on the shelves to the left as you enter and loot the Book of Ur. Each quest holder needs their own copy. If it disappears after someone loots it, wait for it to return."},
    nandos,
    {phase="Dungeon", title="Kill Arugal and loot his head", kind="complete", quests={1014},
     where="Shadowfang Keep / Archmage Arugal / final chamber",
     text="Stay within your healer's line of sight as Arugal teleports. Defeat him, then loot his head. The kill alone does not complete Arugal Must Die."},
    {phase="Dungeon", title="Check before leaving", kind="manual", checklist={1098,1013,1014},
     where="Shadowfang Keep / exit check",
     text="Confirm Vincent's quest is turned in and the book and head quests are ready. Warlocks should also check their large fragment. Return to any missed objective before leaving, then click Next."},
    {phase="Turn in", title="Bring Arugal's head to Dalar", kind="turnin", quests={1014},
     pin={zone="Silverpine Forest", x=.440, y=.390},
     where="Silverpine Forest / The Sepulcher / Dalar Dawnweaver",
     text="Turn in Arugal Must Die to Dalar Dawnweaver and collect your Seal of Sylvanas."},
    {phase="Turn in", title="Return the Book of Ur", kind="turnin", quests={1013},
     pin={zone="Undercity", x=.530, y=.540},
     where="Undercity / Apothecarium / Keeper Bel'dugur",
     text="Give the Book of Ur to Keeper Bel'dugur and choose your reward."},
    classFinish,
}

local alliance = {
    {phase="Prepare", title="Check your class quest", kind="manual",
     where="Alliance / optional level 20 class quests",
     text="The three regular Shadowfang quests are Horde-only. Warlocks can collect The Orb of Soran'ruk from Doan Karhan in The Barrens, 49, 57. Paladins should finish the Tome of Valor chain, then accept the material-collection stage of The Test of Righteousness from Jordan Stilwell outside Ironforge. Click Next when prepared, or if neither applies."},
    {phase="Dungeon", title="Travel to Shadowfang Keep", kind="manual",
     where="Silverpine Forest / hill above Pyrewood Village",
     text="From Southshore, travel west into Silverpine, then follow the road toward Pyrewood Village and climb to the keep. Bring your group and enter. This route uses manual steps and covers the dungeon portion of the optional class quests. Click Next inside."},
    {phase="Dungeon", title="Open the courtyard gate", kind="manual",
     where="Shadowfang Keep / prison cells / Rethilgore",
     text="Defeat Rethilgore, release Sorcerer Ashcrombe and speak to him to open the courtyard door. Follow him, then click Next once the door is open."},
    {phase="Dungeon", title="Optional paladin hammer", kind="manual",
     where="Shadowfang Keep / courtyard / stables",
     text="Paladins on The Test of Righteousness should collect Jordan's Smithing Hammer from the stables. Look on the crate and confirm the hammer is in your bags. Click Next when collected, or if you do not need it."},
    fragment, middle, ramparts,
    {phase="Dungeon", title="Clear Fenrus's room", kind="manual",
     where="Shadowfang Keep / Fenrus the Devourer",
     text="Defeat Fenrus and the enemies that appear afterward, then click Next. The Book of Ur is for the Horde quest."},
    nandos,
    {phase="Dungeon", title="Defeat Archmage Arugal", kind="manual",
     where="Shadowfang Keep / final chamber",
     text="Keep your healer in sight when Arugal teleports. Click Next after the fight. His head quest is Horde-only."},
    {phase="Dungeon", title="Check your class item before leaving", kind="manual",
     where="Shadowfang Keep / exit check",
     text="If you came for a class quest, confirm the large fragment or Jordan's hammer is in your bags before leaving. Click Next to review the remaining work outside this dungeon."},
    classFinish,
}

G.guides.sfk = {
    title="Shadowfang Keep", faction="Horde", steps=steps, finalQuests={1013,1098,1014},
    routes={Alliance={
        title="Shadowfang Keep", faction="Alliance", steps=alliance, finalQuests={},
        endText="Dungeon walkthrough finished. Optional class quests may still need materials and turn-ins elsewhere. Check your quest log; manual steps do not confirm their completion.",
    }},
}
