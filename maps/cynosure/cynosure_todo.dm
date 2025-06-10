
/* Migrations to document
/obj/effect/map_helper/airlock : /obj/abstract/airlock_helper
obj/machinery/atmospherics/omni/atmos_filter : obj/machinery/atmospherics/omni/filter
obj/machinery/door/airlock/glass_ : obj/machinery/door/airlock/glass/
obj/machinery/button/remote/airlock : obj/machinery/button/alternate/door
obj/machinery/access_button/airlock_interior : obj/machinery/button/access/interior
obj/machinery/access_button/airlock_exterior : obj/machinery/button/access/exterior
obj/machinery/access_button : obj/machinery/button/access
obj/structure/ladder/up : obj/structure/ladder
obj/structure/ladder/updown : obj/structure/ladder
obj/item/circuitboard : obj/item/stock_parts/circuitboard
obj/random/mob/mouse : obj/random/mouse
obj/machinery/airlock_sensor/airlock_interior : obj/machinery/airlock_sensor
obj/machinery/airlock_sensor/airlock_exterior : obj/machinery/airlock_sensor
obj/machinery/shower : obj/structure/hygiene/shower
obj/structure/toilet : obj/structure/hygiene/toilet
obj/item/tool/wrench : obj/item/wrench
obj/item/tool/wirecutters : obj/item/wirecutters
obj/item/tool/screwdriver : obj/item/screwdriver
obj/item/clothing/suit/space/anomaly : obj/item/clothing/suit/bio_suit/anomaly
obj/item/clothing/head/helmet/space/anomaly : obj/item/clothing/head/bio_hood/anomaly
obj/item/chainofcommand : obj/item/whip/chainofcommand
obj/item/moneybag/vault : obj/item/bag/cash/filled
obj/item/moneybag : obj/item/bag/cash
obj/item/stack/material/phoron : obj/item/stack/material/crystal/mapped/phoron/twentyfive
obj/item/defib_kit : obj/item/defibrillator
obj/item/stack/rods : obj/item/stack/material/rods
obj/item/clothing/gloves/sterile/latex : obj/item/clothing/gloves/latex
obj/item/modular_computer/console : obj/machinery/computer/modular
obj/machinery/station_map : obj/machinery/holomap

// Other stuff to follow up on
check what `specialfunctions = 4` on door buttons is supposed to do
remap R&D servers with Neb types
remap mining machines with Neb types
reimplement equipment vendors for explo/mining
map circuitboards back into secure storage
corgi statue for central hall
event2 system and event overrides from Polaris Cyno
*/

// Stuff to port
/obj/item/tabloid

/obj/item/box/fancy/markers

/obj/item/book/codex
/obj/item/book/codex/corp_regs
/obj/item/book/codex/lore
/obj/item/book/codex/lore/news
/obj/item/book/codex/lore/robutt
/obj/item/book/codex/lore/vir

/obj/vehicle/boat/sifwood

/obj/vehicle/train/cargo/engine/quadbike
/obj/vehicle/train/cargo/engine/quadbike/random
/obj/vehicle/train/cargo/engine/quadbike/snowmobile/random

/obj/vehicle/train/cargo/trolley/trailer
/obj/vehicle/train/cargo/trolley/trailer/random

// Stubs to reimplement
/obj/item/gun/energy/gun/burst
/obj/item/gun/energy/ionrifle/pistol
/obj/item/gun/energy/phasegun/pistol
/obj/item/gun/energy/taser/xeno
/obj/item/gun/projectile/automatic/c20r
/obj/item/gun/projectile/automatic/l6_saw
/obj/item/gun/projectile/automatic/p90
/obj/item/gun/projectile/automatic/pdw
/obj/item/gun/projectile/automatic/sts35
/obj/item/gun/projectile/colt/detective
/obj/item/gun/projectile/revolver/mateba
/obj/item/gun/projectile/sec
/obj/item/gun/projectile/shotgun/pump/combat
/obj/item/gun/projectile/shotgun/pump/rifle
/obj/item/gun/projectile/shotgun/pump/rifle/lever
/obj/item/gun/energy/phasegun
/obj/item/gun/energy/phasegun/tranq_rifle
/obj/item/gun/energy/phasegun/tranq_pistol
/obj/item/gun/energy/phasegun/rifle

