/atom/movable
	layer = OBJ_LAYER
	appearance_flags = TILE_BOUND | DEFAULT_APPEARANCE_FLAGS | LONG_GLIDE
	glide_size = 8
	abstract_type = /atom/movable

	var/can_buckle = 0
	var/buckle_movable = 0
	var/buckle_allow_rotation = 0
	var/buckle_layer_above = FALSE
	var/buckle_dir = 0
	var/buckle_lying = -1             // bed-like behavior, forces mob to lie or stand if buckle_lying != -1
	/// A list or JSON-encoded list of pixel offsets to use on a mob buckled to this atom. TRUE to use this atom's pixel shifts, null for no pixel shift control.
	var/buckle_pixel_shift            // ex. @'{"x":0,"y":0,"z":0}'
	var/buckle_require_restraints = 0 // require people to be cuffed before being able to buckle. eg: pipes
	var/buckle_require_same_tile = FALSE
	var/buckle_sound
	var/mob/living/buckled_mob = null

	var/movable_flags
	var/last_move = null
	var/anchored = FALSE
	// var/elevation = 2    - not used anywhere
	var/move_speed = 10
	var/l_move_time = 1
	var/m_flag = 1
	var/datum/thrownthing/throwing
	var/throw_speed = 2
	var/throw_range = 7
	var/item_state = null // Used to specify the item state for the on-mob overlays.
	var/does_spin = TRUE // Does the atom spin when thrown (of course it does :P)
	var/list/grabbed_by

	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = 0
	var/inertia_next_move = 0
	var/inertia_move_delay = 5
	var/atom/movable/inertia_ignore

	// Marker for alpha mask update process. null == never update, TRUE == currently updating, FALSE == finished updating.
	var/updating_turf_alpha_mask = null

	// Damage type from using or throwing this atom.
	var/atom_damage_type = BRUTE

// This proc determines if the instance is preserved when the process() despawn of crypods occurs.
/atom/movable/proc/preserve_in_cryopod(var/obj/machinery/cryopod/pod)
	return FALSE

//call this proc to start space drifting
/atom/movable/proc/space_drift(direction)//move this down
	if(!loc || direction & (UP|DOWN) || is_space_movement_permitted() != SPACE_MOVE_FORBIDDEN)
		inertia_dir = 0
		inertia_ignore = null
		return 0

	inertia_dir = direction
	if(!direction)
		return 1
	inertia_last_loc = loc
	SSspacedrift.processing[src] = src
	return 1

// return SPACE_MOVE_FORBIDDEN to space drift, SPACE_MOVE_PERMITTED to stop, SPACE_MOVE_SUPPORTED for mobs to handle space slips
// Note that it may also return an instance of /atom/movable, which acts as SPACE_MOVE_SUPPORTED and results in pushing the movable backwards.
/atom/movable/proc/is_space_movement_permitted(allow_movement = FALSE)
	if(!simulated)
		return SPACE_MOVE_PERMITTED
	if(has_gravity())
		return SPACE_MOVE_PERMITTED
	if(throwing)
		return SPACE_MOVE_PERMITTED
	if(anchored)
		return SPACE_MOVE_PERMITTED
	if(!isturf(loc))
		return SPACE_MOVE_PERMITTED
	if(length(grabbed_by))
		for(var/obj/item/grab/grab as anything in grabbed_by)
			if(grab.assailant == src)
				continue
			return SPACE_MOVE_PERMITTED
	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return SPACE_MOVE_SUPPORTED
	return SPACE_MOVE_FORBIDDEN

/atom/movable/attack_hand(mob/user)
	// Unbuckle anything buckled to us.
	if(!can_buckle || !buckled_mob || !user.check_dexterity(DEXTERITY_SIMPLE_MACHINES, TRUE))
		return ..()
	user_unbuckle_mob(user)
	return TRUE

/atom/movable/hitby(var/atom/movable/AM, var/datum/thrownthing/TT)
	. = ..()
	if(. && density && prob(50))
		do_simple_ranged_interaction()
	process_momentum(AM,TT)

/atom/movable/proc/process_momentum(var/atom/movable/AM, var/datum/thrownthing/TT)//physic isn't an exact science
	. = momentum_power(AM,TT)
	if(.)
		momentum_do(.,TT,AM)

/atom/movable/proc/momentum_power(var/atom/movable/AM, var/datum/thrownthing/TT)
	if(anchored)
		return 0

	. = (AM.get_mass()*TT.speed)/(get_mass()*min(AM.throw_speed,2))
	if(has_gravity())
		. *= 0.5

