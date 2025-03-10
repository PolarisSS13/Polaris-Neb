/*
 *
 *  Map Unit Tests.
 *  Zone checks / APC / Scrubber / Vent / Cryopod Computers.
 *
 *
 */
/datum/unit_test/apc_area_test
	name = "MAP: Area Test APC / Scrubbers / Vents"


/datum/unit_test/apc_area_test/start_test()
	var/list/bad_areas = list()
	var/area_test_count = 0

	for(var/area/A in global.areas)
		if(!A.z)
			continue
		if(!isPlayerLevel(A.z))
			continue
		area_test_count++
		var/area_good = 1
		var/bad_msg = "--------------- [A.proper_name]([A.type])"

		var/exemptions = get_exemptions(A)
		if(!A.apc && !(exemptions & global.using_map.NO_APC))
			log_bad("[bad_msg] lacks an APC.")
			area_good = 0
		else if(A.apc && (exemptions & global.using_map.NO_APC))
			log_bad("[bad_msg] is not supposed to have an APC.")
			area_good = 0

		if(!A.air_scrub_names.len && !(exemptions & global.using_map.NO_SCRUBBER))
			log_bad("[bad_msg] lacks an air scrubber.")
			area_good = 0
		else if(A.air_scrub_names.len && (exemptions & global.using_map.NO_SCRUBBER))
			log_bad("[bad_msg] is not supposed to have an air scrubber.")
			area_good = 0

		if(!A.air_vent_names.len && !(exemptions & global.using_map.NO_VENT))
			log_bad("[bad_msg] lacks an air vent.[ascii_reset]")
			area_good = 0
		else if(A.air_vent_names.len && (exemptions & global.using_map.NO_VENT))
			log_bad("[bad_msg] is not supposed to have an air vent.")
			area_good = 0

		if(!area_good)
			bad_areas.Add(A)

	if(bad_areas.len)
		fail("\[[bad_areas.len]/[area_test_count]\]Some areas did not have the expected APC/vent/scrubber setup.")
	else
		pass("All \[[area_test_count]\] areas contained APCs, air scrubbers, and air vents.")

	return 1

/datum/unit_test/apc_area_test/proc/get_exemptions(var/area)
	// We assume deeper types come last
	for(var/i = global.using_map.apc_test_exempt_areas.len; i>0; i--)
		var/exempt_type = global.using_map.apc_test_exempt_areas[i]
		if(istype(area, exempt_type))
			return global.using_map.apc_test_exempt_areas[exempt_type]

/datum/unit_test/air_alarm_connectivity
	name = "MAP: Air alarms shall receive updates."
	async = TRUE // Waits for SStimers to finish one full run before testing

/datum/unit_test/air_alarm_connectivity/start_test()
	return 1

/datum/unit_test/air_alarm_connectivity/subsystems_to_await()
	return list(SStimer, SSalarm, SSmachines)

/datum/unit_test/air_alarm_connectivity/check_result()
	var/failed = FALSE
	for(var/area/A in global.areas)
		if(!A.z)
			continue
		if(!isPlayerLevel(A.z))
			continue
		// Only test areas with functional alarms
		var/obj/machinery/alarm/found_alarm
		for (var/obj/machinery/alarm/alarm in A)
			if(alarm.inoperable()) // must have at least one functional alarm
				continue
			found_alarm = alarm

		if(!found_alarm)
			continue

		//Make a list of devices that are being controlled by their air alarms
		var/list/vents_in_area = list()
		var/list/scrubbers_in_area = list()
		for(var/obj/machinery/atmospherics/unary/vent_pump/V in A.contents)
			if(V.controlled)
				vents_in_area[V.id_tag] = V
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/V in A.contents)
			if(V.controlled)
				scrubbers_in_area[V.id_tag] = V

		for(var/tag in vents_in_area) // The point of this test is that while the names list is registered at init, the info is transmitted by radio.
			if(!A.air_vent_info[tag])
				var/obj/machinery/atmospherics/unary/vent_pump/V = vents_in_area[tag]
				var/logtext = "Vent [A.air_vent_names[tag]] ([V.x], [V.y], [V.z]) with id_tag [tag] did not update [log_info_line(found_alarm)] in area [A]."
				if(V.inoperable())
					logtext = "[logtext] The vent was not functional."
				var/alarm_dist = get_dist(found_alarm, V)
				if(alarm_dist > 60)
					logtext += " The vent may be out of transmission range (max 60, was [alarm_dist])."
				var/V_freq
				for(var/obj/item/stock_parts/radio/radio_component in V.component_parts)
					V_freq ||= radio_component.frequency
				if(isnull(V_freq))
					logtext += " The vent had no frequency set."
				else if(V_freq != found_alarm.frequency)
					logtext += " Frequencies did not match (alarm: [found_alarm.frequency], vent: [V_freq])."
				log_bad(logtext)
				failed = TRUE
		for(var/tag in scrubbers_in_area)
			if(!A.air_scrub_info[tag])
				var/obj/machinery/atmospherics/unary/vent_scrubber/V = scrubbers_in_area[tag]
				var/logtext = "Scrubber [A.air_scrub_names[tag]] ([V.x], [V.y], [V.z]) with id_tag [tag] did not update [log_info_line(found_alarm)] in area [A]."
				if(V.inoperable())
					logtext = "[logtext] The scrubber was not functional."
				var/alarm_dist = get_dist(found_alarm, V)
				if(alarm_dist > 60)
					logtext += " The scrubber may be out of transmission range (max 60, was [alarm_dist])."
				var/V_freq
				for(var/obj/item/stock_parts/radio/radio_component in V.component_parts)
					V_freq ||= radio_component.frequency
				if(isnull(V_freq))
					logtext += " The scrubber had no frequency set."
				else if(V_freq != found_alarm.frequency)
					logtext += " Frequencies did not match (alarm: [found_alarm.frequency], scrubber: [V_freq])."
				log_bad(logtext)
				failed = TRUE

	if(failed)
		fail("Some areas did not receive updates from all of their atmos devices.")
	else
		pass("All atmos devices updated their area's air alarms successfully.")

	return 1