/obj/item/gunbox

/obj/item/box/poker_chips
/obj/item/radio/intercom/interrogation
/obj/item/baton/slime/loaded
/obj/item/chems/glass/beaker/cryoxadone
/obj/item/rig/breacher
/obj/item/defibrillator/jumper_kit/loaded
/obj/item/twohanded/riding_crop

/obj/item/chems/glass/bottle/biomass
/obj/item/paper/dockingcodes
	var/codes_from_z

/obj/machinery/vending/phoronresearch
/obj/machinery/smartfridge/produce/persistent_lossy

/obj/random/multiple/ore_pile
/obj/random/multiple/corp_crate/no_weapons
/obj/random/multiple/voidsuit/mining

/obj/machinery/porta_turret/industrial
/obj/machinery/porta_turret/industrial/teleport_defense

/obj/machinery/alarm/outside

/obj/effect/floor_decal
/obj/effect/floor_decal/arrivals
/obj/effect/floor_decal/arrivals/right
/obj/effect/floor_decal/emblem/nt1
/obj/effect/floor_decal/emblem/nt2
/obj/effect/floor_decal/emblem/nt3
/obj/effect/floor_decal/milspec_sterile
/obj/effect/floor_decal/milspec_sterile/green
/obj/effect/floor_decal/milspec_sterile/green/half
/obj/effect/floor_decal/milspec/cargo_arrow
/obj/effect/floor_decal/milspec/color/black/half
/obj/effect/floor_decal/milspec/color/orange
/obj/effect/floor_decal/milspec/color/red
/obj/effect/floor_decal/milspec/color/silver/half
/obj/effect/floor_decal/milspec/color/white
/obj/effect/floor_decal/milspec/color/white/corner
/obj/effect/floor_decal/milspec/color/white/half
/obj/effect/floor_decal/milspec/hatchmarks
/obj/effect/floor_decal/milspec/stripe
/obj/effect/floor_decal/shuttle_exit
/obj/effect/floor_decal/shuttles
/obj/effect/floor_decal/shuttles/right
/obj/effect/floor_decal/sign/dock/three
/obj/effect/floor_decal/wheelchair
/obj/effect/floor_decal/milspec
/obj/effect/floor_decal/milspec/box
/obj/effect/floor_decal/milspec/color/blue


/obj/machinery/mixer
/obj/machinery/mixer/cereal
/obj/machinery/mixer/candy



/obj/machinery/navbeacon/patrol
	var/next_patrol

/obj/machinery/computer/shuttle_control/explore/explorer_shuttle

/decl/poster
/decl/poster/pol_4
/decl/poster/pol_9
/decl/poster/pol_11
/decl/poster/pol_12
/decl/poster/pol_13
/decl/poster/pol_14
/decl/poster/pol_15
/decl/poster/pol_16
/decl/poster/pol_17
/decl/poster/bay_35
/decl/poster/bay_44
/decl/poster/bay_27
/decl/poster/bay_29
/decl/poster/bay_39
/decl/poster/bay_2
/decl/poster/bay_37
/decl/poster/bay_36
/decl/poster/bay_49
/decl/poster/bay_19
/decl/poster/bay_28
/decl/poster/bay_6
/decl/poster/bay_13
/decl/poster/bay_11
/decl/poster/bay_38
/decl/poster/bay_3
/decl/poster/vore_75
/decl/poster/vore_29
/decl/poster/vore_69
/decl/poster/vore_43
/decl/poster/vore_91
/decl/poster/vore_45
/decl/poster/vore_100
/decl/poster/vore_37
/decl/poster/vore_96

// Clothes


/obj/item/clothing/badge/holo/cord
/obj/item/clothing/suit/jacket/bomber/alt
/obj/item/clothing/suit/jacket/bomber/retro
/obj/item/clothing/dress/blacktango
/obj/item/clothing/dress/blacktango/alt
/obj/item/clothing/dress/redeveninggown
/obj/item/clothing/dress/sailordress
/obj/item/clothing/glasses/hud/health
/obj/item/clothing/head/pilot/alt
/obj/item/clothing/head/helmet/ert/command
/obj/item/clothing/head/helmet/flexitac