/atom/movable/proc/momentum_do(var/power, var/datum/thrownthing/TT)
	var/direction = TT.init_dir
	switch(power)
		if(0.75 to INFINITY)		//blown backward, also calls being pinned to walls
			throw_at(get_edge_target_turf(src, direction), min((TT.maxrange - TT.dist_travelled) * power, 10), throw_speed * min(power, 1.5))

		if(0.5 to 0.75)	//knocks them back and changes their direction
			step(src, direction)

		if(0.25 to 0.5)	//glancing change in direction
			var/drift_dir
			if(direction & (NORTH|SOUTH))
				if(inertia_dir & (NORTH|SOUTH))
					drift_dir |= (direction & (NORTH|SOUTH)) & (inertia_dir & (NORTH|SOUTH))
				else
					drift_dir |= direction & (NORTH|SOUTH)
			else
				drift_dir |= inertia_dir & (NORTH|SOUTH)
			if(direction & (EAST|WEST))
				if(inertia_dir & (EAST|WEST))
					drift_dir |= (direction & (EAST|WEST)) & (inertia_dir & (EAST|WEST))
				else
					drift_dir |= direction & (EAST|WEST)
			else
				drift_dir |= inertia_dir & (EAST|WEST)
			space_drift(drift_dir)

/atom/movable/proc/get_mass()
	return 1.5

/atom/movable/Bump(var/atom/A, yes)
	if(!QDELETED(throwing))
		throwing.hit_atom(A)

	if(inertia_dir)
		inertia_dir = 0

	if (A && yes)
		A.last_bumped = world.time
		INVOKE_ASYNC(A, TYPE_PROC_REF(/atom, Bumped), src) // Avoids bad actors sleeping or unexpected side effects, as the legacy behavior was to spawn here
	..()

/atom/movable/proc/forceMove(atom/destination)

	if(QDELETED(src) && !isnull(destination))
		CRASH("Attempted to forceMove a QDELETED [src] out of nullspace!!!")

	if(loc == destination)
		return FALSE

	var/is_origin_turf = isturf(loc)
	var/is_destination_turf = isturf(destination)
	// It is a new area if:
	//  Both the origin and destination are turfs with different areas.
	//  When either origin or destination is a turf and the other is not.
	var/is_new_area = (is_origin_turf ^ is_destination_turf) || (is_origin_turf && is_destination_turf && loc.loc != destination.loc)
	var/was_below_z_turf = MOVABLE_IS_BELOW_ZTURF(src)

	var/atom/origin = loc
	loc = destination

	if(origin)
		origin.Exited(src, destination)
		if(is_origin_turf)
			for(var/atom/movable/AM in origin)
				AM.Uncrossed(src)
			if(is_new_area && is_origin_turf)
				origin.loc.Exited(src, destination)

	if(destination)
		destination.Entered(src, origin)
		if(is_destination_turf) // If we're entering a turf, cross all movable atoms
			for(var/atom/movable/AM in loc)
				if(AM != src)
					AM.Crossed(src)
			if(is_new_area && is_destination_turf)
				destination.loc.Entered(src, origin)

	. = TRUE

	// observ
	if(!loc && event_listeners?[/decl/observ/moved])
		raise_event_non_global(/decl/observ/moved, origin, null)

	// freelook
	if(simulated && opacity)
		updateVisibility(src)

	// lighting
	if (light_source_solo)
		light_source_solo.source_atom.update_light()
	else if (light_source_multi)
		var/datum/light_source/L
		var/thing
		for (thing in light_source_multi)
			L = thing
			L.source_atom.update_light()

	// Z-Mimic.
	if (bound_overlay)
		// The overlay will handle cleaning itself up on non-openspace turfs.
		if (isturf(destination))
			bound_overlay.forceMove(get_step(src, UP))
			if (dir != bound_overlay.dir)
				bound_overlay.set_dir(dir)
		else	// Not a turf, so we need to destroy immediately instead of waiting for the destruction timer to proc.
			qdel(bound_overlay)
	else if (isturf(loc) && (!origin || !was_below_z_turf) && MOVABLE_SHALL_MIMIC(src))
		SSzcopy.discover_movable(src)

	if(buckled_mob)
		if(isturf(loc))
			buckled_mob.glide_size = glide_size // Setting loc apparently does animate with glide size.
			buckled_mob.forceMove(loc)
			refresh_buckled_mob(0)
		else
			unbuckle_mob()

/atom/movable/set_dir(ndir)
	. = ..()
	if(.)
		refresh_buckled_mob(0)

