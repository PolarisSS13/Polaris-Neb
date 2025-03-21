/proc/get_footstep_for_mob(var/footstep_type, var/mob/living/caller)
	. = istype(caller) && caller.get_mob_footstep(footstep_type)
	if(!.)
		var/decl/footsteps/footsteps = GET_DECL(footstep_type)
		. = pick(footsteps.footstep_sounds)

/turf/proc/get_footstep_sound(var/mob/caller)
	for(var/obj/structure/S in contents)
		if(S.footstep_type)
			return get_footstep_for_mob(S.footstep_type, caller)
	if(check_fluid_depth(10) && !is_flooded(TRUE))
		return get_footstep_for_mob(/decl/footsteps/water, caller)
	if(footstep_type)
		return get_footstep_for_mob(footstep_type, caller)
	return get_footstep_for_mob(/decl/footsteps/blank, caller)