/obj/item/clothing/suit/caution

/obj/item/clothing/suit/costume/justice

/obj/item/clothing/head/helmet/space/sports
/obj/item/clothing/suit/space/sports

/obj/item/clothing/armor_attachment/armorplate/laserproof
/obj/item/clothing/armor_attachment/armorplate/riot
/obj/item/clothing/armor_attachment/armorplate/bulletproof

/obj/item/clothing/webbing/vox
/obj/item/clothing/glasses/night/vox

/obj/item/clothing/suit/jacket/winter/parka
/obj/item/clothing/suit/jacket/winter/parka/nanotrasen
/obj/item/clothing/suit/jacket/winter/parka/purple
/obj/item/clothing/suit/jacket/winter/medical/sar


/obj/abstract/landmark/crashed_pod
/obj/abstract/landmark/submap_position
/obj/abstract/landmark/submap_position/random_subtype
/obj/abstract/landmark/submap_position/random_subtype/cynosure_nine_by_eight_maint
/obj/abstract/landmark/submap_position/random_subtype/cynosure_eight_by_nine_maint
/obj/abstract/landmark/submap_position/random_subtype/cynosure_eight_by_five_maint
/obj/abstract/landmark/submap_position/random_subtype/cynosure_nine_by_ten_maint
/obj/abstract/landmark/submap_position/random_subtype/cynosure_medical_basement
/obj/abstract/landmark/submap_position/random_subtype/cynosure_sixteen_by_eleven_maint
/obj/abstract/landmark/submap_position/random_subtype/cynosure_seven_by_seven_maint
/obj/abstract/landmark/submap_position/random_subtype/cynosure_ten_by_nine_maint
/obj/abstract/landmark/free_ai_shell
/obj/abstract/landmark/free_ai_shell/flying
/obj/abstract/landmark/virtual_reality
/obj/abstract/landmark/ai_multicam_room
/obj/abstract/landmark/teleport_mark

/turf/unsimulated/ai_visible

/turf/unsimulated/wall/planetary
/turf/unsimulated/wall/planetary/sif
/turf/unsimulated/wall/sealed_door
/turf/unsimulated/wall/sealed_blast_door
/turf/unsimulated/wall/uranium_door
/turf/unsimulated/wall/sealed_door_maint
/turf/unsimulated/wall/planetary/sif/alt

/turf/unsimulated/floor/steel_grid
/turf/unsimulated/floor/dark
/turf/unsimulated/floor/wood
/turf/unsimulated/floor/wood/broken
/turf/unsimulated/floor/techfloor/gray
/turf/unsimulated/floor/monotile
/turf/unsimulated/floor/white
/turf/unsimulated/floor/steel
/turf/unsimulated/floor/plating
/turf/unsimulated/floor/techfloor
/turf/unsimulated/floor/techfloor/grid

/turf/floor/holofloor/bmarble
/turf/floor/holofloor/wmarble
/turf/floor/shuttle/carry
/turf/floor/hull
/turf/floor/shuttle/voidcraft/dark
/turf/floor/shuttle/voidcraft/light
/turf/floor/shuttle/airless/carry
/turf/floor/reinforced/supermatter_core

/obj/item/chems/condiment/mustard
/obj/item/chems/condiment/spacespice

/turf/wall/shuttle/dark/no_join
/turf/wall/shuttle/orange
/turf/wall/tgmc/redstripe
/turf/wall/tgmc/redstripe_r
/turf/wall/tgmc/whitewall
/turf/wall/tgmc/window/white/reinf

// mining machinery
/obj/machinery/mineral/equipment_vendor

/obj/machinery/camera/xray/command
/obj/effect/overlay/snow/floor

/obj/abstract/airlock_helper/atmos/pump_out_external
/obj/machinery/portable_atmospherics/powered/reagent_distillery
/obj/machinery/vending/giftvendor
/obj/machinery/neonsign/cafe
/obj/machinery/chemical_analyzer
/obj/machinery/vending/fishing
/obj/machinery/power/grid_checker
/obj/machinery/computer/shutoff_monitor
/obj/machinery/smartfridge/sheets/persistent_lossy
/obj/machinery/bluespace_beacon
/obj/machinery/computer/pod
	var/title