/atom/movable/proc/refresh_buckled_mob(var/delay_offset_anim = 4)
	if(buckled_mob)
		buckled_mob.set_dir(buckle_dir || dir)
		buckled_mob.reset_offsets(delay_offset_anim)
		buckled_mob.reset_plane_and_layer()

/atom/movable/Move(...)

	var/old_loc = loc
	var/was_below_z_turf = MOVABLE_IS_BELOW_ZTURF(src)
	. = ..()

	if(.)

		if(buckled_mob)
			if(isturf(loc))
				buckled_mob.glide_size = glide_size // Setting loc apparently does animate with glide size.
				buckled_mob.forceMove(loc)
				refresh_buckled_mob(0)
			else
				unbuckle_mob()

		if(!loc && event_listeners?[/decl/observ/moved])
			raise_event_non_global(/decl/observ/moved, old_loc, null)

		// freelook
		if(simulated && opacity)
			updateVisibility(src)

		// lighting
		if (light_source_solo)
			light_source_solo.source_atom.update_light()
		else if (light_source_multi)
			var/datum/light_source/L
			var/thing
			for (thing in light_source_multi)
				L = thing
				L.source_atom.update_light()

		// Z-Mimic.
		if (bound_overlay)
			// The overlay will handle cleaning itself up on non-openspace turfs.
			bound_overlay.forceMove(get_step(src, UP))
			if (bound_overlay.dir != dir)
				bound_overlay.set_dir(dir)
		else if (isturf(loc) && (!old_loc || !was_below_z_turf) && MOVABLE_SHALL_MIMIC(src))
			SSzcopy.discover_movable(src)

		if(isturf(loc))
			var/turf/T = loc
			if(T.reagents?.total_volume && submerged())
				fluid_act(T.reagents)

		for(var/mob/viewer in storage?.storage_ui?.is_seeing)
			if(!storage.can_view(viewer))
				storage.close(viewer)

//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, var/datum/thrownthing/TT)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(hit_atom) && !QDELETED(hit_atom))
		hit_atom.hitby(src, TT)

/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, datum/callback/callback) //If this returns FALSE then callback will not be called.

	. = TRUE
	if (!target || speed <= 0 || QDELETED(src) || (target.z != src.z))
		return FALSE

	QDEL_NULL_LIST(grabbed_by)

	var/datum/thrownthing/TT = new(src, target, range, speed, thrower, callback)
	throwing = TT

	storage?.close_all()

	pixel_z = 0
	if(spin && does_spin)
		SpinAnimation(4,1)

	SSthrowing.processing[src] = TT
	if (SSthrowing.state == SS_PAUSED && length(SSthrowing.currentrun))
		SSthrowing.currentrun[src] = TT

/atom/movable/proc/touch_map_edge(var/overmap_id)
	if(!simulated)
		return

	if(!z || isSealedLevel(z))
		return

	if(!global.universe.OnTouchMapEdge(src))
		return

	if(overmap_id)
		var/datum/overmap/overmap = global.overmaps_by_name[overmap_id]
		if(overmap)
			overmap.travel(get_turf(src), src)
			return

	var/new_x
	var/new_y
	var/new_z = global.using_map.get_transit_zlevel(z)
	if(new_z)
		if(x <= TRANSITIONEDGE)
			new_x = world.maxx - TRANSITIONEDGE - 2
			new_y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

		else if (x >= (world.maxx - TRANSITIONEDGE + 1))
			new_x = TRANSITIONEDGE + 1
			new_y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

		else if (y <= TRANSITIONEDGE)
			new_y = world.maxy - TRANSITIONEDGE -2
			new_x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

		else if (y >= (world.maxy - TRANSITIONEDGE + 1))
			new_y = TRANSITIONEDGE + 1
			new_x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

		var/turf/T = locate(new_x, new_y, new_z)
		if(T)
			forceMove(T)

/atom/movable/proc/get_bullet_impact_effect_type()
	return BULLET_IMPACT_NONE

/atom/movable/proc/pushed(var/pushdir)
	set waitfor = FALSE
	step(src, pushdir)

/**
* A wrapper for setDir that should only be able to fail by living mobs.
*
* Called from [/atom/movable/proc/keyLoop], this exists to be overwritten by living mobs with a check to see if we're actually alive enough to change directions
*/
/atom/movable/proc/keybind_face_direction(direction)
	return

/atom/movable/proc/get_mob()
	return buckled_mob

/atom/movable/proc/can_buckle_mob(var/mob/living/dropping)
	. = (can_buckle && istype(dropping) && !dropping.buckled && !dropping.anchored && !dropping.buckled_mob && !buckled_mob)

