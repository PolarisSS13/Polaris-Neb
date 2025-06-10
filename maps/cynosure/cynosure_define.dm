// To be filled out when more progress on the new map occurs.

#define Z_LEVEL_STATION_ONE				1
#define Z_LEVEL_STATION_TWO				2
#define Z_LEVEL_STATION_THREE			3
#define Z_LEVEL_EMPTY_SPACE				4
#define Z_LEVEL_TCOMM					5
#define Z_LEVEL_CENTCOM					6
#define Z_LEVEL_SURFACE_WILD			7

/datum/map/cynosure
	name = "Cynosure"
	full_name = "Cynosure Station"
	path = "cynosure"

	lobby_screens = list('maps/cynosure/title_cynosure.png')

	/*
	lobby_tracks = list(
		/decl/music_track/chasing_time,
		/decl/music_track/epicintro2015,
		/decl/music_track/human,
		/decl/music_track/marhaba,
		/decl/music_track/treacherous_voyage,
		/decl/music_track/asfarasitgets,
		/decl/music_track/space_oddity,
		/decl/music_track/martiancowboy)

	holomap_smoosh = list(list(
		Z_LEVEL_STATION_ONE,
		Z_LEVEL_STATION_TWO,
		Z_LEVEL_STATION_THREE))

	zlevel_datum_type = /datum/map_z_level/cynosure
	*/

	station_name  = "Cynosure Station"
	station_short = "Cynosure"
	dock_name     = "NCS Northern Star" // Still the centcom!
	boss_name     = "Central Command"
	boss_short    = "Centcom"
	company_name  = "NanoTrasen"
	company_short = "NT"
	//starsys_name  = "Vir"

	shuttle_docked_message = "The scheduled shuttle to the %dock_name% has landed at Cynosure departures pad. It will depart in approximately %ETD%."
	shuttle_leaving_dock = "The Crew Transfer Shuttle has left the station. Estimate %ETA% until the shuttle docks at %dock_name%."
	shuttle_called_message = "A crew transfer to %dock_name% has been scheduled. The shuttle has been called. Those leaving should proceed to Cynosure Departures Pad in approximately %ETA%."
	shuttle_recall_message = "The scheduled crew transfer has been cancelled."
	emergency_shuttle_docked_message = "The Emergency Shuttle has landed at Cynosure departures pad. You have approximately %ETD% to board the Emergency Shuttle."
	emergency_shuttle_leaving_dock = "The Emergency Shuttle has left the station. Estimate %ETA% until the shuttle docks at %dock_name%."
	emergency_shuttle_called_message = "An emergency evacuation shuttle has been called. It will arrive at Cynosure departures pad in approximately %ETA%."
	emergency_shuttle_recall_message = "The emergency shuttle has been recalled."
	emergency_shuttle_called_sound = 'sound/AI/shuttlecalled.ogg'
	command_report_sound = 'sound/AI/commandreport.ogg'
	grid_check_sound = 'sound/AI/poweroff.ogg'
	grid_restored_sound = 'sound/AI/poweron.ogg'
	meteor_detected_sound = 'sound/AI/meteors.ogg'
	radiation_detected_sound = 'sound/AI/radiation.ogg'
	space_time_anomaly_sound = 'sound/AI/spanomalies.ogg'
	unidentified_lifesigns_sound = 'sound/AI/aliens.ogg'

	default_telecomms_channels = list(
		COMMON_FREQUENCY_DATA,
		list("name" = "Entertainment", "key" = "z", "frequency" = 1461, "color" = COMMS_COLOR_ENTERTAIN, "span_class" = CSS_CLASS_RADIO, "receive_only" = TRUE),
		list("name" = "Command",       "key" = "c", "frequency" = 1353, "color" = COMMS_COLOR_COMMAND,   "span_class" = "comradio", "secured" = list(access_bridge)),
		list("name" = "Security",      "key" = "s", "frequency" = 1359, "color" = COMMS_COLOR_SECURITY,  "span_class" = "secradio", "secured" = list(access_security)),
		list("name" = "Engineering",   "key" = "e", "frequency" = 1357, "color" = COMMS_COLOR_ENGINEER,  "span_class" = "engradio", "secured" = list(access_engine)),
		list("name" = "Medical",       "key" = "m", "frequency" = 1355, "color" = COMMS_COLOR_MEDICAL,   "span_class" = "medradio", "secured" = list(access_medical)),
		list("name" = "Science",       "key" = "n", "frequency" = 1351, "color" = COMMS_COLOR_SCIENCE,   "span_class" = "sciradio", "secured" = list(access_research)),
		list("name" = "Service",       "key" = "v", "frequency" = 1349, "color" = COMMS_COLOR_SERVICE,   "span_class" = "srvradio", "secured" = list(access_bar)),
		list("name" = "Supply",        "key" = "u", "frequency" = 1347, "color" = COMMS_COLOR_SUPPLY,    "span_class" = "supradio", "secured" = list(access_cargo)),
		list("name" = "Exploration",   "key" = "x", "frequency" = 1361, "color" = COMMS_COLOR_EXPLORER , "span_class" = "EXPradio", "secured" = list(access_eva)),
		list("name" = "AI Private",    "key" = "p", "frequency" = 1343, "color" = COMMS_COLOR_AI,        "span_class" = "airadio",  "secured" = list(access_ai_upload))
	)

	default_law_type = /datum/ai_laws/nanotrasen
	evac_controller_type = /datum/evacuation_controller/shuttle

	/*

	usable_email_tlds = list("freemail.nt")
	allowed_spawns = list(
		"Arrivals Shuttle",
		"Cryogenic Storage",
		"Cyborg Storage",
		"Checkpoint",
		"Wilderness"
	)
	use_overmap = 			TRUE
	overmap_size = 			20
	overmap_event_areas = 	6
	default_skybox = /datum/skybox_settings/cynosure

	unit_test_exempt_areas = list(
		/area/ninja_dojo,
		/area/ninja_dojo/firstdeck,
		/area/ninja_dojo/arrivals_dock,
		/area/surface/cave,
		/area/surface/station/construction,
		/area/surface/station/rnd/test_area
	)
	unit_test_exempt_from_atmos = list(
		/area/tcommsat/chamber,
		/area/surface/station/maintenance
	)

	planet_datums_to_make = list(/datum/planet/sif)

	map_levels = list(
			Z_LEVEL_STATION_ONE,
			Z_LEVEL_STATION_TWO,
			Z_LEVEL_STATION_THREE,
			Z_LEVEL_SURFACE_WILD
		)

	the_station_areas = list(
	/area/surface/station,
	/area/shuttle/arrival,
	/area/shuttle/escape/station,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/shuttle/large_escape_pod1/station,
	/area/shuttle/large_escape_pod2/station,
	/area/shuttle/mining/station,
	/area/shuttle/transport1/station,
	/area/shuttle/prison/station,
	/area/shuttle/administration/station,
	/area/shuttle/specops/station
	)

	hallway_areas = /area/surface/station/hallway
	maintenance_areas = /area/surface/station/maintenance

/datum/map/cynosure/perform_map_generation()
	// First, place a bunch of submaps. This comes before tunnel/forest generation as to not interfere with the submap.

	// Cave submaps are first.
	SSmapping.seed_area_submaps(
		list(Z_LEVEL_STATION_ONE),
		75,
		/area/surface/cave/unexplored/normal,
		/datum/map_template/surface/mountains/normal
	)
	SSmapping.seed_area_submaps(
		list(Z_LEVEL_STATION_ONE),
		75,
		/area/surface/cave/unexplored/deep,
		/datum/map_template/surface/mountains/deep
	)

	// Plains to make them less plain.
	SSmapping.seed_area_submaps(
		list(Z_LEVEL_STATION_TWO),
		100,
		/area/surface/outside/plains/normal,
		/datum/map_template/surface/plains
	) // Center area is WIP until map editing settles down.

	// Wilderness is next.
	SSmapping.seed_area_submaps(
		list(Z_LEVEL_SURFACE_WILD),
		75,
		/area/surface/outside/wilderness/normal,
		/datum/map_template/surface/wilderness/normal
	)

	SSmapping.seed_area_submaps(
		list(Z_LEVEL_SURFACE_WILD),
		75,
		/area/surface/outside/wilderness/deep,
		/datum/map_template/surface/wilderness/deep
	)
	return 1
*/
/datum/map/cynosure/get_map_info()
	. = list()
	. +=  "[full_name] is a a cutting-edge anomaly research facility on the frozen garden world of Sif, jewel of the Vir system.<br>"
	. +=  "Following the Skathari Incursion, an invasion of reality-bending creatures from the remnants of a dead universe, the known galaxy has been thrown into disarray.<br>"
	. +=  "The Solar Confederate Government struggles under its own weight, with new factions arising with promises of autonomy, security or profit like circling vultures.<br>"
	. +=  "Humanity already stands on the precipice of a technological singularity that few are ready to face, and the winds of change whip at their backs.<br>"
	. +=  "On the edge of Sif's Anomalous Region, NanoTrasen seeks to exploit new phenomena stirred by the Incursion... That's where you come in."
	return jointext(., "<br>")
