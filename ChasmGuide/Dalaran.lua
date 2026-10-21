local _, G = ...
-- Quest IDs and exterior pins are in DungeonUpdate.lua. No interior coordinates are assumed.
local function Build(faction)
    local steps={}
    local function Manual(title,where,text,pin,checklist)
        steps[#steps+1]={phase="Prepare",title=title,kind="manual",where=where,text=text,pin=pin,checklist=checklist}
    end
    local function Quest(kind,id,phase,text,where,pin)
        local q=G.questCatalog[id]
        local at=kind=="turnin" and q.finish or q.start
        steps[#steps+1]={phase=phase,title=({accept="Accept ",complete="Complete ",turnin="Turn in "})[kind]..q.name,
            kind=kind,quests={id},where=where or (kind=="complete" and "City of Dalaran / dungeon" or at.where),
            text=text or (kind=="accept" and "Speak to the quest giver and accept the quest."
                or kind=="turnin" and "Return to the quest giver. Choose your reward yourself."
                or "Finish every objective shown in your quest log."),
            pin=pin or (kind~="complete" and at.pin or nil)}
    end
    Manual("Prepare for City of Dalaran","Dalaran / five-player dungeon",
        "The dungeon is open in beta. Blizzard lists levels 28-33. Pick up your faction's quests before entering. Interior steps use written directions and the live quest log. Skip completed preparation with Next.")
    if faction=="Alliance" then
        Quest("accept",92456,"Prepare")
        Quest("accept",92489,"Prepare")
        Manual("Optional Southshore breadcrumb",G.questCatalog[92432].start.where,
            "At level 30, Emissary Jacques offers An Alarming Request. Deliver it to the Image of Archmage Modera if you take it. You can visit Modera directly for her level-24 dungeon quests.",G.questCatalog[92432].start.pin,{92432})
        Quest("accept",92458,"Prepare","Ask Modera for Heart of Disruption and check for the Dalaran Sewer Key. If you brought An Alarming Request, turn it in first.")
        Quest("accept",92457,"Prepare","Accept Starving Arcane from Modera. Watch its three kill counters during the run.")
    else
        Quest("accept",96988,"Prepare")
        Quest("accept",96986,"Prepare")
        Manual("Check your sewer key","Tarren Mill / Magus Wordeen Voidglare",
            "The following key preparation starts at level 30. If you already have the Dalaran Sewer Key, skip completed preparation. A group member can open the gate, but that does not complete your own quest chain.",G.questCatalog[93680].start.pin)
        Quest("accept",544,"Key chain")
        Quest("accept",93680,"Key chain")
        Quest("complete",544,"Key chain","Recover the four bloodstone items from the imprisoned traitors in the Dalaran camps. Follow each item in the quest log.","Alterac Mountains / Dalaran camps")
        Quest("complete",93680,"Key chain","Search the Warden's Footlocker for the Grimy Key. The reported building is near 15, 88 in Alterac Mountains. This is the unenchanted key for Wordeen.","Alterac Mountains / Dalaran camps",{zone="Alterac Mountains",mapID=1416,x=.15,y=.88})
        Quest("turnin",544,"Key chain")
        Quest("turnin",93680,"Key chain")
        Quest("accept",545,"Key chain")
        Quest("complete",545,"Key chain","Defeat Dalaran Summoners and Elemental Slaves around Dalaran. Use your live quest counters for the required numbers.","Alterac Mountains / Dalaran patrols")
        Quest("turnin",545,"Key chain")
        Quest("accept",92434,"Key chain","After the patrol and key tasks, accept Blood in the Streets from Wordeen.")
        Quest("turnin",92434,"Key chain","Deliver Wordeen's request to Modera outside the sewer gate.")
        Quest("accept",96984,"Key chain","Accept Heart of Disruption and check your keyring for the enchanted Dalaran Sewer Key. This Horde quest returns to Wordeen in Tarren Mill.")
    end
    local main=faction=="Alliance" and {92456,92489,92457,92458} or {96986,96988,96984}
    Manual("Enter through the sewer gate",G.wowheadEntrances.dalaran.where,
        "Check your pickups, open the gate with the key and enter with your party. Click Next inside.",G.wowheadEntrances.dalaran.pin,main)
    if faction=="Horde" then
        Quest("accept",96987,"Dungeon","Find Rexxie Copperclutch near the dungeon entrance and accept the book quest before moving on.")
        Quest("complete",96988,"Dungeon","Loot six Cracked Sentry Cores from sentries as your group clears the dungeon.")
        Quest("complete",96986,"Dungeon","Defeat Atrexis the Grave Knight and check your quest credit.")
        Quest("complete",96987,"Dungeon","Search for The Founding of Dalaran and loot the book. Check the quest log before leaving.")
    else
        Quest("complete",92456,"Dungeon","Collect a Fel Infused Blossom in the garden.")
        Quest("complete",92489,"Dungeon","Defeat the Mana Elemental, listed as Arcanic Enigma in dungeon references, and check your quest credit.")
        Quest("complete",92457,"Dungeon","Defeat Seeking Remnants, Saturated Remnants and Mana Echoes. All three counters must be complete. Arrange another run if your group leaves you short.")
    end
    local heart=faction=="Alliance" and 92458 or 96984
    Quest("complete",heart,"Dungeon","Defeat the Shade of the Archmage and loot the Arcane Mote. Keep it for the quest turn-in.")
    if faction=="Horde" then
        Quest("turnin",96987,"Turn in","Return to Rexxie with The Founding of Dalaran before leaving the dungeon.")
    end
    Manual("Check your log before leaving","City of Dalaran / exit",
        "Check every remaining dungeon objective and your Arcane Mote. A skipped step does not mean the quest is complete. Click Next when ready to leave.",nil,main)
    if faction=="Alliance" then
        Quest("turnin",92457,"Turn in")
        Quest("turnin",92458,"Turn in")
        Quest("accept",92459,"Follow-up")
        Quest("turnin",92459,"Follow-up","Take the mote to Archmage Celindra in the Violet Citadel in the outdoor city.")
        Quest("turnin",92456,"Turn in")
        Quest("turnin",92489,"Turn in")
    else
        Quest("turnin",96986,"Turn in")
        Quest("turnin",96984,"Turn in","Return the Arcane Mote to Magus Wordeen Voidglare in Tarren Mill.")
        Manual("Shrewd Negotiations is blocked by city access","Dalaran / outdoor city / historical follow-up",
            "Shrewd Negotiations previously sent Horde to Celindra. Blizzard's 15 October notes now say outdoor Dalaran guards attack Horde on sight, even after the key chain. Dungeon access is unchanged. This guide does not send you into the outdoor city. Leave this follow-up for a confirmed quest update and click Next.",nil,{97287})
        Quest("turnin",96988,"Turn in")
    end
    return {title="City of Dalaran",faction=faction,steps=steps,
        finalQuests=faction=="Alliance" and {92456,92489,92457,92459} or {96986,96988,96987,96984},
        endText="Check the quest log for unfinished objectives or blocked follow-ups. The route does not claim completion for manually skipped quests."}
end
G.guides.dalaran=Build("Alliance")
G.guides.dalaran.routes={Horde=Build("Horde")}
