/decl/alt_title/emt

/decl/department/science
	name = "Science"
	goals = list(/datum/goal/department/extract_slime_cores)
	colour = "#a65ba6"
	display_color = "#e79fff"

/decl/alt_title
	var/title
	var/title_blurb
	var/title_outfit

#define CRASH_SURVIVOR_TITLE "Crash Survivor"

/decl/department/planetside
	name = "Planetside"
	display_color = "#555555"
	display_priority = 2 // Same as cargo in importance.

/datum/job/explorer
	title = "Explorer"
	department_types = list(
		/decl/department/science,
		/decl/department/planetside
	)
	total_positions = 4
	spawn_positions = 4
	supervisors = "the Research Director"
	selection_color =  "#633D63"
	economic_power = 4
	access = list(access_explorer, access_research)
	minimal_access = list(access_explorer, access_research)

	outfit_type = /decl/outfit/job/explorer
	description = "An Explorer searches for interesting things on the surface of Sif, and returns them to the station."

	alt_titles = list(
		"Pilot" = /decl/alt_title/pilot)

/decl/alt_title/pilot
	title = "Pilot"
	title_blurb = "A pilot ferries crew around in Cynosure Station's shuttle, the NTC Calvera."
	title_outfit = /decl/outfit/job/pilot

/datum/job/paramedic
	alt_titles = list(
					"Emergency Medical Technician" = /decl/alt_title/emt,
					"Search and Rescue" = /decl/alt_title/sar)

/decl/alt_title/sar
	title = "Search and Rescue"
	title_blurb = "A Search and Rescue operative recovers individuals who are injured or dead on the surface of Sif."
	title_outfit = /decl/outfit/job/medical/sar

/datum/job/rd
	access = list(
		access_rd,
		access_heads,
		access_tox,
		access_morgue,
		access_tox_storage,
		access_teleporter,
		access_sec_doors,
		access_research,
		access_robotics,
		access_xenobiology,
		access_xenofauna,
		access_ai_upload,
		access_tech_storage,
		access_RC_announce,
		access_keycard_auth,
		access_tcomsat,
		access_gateway,
		access_xenoarch,
		access_network,
		access_maint_tunnels,
		access_explorer,
		access_eva,
		access_external_airlocks
	)
	minimal_access = list(
		access_rd,
		access_heads,
		access_tox,
		access_morgue,
		access_tox_storage,
		access_teleporter,
		access_sec_doors,
		access_research,
		access_robotics,
		access_xenobiology,
		access_xenofauna,
		access_ai_upload,
		access_tech_storage,
		access_RC_announce,
		access_keycard_auth,
		access_tcomsat,
		access_gateway,
		access_xenoarch,
		access_network,
		access_maint_tunnels,
		access_explorer,
		access_eva,
		access_external_airlocks
	)

/datum/job/survivalist
	title = "Survivalist"
	department_types = list(/decl/department/planetside)
	selection_color = "#6085a8"
	total_positions = 3
	spawn_positions = 3
	supervisors = "your conscience"
	economic_power = 1
	access = list()
	minimal_access = list()
	outfit_type = /decl/outfit/job/survivalist
	description = "There are a few small groups of people living in the wilderness of Sif, and they occasionally venture to the Cynosure to trade, ask for help, or just have someone to talk to."
	account_allowed = FALSE
	announced = FALSE
	alt_titles = list(CRASH_SURVIVOR_TITLE = /decl/alt_title/crash_survivor)
	var/const/SPAWN_DAMAGE_MULT = 0.15
	var/const/TOTAL_INJURIES = 3
/*
	var/static/list/pod_templates = list(
		/datum/map_template/surface/plains/Epod,
		/datum/map_template/surface/plains/Epod2,
		///datum/map_template/surface/wilderness/deep/Epod3, // Don't use this one, it has spiders.
		/datum/map_template/surface/wilderness/normal/Epod4
	)
*/

/datum/job/survivalist/get_outfit(var/mob/living/human/H, var/alt_title)
	if(H.species?.uid == /decl/species/vox::uid)
		return GET_DECL(/decl/outfit/vox/survivor)
	return ..()

/decl/alt_title/crash_survivor
	title = CRASH_SURVIVOR_TITLE
	title_blurb = "Crashing in the wilderness of Sif's anomalous region is not a recommended holiday activity."
	title_outfit = /decl/outfit/job/survivalist/crash_survivor