/atom/movable/receive_mouse_drop(atom/dropping, mob/user, params)
	. = ..()
	if(!. && can_buckle_mob(dropping))
		user_buckle_mob(dropping, user)
		return TRUE

/atom/movable/proc/buckle_mob(mob/living/M)

	if(buckled_mob) //unless buckled_mob becomes a list this can cause problems
		return FALSE

	if(!istype(M) || (M.loc != loc) || M.buckled || LAZYLEN(M.pinned) || (buckle_require_restraints && !M.restrained()))
		return FALSE

	M.buckled = src
	M.facing_dir = null
	if(!buckle_allow_rotation)
		M.set_dir(buckle_dir ? buckle_dir : dir)
	M.update_posture()
	M.update_floating()
	buckled_mob = M

	if(buckle_sound)
		playsound(src, buckle_sound, 20)

	post_buckle_mob(M)
	return TRUE

/atom/movable/proc/unbuckle_mob()
	if(buckled_mob && buckled_mob.buckled == src)
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_posture()
		buckled_mob.update_floating()
		buckled_mob = null
		post_buckle_mob(.)

/atom/movable/proc/post_buckle_mob(mob/living/M)
	if(M)
		M.reset_offsets(4)
		M.reset_plane_and_layer()
	if(buckled_mob && buckled_mob != M)
		refresh_buckled_mob()

/atom/movable/proc/user_buckle_mob(mob/living/M, mob/user)
	if(M != user && user.incapacitated())
		return FALSE
	if(M == buckled_mob)
		return FALSE
	if(!M.can_be_buckled(user))
		return FALSE

	add_fingerprint(user)
	unbuckle_mob()

	//can't buckle unless you share locs so try to move M to the obj if buckle_require_same_tile turned off.
	if(M.loc != src.loc)
		if(buckle_require_same_tile)
			return FALSE
		M.dropInto(loc)

	. = buckle_mob(M)
	if(.)
		show_buckle_message(M, user)

/atom/movable/proc/show_buckle_message(var/mob/buckled, var/mob/buckling)
	if(buckled == buckling)
		var/decl/pronouns/pronouns = buckled.get_pronouns()
		visible_message(
			SPAN_NOTICE("\The [buckled] buckles [pronouns.self] to \the [src]."),
			SPAN_NOTICE("You buckle yourself to \the [src]."),
			SPAN_NOTICE("You hear metal clanking.")
		)
	else
		visible_message(
			SPAN_NOTICE("\The [buckled] is buckled to \the [src] by \the [buckling]!"),
			SPAN_NOTICE("You are buckled to \the [src] by \the [buckling]!"),
			SPAN_NOTICE("You hear metal clanking.")
		)

/atom/movable/proc/user_unbuckle_mob(mob/user)
	var/mob/living/M = unbuckle_mob()
	if(M)
		show_unbuckle_message(M, user)
		for(var/obj/item/grab/grab as anything in (M.grabbed_by|grabbed_by))
			qdel(grab)
		add_fingerprint(user)
	return M

/atom/movable/proc/show_unbuckle_message(var/mob/buckled, var/mob/buckling)
	if(buckled == buckling)
		var/decl/pronouns/pronouns = buckled.get_pronouns()
		visible_message(
			SPAN_NOTICE("\The [buckled] unbuckled [pronouns.self] from \the [src]!"),
			SPAN_NOTICE("You unbuckle yourself from \the [src]."),
			SPAN_NOTICE("You hear metal clanking.")
		)
	else
		visible_message(
			SPAN_NOTICE("\The [buckled] was unbuckled from \the [src] by \the [buckling]!"),
			SPAN_NOTICE("You were unbuckled from \the [src] by \the [buckling]."),
			SPAN_NOTICE("You hear metal clanking.")
		)

/atom/movable/proc/handle_buckled_relaymove(var/datum/movement_handler/mh, var/mob/mob, var/direction, var/mover)
	return

/atom/movable/singularity_act()
	if(!simulated)
		return 0
	physically_destroyed()
	if(!QDELETED(src))
		qdel(src)
	return 2

/atom/movable/singularity_pull(S, current_size)
	if(simulated && !anchored)
		step_towards(src, S)

/atom/movable/proc/crossed_mob(var/mob/living/victim)
	return

/atom/movable/proc/get_object_size()
	return ITEM_SIZE_NORMAL

/atom/movable/get_manual_heat_source_coefficient()
	return ..() * (get_object_size() / ITEM_SIZE_NORMAL)