//=======================================================================================

/datum/unit_test/wire_test
	name = "MAP: Cable Overlap Test"

/datum/unit_test/wire_test/start_test()
	var/wire_test_count = 0
	var/bad_tests = 0
	var/turf/T = null
	var/obj/structure/cable/C = null
	var/list/cable_turfs = list()
	var/list/dirs_checked = list()

	for(C in world)
		T = get_turf(C)
		cable_turfs |= get_turf(C)

	for(T in cable_turfs)
		var/bad_msg = "[ascii_red]--------------- [T.name] \[[T.x] / [T.y] / [T.z]\]"
		dirs_checked.Cut()
		for(C in T)
			wire_test_count++
			var/combined_dir = "[C.d1]-[C.d2]"
			if(combined_dir in dirs_checked)
				bad_tests++
				log_unit_test("[bad_msg] Contains multiple wires with same direction on top of each other.")
			dirs_checked.Add(combined_dir)

	if(bad_tests)
		fail("\[[bad_tests] / [wire_test_count]\] Some turfs had overlapping wires going the same direction.")
	else
		pass("All \[[wire_test_count]\] wires had no overlapping cables going the same direction.")

	return 1

//=======================================================================================

/datum/unit_test/wire_dir_and_icon_stat
	name = "MAP: Cable Dir And Icon State Test"

/datum/unit_test/wire_dir_and_icon_stat/start_test()
	var/list/bad_cables = list()

	for(var/obj/structure/cable/C in global.all_cables)
		var/expected_icon_state = "[C.d1]-[C.d2]"
		if(C.icon_state != expected_icon_state)
			bad_cables |= C
			log_bad("[log_info_line(C)] has an invalid icon state. Expected [expected_icon_state], was [C.icon_state]")
		if(!(C.icon_state in icon_states(C.icon)))
			bad_cables |= C
			log_bad("[log_info_line(C)] has an non-existing icon state.")

	if(bad_cables.len)
		fail("Found [bad_cables.len] cable\s with an unexpected icon state.")
	else
		pass("All wires had their expected icon state.")

	return 1

//=======================================================================================

/datum/unit_test/closet_test
	name = "MAP: Closet Capacity Test Player Z levels"

/datum/unit_test/closet_test/start_test()
	var/bad_tests = 0

	for(var/obj/structure/closet/C in global.closets)
		if(!C.opened && isPlayerLevel(C.z))
			var/total_content_size = 0
			for(var/atom/movable/AM in C.contents)
				total_content_size += C.content_size(AM)
			if(total_content_size > C.storage_capacity)
				log_bad("[log_info_line(C)] contains more objects than able to hold ([total_content_size] / [C.storage_capacity]).")
				bad_tests++

	if(bad_tests)
		fail("\[[bad_tests]\] Some closets contained more objects than they were able to hold.")
	else
		pass("No overflowing closets found.")

	return 1

//=======================================================================================

/datum/unit_test/closet_containment_test
	name = "MAP: Closet Containment Test Player Z levels"
	var/list/exceptions = list()

