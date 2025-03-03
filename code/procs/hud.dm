/* Using the HUD procs is simple. Call these procs in the life.dm of the intended mob.
Use the regular_hud_updates() proc before process_med_hud(mob) or process_sec_hud(mob) so
the HUD updates properly! */

// hud overlay image type, used for clearing client.images precisely
/image/hud_overlay
	appearance_flags = RESET_COLOR|RESET_TRANSFORM|KEEP_APART
	layer = ABOVE_HUMAN_LAYER
	plane = DEFAULT_PLANE

//Medical HUD outputs. Called by the Life() proc of the mob using it, usually.
/proc/process_med_hud(var/mob/M, var/local_scanner, var/mob/Alt, datum/computer_network/network)
	if(!can_process_hud(M))
		return
	var/datum/arranged_hud_process/P = arrange_hud_process(M, Alt, global.med_hud_users)
	for(var/mob/living/human/patient in P.hud_mob.in_view(P.hud_turf))

		if(patient.is_invisible_to(P.hud_mob))
			continue

		if(local_scanner)
			P.hud_client.images += patient.hud_list[HEALTH_HUD]

			if(network)
				var/record = network.get_crew_record_by_name(patient.get_visible_name())
				if(!record)
					return
				P.hud_client.images += patient.hud_list[STATUS_HUD]
		else
			var/sensor_level = getsensorlevel(patient)
			if(sensor_level >= VITALS_SENSOR_VITAL)
				P.hud_client.images += patient.hud_list[HEALTH_HUD]
			if(sensor_level >= VITALS_SENSOR_BINARY)
				P.hud_client.images += patient.hud_list[LIFE_HUD]

//Security HUDs. Pass a value for the second argument to enable implant viewing or other special features.
/proc/process_sec_hud(var/mob/M, var/advanced_mode, var/mob/Alt, datum/computer_network/network)
	if(!can_process_hud(M))
		return
	var/datum/arranged_hud_process/P = arrange_hud_process(M, Alt, global.sec_hud_users)
	for(var/mob/living/human/perp in P.hud_mob.in_view(P.hud_turf))

		if(perp.is_invisible_to(P.hud_mob))
			continue

		if(network)
			var/record = network.get_crew_record_by_name(perp.get_visible_name())
			if(!record)
				return
			P.hud_client.images += perp.hud_list[ID_HUD]
			if(advanced_mode)
				P.hud_client.images += perp.hud_list[WANTED_HUD]
				P.hud_client.images += perp.hud_list[IMPTRACK_HUD]
				P.hud_client.images += perp.hud_list[IMPLOYAL_HUD]
				P.hud_client.images += perp.hud_list[IMPCHEM_HUD]

/proc/process_jani_hud(var/mob/M, var/mob/Alt)
	var/datum/arranged_hud_process/P = arrange_hud_process(M, Alt, global.jani_hud_users)
	for (var/obj/effect/decal/cleanable/dirtyfloor in view(P.hud_mob))
		if(istype(dirtyfloor, /obj/effect/decal/cleanable/dirt))
			var/obj/effect/decal/cleanable/dirt/dirt = dirtyfloor
			if(dirt.alpha <= 0)
				continue
		P.hud_client.images += dirtyfloor.hud_overlay

/datum/arranged_hud_process
	var/client/hud_client
	var/mob/hud_mob
	var/turf/hud_turf

/proc/arrange_hud_process(var/mob/M, var/mob/Alt, var/list/hud_list)
	hud_list |= M
	var/datum/arranged_hud_process/P = new
	P.hud_client = M.client
	P.hud_mob = Alt ? Alt : M
	P.hud_turf = get_turf(P.hud_mob)
	return P

/proc/can_process_hud(var/mob/M)
	return M?.client && M.stat == CONSCIOUS

//Deletes the current HUD images so they can be refreshed with new ones.
/mob/proc/handle_hud_glasses() //Used in the life.dm of mobs that can use HUDs.
	if(client)
		for(var/image/hud_overlay/hud in client.images)
			client.images -= hud
	global.med_hud_users -= src
	global.sec_hud_users -= src
	global.jani_hud_users -= src

/mob/proc/in_view(var/turf/T)
	return view(T)

/mob/observer/eye/in_view(var/turf/T)
	var/list/viewed = new
	for(var/mob/living/human/H in SSmobs.mob_list)
		if(get_dist(H, T) <= 7)
			viewed += H
	return viewed
