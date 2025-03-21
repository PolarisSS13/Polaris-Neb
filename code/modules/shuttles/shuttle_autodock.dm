#define DOCK_ATTEMPT_TIMEOUT 200	//how long in ticks we wait before assuming the docking controller is broken or blown up.

/datum/shuttle/autodock
	var/in_use = null	//tells the controller whether this shuttle needs processing, also attempts to prevent double-use
	var/last_dock_attempt_time = 0
	var/current_dock_target
	//ID of the controller on the shuttle
	var/dock_target = null
	var/docking_cues = null // A list of string cues -> controller tags, if we have multiple controllers. On landmarks set special_dock_target = list(our type -> docking cue) to determine which dock is used.
	var/datum/computer/file/embedded_program/docking/shuttle_docking_controller
	var/docking_codes

	var/obj/effect/shuttle_landmark/next_location  //This is only used internally.
	var/datum/computer/file/embedded_program/docking/active_docking_controller

	var/obj/effect/shuttle_landmark/landmark_transition  //This variable is type-abused initially: specify the landmark_tag, not the actual landmark.
	var/move_time = 240		//the time spent in the transition area

	abstract_type = /datum/shuttle/autodock
	flags = SHUTTLE_FLAGS_PROCESS | SHUTTLE_FLAGS_ZERO_G

/datum/shuttle/autodock/New(var/map_hash, var/obj/effect/shuttle_landmark/start_waypoint)
	..()
	if(map_hash)
		ADJUST_TAG_VAR(landmark_transition, map_hash)
		ADJUST_TAG_VAR(dock_target, map_hash)
		for(var/cue in docking_cues)
			ADJUST_TAG_VAR(docking_cues[cue], map_hash)

	//Initial dock
	active_docking_controller = current_location.docking_controller
	update_docking_target(current_location)
	if(active_docking_controller)
		set_docking_codes(active_docking_controller.docking_codes)
	else if(current_location?.overmap_id)
		var/obj/effect/overmap/visitable/location = global.overmap_sectors[num2text(current_location.z)]
		if(location && location.docking_codes)
			set_docking_codes(location.docking_codes)
	dock()

	//Optional transition area
	if(landmark_transition)
		landmark_transition = SSshuttle.get_landmark(landmark_transition)

/datum/shuttle/autodock/Destroy()
	next_location = null
	active_docking_controller = null
	landmark_transition = null

	return ..()

/datum/shuttle/autodock/proc/set_docking_codes(var/code)
	docking_codes = code
	if(shuttle_docking_controller)
		shuttle_docking_controller.docking_codes = code

/datum/shuttle/autodock/shuttle_moved(obj/effect/shuttle_landmark/destination, list/turf_translation, angle = 0)
	force_undock() //bye!
	..()

/datum/shuttle/autodock/proc/get_dock_target_by_port_tag(var/port_tag)
	var/obj/abstract/local_dock/dock = get_port_by_tag(port_tag)
	if(!dock)
		return dock_target // fallback, this should never happen
	return dock.dock_target // do not fall back to default here; allow certain rotation points (center, etc) to disable docking

/datum/shuttle/autodock/proc/update_docking_target(var/obj/effect/shuttle_landmark/location)
	if(location && docking_cues && location.special_dock_targets && location.special_dock_targets[type])
		current_dock_target = docking_cues[location.special_dock_targets[type]]
	else if(current_port_tag)
		current_dock_target = get_dock_target_by_port_tag(current_port_tag)
	else
		current_dock_target = dock_target // fallback
	shuttle_docking_controller = SSshuttle.docking_registry[current_dock_target]
/*
	Docking stuff
*/
/datum/shuttle/autodock/proc/dock()
	if(active_docking_controller && shuttle_docking_controller)
		if(flags & SHUTTLE_FLAGS_NO_CODE)
			set_docking_codes(active_docking_controller.docking_codes)
		shuttle_docking_controller.initiate_docking(active_docking_controller.id_tag)
		last_dock_attempt_time = world.time

/datum/shuttle/autodock/proc/undock()
	if(shuttle_docking_controller)
		shuttle_docking_controller.initiate_undocking()

/datum/shuttle/autodock/proc/force_undock()
	if(shuttle_docking_controller)
		shuttle_docking_controller.force_undock()