/datum/unit_test/closet_containment_test/start_test()
	var/bad_tests = 0

	for(var/obj/structure/closet/C in global.closets)
		if(exceptions[C.type])
			continue
		if(!C.opened && isPlayerLevel(C.z))
			var/contents_pre_open = C.contents.Copy()
			C.dump_contents()
			C.store_contents()
			var/list/no_longer_contained_atoms = contents_pre_open - C.contents
			var/list/previously_not_contained_atoms = C.contents - contents_pre_open

			if(no_longer_contained_atoms.len)
				bad_tests++
				log_bad("[log_info_line(C)] no longer contains the following atoms: [log_info_line(no_longer_contained_atoms)]")
			if(previously_not_contained_atoms.len)
				log_debug("[log_info_line(C)] now contains the following atoms: [log_info_line(previously_not_contained_atoms)]")

	if(bad_tests)
		fail("[bad_tests] closet\s with inconsistent pre/post-open contents found.")
	else
		pass("No closets with inconsistent pre/post-open contents found.")

	return 1

//=======================================================================================

/datum/unit_test/storage_map_test
	name = "MAP: On Map Storage Item Capacity Test Player Z levels"

/datum/unit_test/storage_map_test/start_test()
	var/bad_tests = 0

// We have to ifdef this because _test_storage_items doesn't exist when UNIT_TEST isn't defined.
#ifdef UNIT_TEST
	for(var/datum/storage/storage in global._test_storage_items)
		if(storage.holder?.z && isPlayerLevel(storage.holder.z))
			var/bad_msg = "[ascii_red]--------------- [storage.holder.name] \[[storage.holder.type]\] \[[storage.holder.x] / [storage.holder.y] / [storage.holder.z]\]"
			bad_tests += test_storage_capacity(storage, bad_msg)
#endif

	if(bad_tests)
		fail("\[[bad_tests]\] Some on-map storage items were not able to hold their initial contents.")
	else
		pass("All on-map storage items were able to hold their initial contents.")

	return 1
/datum/unit_test/map_image_map_test
	name = "MAP: All map levels shall have a corresponding map image."

/datum/unit_test/map_image_map_test/start_test()
	var/failed = FALSE

	for(var/z in SSmapping.map_levels)
		var/file_name = map_image_file_name(z)
		var/file_path = MAP_IMAGE_PATH + file_name
		if(!fexists(file_path))
			failed = TRUE
			log_unit_test("[global.using_map.path]-[z] is missing its map image [file_name].")

	if(failed)
		fail("One or more map levels were missing a corresponding map image.")
	else
		pass("All map levels had a corresponding image.")

	return 1

//=======================================================================================

/datum/unit_test/correct_allowed_spawn_test
	name = "MAP: All allowed_latejoin_spawns entries should have spawnpoints on map."

/datum/unit_test/correct_allowed_spawn_test/start_test()

	var/list/failed = list()
	var/list/check_spawn_flags = list(
		"SPAWN_FLAG_PRISONERS_CAN_SPAWN"   = SPAWN_FLAG_PRISONERS_CAN_SPAWN,
		"SPAWN_FLAG_JOBS_CAN_SPAWN"        = SPAWN_FLAG_JOBS_CAN_SPAWN,
		"SPAWN_FLAG_PERSISTENCE_CAN_SPAWN" = SPAWN_FLAG_PERSISTENCE_CAN_SPAWN
	)

	// Check that all flags are represented in compiled spawnpoints.
	// The actual validation will happen at the end of the proc.
	var/list/all_spawnpoints = decls_repository.get_decls_of_subtype(/decl/spawnpoint)
	for(var/spawn_type in all_spawnpoints)
		var/decl/spawnpoint/spawnpoint = all_spawnpoints[spawn_type]
		// No turfs probably means it isn't mapped; if it's in the allowed list this will be picked up below.
		if(!length(spawnpoint.get_spawn_turfs()))
			continue
		if(spawnpoint.spawn_flags)
			for(var/spawn_flag in check_spawn_flags)
				if(spawnpoint.spawn_flags & check_spawn_flags[spawn_flag])
					check_spawn_flags -= spawn_flag
		if(!length(check_spawn_flags))
			break

	// Check if spawn points have any turfs at all associated.
	for(var/decl/spawnpoint/spawnpoint as anything in global.using_map.allowed_latejoin_spawns)
		if(!length(spawnpoint.get_spawn_turfs()))
			log_unit_test("Map allows spawning in [spawnpoint.name], but [spawnpoint.name] has no associated spawn turfs.")
			failed += spawnpoint.type

	// Validate our forced job spawnpoints since they may not be included in allowed_latejoin_spawns.
	for(var/job_title in SSjobs.titles_to_datums)
		var/datum/job/job = SSjobs.titles_to_datums[job_title]
		if(!job.forced_spawnpoint)
			continue
		var/decl/spawnpoint/spawnpoint = GET_DECL(job.forced_spawnpoint)
		if(!spawnpoint.check_job_spawning(job))
			log_unit_test("Forced spawnpoint for [job_title], [spawnpoint.name], does not permit the job to spawn there.")
			failed += spawnpoint.type
		if(!length(spawnpoint.get_spawn_turfs()))
			log_unit_test("Job [job_title] forces spawning in [spawnpoint.name], but [spawnpoint.name] has no associated spawn turfs.")
			failed += spawnpoint.type

	// Observer spawn is special and isn't in the using_map list.
	var/decl/spawnpoint/observer_spawn = GET_DECL(/decl/spawnpoint/observer)
	if(!length(observer_spawn.get_spawn_turfs()))
		log_unit_test("Map has no [observer_spawn.name] spawn turfs.")
		failed += observer_spawn.type
	if(!(observer_spawn.spawn_flags & SPAWN_FLAG_GHOSTS_CAN_SPAWN))
		log_unit_test("[observer_spawn.name] is missing SPAWN_FLAG_GHOSTS_CAN_SPAWN.")
		failed |= observer_spawn.type

	// Report test outcome.
	if(!length(failed) && !length(check_spawn_flags))
		pass("All allowed spawnpoints have spawnpoint turfs.")
	else
		var/list/failstring = list()
		if(length(failed))
			failstring += "Some allowed spawnpoints have no spawnpoint turfs:\n[jointext(failed, "\n")]"
		if(length(check_spawn_flags))
			failstring += "Some required spawn flags are not set on available spawnpoints:\n[jointext(check_spawn_flags, "\n")]"
		fail(jointext(failstring, "\n"))
	return 1

