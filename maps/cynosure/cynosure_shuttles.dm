// Cynosure Shuttles
// Supply shuttle
/datum/shuttle/autodock/ferry/supply/cargo
	name = "Supply"
	location = 1
	warmup_time = 10
	move_time = 120
	shuttle_area = /area/shuttle/cynosure/supply
	dock_target = "supply_shuttle"
	waypoint_offsite = "supply_offsite"
	waypoint_station = "supply_station"
	//landmark_transition
	ceiling_type = /turf/floor/reinforced
	flags = SHUTTLE_FLAGS_PROCESS | SHUTTLE_FLAGS_SUPPLY | SHUTTLE_FLAGS_NO_CODE

/obj/effect/shuttle_landmark/cynosure/supply_offsite
	name = "Centcom Supply Depot"
	landmark_tag = "supply_offsite"
	base_area = /area/centcom/command
	base_turf = /turf/floor

/obj/effect/shuttle_landmark/cynosure/supply_station
	name = "Station"
	landmark_tag = "supply_station"
	docking_controller = "cargo_bay"
	base_area = /area/surface/outside/plains/station
	base_turf = /turf/floor/tiled/asteroid_steel


// Emergency shuttle
/datum/shuttle/autodock/ferry/emergency/escape_shuttle
	name = "Escape Shuttle"
	warmup_time = 10
	location = 1
	dock_target = "escape_shuttle"
	shuttle_area = /area/shuttle/cynosure/escape_shuttle
	waypoint_offsite = "escape_shuttle_start"
	waypoint_station = "escape_shuttle_station"
	landmark_transition = "escape_shuttle_transit"
	flags = SHUTTLE_FLAGS_PROCESS | SHUTTLE_FLAGS_NO_CODE

/obj/effect/shuttle_landmark/cynosure/escape_shuttle/start
	landmark_tag = "escape_shuttle_start"
	docking_controller = "centcom_escape_dock"
	base_area = /area/space
	base_turf = /turf/space

/obj/effect/shuttle_landmark/cynosure/escape_shuttle/transit
	landmark_tag = "escape_shuttle_transit"

/obj/effect/shuttle_landmark/cynosure/escape_shuttle/station
	landmark_tag = "escape_shuttle_station"
	docking_controller = "cynosure_escape_shuttle"
	base_area = /area/surface/outside/plains/station
	base_turf = /turf/floor/concrete


// Large Escape Pod A (Xenoarch Outpost)
/datum/shuttle/autodock/ferry/escape_pod/escape_pod_A
	name = "Large Escape Pod A"
	warmup_time = 10
	location = 0
	dock_target = "escape_pod_A"
	shuttle_area = /area/shuttle/cynosure/escape_pod_A
	waypoint_offsite = "escape_pod_A_start"
	waypoint_station = "escape_pod_A_station"
	arming_controller = "cynosure_escape_pod_A"
	landmark_transition = "escape_pod_A_transit"
	flags = SHUTTLE_FLAGS_PROCESS | SHUTTLE_FLAGS_NO_CODE

/obj/effect/shuttle_landmark/cynosure/escape_pod_A/start
	landmark_tag = "escape_pod_A_start"
	docking_controller = "centcom_escape_pod_A"
	base_area = /area/space
	base_turf = /turf/space

/obj/effect/shuttle_landmark/cynosure/escape_pod_A/transit
	landmark_tag = "escape_pod_A_transit"

/obj/effect/shuttle_landmark/cynosure/escape_pod_A/station
	landmark_tag = "escape_pod_A_station"
	docking_controller = "cynosure_escape_pod_A"
	base_area = /area/surface/outside/plains/station
	base_turf = /turf/floor/concrete


// Large Escape Pod B (Roof)
/datum/shuttle/autodock/ferry/escape_pod/escape_pod_B
	name = "Large Escape Pod B"
	warmup_time = 10
	location = 0
	dock_target = "escape_pod_B"
	shuttle_area = /area/shuttle/cynosure/escape_pod_B
	waypoint_offsite = "escape_pod_B_start"
	waypoint_station = "escape_pod_B_station"
	arming_controller = "cynosure_escape_pod_B"
	landmark_transition = "escape_pod_B_transit"
	flags = SHUTTLE_FLAGS_PROCESS | SHUTTLE_FLAGS_NO_CODE

