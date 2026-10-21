# Chasm Guide

Version 1.3.0 is a dungeon quest guide for WoW Forever. Open it with `/cguide` and open configuration with `/cguide config`. Questie and TomTom are optional.

## Credits

Thanks to [Hacker--x](https://github.com/Hacker--x) for contributing an update to Chasm Guide.

## New in 1.3.0

Reviewed on 17 October 2026. City of Dalaran now has a route for each faction, with all eight listed dungeon quests, Horde sewer-key preparation, the optional Alliance breadcrumb, and the Alliance follow-up. The former Horde follow-up stays as a blocked reference. The route collects outside quests before the run and separates each faction's Heart of Disruption turn-in. Verified exterior NPC positions support the optional arrow. Interior steps use written directions.

Scarlet Monastery adds Past Due for Alliance characters at level 30. Pick it up from Magus Olvek outside Dalaran, recover The Lost Magic of the Runemasters in the Library, and return to him. Excavation now shows Blizzard's level range of 26-31. Razorfen Downs and Uldaman note their beta access levels without treating those as recommended clear levels.

Blizzard opened City of Dalaran on 8 October. The 15 October notes do not announce another dungeon opening. The Drowned City, Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold and Shaper's Terrace remain planning entries with no verified quest routes. Blizzard's 15 October notes confirm that outdoor Dalaran guards attack Horde on sight. Dungeon access remains available. Shrewd Negotiations stays as a blocked reference, with no city waypoint or automatic quest step.

Existing ChasmGuide quest cursors and skips in Dalaran and Scarlet Monastery migrate by quest ID. Completed routes stay finished; use `/cguide restart` to review newly added quests. Unmatched manual checkpoints return to the route's first step. The addon retains a copy of each old cursor and skips in its own saved data. Confirmed turn-ins and configuration choices remain intact. Fresh arrow and automation settings remain off, and reward choices remain manual.

Fully exit and restart WoW after this update, which adds two Lua files. See `RELEASE-NOTES.txt` for sources and verification limits.

## Fixes in 1.2.1

The generated checklists now include applicable quests from the overview as well as the original dungeon catalog. Dire Maul includes Shards of the Felvine, its prerequisite A Reliquary of Purity, and the mage quest Arcane Refreshment. Razorfen Kraul includes the Horde scroll quest An Unholy Alliance. These quests have pickup, objective and turn-in steps, so the current-guide automation scope includes them. Existing faction and class restrictions still apply.

Hall of Thanes pickup steps for Afadra Dunwall and Thom Filch now use the verified coordinates shown in Details. Pickup and turn-in pins match by quest ID when metadata is available. Grouped quests only share a metadata pin when their destinations agree. Dungeon objectives and item-drop locations keep their existing directions.

Older saved catalog routes retain their current step, skipped steps and finished state. New quests follow the existing quest steps, before the final entrance check. If you had already reached that check or finished a route, use `/cguide restart` to include its new quests. Confirmed turn-ins remain complete. Existing manually written class-material reminders still cover only their dungeon portion.

The arrow, TomTom integration and quest automation default to off. Existing configuration choices are preserved. Reward choices and branching dialogue remain manual.

The existing regression suite and native Lua 5.1 tests passed. Tests cover the added quests, their prerequisite order, class and faction filters, guide-only automation, every old cursor in the expanded routes, inactive saves, repeated reloads, and the Hall of Thanes pins passed to TomTom. Live UI and gameplay verification remain pending. Fully exit and restart WoW after installing this update so it loads the added Lua files.

## New in 1.2.0: quest overview

The opening view is a Wowhead-style table: **Quest | Level | Side | Effort | Share? | Starts**. Choosing a dungeon or faction brings you back to this overview. Pickup NPCs, coordinates and prerequisites are visible in the rows before you start the route. Difficulty level bands sit above the table. The default list contains the dungeon quests; **Include chain quests** adds intermediate preparation quests. Wailing Caverns shows seven Horde quests or five Alliance quests by default.

Click **Start guide** or **Resume guide** to switch to the narrower step-by-step view, with clearer phase labels, a progress bar and restyled controls. The **Quest overview** tab returns to the table without resetting your route. The table uses alternating row backgrounds, fixed headers, wrapped text and a scroll area. It fits the available screen size; longer lists and smaller screens require scrolling. Your selected view is saved across reloads.

Click a table row for full details, completion requirements and source links. Right-click a row to pin its pickup. **Pin entrance** and **Dungeon info** are available below the table. Details include a Wowhead address you can copy with Ctrl+C. Browsing and pinning do not change your route step. Class and profession restrictions are displayed in the quest column; other-class quests remain visible for party planning.

Commands: `/cguide overview`, `/cguide quests` and `/cguide info` open the table. `/cguide guide` opens the route; `/cguide details` opens details for the current step. `/cguide wc` opens the Wailing Caverns table.

## Quest data retained from 1.1.0

- **Share?** distinguishes Yes, No, Pre, Drop, Item, Escort and ? (unverified). A Pre marker alone does not establish that sharing is possible. Individual quest-page flags take priority when checked. Yes / Pre and No / Pre retain verified sharing flags while also showing prerequisite requirements.
- **Prerequisites** list direct requirements, the beginning of longer chains, optional breadcrumbs and completion states separately. A quest in progress is not treated as a completed prerequisite. Existing database dependencies are labelled separately from Wowhead facts.
- **Level** is the pickup level listed by the guide. An asterisk identifies a fallback level from the bundled database. **Effort** means preparation to obtain a quest: Low, Med or High. **Dungeon difficulty** gives Wowhead level bands; Dire Maul and Blackrock Spire retain their wing differences. These are planning recommendations, not an assessment of your gear or group.
- **Locations** use verified Wowhead NPC and quest-map data for pickup and turn-in pins. New entrance directions cover Excavation, Dalaran and Lordaeron. Inside dungeons, written landmarks remain where no verified map pin exists.
- **Minimize** collapses either view to the draggable title block. Expanding restores the selected view. Details close when you minimize. `/cguide details` can open details independently.

The original metadata was checked on 5 October 2026. The 1.3.0 update adds a dated review in DungeonUpdate.lua. Coverage uses Wowhead's all-dungeon quest guide, dedicated Forever guides and individual NPC/quest pages. An entry without source data is explicitly Unverified. The five announced dungeons retain their published region and level range but have no invented quest routes or exact entrance pins. Sharing flags not verified during the Dalaran review remain unknown, as do its effort ratings.

Some source tables conflict. The update corrects Tabitha's pickup to Silverpine, Afadra's NPC position, and the direction of the Underground Map prerequisite. Seeking Caitlin remains optional. Highland Hides explains the conflicting prerequisite reports. Excavation shows community difficulty bands alongside Blizzard's level range of 26-31.

For this update, **exit WoW completely**, replace only the ChasmGuide folder in Interface\AddOns, and restart. Keep your WTF/SavedVariables files. Confirmed turn-ins, automation options and minimization settings are retained. Route migration is described above.

Primary sources:

- [Wowhead: every dungeon quest, sharing, preparation effort and level bands](https://www.wowhead.com/forever/guide/dungeons/every-dungeon-quest-location)
- [Wowhead: dungeon catalog and announced locations](https://www.wowhead.com/forever/guide/dungeons-overview-locations-details)
- [Excavation Site](https://www.wowhead.com/forever/guide/excavation-site-wetlands-dungeon-overview-location-rewards)
- [City of Dalaran](https://www.wowhead.com/forever/guide/city-of-dalaran-dungeon-overview-location-rewards)
- [Ruins of Lordaeron](https://www.wowhead.com/forever/guide/ruins-of-lordaeron-dungeon-overview-location-rewards)
- [Hall of Thanes](https://www.wowhead.com/forever/guide/hall-of-thanes-dungeon-overview-location-rewards)

Individual source URLs are retained with the factual records in WowheadData.lua and shown in Details. Wailing Caverns retains the corrected NPC coordinates from 1.1.0, even where the supplied guide table used different coordinates. The archive contains no downloaded web pages.

## Dungeon and faction menus

Choose a dungeon and faction from the dropdowns. Scroll the dungeon menu or use its Previous and Next buttons. My faction selects your character's faction. Each dungeon and faction keeps its own place. Previewing the other faction pauses quest automation.

The catalog has 28 entries, with wings grouped under their dungeon. Twenty-three entries have guides or quest checklists. Five announced dungeons have no verified quest route in this package and carry an asterisk: The Drowned City, Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold and Shaper's Terrace.

The six existing detailed guides remain. Excavation Site: Wetlands adds Alliance and Horde routes. City of Dalaran has four dungeon quests per faction, key preparation and the Alliance follow-up. Other dungeons use bundled quest records from the installed Forever QuestieDB snapshot. The package does not require that database at runtime.

Generated checklists arrange quests by dependency. Review pickups before entering. They are not optimized boss routes, and chains can require return visits. They filter class and race restrictions for your character. Profession, reputation, repeatable and alternative quests remain reviewable. Use Next for quests you cannot or do not want to take. Higher-level requirements may still reflect Classic. A catalog entry does not establish that the dungeon is open in the current beta.

## Configuration

All new automation and arrow switches start off. The quest scope starts at Any quest but does nothing until acceptance or turn-ins are enabled.

| Option | What it does | Default |
| --- | --- | --- |
| Show waypoint arrow | Follows the current guide step's coordinates | Off |
| Use TomTom | Uses installed TomTom, with the built-in arrow as fallback | Off |
| Automatically accept quests | Accepts the quest shown by an NPC or item | Off |
| Automatically turn in completed quests | Advances ready quests when no reward choice is needed | Off |
| Select all eligible quest entries | Opens multiple NPC quest entries one at a time | Off |
| Include low-level quests | Allows automatic selection of trivial offers | Off |
| Quest scope | Any quest, or current guide quests only | Any quest |

Acceptance and turn-ins are independent. Any quest includes quests outside this add-on. With Select all disabled, multiple eligible offers wait for your selection. Ordinary gossip dialogue, multiple reward choices and money costs remain manual. After selecting a reward, click Complete Quest yourself. Known mutually exclusive quests are excluded from automatic gossip selection. Hold Shift to pause automation. Combat also pauses it.

Automation acts when you interact with a quest giver. It does not perform objectives. The existing Auto-advance guide checkbox is separate and does not accept or turn in quests.

## Waypoint arrow

Enable Show waypoint arrow in Configuration. Drag the built-in arrow to move it. Its destination changes when you advance, go back, switch dungeons or switch factions. It clears the target on steps without coordinates and at the end. Arrival does not mark a quest complete.

The built-in arrow calculates direction and distance from client map positions. Inside an instance, across continents or without usable positions, it shows the destination text instead. Outdoor pins do not describe indoor paths or transport routes. TomTom mode creates temporary waypoints and removes only its own waypoint. Turning the arrow off removes that waypoint.

Map pin remains a separate manual button. It places a Blizzard user waypoint and replaces your previous Blizzard waypoint.

## Controls and installation

The panel scrolls long quest text. Drag its title to move it.

- Click **-** beside the close button to collapse the guide to a small title block. Click **+** to expand it again.
- The compact block is draggable. Its position and minimized state are saved per character across reloads and logins. Guide tracking, enabled quest automation and the waypoint arrow continue while minimized.
- `/cguide minimize` and `/cguide expand` also switch views. Opening a dungeon shortcut or `/cguide guides` expands the guide.
- The close button hides the guide; `/cguide` toggles visibility while keeping your chosen view.
- Next advances manually and marks unfinished quest steps skipped.
- Back pauses automatic guide progression until you enable Auto-advance again.
- `/cguide restart` clears skips for this route and finds its first unfinished step.
- `/cguide resetpos` expands and centers the guide.
- `/cguide config`, `/cguide settings` and `/cguide options` open configuration.
- Existing shortcuts still work, including `/cguide wc`, `/cguide dm`, `/cguide sfk` and `/cguide hot`.
- New shortcuts include stockade, bfd, excavation, dalaran, sm, gnomeregan, rfk, rfd, uldaman, zf, maraudon, st, brd, brs, diremaul, scholomance and stratholme.

Extract the ZIP and copy its ChasmGuide folder into your Forever client's Interface\AddOns folder. The final path should end in Interface\AddOns\ChasmGuide\ChasmGuide.toc. Fully restart for this update so WoW discovers the added Lua files.

The TOC targets interface 16001. Saved progress and settings are per character. The update retains the existing guide cursors and confirmed turn-ins. The earlier Alliance Lordaeron migration still preserves its legacy cursor.

Detailed guides report unconfirmed final turn-ins. Database checklists list quest states at the end because optional and alternative quests cannot all be required. Manual checkpoints do not prove a boss died.

## Verification and limits

Version 1.2.0 passes Lua 5.1 syntax checks and offline tests covering all 28 dungeons for both factions, quest metadata, prerequisite states, source conflicts, waypoint targets, and the real UI handlers with mocked WoW APIs. The tests cover the Wailing Caverns table, row details and pins, faction and chain filters, wrapped row geometry, an 800x600 logical viewport, minimize/expand, saved state and route progression. Layout previews were rendered from the mocked frame geometry. This build has not been tested inside WoW Forever.

Data was checked on October 5, 2026. The Excavation guide describes its outdoor prerequisite chains and optional breadcrumbs without a separate step for every prerequisite objective. The starting NPC for Dragonmaw Rumors remains unverified. Dalaran uses NPC names where coordinates are unverified. Verified outdoor pins carry map IDs; other older pins still use English zone-name lookup.

For errors, enable `/console scriptErrors 1`, reload and save the first error. Disable messages afterward with `/console scriptErrors 0`.

## New data and API sources

Factual quest and location records come from the installed QuestieDB snapshot, based on upstream commit ffcb803715edeb3b5e5497fa84f95ca5b8eba471 with local Forever corrections. Chasm Guide does not bundle QuestieDB code. The developer export and catalog builder remain in the workspace under work/overhaul.

- [QuestieDB source and provenance](https://github.com/Questie/QuestieDB)
- [Forever dungeon catalog](https://www.wowhead.com/forever/guide/dungeons-overview-locations-details)
- [Excavation quest pickups](https://www.wowhead.com/forever/news/every-quest-in-excavation-site-wetlands-wow-forever-383239)
- [Forever client quest records](https://wowforevertalents.com/quests/)
- [Blizzard quest UI source](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_UIPanels_Game/Classic/QuestFrame.lua)
- [Blizzard map API](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/MapDocumentation.lua)
- [Blizzard gossip API](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/GossipInfoDocumentation.lua)
- [TomTom interface reference](https://github.com/Pjort/TomTom)

- [horrors in the highland, 95646](https://www.wowhead.com/forever/quest=95646/horrors-in-the-highland)
- [lost in the thicket things, 95647](https://www.wowhead.com/forever/quest=95647/lost-in-the-thicket-things)
- [elder knowledge, 95664](https://www.wowhead.com/forever/quest=95664/elder-knowledge)
- [open the maw, 95682](https://www.wowhead.com/forever/quest=95682/open-the-maw)
- [changing tastes, 95697](https://www.wowhead.com/forever/quest=95697/changing-tastes)
- [songblade search, 95772](https://www.wowhead.com/forever/quest=95772/songblade-search)
- [heartwoven, 95809](https://www.wowhead.com/forever/quest=95809/heartwoven)
- [lost relic carry, 95810](https://www.wowhead.com/forever/quest=95810/lost-relic-carry)
- [highland hides, 98815](https://www.wowhead.com/forever/quest=98815/highland-hides)
- [earthen echo, 98823](https://www.wowhead.com/forever/quest=98823/earthen-echo)
- [prehistoric prism, 98824](https://www.wowhead.com/forever/quest=98824/prehistoric-prism)

- [a green sample, 92456](https://wowforevertalents.com/quests/a-green-sample-92456/)
- [power overwhelming, 92489](https://wowforevertalents.com/quests/power-overwhelming-92489/)
- [dragonmaw rumors, 95663](https://wowforevertalents.com/quests/dragonmaw-rumors-95663/)
- [seeking caitlin, 95737](https://wowforevertalents.com/quests/seeking-caitlin-95737/)
- [fallen in the fen, 95795](https://wowforevertalents.com/quests/fallen-in-the-fen-95795/)
- [the grave knight, 96986](https://wowforevertalents.com/quests/the-grave-knight-96986/)
- [opportunistic education, 96987](https://wowforevertalents.com/quests/opportunistic-education-96987/)
- [source of power, 96988](https://wowforevertalents.com/quests/source-of-power-96988/)

## Sources

Wailing Caverns sources, checked October 4, 2026:

- [Forever dungeon quest list and pickup requirements](https://www.icy-veins.com/wow-forever/wailing-caverns-quests)
- [Classic dungeon quest walkthrough](https://www.wowhead.com/classic/guide/classic-wow-wailing-caverns-dungeon-quests)
- [Raptor Horns, quest 865](https://www.wowhead.com/forever/quest=865/raptor-horns)
- [Trouble at the Docks, quest 959](https://www.wowhead.com/forever/quest=959/trouble-at-the-docks)
- [Smart Drinks, quest 1491](https://www.wowhead.com/forever/quest=1491/smart-drinks)
- [Deviate Hides, quest 1486](https://www.wowhead.com/forever/quest=1486/deviate-hides)
- [Deviate Eradication, quest 1487](https://www.wowhead.com/forever/quest=1487/deviate-eradication)
- [Glowing Shard quest-starting item 10441](https://www.wowhead.com/forever/item=10441/glowing-shard)
- [The Glowing Shard, quest 6981](https://www.wowhead.com/forever/quest=6981/the-glowing-shard)
- [Alliance In Nightmares, quest 3370](https://www.wowhead.com/forever/quest=3370/in-nightmares)

Alliance Ruins of Lordaeron sources, checked October 4, 2026:

- [Faction quest list and dungeon locations](https://www.wowhead.com/forever/guide/ruins-of-lordaeron-dungeon-overview-location-rewards)
- [Abominable Creatures, quest 95250](https://www.wowhead.com/forever/quest=95250/abominable-creatures)
- [Bloodied Insignia, quest 95195](https://www.wowhead.com/forever/quest=95195/bloodied-insignia)
- [Remember That I Love You, Stormwind quest 92415](https://www.wowhead.com/forever/quest=92415/remember-that-i-love-you)
- [Remember That I Love You, Duskwood quest 95161](https://www.wowhead.com/forever/quest=95161/remember-that-i-love-you)
- [Alliance Crest of Lordaeron, quest 95189](https://www.wowhead.com/forever/quest=95189/crest-of-lordaeron)
- [Lady Dena Kennedy](https://www.wowhead.com/forever/npc=15991/lady-dena-kennedy)
- [General Marcus Jonathan](https://www.wowhead.com/forever/npc=466/general-marcus-jonathan)

Deadmines sources, checked October 3, 2026:

- [Forever dungeon quest list](https://www.icy-veins.com/wow-forever/deadmines-quests)
- [The Defias Brotherhood, initial quest and chain](https://www.wowhead.com/forever/quest=65/the-defias-brotherhood)
- [Wiley's delivery, quest 132](https://www.wowhead.com/forever/quest=132/the-defias-brotherhood)
- [Mathias Shaw, quest 135](https://www.wowhead.com/forever/quest=135/the-defias-brotherhood)
- [Shaw's report, quest 141](https://www.wowhead.com/forever/quest=141/the-defias-brotherhood)
- [Defias Messenger, quest 142](https://www.wowhead.com/forever/quest=142/the-defias-brotherhood)
- [Traitor escort, quest 155](https://www.wowhead.com/forever/quest=155/the-defias-brotherhood)
- [VanCleef, quest 166](https://www.wowhead.com/forever/quest=166/the-defias-brotherhood)
- [Red Silk Bandanas, quest 214](https://www.wowhead.com/forever/quest=214/red-silk-bandanas)
- [Collecting Memories, quest 168](https://www.wowhead.com/forever/quest=168/collecting-memories)
- [Oh Brother..., quest 167](https://www.wowhead.com/forever/quest=167/oh-brother)
- [Underground Assault, quest 2040](https://www.wowhead.com/forever/quest=2040/underground-assault)
- [The Unsent Letter, quest 373](https://www.wowhead.com/forever/quest=373/the-unsent-letter)
- [Testing the Wells, quest 92742 and Toxic Soil chain](https://www.wowhead.com/forever/quest=92742/testing-the-wells)
- [Murloc Gills, quest 92744](https://www.wowhead.com/forever/quest=92744/murloc-gills)
- [The State of the Mines, quest 92745](https://www.wowhead.com/forever/quest=92745/the-state-of-the-mines)
- [Moonbrook Espionage, quest 92747](https://www.wowhead.com/forever/quest=92747/moonbrook-espionage)
- [Explosive Consultation, quest 92748](https://www.wowhead.com/forever/quest=92748/explosive-consultation)
- [A Dynamite Plan, quest 92749 and beta item reports](https://www.wowhead.com/forever/quest=92749/a-dynamite-plan)
- [Detonation at a Distance, quest 92750](https://www.wowhead.com/forever/quest=92750/detonation-at-a-distance)
- [Detonator delivery, quest 92751](https://www.wowhead.com/forever/quest=92751/detonation-at-a-distance)
- [Return to Alba, quest 92752](https://www.wowhead.com/forever/quest=92752/explosive-consultation)
- [Destruction in Deadmines, placement quest 92753](https://www.wowhead.com/forever/quest=92753/destruction-in-deadmines)
- [Destruction in Deadmines, detonation quest 92819](https://www.wowhead.com/forever/quest=92819/destruction-in-deadmines)
- [Alba's back-exit location](https://60forever.com/quests/destruction-in-deadmines)
- [Paladin material objectives](https://www.wowhead.com/forever/quest=1654/the-test-of-righteousness)

Shadowfang Keep sources, checked October 3, 2026:

- [Forever dungeon quest list](https://www.wowhead.com/forever/guide/dungeons/every-dungeon-quest-location)
- [The Book of Ur, quest 1013](https://www.wowhead.com/forever/quest=1013/the-book-of-ur)
- [Deathstalkers in Shadowfang, quest 1098](https://www.wowhead.com/forever/quest=1098/deathstalkers-in-shadowfang)
- [Arugal Must Die, quest 1014](https://www.wowhead.com/forever/quest=1014/arugal-must-die)
- [The Orb of Soran'ruk, quest 1740](https://www.wowhead.com/forever/quest=1740/the-orb-of-soranruk)
- [The Test of Righteousness, quest 1654](https://www.wowhead.com/forever/quest=1654/the-test-of-righteousness)
- [Classic dungeon quest requirements](https://www.wowhead.com/classic/guide/classic-wow-shadowfang-keep-dungeon-quests)
- [Classic route and bosses](https://www.wowhead.com/classic/guide/shadowfang-keep-dungeon-strategy-wow-classic)

Hall of Thanes sources, checked October 1, 2026:

- [Quest pickups and route](https://www.wowhead.com/forever/guide/hall-of-thanes-dungeon-overview-location-rewards)
- [Boss tactics](https://www.icy-veins.com/wow-forever/hall-of-thanes-guide/)
- [Underground Map, quest 96391](https://www.wowhead.com/forever/quest=96391/underground-map)
- [Old Ironforge Incursion, quest 96393](https://www.wowhead.com/forever/quest=96393/old-ironforge-incursion)
- [The Restless Dead, quest 96394](https://www.wowhead.com/forever/quest=96394/the-restless-dead)
- [An Ancient Grudge, quest 96395](https://www.wowhead.com/forever/quest=96395/an-ancient-grudge)
- [Important Heirlooms, quest 96403](https://www.wowhead.com/forever/quest=96403/important-heirlooms)
- [The Treaty of Understanding, quest 98423](https://www.wowhead.com/forever/quest=98423/the-treaty-of-understanding)

Earlier guides, checked September 20, 2026:

- [Classic Ragefire Chasm quests](https://www.wowhead.com/classic/guide/classic-wow-ragefire-chasm-dungeon-quests)
- [Quest locations and turn-ins](https://www.icy-veins.com/wow-classic/ragefire-chasm-quests-guide)
- [Forever beta quest listing](https://wowforevertalents.com/quests/)
- [Ruins pickups and uncertain beta details](https://quissy.tv/wow-forever-ruins-of-lordaeron-quests/)
- [Boss positions and pickup coordinates](https://mobalytics.gg/wow-forever/dungeons/ruins-of-lordaeron-dungeon-guide)
- [The New Plague coordinates](https://www.chromie.de/ruinen-von-lordaeron-alle-quests-im-uberblick)
- [A Frightened Request, quest 92401](https://wowforevertalents.com/quests/a-frightened-request-92401/)
- [Light's Justice, quest 92421](https://wowforevertalents.com/quests/light-s-justice-92421/)
- [The New Plague, quest 95216](https://wowforevertalents.com/quests/the-new-plague-95216/)
- [The Wrath of Rath'mael, quest 92422](https://wowforevertalents.com/quests/the-wrath-of-rath-mael-92422/)
- [Horde Crest of Lordaeron, quest 95204](https://wowforevertalents.com/quests/crest-of-lordaeron-95204/)
- [Unending Torment, head delivery](https://warcraftforever.games/quests/97288)
- [Unending Torment, Othmar](https://warcraftforever.games/quests/97289)
- [Unending Torment, report to Faranell](https://warcraftforever.games/quests/97290)
- [Unending Torment, ingredients](https://warcraftforever.games/quests/97291)
- [Unending Torment, serum](https://warcraftforever.games/quests/97292)
- [Blizzard UI source mirror and API documentation](https://github.com/Gethe/wow-ui-source)

Read on September 20, 2026. The implementation checks API availability and leaves manual progression available if quest tracking is unavailable.