//=======================================================================================

/datum/unit_test/map_check
	name = "MAP: Map Check"

/datum/unit_test/map_check/start_test()
	if(world.maxx < 1 || world.maxy < 1 || world.maxz < 1)
		fail("Unexpected map size. Was a map properly included?")
	else
		pass("Map size met minimum requirements.")
	return 1
//=======================================================================================

/datum/unit_test/ladder_check
	name = "MAP: Ladder Check"

/datum/unit_test/ladder_check/start_test()
	var/failed
	for(var/obj/structure/ladder/L)
		if(HasAbove(L.z))
			var/turf/T = GetAbove(L)
			if(!istype(T) || !T.is_open() && (locate(/obj/structure/ladder) in T))
				LAZYADD(failed, "[L.x],[L.y],[L.z]")
				continue
		if(HasBelow(L.z))
			var/turf/T = get_turf(L)
			if((!istype(T) || !T.is_open()) && (locate(/obj/structure/ladder) in GetBelow(L)))
				LAZYADD(failed, "[L.x],[L.y],[L.z]")
				continue
	if(LAZYLEN(failed))
		fail("[LAZYLEN(failed)] ladder\s are incorrectly setup: [english_list(failed)].")
	else
		pass("All ladders are correctly setup.")
	return 1

//=======================================================================================

/datum/unit_test/landmark_check
	name = "MAP: Landmark Check"

/datum/unit_test/landmark_check/start_test()
	var/safe_landmarks = 0
	var/space_landmarks = 0

	for(var/lm in global.all_landmarks)
		var/obj/abstract/landmark/landmark = lm
		if(istype(landmark, /obj/abstract/landmark/test/safe_turf))
			log_debug("Safe landmark found: [log_info_line(landmark)]")
			safe_landmarks++
		else if(istype(landmark, /obj/abstract/landmark/test/space_turf))
			log_debug("Space landmark found: [log_info_line(landmark)]")
			space_landmarks++
		else if(istype(landmark, /obj/abstract/landmark/test))
			log_debug("Test landmark with unknown tag found: [log_info_line(landmark)]")

	if(safe_landmarks != 1 || space_landmarks != 1)
		if(safe_landmarks != 1)
			log_bad("Found [safe_landmarks] safe landmarks. Expected 1.")
		if(space_landmarks != 1)
			log_bad("Found [space_landmarks] space landmarks. Expected 1.")
		fail("Expected exactly one safe landmark, and one space landmark.")
	else
		pass("Exactly one safe landmark, and exactly one space landmark found.")

	return 1

//=======================================================================================

/datum/unit_test/cryopod_comp_check
	name = "MAP: Cryopod Validity Check"

/datum/unit_test/cryopod_comp_check/start_test()
	var/pass = TRUE

	for(var/obj/machinery/cryopod/C in SSmachines.machinery)
		if(!C.control_computer)
			log_bad("[get_area_name(C)] lacks a cryopod control computer while holding a cryopod.")
			pass = FALSE

	for(var/obj/machinery/computer/cryopod/C in SSmachines.machinery)
		if(!(locate(/obj/machinery/cryopod) in get_area(C)))
			log_bad("[get_area_name(C)] lacks a cryopod while holding a control computer.")
			pass = FALSE

	if(pass)
		pass("All cryopods have their respective control computers.")
	else
		fail("Cryopods were not set up correctly.")

	return 1

//=======================================================================================

/datum/unit_test/camera_nil_c_tag_check
	name = "MAP: Camera nil c_tag check"