/obj/effect/shuttle_landmark/cynosure/escape_pod_B/start
	landmark_tag = "escape_pod_B_start"
	docking_controller = "centcom_escape_pod_B"
	base_area = /area/space
	base_turf = /turf/space

/obj/effect/shuttle_landmark/cynosure/escape_pod_B/transit
	landmark_tag = "escape_pod_B_transit"

/obj/effect/shuttle_landmark/cynosure/escape_pod_B/station
	landmark_tag = "escape_pod_B_station"
	docking_controller = "cynosure_escape_pod_B"
	base_area = /area/surface/outside/station/roof
	base_turf = /turf/floor/plating




// TODO: Fix all remaining shuttles

/*
// Arrivals Shuttle
/datum/shuttle/autodock/ferry/arrivals/cynosure
	name = "Arrivals"
	location = FERRY_LOCATION_OFFSITE
	shuttle_area = /area/shuttle/arrival/pre_game
	landmark_offsite = "arrivals_offsite"
	landmark_station = "arrivals_station"
	docking_controller_tag = "arrivals_shuttle"
	ceiling_type = /turf/floor/reinforced

/obj/effect/shuttle_landmark/cynosure/arrivals_offsite
	name = "Transit to Station"
	landmark_tag = "arrivals_offsite"
	base_area = /area/space
	base_turf = /turf/space

/obj/effect/shuttle_landmark/cynosure/arrivals_station
	name = "Cynosure Arrivals Pad"
	landmark_tag = "arrivals_station"
	docking_controller = "arrivals_dock"
	base_turf = /turf/floor/concrete

// Cargo shuttle.



//Transport

/obj/machinery/computer/shuttle_control/multi/centcom
	name = "shuttle control console"
	shuttle_tag = "Centcom"
	req_access = list(access_cent_general)

/datum/shuttle/autodock/multi/centcom
	name = "Centcom"
	warmup_time = 0
	current_location = "centcom_shuttle_start"
	landmark_transition = "centcom_shuttle_transit"
	shuttle_area = /area/shuttle/transport1/centcom
	destination_tags = list(
		"centcom_shuttle_start",
		"nav_telecomm_dockarm",
		"nav_pad3_cynosure",
		"nav_pad4_cynosure",
		"nav_perimeter_cynosure",
		"nav_wilderness"
		)
	docking_controller_tag = "centcom_shuttle"
	ceiling_type = /turf/floor/reinforced
	announcer = "Automated Traffic Control"
	arrival_message = "Attention, Transport Shuttle is approaching Cynosure Station."
	departure_message = "Attention, Transport Shuttle is departing Cynosure Station."

//Administration

/obj/machinery/computer/shuttle_control/multi/administration
	name = "administration shuttle console"
	shuttle_tag = "Administration"
	req_access = list(access_cent_general)

/datum/shuttle/autodock/multi/administration
	name = "Administration"
	warmup_time = 0
	current_location = "admin_shuttle_start"
	landmark_transition = "admin_shuttle_transit"
	shuttle_area = /area/shuttle/administration/centcom
	destination_tags = list(
		"admin_shuttle_start",
		"nav_telecomm_dockarm",
		"nav_perimeter_cynosure",
		"nav_wilderness"
		)
	docking_controller_tag = "admin_shuttle"
	ceiling_type = /turf/floor/reinforced
	announcer = "Automated Traffic Control"
	arrival_message = "Attention, Administration Shuttle is approaching Cynosure Station."
	departure_message = "Attention, Administration Shuttle is departing Cynosure Station."

//ERT

/obj/machinery/computer/shuttle_control/multi/response
	name = "response shuttle console"
	shuttle_tag = "Response Operations"
	req_access = list(access_cent_specops)

/datum/shuttle/autodock/multi/response
	name = "Response Operations"
	can_cloak = TRUE
	cloaked = FALSE
	warmup_time = 5
	current_location = "response_ship_start"
	landmark_transition = "reponse_ship_transit"
	shuttle_area = /area/shuttle/response_ship/start
	destination_tags = list(
		"response_ship_start",
		"nav_telecomm_dockarm",
		"nav_pad3_cynosure",
		"nav_pad4_cynosure",
		"nav_perimeter_cynosure",
		"nav_wilderness"
		)
	docking_controller_tag = "response_shuttle"
	ceiling_type = /turf/floor/reinforced
	announcer = "Automated Traffic Control"
	arrival_message = "Attention, the Emergency Response Team's shuttle is approaching Cynosure Station."
	departure_message = "Attention, the Emergency Response Team's shuttle is departing Cynosure Station."

//Trader

/obj/machinery/computer/shuttle_control/multi/merchant
	name = "merchant shuttle control console"
	shuttle_tag = "Merchant"

/datum/shuttle/autodock/multi/merchant
	name = "Merchant"
	warmup_time = 0
	current_location = "trade_shuttle_start"
	landmark_transition = "trade_shuttle_transit"
	shuttle_area = /area/shuttle/merchant/home
	destination_tags = list(
		"trade_shuttle_start",
		"nav_perimeter_cynosure",
		"nav_wilderness"
		)
	docking_controller_tag = "trade_shuttle"
	ceiling_type = /turf/floor/reinforced
	announcer = "Automated Traffic Control"
	arrival_message = "Attention, Beruang is approaching Cynosure Station."
	departure_message = "Attention, Beruang is departing Cynosure Station."

//Ninja

/obj/machinery/computer/shuttle_control/multi/ninja
	name = "ninja shuttle console"
	shuttle_tag = "Ninja"
	req_access = list(access_syndicate)

/datum/shuttle/autodock/multi/ninja
	name = "Ninja"
	can_cloak = TRUE
	cloaked = TRUE
	warmup_time = 0
	current_location = "ninja_start"
	landmark_transition = "ninja_transit"
	shuttle_area = /area/ninja_dojo/start
	destination_tags = list(
		"ninja_start",
		"nav_telecomm_dockarm",
		"nav_telecomm_solars",
		"nav_pad3_cynosure",
		"nav_pad4_cynosure",
		"nav_perimeter_cynosure",
		"nav_wilderness"
		)
	docking_controller_tag = "ninja_shuttle"
	ceiling_type = /turf/floor/reinforced
	announcer = "Automated Traffic Control"
	arrival_message = "Attention, unknown shuttle is approaching Cynosure Station."
	departure_message = "Attention, unknown shuttle is departing Cynosure Station."

//Heist

/obj/machinery/computer/shuttle_control/multi/heist
	name = "skipjack control console"
	shuttle_tag = "Skipjack"
	req_access = list(access_syndicate)

/datum/shuttle/autodock/multi/heist
	name = "Skipjack"
	can_cloak = TRUE
	cloaked = TRUE
	warmup_time = 0
	current_location = "skipjack_start"
	landmark_transition = "skipjack_transit"
	shuttle_area = /area/skipjack_station/start
	destination_tags = list(
		"skipjack_start",
		"nav_telecomm_solars",
		"nav_perimeter_cynosure",
		"nav_wilderness"
		)
	docking_controller_tag = "skipjack_shuttle"
	ceiling_type = /turf/floor/reinforced
	announcer = "Automated Traffic Control"
	arrival_message = "Attention, unknown shuttle is approaching Cynosure Station."
	departure_message = "Attention, unknown shuttle is departing Cynosure Station."

//Mercenary

/obj/machinery/computer/shuttle_control/multi/mercenary
	name = "mercenary ship control console"
	shuttle_tag = "Mercenary"

/datum/shuttle/autodock/multi/mercenary
	name = "Mercenary"
	can_cloak = TRUE
	cloaked = TRUE
	warmup_time = 0
	current_location = "syndie_start"
	landmark_transition = "syndie_transit"
	shuttle_area = /area/syndicate_station/start
	destination_tags = list(
		"syndie_start",
		"nav_telecomm_solars",
		"nav_perimeter_cynosure",
		"nav_wilderness"
		)
	docking_controller_tag = "merc_shuttle"
	ceiling_type = /turf/floor/reinforced
	announcer = "Automated Traffic Control"
	arrival_message = "Attention, unknown shuttle is approaching Cynosure Station."
	departure_message = "Attention, unknown shuttle is departing Cynosure Station."

/obj/machinery/computer/shuttle_control/multi/mercenary_elite
	name = "mercenary ship control console"
	shuttle_tag = "Mercenary Elite"
	req_access = list(access_syndicate)

/datum/shuttle/autodock/multi/mercenary_elite
	name = "Mercenary Elite"
	can_cloak = TRUE
	cloaked = TRUE
	warmup_time = 0
	current_location = "syndie_elite_start"
	landmark_transition = "syndie_elite_transit"
	shuttle_area = /area/shuttle/syndicate_elite/mothership
	destination_tags = list(
		"syndie_elite_start",
		"nav_telecomm_dockarm",
		"nav_perimeter_cynosure",
		"nav_wilderness"
		)
	docking_controller_tag = "merc_elite_shuttle"
	ceiling_type = /turf/floor/reinforced
	announcer = "Automated Traffic Control"
	arrival_message = "Attention, unknown shuttle is approaching Cynosure Station."
	departure_message = "Attention, unknown shuttle is departing Cynosure Station."

//Cynosure Station Docks

/obj/effect/shuttle_landmark/cynosure/pads/pad3
	name = "Shuttle Pad Three"
	landmark_tag = "nav_pad3_cynosure"
	docking_controller = "pad3"
	base_area = /area/surface/outside/station/shuttle/pad3
	base_turf = /turf/floor/concrete

/obj/effect/shuttle_landmark/cynosure/pads/pad4
	name = "Shuttle Pad Four"
	landmark_tag = "nav_pad4_cynosure"
	docking_controller = "pad4"
	base_area = /area/surface/outside/station/shuttle/pad4
	base_turf = /turf/floor/concrete

/obj/effect/shuttle_landmark/cynosure/pads/perimeter
	name = "Cynosure Perimeter"
	landmark_tag = "nav_perimeter_cynosure"
	docking_controller = "pad4"
	base_area = /area/surface/outside/plains/station
	base_turf = /turf/floor/dirt

//Wilderness

/obj/effect/shuttle_landmark/cynosure/wilderness
	name = "Wilderness"
	landmark_tag = "nav_wilderness"
	base_area = /area/surface/outside/wilderness/deep
	base_turf = /turf/floor/dirt
*/
// Explorer Shuttle
/*
/datum/shuttle/autodock/overmap/explorer_shuttle
	name = "NTC Calvera"
	warmup_time = 0
	current_location = "nav_pad4_cynosure"
	docking_controller_tag = "expshuttle_docker"
	shuttle_area = list(/area/shuttle/exploration/general, /area/shuttle/exploration/cockpit, /area/shuttle/exploration/cargo)
	fuel_consumption = 3
	ceiling_type = /turf/floor/reinforced

/obj/effect/overmap/visitable/ship/landable/explorer_shuttle
	name = "NTC Calvera"
	desc = "The exploration team's shuttle."
	scanner_desc = "A Wulf Vagabond-class short-range expedition shuttle. It is broadcasting NanoTrasen identification codes: VIR-472-320377 - NTC Calvera."
	vessel_mass = 2000
	vessel_size = SHIP_SIZE_SMALL
	shuttle = "NTC Calvera"
	icon_state = "calvera"
	moving_state = "calvera_moving"

/obj/machinery/computer/shuttle_control/explore/explorer_shuttle
	name = "takeoff and landing console"
	shuttle_tag = "NTC Calvera"
	req_access = list(access_explorer)
*/