/*
// Skybox Settings
/datum/skybox_settings/cynosure
	icon_state = "dyable"
	random_color = TRUE

// For making the 6-in-1 holomap, we calculate some offsets
#define SOUTHERN_CROSS_MAP_SIZE 160 // Width and height of compiled in Southern Cross z levels.
#define SOUTHERN_CROSS_HOLOMAP_CENTER_GUTTER 40 // 40px central gutter between columns
#define SOUTHERN_CROSS_HOLOMAP_MARGIN_X ((HOLOMAP_ICON_SIZE - (2*SOUTHERN_CROSS_MAP_SIZE) - SOUTHERN_CROSS_HOLOMAP_CENTER_GUTTER) / 2) // 100
#define SOUTHERN_CROSS_HOLOMAP_MARGIN_Y ((HOLOMAP_ICON_SIZE - (3*SOUTHERN_CROSS_MAP_SIZE)) / 2) // 60

/datum/map_z_level/cynosure/station
	flags = MAP_LEVEL_STATION|MAP_LEVEL_CONTACT|MAP_LEVEL_PLAYER|MAP_LEVEL_CONSOLES
	holomap_legend_x = 220
	holomap_legend_y = 160

/datum/map_z_level/cynosure/station/station_one
	z = Z_LEVEL_STATION_ONE
	name = "Underground"
	flags = MAP_LEVEL_STATION|MAP_LEVEL_CONTACT|MAP_LEVEL_PLAYER|MAP_LEVEL_CONSOLES|MAP_LEVEL_SEALED|MAP_LEVEL_UNDERGROUND
	base_turf = /turf/floor/rock
	holomap_offset_x = SOUTHERN_CROSS_HOLOMAP_MARGIN_X - 40
	holomap_offset_y = SOUTHERN_CROSS_HOLOMAP_MARGIN_Y + SOUTHERN_CROSS_MAP_SIZE*0
	event_regions = list(EVENT_REGION_PLANETSURFACE, EVENT_REGION_PLAYER_MAIN_AREA)

/datum/map_z_level/cynosure/station/station_two
	z = Z_LEVEL_STATION_TWO
	name = "Surface"
	flags = MAP_LEVEL_STATION|MAP_LEVEL_CONTACT|MAP_LEVEL_PLAYER|MAP_LEVEL_CONSOLES|MAP_LEVEL_SEALED
	base_turf = /turf/open
	holomap_offset_x = SOUTHERN_CROSS_HOLOMAP_MARGIN_X - 40
	holomap_offset_y = SOUTHERN_CROSS_HOLOMAP_MARGIN_Y + SOUTHERN_CROSS_MAP_SIZE*1
	event_regions = list(EVENT_REGION_PLANETSURFACE, EVENT_REGION_PLAYER_MAIN_AREA, EVENT_REGION_SUBTERRANEAN)

/datum/map_z_level/cynosure/station/station_three
	z = Z_LEVEL_STATION_THREE
	name = "Deck 2"
	flags = MAP_LEVEL_STATION|MAP_LEVEL_CONTACT|MAP_LEVEL_PLAYER|MAP_LEVEL_CONSOLES|MAP_LEVEL_SEALED
	base_turf = /turf/open
	holomap_offset_x = HOLOMAP_ICON_SIZE - SOUTHERN_CROSS_HOLOMAP_MARGIN_X - SOUTHERN_CROSS_MAP_SIZE - 40
	holomap_offset_y = SOUTHERN_CROSS_HOLOMAP_MARGIN_Y + SOUTHERN_CROSS_MAP_SIZE*1
	event_regions = list(EVENT_REGION_PLANETSURFACE, EVENT_REGION_PLAYER_MAIN_AREA)

/datum/map_z_level/cynosure/empty_space
	z = Z_LEVEL_EMPTY_SPACE
	name = "Empty"
	flags = MAP_LEVEL_PLAYER
	transit_chance = 76
	event_regions = list(EVENT_REGION_DEEPSPACE)

/datum/map_z_level/cynosure/tcomm
	z = Z_LEVEL_TCOMM
	name = "Telecommunications Satellite"
	flags = MAP_LEVEL_PLAYER|MAP_LEVEL_CONTACT
	transit_chance = 24
	event_regions = list(EVENT_REGION_SPACESTATION)

/datum/map_z_level/cynosure/centcom
	z = Z_LEVEL_CENTCOM
	name = "Centcom"
	flags = MAP_LEVEL_ADMIN|MAP_LEVEL_CONTACT | MAP_LEVEL_SEALED

/datum/map_z_level/cynosure/surface_wild
	z = Z_LEVEL_SURFACE_WILD
	name = "Wilderness"
	flags = MAP_LEVEL_PLAYER|MAP_LEVEL_SEALED|MAP_LEVEL_CONTACT|MAP_LEVEL_CONSOLES
	base_turf = /turf/floor/rock
	event_regions = list(EVENT_REGION_PLANETSURFACE)

*/