/datum/unit_test/camera_nil_c_tag_check/start_test()
	var/pass = TRUE

	for(var/obj/machinery/camera/C in SSmachines.machinery)
		if(!C.c_tag)
			log_bad("Following camera does not have a c_tag set: [log_info_line(C)]")
			pass = FALSE

	if(pass)
		pass("All cameras have the c_tag set.")
	else
		fail("One or more cameras do not have the c_tag set.")

	return 1

//=======================================================================================

/datum/unit_test/camera_unique_c_tag_check
	name = "MAP: Camera unique c_tag check"

/datum/unit_test/camera_unique_c_tag_check/start_test()
	var/cameras_by_ctag = list()
	var/checked_cameras = 0

	for(var/obj/machinery/camera/C in SSmachines.machinery)
		if(!C.c_tag)
			continue
		checked_cameras++
		group_by(cameras_by_ctag, C.c_tag, C)

	var/number_of_issues = number_of_issues(cameras_by_ctag, "Camera c_tags", /decl/noi_feedback/detailed)
	if(number_of_issues)
		fail("[number_of_issues] issue\s with camera c_tags found.")
	else
		pass("[checked_cameras] camera\s have a unique c_tag.")

	return 1

//=======================================================================================

// These vars are used to avoid in-world loops in the following unit test.
var/global/_unit_test_disposal_segments = list()
var/global/_unit_test_sort_junctions = list()

#ifdef UNIT_TEST
/obj/structure/disposalpipe/segment/Initialize(mapload)
	. = ..()
	_unit_test_disposal_segments += src

/obj/structure/disposalpipe/segment/Destroy()
	_unit_test_disposal_segments -= src
	return ..()

/obj/structure/disposalpipe/sortjunction/Initialize(mapload)
	. = ..()
	_unit_test_sort_junctions += src

/obj/structure/disposalpipe/sortjunction/Destroy()
	_unit_test_sort_junctions -= src
	return ..()
#endif

/datum/unit_test/disposal_segments_shall_connect_with_other_disposal_pipes
	name = "MAP: Disposal segments shall connect with other disposal pipes"

/datum/unit_test/disposal_segments_shall_connect_with_other_disposal_pipes/start_test()
	var/list/faulty_pipes = list()

	// Desired directions for straight pipes, when encountering curved pipes in the main and reversed dir respectively
	var/list/straight_desired_directions = list(
		num2text(SOUTH) = list(list(NORTH, WEST), list(SOUTH, EAST)),
		num2text(EAST) = list(list(SOUTH, WEST), list(NORTH, EAST)))

	// Desired directions for curved pipes:
	// list(desired_straight, list(desired_curved_one, desired_curved_two) in the main and curved direction
	var/list/curved_desired_directions = list(
		num2text(NORTH) = list(list(SOUTH, list(SOUTH, EAST)), list(EAST,  list(SOUTH, WEST))),
		num2text(EAST)  = list(list(EAST,  list(SOUTH, WEST)), list(SOUTH, list(NORTH, WEST))),
		num2text(SOUTH) = list(list(SOUTH, list(NORTH, WEST)), list(EAST,  list(NORTH, EAST))),
		num2text(WEST)  = list(list(EAST,  list(NORTH, EAST)), list(SOUTH, list(SOUTH, EAST))))

	for(var/obj/structure/disposalpipe/segment/D in _unit_test_disposal_segments)
		if(!D.loc)
			continue
		if(D.icon_state == "pipe-s")
			if(!(D.dir == SOUTH || D.dir == EAST))
				log_bad("Following disposal pipe has an invalid direction set: [log_info_line(D)]")
				continue
			var/turf/turf_one = get_step(D.loc, D.dir)
			var/turf/turf_two = get_step(D.loc, turn(D.dir, 180))

			var/list/desired_dirs = straight_desired_directions[num2text(D.dir)]
			if(!turf_contains_matching_disposal_pipe(turf_one, D.dir, desired_dirs[1]) || !turf_contains_matching_disposal_pipe(turf_two, D.dir, desired_dirs[2]))
				log_bad("Following disposal pipe does not connect correctly: [log_info_line(D)]")
				faulty_pipes += D
		else
			var/turf/turf_one = get_step(D.loc, D.dir)
			var/turf/turf_two = get_step(D.loc, turn(D.dir, -90))

			var/list/desired_dirs = curved_desired_directions[num2text(D.dir)]
			var/main_dirs = desired_dirs[1]
			var/rev_dirs = desired_dirs[2]

			if(!turf_contains_matching_disposal_pipe(turf_one, main_dirs[1], main_dirs[2]) || !turf_contains_matching_disposal_pipe(turf_two, rev_dirs[1], rev_dirs[2]))
				log_bad("Following disposal pipe does not connect correctly: [log_info_line(D)]")
				faulty_pipes += D

	if(faulty_pipes.len)
		fail("[faulty_pipes.len] disposal segment\s did not connect with other disposal pipes.")
	else
		pass("All disposal segments connect with other disposal pipes.")

	return 1