/obj/effect/step_trigger/teleporter/planetary_fall/sif
/obj/machinery/computer/shuttle_control/arrivals

/obj/effect/step_trigger/teleporter/landmark
	var/landmark_id
/obj/machinery/power/sensor
	var/long_range

/mob/living/simple_animal/slime/rainbow/kendrick
/mob/living/silicon/decoy
/mob/living/simple_animal/passive/dog/tamaskan/Spice
/mob/living/simple_animal/passive/dog/corgi/puppy/Bockscar

/area/unionoffice
/area/wizard_station
/area/beach
/area/virtual_reality
/area/ai_multicam_room
/area/syndicate_mothership/elite_squad
/area/prison/solitary
/area/holodeck/source_chess
/area/skipjack_station/start
/area/shuttle/trade
/area/shuttle/syndicate_elite/mothership
/area/centcom/suppy
/area/centcom/creed

/obj/machinery/door/firedoor/glass
/obj/machinery/door/firedoor/multi_tile

/obj/machinery/door/blast/gate
/obj/machinery/door/blast/gate/thin
/obj/machinery/door/blast/gate/thin/open

/obj/machinery/door/airlock/uranium
/obj/machinery/door/airlock/voidcraft
/obj/machinery/door/airlock/engineeringatmos
/obj/machinery/door/airlock/silver
/obj/machinery/door/airlock/external/white
/obj/machinery/door/airlock/glass/centcom
/obj/machinery/door/airlock/glass/engineeringatmos
/obj/machinery/door/airlock/voidcraft/vertical

/obj/structure/curtain/open/shower/medical
/obj/structure/chair/wood/pine
/obj/structure/hull_corner/long_vert

