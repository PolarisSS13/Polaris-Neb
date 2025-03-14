/decl/special_role/proc/get_starting_locations()
	if(landmark_id)
		starting_locations = list()
		for(var/obj/abstract/landmark/L in global.all_landmarks)
			if(L.name == landmark_id)
				starting_locations |= get_turf(L)

/decl/special_role/proc/announce_antagonist_spawn()

	if(spawn_announcement)
		if(announced)
			return
		announced = 1
		spawn(0)
			if(spawn_announcement_delay)
				sleep(spawn_announcement_delay)
			if(spawn_announcement_sound)
				command_announcement.Announce("[spawn_announcement]", "[spawn_announcement_title ? spawn_announcement_title : "Priority Alert"]", new_sound = spawn_announcement_sound)
			else
				command_announcement.Announce("[spawn_announcement]", "[spawn_announcement_title ? spawn_announcement_title : "Priority Alert"]")
	return

/decl/special_role/proc/place_mob(var/mob/living/mob)
	if(!starting_locations || !starting_locations.len)
		return
	var/turf/T = pick_mobless_turf_if_exists(starting_locations)
	mob.forceMove(T)