/datum/unit_test/disposal_segments_shall_connect_with_other_disposal_pipes/proc/turf_contains_matching_disposal_pipe(var/turf/T, var/straight_dir, var/list/curved_dirs)
	if(!T)
		return FALSE

	// We need to loop over all potential pipes in a turf as long as there isn't a dir match, as they may be overlapping (i.e. 2 straight pipes in a cross)
	for(var/obj/structure/disposalpipe/D in T)
		if(D.type == /obj/structure/disposalpipe/segment)
			if(D.icon_state == "pipe-s")
				if(D.dir == straight_dir)
					return TRUE
			else
				if(D.dir in curved_dirs)
					return TRUE
		else
			return TRUE
	return FALSE

//=======================================================================================

// Having them face north or west is now supported fully in code; this is for map consistency.
/datum/unit_test/simple_pipes_shall_not_face_north_or_west
	name = "MAP: Simple pipes shall not face north or west"

/datum/unit_test/simple_pipes_shall_not_face_north_or_west/start_test()
	var/failures = 0
	for(var/obj/machinery/atmospherics/pipe/simple/pipe in SSmachines.machinery)
		if(!istype(pipe, /obj/machinery/atmospherics/pipe/simple/hidden) && !istype(pipe, /obj/machinery/atmospherics/pipe/simple/visible))
			continue
		if(pipe.dir == NORTH || pipe.dir == WEST)
			log_bad("Following pipe had an invalid direction: [log_info_line(pipe)]")
			failures++

	if(failures)
		fail("[failures] simple pipe\s faced the wrong direction.")
	else
		pass("All simple pipes faced an appropriate direction.")
	return 1

//=======================================================================================

/datum/unit_test/shutoff_valves_shall_connect_to_two_different_pipe_networks
	name = "MAP: Shutoff valves shall connect to two different pipe networks"

/datum/unit_test/shutoff_valves_shall_connect_to_two_different_pipe_networks/start_test()
	var/failures = 0
	for(var/obj/machinery/atmospherics/valve/shutoff/SV in SSmachines.machinery)
		SV.close()
	for(var/obj/machinery/atmospherics/valve/shutoff/SV in SSmachines.machinery)
		if(SV.network_in_dir(SV.dir) == SV.network_in_dir(turn(SV.dir, 180)))
			log_bad("Following shutoff valve does not connect to two different pipe networks: [log_info_line(SV)]")
			failures++

	if(failures)
		fail("[failures] shutoff valves did not connect to two different pipe networks.")
	else
		pass("All shutoff valves connect to two different pipe networks.")
	return 1

//=======================================================================================

/datum/unit_test/pipes_shall_not_leak
	name = "MAP: Pipes shall not leak unless allowed"

/datum/unit_test/pipes_shall_not_leak/start_test()
	var/failures = 0
	for(var/obj/machinery/atmospherics/pipe/P in SSmachines.machinery)
		if(P.leaking && !(locate(/obj/abstract/landmark/allowed_leak) in get_turf(P)))
			failures++
			log_bad("Following pipe is leaking: [log_info_line(P)]")

	if(failures)
		fail("[failures] pipe\s leaking without allowed leak landmark!")
	else
		pass("No pipes are leaking.")
	return 1

//=======================================================================================

/datum/unit_test/station_power_terminals_shall_be_wired
	name = "MAP: Station power terminals shall be wired"

/datum/unit_test/station_power_terminals_shall_be_wired/start_test()
	var/failures = 0
	for(var/obj/machinery/power/terminal/term in SSmachines.machinery)
		var/turf/T = get_turf(term)
		if(!T)
			failures++
			log_bad("Nullspace terminal : [log_info_line(term)]")
			continue

		if(!isStationLevel(T.z))
			continue

		var/found_cable = FALSE
		for(var/obj/structure/cable/C in T)
			if(C.d2 > 0 && C.d1 == 0)
				found_cable = TRUE
				break
		if(!found_cable)
			failures++
			log_bad("Unwired terminal : [log_info_line(term)]")

	if(failures)
		fail("[failures] unwired power terminal\s.")
	else
		pass("All station power terminals are wired.")
	return 1

//=======================================================================================

/datum/unit_test/station_wires_shall_be_connected
	name = "MAP: Station wires shall be connected"
	var/list/exceptions