/obj/structure/rack/shelf
/obj/structure/rack/shelf/steel
/obj/structure/sign/pods
/obj/structure/sign/calendar
/obj/structure/sign/bigname
/obj/structure/sign/bigname/seg_2
/obj/structure/sign/bigname/seg_3
/obj/structure/sign/bigname/seg_4
/obj/structure/sign/bigname/seg_5
/obj/structure/sign/bigname/seg_6
/obj/structure/sign/bigname/seg_7
/obj/structure/sign/level
/obj/structure/sign/level/ground
/obj/structure/sign/level/ground/large
/obj/structure/sign/level/basement
/obj/structure/sign/level/basement/large
/obj/structure/sign/level/two
/obj/structure/sign/level/two/large
/obj/structure/sign/levels
/obj/structure/sign/levels/medical
/obj/structure/sign/levels/medical/virology
/obj/structure/sign/levels/medical/morgue
/obj/structure/sign/levels/medical/surgery
/obj/structure/sign/levels/medical/cloning
/obj/structure/sign/levels/medical/chemlab
/obj/structure/sign/levels/engineering
/obj/structure/sign/levels/engineering/reactor
/obj/structure/sign/levels/security
/obj/structure/sign/levels/security/seceqp
/obj/structure/sign/levels/security/interrogation
/obj/structure/sign/levels/security/forensics
/obj/structure/sign/levels/security/brig
/obj/structure/sign/levels/security/armory
/obj/structure/sign/levels/armory
/obj/structure/sign/levels/brig
/obj/structure/sign/levels/cryo
/obj/structure/sign/levels/evac
/obj/structure/sign/levels/eva
/obj/structure/sign/levels/command
/obj/structure/sign/levels/science
/obj/structure/sign/levels/science/xenoflora
/obj/structure/sign/levels/science/xenobiology
/obj/structure/sign/levels/science/exploration
/obj/structure/sign/levels/science/robotics
/obj/structure/sign/levels/science/toxins
/obj/structure/sign/levels/science/xenoarch
/obj/structure/sign/levels/science/rnd
/obj/structure/sign/levels/dorms
/obj/structure/sign/levels/cargo
/obj/structure/sign/levels/cargo/mining
/obj/structure/sign/levels/recreation
/obj/structure/sign/clock
/obj/structure/sign/science
/obj/structure/sign/warning/cold
/obj/structure/sign/warning/secure_area/armory
/obj/structure/sign/explosive
/obj/structure/sign/redcross
/obj/structure/sign/directions
/obj/structure/sign/directions/security
/obj/structure/sign/directions/security/seceqp
/obj/structure/sign/directions/stairwell
/obj/structure/sign/directions/command
/obj/structure/sign/directions/dorms
/obj/structure/sign/directions/elevator
/obj/structure/sign/directions/ladder_up
/obj/structure/sign/directions/ladder_down
/obj/structure/sign/directions/ladderwell
/obj/structure/sign/directions/engineering
/obj/structure/sign/directions/engineering/solars
/obj/structure/sign/directions/engineering/engeqp
/obj/structure/sign/directions/engineering/reactor
/obj/structure/sign/directions/engineering/atmospherics
/obj/structure/sign/directions/medical
/obj/structure/sign/directions/medical/morgue
/obj/structure/sign/directions/stairs_up
/obj/structure/sign/directions/cargo
/obj/structure/sign/directions/cargo/mining
/obj/structure/sign/directions/cargo/refinery
/obj/structure/sign/directions/science
/obj/structure/sign/directions/science/xenoarch
/obj/structure/sign/directions/science/xenoflora
/obj/structure/sign/directions/science/xenobiology
/obj/structure/sign/directions/science/exploration
/obj/structure/sign/directions/science/toxins
/obj/structure/sign/directions/teleporter
/obj/structure/sign/directions/security/interrogation
/obj/structure/sign/directions/security/internal_affairs
/obj/structure/sign/directions/security/forensics/alt
/obj/structure/sign/directions/security/brig
/obj/structure/sign/directions/security/armory
/obj/structure/sign/directions/science/robotics
/obj/structure/sign/directions/science/rnd
/obj/structure/sign/directions/roomnum
/obj/structure/sign/directions/recreation
/obj/structure/sign/directions/pool
/obj/structure/sign/directions/medical/virology
/obj/structure/sign/directions/medical/surgery
/obj/structure/sign/directions/medical/operating_2
/obj/structure/sign/directions/medical/operating_1
/obj/structure/sign/directions/medical/cloning
/obj/structure/sign/directions/janitor
/obj/structure/sign/directions/eva
/obj/structure/sign/directions/bar
/obj/structure/sign/directions/ai_core
/obj/structure/sign/directions/stairs_down
/obj/structure/closet/athletic_swimwear
/obj/structure/closet/wardrobe/captain
/obj/structure/closet/wardrobe/detective
/obj/structure/closet/crate/freezer/nanotrasen
/obj/structure/closet/crate/focalpoint
/obj/structure/closet/crate/secure/nanotrasen
/obj/structure/closet/crate/nanotrasen
/obj/structure/closet/crate/science
/obj/structure/closet/crate/large/nanotrasen
/obj/structure/closet/secure_closet/guncabinet/phase
/obj/structure/closet/secure_closet/security/cynosure
/obj/structure/closet/secure_closet/hos/cynosure
/obj/structure/closet/secure_closet/warden/cynosure
/obj/structure/closet/secure_closet/detective/cynosure
/obj/structure/closet/secure_closet/guncabinet/tranq
/obj/structure/closet/walllocker/emerglocker
/obj/structure/bed/double
/obj/structure/bed/double/padded
/obj/structure/railing/grey
/obj/structure/shuttle/falsewall_no_join
/obj/structure/shuttle/falsewall_no_join/white
/obj/structure/shuttle/falsewall_no_join/window/white
/obj/structure/largecrate/hoverpod
/obj/structure/hull_corner/long_horiz
/obj/structure/reagent_dispensers/beerkeg/fakenuke
/obj/structure/reagent_dispensers/water_cooler/full
/obj/structure/reagent_dispensers/watertank/high
/obj/structure/reagent_dispensers/coolanttank
/obj/structure/filing_cabinet/records/security

/obj/structure/animal_den

/obj/structure/marker_beacon // should be changed to /obj/item/stack/flag with upright = true?
	var/mapped_in_color

/obj/structure/sign/poster/custom // interactable, adjustable subtype
	var/poster_decl