// TODO: account for reagents and matter.
/atom/movable/get_thermal_mass()
	if(!simulated)
		return 0
	return max(ITEM_SIZE_MIN, get_object_size()) * THERMAL_MASS_CONSTANT

/atom/movable/get_thermal_mass_coefficient(delta)
	if(!simulated)
		return 0
	return (max(ITEM_SIZE_MIN, MOB_SIZE_MIN) * THERMAL_MASS_CONSTANT) / get_thermal_mass()

/atom/movable/proc/try_burn_wearer(var/mob/living/holder, var/held_slot, var/delay = 0)
	set waitfor = FALSE

	if(delay)
		sleep(delay)

	if(!held_slot || !istype(holder) || QDELETED(holder) || loc != holder)
		return

	// TODO: put these flags on the inventory slot or something.
	var/check_slots
	if(held_slot in global.all_hand_slots)
		check_slots = SLOT_HANDS
	else if(held_slot == BP_MOUTH || held_slot == BP_HEAD)
		check_slots = SLOT_FACE

	if(check_slots)
		for(var/obj/item/covering in holder.get_covering_equipped_items(check_slots))
			if(covering.max_heat_protection_temperature >= temperature)
				return

	// TODO: less simplistic messages and logic
	var/datum/inventory_slot/slot = held_slot && holder.get_inventory_slot_datum(held_slot)
	var/check_organ = slot?.requires_organ_tag
	if(temperature >= holder.get_mob_temperature_threshold(HEAT_LEVEL_3, check_organ))
		to_chat(holder, SPAN_DANGER("You are burned by \the [src]!"))
	else if(temperature >= holder.get_mob_temperature_threshold(HEAT_LEVEL_2, check_organ))
		if(prob(10))
			to_chat(holder, SPAN_DANGER("\The [src] is uncomfortably hot..."))
		return
	else if(temperature <= holder.get_mob_temperature_threshold(COLD_LEVEL_3, check_organ))
		to_chat(holder, SPAN_DANGER("You are frozen by \the [src]!"))
	else if(temperature <= holder.get_mob_temperature_threshold(COLD_LEVEL_2, check_organ))
		if(prob(10))
			to_chat(holder, SPAN_DANGER("\The [src] is uncomfortably cold..."))
		return
	else
		return

	var/my_size = get_object_size()
	var/burn_damage = rand(my_size, round(my_size * 1.5))
	var/obj/item/organ/external/organ = check_organ && holder.get_organ(check_organ)
	if(istype(organ))
		organ.take_damage(burn_damage, BURN)
	else
		holder.take_damage(burn_damage, BURN)
	if(held_slot in holder.get_held_item_slots())
		holder.drop_from_inventory(src)
	else
		. = null // We might keep burning them next time.

/atom/movable/proc/update_appearance_flags(add_flags, remove_flags)
	var/old_appearance = appearance_flags
	if(add_flags)
		appearance_flags |= add_flags
	if(remove_flags)
		appearance_flags &= ~remove_flags
	return old_appearance != appearance_flags

/atom/movable/proc/end_throw(datum/thrownthing/TT)
	throwing = null

/atom/movable/proc/reset_movement_delay()
	var/datum/movement_handler/delay/delay = locate() in movement_handlers
	if(istype(delay))
		delay.next_move = world.time

/atom/movable/get_affecting_weather()
	var/turf/my_turf = get_turf(src)
	if(!istype(my_turf))
		return
	var/turf/actual_loc = loc
	// If we're standing in the rain, use the turf weather.
	. = istype(actual_loc) && actual_loc.weather
	if(!.) // If we're under or inside shelter, use the z-level rain (for ambience)
		. = SSweather.weather_by_z[my_turf.z]

/atom/movable/proc/handle_post_automoved(atom/old_loc)
	return

/atom/movable/take_vaporized_reagent(reagent, amount)
	if(ATOM_IS_OPEN_CONTAINER(src))
		return loc?.take_vaporized_reagent(reagent, amount)
	return null

/atom/movable/immune_to_floor_hazards()
	return ..() || !!throwing

// TODO: make everything use this.
/atom/movable/proc/set_anchored(new_anchored)
	SHOULD_CALL_PARENT(TRUE)
	if(anchored != new_anchored)
		anchored = new_anchored
		return TRUE
	return FALSE

// updates pixel offsets, triggers fluids, etc.
/atom/movable/proc/on_turf_height_change(new_height)
	if(simulated)
		reset_offsets()
		return TRUE
	return FALSE

/atom/movable/proc/get_cryogenic_power()
	return 0

/atom/movable/proc/is_valid_merchant_pad_target()
	return simulated