/datum/job/survivalist/equip_job(mob/living/human/H, alt_title, datum/mil_branch/branch, datum/mil_rank/grade)
	. = ..()
	if(.)

		if(alt_title == CRASH_SURVIVOR_TITLE)

			// Spawn some kit for getting out of the pod, if they don't have it already.
			var/turf/T = get_turf(H)

			var/obj/item/toolbox/mechanical/toolbox
			for(var/turf/neighbor in RANGE_TURFS(T, 1))
				toolbox = locate(/obj/item/toolbox/mechanical) in neighbor
				if(toolbox)
					break

			if(!toolbox)
				toolbox = new(T)
			if(!(locate(/obj/item/tool/xeno/hand) in toolbox))
				new /obj/item/tool/xeno/hand(toolbox)
			if(!(locate(/obj/item/gps) in toolbox))
				new /obj/item/gps(toolbox)
			toolbox.name = "emergency toolbox"
			toolbox.desc = "A heavy toolbox stocked with tools for getting out of a crashed pod, as well as a GPS to aid with recovery."
			toolbox.storage.make_exact_fit()

			// Clear the mark so it isn't available for other spawns.
			for(var/obj/abstract/landmark/crashed_pod/pod_landmark in T)
				qdel(pod_landmark)

			// Smack them around from the landing.
			apply_post_spawn_damage(H)

/datum/job/survivalist/proc/apply_post_spawn_damage(var/mob/living/human/H)
	set waitfor = FALSE
	sleep(1) // let init and setup finish
	// beat them up a little
	for(var/injuries in 1 to TOTAL_INJURIES)
		var/deal_brute = rand(0, round(H.species.total_health * SPAWN_DAMAGE_MULT))
		H.take_overall_damage(deal_brute, round(H.species.total_health * SPAWN_DAMAGE_MULT) - deal_brute, "Crash Trauma")
	// remove any bleeding/internal bleeding, don't be too unfair
	for(var/obj/item/organ/external/E in H.get_external_organs())
		E.status &= ~ORGAN_ARTERY_CUT
		E.clamp_organ()
		E.update_damages()

/* TODO rewrite for our level system

/datum/job/survivalist/get_latejoin_spawn_locations(var/mob/spawning, var/rank)
	var/alt_title = spawning?.client?.prefs?.GetPlayerAltTitle(job_master.GetJob(rank))
	if(alt_title == CRASH_SURVIVOR_TITLE)
		return get_spawn_locations(spawning, rank)
	return ..()

/datum/job/survivalist/proc/get_existing_spawn_points()
	for(var/obj/abstract/landmark/crashed_pod/sloc in landmarks_list)
		if(!(locate(/mob/living) in sloc.loc))
			LAZYADD(., get_turf(sloc))

/datum/job/survivalist/get_spawn_locations(var/mob/spawning, var/rank)

	var/alt_title = spawning?.client?.prefs?.GetPlayerAltTitle(job_master.GetJob(rank))
	if(!spawning || alt_title != CRASH_SURVIVOR_TITLE)
		return ..()

	var/list/existing_points = get_existing_spawn_points()
	// Create a point if none are available.
	if(!length(existing_points))
		// Boilerplate from mapping.dm
		var/specific_sanity = 100
		var/datum/map_template/chosen_template = pick(pod_templates)
		chosen_template = new chosen_template
		while(specific_sanity > 0)
			specific_sanity--
			var/width_border = TRANSITIONEDGE + SUBMAP_MAP_EDGE_PAD + round(chosen_template.width / 2)
			var/height_border = TRANSITIONEDGE + SUBMAP_MAP_EDGE_PAD + round(chosen_template.height / 2)
			var/turf/T = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), Z_LEVEL_SURFACE_WILD)
			var/valid = TRUE
			for(var/turf/check in chosen_template.get_affected_turfs(T,TRUE))
				var/area/new_area = get_area(check)
				if(!(istype(new_area, /area/surface/outside/wilderness)))
					valid = FALSE // Probably overlapping something important.
					break
			if(!valid)
				continue
			chosen_template.load(T, centered = TRUE)
			admin_notice("Crash survivor placed \"[chosen_template.name]\" at ([T.x], [T.y], [T.z])\n", R_DEBUG)
			break

		// Rebuild the spawn point list now that one has been spawned.
		existing_points = get_existing_spawn_points()

	return existing_points
*/
#undef CRASH_SURVIVOR_TITLE

/datum/job/trained_animal
	title = "Trained Drake"
	department_types = list(/decl/department/planetside)
	selection_color  = "#6085a8"
	total_positions  = 2
	spawn_positions  = 1
	supervisors      = "your conscience"
	economic_power   = 1
	access           = list()
	minimal_access   = list()
	outfit_type      = /decl/outfit/naked // Have to have an outfit to pass job validation.
	description      = "A number of the bolder folks in Sif's anomalous region have partially domesticated some of the local wildlife as working animals."
	account_allowed  = FALSE
	announced        = FALSE