/obj/machinery/computer/card/centcom
/obj/structure/closet/crate/secure/decalock/loot
/obj/machinery/computer/shuttle_control/multi/mercenary_elite
/obj/machinery/vending/deathmatch/red

/obj/mecha/medical/odysseus/loaded
/obj/mecha/combat/gygax/dark
/obj/mecha/working/hoverpod
/obj/mecha/combat/marauder/mauler

/obj/abstract/landmark/teleport_mark
	var/landmark_id

/obj/machinery/computer/shuttle_control/multi/heist
/obj/machinery/computer/shuttle_control/multi/centcom
/obj/machinery/computer/shuttle_control/multi/merchant
/obj/machinery/computer/shuttle_control/multi/response
/obj/machinery/computer/shuttle_control/multi/administration

/obj/machinery/computer/modular/preset/nuclear


/obj/structure/closet/wardrobe/ert
/obj/item/rig/internalaffairs


/obj/machinery/atmospherics/pipe/vent
/obj/machinery/atmospherics/binary/pump/fuel
/obj/machinery/atmospherics/binary/dp_vent_pump
/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume
/obj/machinery/atmospherics/portables_connector/fuel
/obj/machinery/atmospherics/trinary/mixer

/obj/item/pinpointer/shuttle/merc
/obj/item/pinpointer/shuttle/heist

/obj/structure/cliff
/obj/structure/cliff/automatic
/obj/structure/cliff/automatic/corner
/obj/structure/cliff/automatic/ramp

// Outfit stuff
/decl/closet_appearance/secure_closet/medical/paramedic

/obj/item/clothing/suit/toggle/fr_jacket
/obj/item/clothing/suit/toggle/labcoat/emt

/obj/item/clothing/head/pilot
/obj/item/clothing/suit/jacket/bomber/pilot
/obj/item/clothing/gloves/fingerless

// PORT XENOFAUNA
/obj/structure/flaps/xenofauna
/obj/item/clothing/under/xenofauna
/obj/item/clothing/suit/hooded/explorer/xenofauna
/obj/structure/closet/secure_closet/xenofauna
/obj/item/specimen_tagger

// PORT TECHNOMANCER
/obj/item/clothing/costume/technomancer
/obj/item/clothing/head/technomancer
/obj/item/antag_spawner/technomancer_apprentice

/obj/item/clothing/mask/gas/sechailer/swat/warden
/obj/item/shield/riot/tele
/obj/item/box/holobadge/hos
/obj/item/clothing/badge/holo/hos
/obj/item/clothing/suit/jacket/winter/security/hos
/obj/item/clothing/mask/gas/sechailer/swat/hos
/obj/item/clothing/badge/holo/warden
/obj/item/clothing/badge/holo/detective
/obj/item/clothing/glasses/fakesunglasses/aviator

/obj/item/communicator
	var/static_name
	var/occupation