/datum/unit_test/station_wires_shall_be_connected/start_test()
	var/failures = 0

	exceptions = global.using_map.disconnected_wires_test_exempt_turfs

	var/exceptions_by_turf = list()
	for(var/exception in exceptions)
		var/turf/T = locate(exception[1], exception[2], exception[3])
		if(!T)
			CRASH("Invalid exception: [exception[1]] - [exception[2]] - [exception[3]]")
		if(!(T in exceptions_by_turf))
			exceptions_by_turf[T] = list()
		exceptions_by_turf[T] += exception[4]
	exceptions = exceptions_by_turf

	for(var/obj/structure/cable/C in global.all_cables)
		if(!QDELETED(C) && !all_ends_connected(C))
			failures++

	if(failures)
		fail("Found [failures] cable\s without connections.")
	else if(exceptions.len)
		for(var/entry in exceptions)
			log_bad("[log_info_line(entry)] - [english_list(exceptions[entry])] ")
		fail("Unnecessary exceptions need to be cleaned up.")
	else
		pass("All station wires are properly connected.")

	return 1

// We work on the assumption that another test ensures we only have valid directions
/datum/unit_test/station_wires_shall_be_connected/proc/all_ends_connected(var/obj/structure/cable/C)
	. = TRUE

	var/turf/source_turf = get_turf(C)
	if(!source_turf)
		log_bad("Nullspace wire: [log_info_line(C)]")
		return FALSE

	// We don't care about non-station wires
	if(!isStationLevel(source_turf.z))
		return TRUE

	for(var/dir in list(C.d1, C.d2))
		if(!dir) // Don't care about knots
			continue
		var/rev_dir = global.reverse_dir[dir]

		var/list/exception = exceptions[source_turf]
		if(exception && (dir in exception))
			exception -= dir
			if(!exception.len)
				exceptions -= source_turf
			continue

		var/turf/target_turf
		if(dir == UP)
			target_turf = GetAbove(C)
		if(dir == DOWN)
			target_turf = GetBelow(C)
		else
			target_turf = get_step(C, dir)

		var/connected = FALSE
		for(var/obj/structure/cable/revC in target_turf)
			if(revC.d1 == rev_dir || revC.d2 == rev_dir)
				connected = TRUE
				break

		if(!connected)
			log_bad("Disconnected wire: [dir2text(dir)] - [log_info_line(C)]")
			. = FALSE

/datum/unit_test/networked_disposals_shall_deliver_tagged_packages
	name = "MAP: Networked disposals shall deliver tagged packages"
	async = 1

	var/extra_spawns = 1

	var/list/packages_awaiting_delivery = list()
	var/list/all_tagged_bins = list()
	var/list/all_tagged_destinations = list()

	var/failed = FALSE
	var/list/exempt_junctions = list(
		/obj/structure/disposalpipe/sortjunction/untagged
	)

/datum/unit_test/networked_disposals_shall_deliver_tagged_packages/start_test()
	. = 1
	var/fail = FALSE
	for(var/obj/structure/disposalpipe/sortjunction/sort in _unit_test_sort_junctions)
		if(!sort.loc)
			continue
		if(is_type_in_list(sort, exempt_junctions))
			continue
		if(sort.sort_type in global.using_map.disconnected_disposals_tags)
			continue
		var/obj/machinery/disposal/bin = get_bin_from_junction(sort)
		if(!bin)
			log_bad("Junction with tag [sort.sort_type] at ([sort.x], [sort.y], [sort.z]) could not find disposal.")
			fail = TRUE
			continue
		all_tagged_destinations[sort.sort_type] = bin
		if(!istype(bin)) // Can also be an outlet.
			continue
		all_tagged_bins[sort.sort_type] = bin
	if(fail)
		fail("Improperly connected junction detected.")
		return
	for(var/target_tag in all_tagged_destinations)
		var/start_tag = all_tagged_bins[target_tag] ? target_tag : pick(all_tagged_bins)
		spawn_package(start_tag, target_tag)
		for(var/i in 1 to extra_spawns)
			spawn_package(pick(all_tagged_bins), target_tag) // This potentially helps catch errors in junction logic.

/datum/unit_test/networked_disposals_shall_deliver_tagged_packages/proc/spawn_package(start_tag, target_tag)
	var/obj/structure/disposalholder/unit_test/package = new()
	package.tomail = 1
	package.destinationTag = target_tag
	package.start(all_tagged_bins[start_tag])
	package.test = src
	packages_awaiting_delivery[package] = start_tag

/obj/structure/disposalholder/unit_test
	is_spawnable_type = FALSE // NO
	var/datum/unit_test/networked_disposals_shall_deliver_tagged_packages/test
	speed = 100

/obj/structure/disposalholder/unit_test/merge()
	return FALSE

/obj/structure/disposalholder/unit_test/Destroy()
	test.package_delivered(src)
	. = ..()

/obj/structure/disposalholder/unit_test/Process()
	for(var/i in 1 to speed) // Go faster, as it takes a while and we don't want to wait forever.
		. = ..()
		if(. == PROCESS_KILL)
			if(QDELETED(src) || !test.packages_awaiting_delivery[src])
				return
			log_and_fail()
			return