/datum/shuttle/autodock/proc/check_docked()
	if(shuttle_docking_controller)
		return shuttle_docking_controller.docked()
	return TRUE

/datum/shuttle/autodock/proc/check_undocked()
	if(shuttle_docking_controller)
		return shuttle_docking_controller.can_launch()
	return TRUE

/*
	Please ensure that long_jump() and short_jump() are only called from here. This applies to subtypes as well.
	Doing so will ensure that multiple jumps cannot be initiated in parallel.
*/
/datum/shuttle/autodock/Process()
	switch(process_state)
		if (WAIT_LAUNCH)
			if(check_undocked())
				//*** ready to go
				process_launch()

		if (FORCE_LAUNCH)
			process_launch()

		if (WAIT_ARRIVE)
			if (moving_status == SHUTTLE_IDLE)
				//*** we made it to the destination, update stuff
				process_arrived()
				process_state = WAIT_FINISH

		if (WAIT_FINISH)
			if (world.time > last_dock_attempt_time + DOCK_ATTEMPT_TIMEOUT || check_docked())
				//*** all done here
				process_state = IDLE_STATE
				arrived()

//not to be confused with the arrived() proc
/datum/shuttle/autodock/proc/process_arrived()
	active_docking_controller = next_location.docking_controller
	update_docking_target(next_location)
	dock()

	next_location = null
	in_use = null	//release lock

/datum/shuttle/autodock/proc/get_travel_time()
	return move_time

/datum/shuttle/autodock/proc/process_launch()
	if(!next_location.is_valid(src) || current_location.cannot_depart(src))
		process_state = IDLE_STATE
		in_use = null
		return
	if (get_travel_time() && landmark_transition)
		. = long_jump(next_location, landmark_transition, get_travel_time())
	else
		. = short_jump(next_location)
	process_state = WAIT_ARRIVE

/*
	Guards
*/
/datum/shuttle/autodock/proc/can_launch()
	return (next_location && next_location.is_valid(src) && !current_location.cannot_depart(src) && moving_status == SHUTTLE_IDLE && !in_use)

/datum/shuttle/autodock/proc/can_force()
	return (next_location && next_location.is_valid(src) && !current_location.cannot_depart(src) && moving_status == SHUTTLE_IDLE && process_state == WAIT_LAUNCH)

/datum/shuttle/autodock/proc/can_cancel()
	return (moving_status == SHUTTLE_WARMUP || process_state == WAIT_LAUNCH || process_state == FORCE_LAUNCH)

/*
	"Public" procs
*/
/datum/shuttle/autodock/proc/launch(var/user)
	if (!can_launch()) return

	in_use = user	//obtain an exclusive lock on the shuttle

	process_state = WAIT_LAUNCH
	undock()

/datum/shuttle/autodock/proc/force_launch(var/user)
	if (!can_force()) return

	in_use = user	//obtain an exclusive lock on the shuttle

	process_state = FORCE_LAUNCH

/datum/shuttle/autodock/proc/cancel_launch(var/user)
	if (!can_cancel()) return

	moving_status = SHUTTLE_IDLE
	process_state = WAIT_FINISH
	in_use = null

	//whatever we were doing with docking: stop it, then redock
	force_undock()
	spawn(1 SECOND)
		dock()

//returns 1 if the shuttle is getting ready to move, but is not in transit yet
/datum/shuttle/autodock/proc/is_launching()
	return (moving_status == SHUTTLE_WARMUP || process_state == WAIT_LAUNCH || process_state == FORCE_LAUNCH)

//This gets called when the shuttle finishes arriving at it's destination
//This can be used by subtypes to do things when the shuttle arrives.
//Note that this is called when the shuttle leaves the WAIT_FINISHED state, the proc name is a little misleading
/datum/shuttle/autodock/proc/arrived()
	return	//do nothing for now

/obj/effect/shuttle_landmark/transit
	flags = SLANDMARK_FLAG_ZERO_G

/datum/shuttle/autodock/test_landmark_setup()
	. = ..()
	if(.)
		return
	if(!landmark_transition && initial(landmark_transition))
		return "A transition landmark was expected (tag: [initial(landmark_transition)]) but not found."