/obj/item/communicator/desktop
/obj/machinery/disease2/isolator
/obj/machinery/disease2/incubator
/obj/machinery/disease2/diseaseanalyser
/obj/structure/reagent_dispensers/virusfood
/obj/item/virusdish/random
/obj/machinery/computer/diseasesplicer
/obj/machinery/computer/centrifuge
/obj/machinery/smartfridge/secure/virology
/obj/item/chems/syringe/antiviral
/obj/effect/overmap/visitable/planet/Sif
/obj/effect/overmap/visitable/ship/landable/explorer_shuttle
/obj/effect/shuttle_landmark/cynosure/arrivals_offsite
/obj/effect/shuttle_landmark/cynosure/arrivals_station
/obj/effect/shuttle_landmark/cynosure/escape_pod1/offsite
/obj/effect/shuttle_landmark/cynosure/escape_pod1/station
/obj/effect/shuttle_landmark/cynosure/escape_pod1/transit
/obj/effect/shuttle_landmark/cynosure/pads/pad3
/obj/effect/shuttle_landmark/cynosure/pads/pad4
/obj/effect/shuttle_landmark/cynosure/pads/perimeter
/obj/effect/shuttle_landmark/cynosure/wilderness
/obj/machinery/dna_scannernew
/obj/machinery/computer/cloning
/obj/machinery/computer/scan_consolenew
/obj/machinery/clonepod
/obj/machinery/cash_register
/obj/machinery/cash_register/civilian
/obj/item/scanner/barcode
/mob/living/bot/secbot/slime
/mob/living/bot/secbot/slime/slimesky
/turf/floor/tiled/yellow
/turf/floor/tiled/milspec
/turf/floor/tiled/milspec/dark
/turf/floor/tiled/milspec/raised
/turf/floor/tiled/milspec/sterile
/turf/floor/tiled/hydro
/turf/floor/tiled/old_tile
/turf/floor/tiled/old_tile/gray
/turf/floor/tiled/old_tile/white
/turf/floor/tiled/old_tile/yellow
/turf/floor/tiled/old_tile/blue
/turf/floor/tiled/old_cargo
/turf/floor/tiled/old_cargo/gray
/turf/floor/tiled/old_cargo/white
/turf/floor/tiled/old_cargo/blue
/turf/floor/tiled/neutral
/turf/floor/tiled/asteroid_steel
/turf/floor/tiled/kafel_full/gray
/turf/floor/tiled/eris
/turf/floor/tiled/eris/cafe
/turf/floor/tiled/eris/steel
/turf/floor/tiled/eris/steel/danger
/obj/item/scanner/health/advanced
/obj/item/scanner/health/improved
/obj/structure/reagent_dispensers/he3
/obj/item/ammo_magazine/clip
/obj/item/ammo_magazine/clip/c762
/obj/item/ammo_magazine/clip/c762/hunter
/obj/item/ammo_magazine/m10mm
/obj/item/ammo_magazine/m45
/obj/item/ammo_magazine/m45/practice
/obj/item/ammo_magazine/m45/rubber
/obj/item/ammo_magazine/m45/flash
/obj/item/ammo_magazine/m545
/obj/item/ammo_magazine/m545saw
/obj/item/ammo_magazine/m9mm
/obj/item/ammo_magazine/m9mmp90
/obj/item/ammo_magazine/m9mmt
/obj/item/ammo_magazine/m9mmt/rubber
/obj/item/ammo_magazine/m9mmt/practice
/obj/item/sticky_pad/poster
/obj/item/sticky_pad/poster/command
/obj/item/sticky_pad/poster/blue
/obj/item/sticky_pad/poster/yellow
/obj/item/folder/blue_captain
/obj/item/folder/blue_hop
/obj/item/folder/red_hos
/obj/item/folder/white
/obj/item/folder/white_cmo
/obj/item/folder/white_rd
/obj/item/folder/yellow_ce
/obj/item/eftpos/departmental/service
/obj/item/eftpos/departmental/security
/obj/item/eftpos/departmental/cargo
/obj/item/eftpos/departmental/command
/obj/item/clothing/webbing/bandolier/tactical
/obj/item/roller/advanced
/obj/item/bedsheet/bluedouble
/obj/item/bedsheet/browndouble
/obj/item/bedsheet/captaindouble
/obj/item/bedsheet/double
/obj/item/bedsheet/iandouble
/obj/item/bedsheet/mimedouble
/obj/item/bedsheet/orangedouble
/obj/item/bedsheet/purpledouble
/obj/item/bedsheet/rddouble
/obj/item/bedsheet/reddouble
/obj/item/bedsheet/yellowdouble
/obj/random/vendor/drink
/obj/random/vendor/food
/obj/item/soap/deluxe
/obj/item/soap/nanotrasen
/obj/item/soap/syndie
/obj/item/flashlight/red
/obj/item/radio/phone/medbay
/obj/item/radio/intercom/custom
/obj/item/radio/intercom/private
/obj/item/radio/intercom/locked/ai_private
/obj/item/radio/intercom/department
/obj/item/radio/intercom/department/security
/obj/item/radio/intercom/department/medbay
/obj/item/radio/intercom/specops
/obj/item/bladed/knife/tactical
/obj/item/bladed/knife/survival
/obj/machinery/door/firedoor/border_only
/obj/machinery/porta_turret/ai_defense
/obj/machinery/computer/cryopod/checkpoint
/obj/machinery/computer/cryopod/dorms
/obj/machinery/cryopod/robot/door/checkpoint