/obj/structure/disposalholder/unit_test/proc/log_and_fail()
	var/location = log_info_line(get_turf(src))
	var/expected_loc = log_info_line(get_turf(test.all_tagged_destinations[destinationTag]))
	test.log_bad("A package routed from [test.packages_awaiting_delivery[src]] to [destinationTag] was misrouted to [location]; expected location was [expected_loc].")
	test.failed = TRUE
	test.packages_awaiting_delivery -= src

/datum/unit_test/networked_disposals_shall_deliver_tagged_packages/check_result()
	. = 1
	if(failed)
		fail("A package has been delivered to an incorrect location.")
		return
	if(!packages_awaiting_delivery.len)
		pass("All packages delivered.")
		return
	return 0

/datum/unit_test/networked_disposals_shall_deliver_tagged_packages/proc/package_delivered(var/obj/structure/disposalholder/unit_test/package)
	if(!packages_awaiting_delivery[package])
		return
	var/obj/structure/disposalpipe/trunk/trunk = package.loc

	if(!istype(trunk))
		package.log_and_fail()
		return
	var/obj/linked = trunk.linked
	if(all_tagged_destinations[package.destinationTag] != linked)
		package.log_and_fail()
		return
	packages_awaiting_delivery -= package

/datum/unit_test/networked_disposals_shall_deliver_tagged_packages/proc/get_bin_from_junction(var/obj/structure/disposalpipe/sortjunction/sort)
	var/list/traversed = list(sort) // Avoid self-looping, infinite loops.
	var/obj/structure/disposalpipe/our_pipe = sort
	var/current_dir = sort.sortdir
	while(1)
		if(istype(our_pipe, /obj/structure/disposalpipe/trunk))
			var/obj/structure/disposalpipe/trunk/trunk = our_pipe
			return trunk.linked
		var/obj/structure/disposalpipe/next_pipe
		for(var/obj/structure/disposalpipe/P in get_step(our_pipe, current_dir))
			if(global.reverse_dir[current_dir] & P.dpdir)
				next_pipe = P
				break
		if(!istype(next_pipe))
			return
		if(next_pipe in traversed)
			return
		traversed += next_pipe
		current_dir = next_pipe.nextdir(current_dir, sort.sort_type)
		our_pipe = next_pipe

/datum/unit_test/req_access_shall_have_valid_strings
	name = "MAP: every obj shall have valid access strings in req_access"
	var/list/accesses

/datum/unit_test/req_access_shall_have_valid_strings/start_test()
	if(!accesses)
		accesses = get_all_access_datums()

	var/list/obj_access_pairs = list()
	for(var/obj/O in world)
		if(O.req_access)
			for(var/req in O.req_access)
				if(islist(req))
					for(var/req_one in req)
						if(is_invalid(req_one))
							obj_access_pairs += list(list(O, req_one))
				else if(is_invalid(req))
					obj_access_pairs += list(list(O, req))

	if(obj_access_pairs.len)
		for(var/entry in obj_access_pairs)
			log_bad("[log_info_line(entry[1])] has an invalid value ([entry[2]]) in req_access.")
		fail("Mapped objs with req_access must be set up to use existing access strings.")
	else
		pass("All mapped objs have correctly set req_access.")

	return 1

/datum/unit_test/req_access_shall_have_valid_strings/proc/is_invalid(var/value)
	if(!istext(value))
		return TRUE //Someone tried to use a non-string as an access. There is no case where this is allowed.

	for(var/datum/access/A in accesses)
		if(value == A.id)
			return FALSE

	return TRUE

/datum/unit_test/doors_shall_be_on_appropriate_turfs
	name = "MAP: Doors shall be on appropriate turfs"

/datum/level_data/proc/get_door_turf_exceptions(var/obj/machinery/door/D)
	return LAZYACCESS(UT_turf_exceptions_by_door_type, D.type)

/datum/unit_test/doors_shall_be_on_appropriate_turfs/start_test()
	var/bad_doors = 0
	for(var/obj/machinery/door/D in SSmachines.machinery)
		if(QDELETED(D))
			continue
		if(!isturf(D.loc))
			bad_doors++
			log_bad("Invalid door turf: [log_info_line(D.loc)]")
		else
			var/datum/level_data/level_data = SSmapping.levels_by_z[D.loc.z]
			var/list/turf_exceptions = level_data?.get_door_turf_exceptions(D)

			var/is_bad_door = FALSE
			for(var/turf/T in D.locs)
				if(T.is_open() && !(T.type in turf_exceptions))
					is_bad_door = TRUE
					log_bad("Invalid door turf: [log_info_line(T)]")
			if(is_bad_door)
				bad_doors++

	if(bad_doors)
		fail("Found [bad_doors] door\s on inappropriate turfs")
	else
		pass("All doors are on appropriate turfs")
	return TRUE
