// callproc moved to code/modules/admin/callproc


/client/proc/Cell()
	set category = "Debug"
	set name = "Cell"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!( isturf(T) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = "<span class='notice'>Coordinates: [T.x],[T.y],[T.z]</span>\n"
	t += "<span class='warning'>Temperature: [env.temperature]</span>\n"
	t += "<span class='warning'>Pressure: [env.return_pressure()]kPa</span>\n"
	for(var/g in env.gas)
		t += "<span class='notice'>[g]: [env.gas[g]] / [env.gas[g] * R_IDEAL_GAS_EQUATION * env.temperature / env.volume]kPa</span>\n"

	usr.show_message(t, 1)
	SSstatistics.add_field_details("admin_verb","ASL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(var/mob/M in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(GAME_STATE < RUNLEVEL_GAME)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_animalize(var/mob/M in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(GAME_STATE < RUNLEVEL_GAME)
		alert("Wait until the game starts")
		return

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()


/client/proc/makepAI(var/turf/T in SSmobs.mob_list)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/player in SSmobs.mob_list)
		if(player.key)
			available.Add(player)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!isghost(choice))
		var/confirm = input("[choice.key] isn't ghosting right now. Are you sure you want to yank them out of them out of their body and place them in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	pai.SetName(sanitize_safe(input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text))
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/paiCandidate/candidate in paiController.pai_candidates)
		if(candidate.key == choice.key)
			paiController.pai_candidates.Remove(candidate)
	SSstatistics.add_field_details("admin_verb","MPAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all()
	set category = "Debug"
	set name = "Del-All"

	// to prevent REALLY stupid deletions
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/human, /mob/observer, /mob/living/silicon, /mob/living/silicon/robot, /mob/living/silicon/ai)
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in typesof(/obj) + typesof(/mob) - blocked
	if(hsbitem)
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				qdel(O)
		log_admin("[key_name(src)] has deleted all instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all instances of [hsbitem].", 0)
	SSstatistics.add_field_details("admin_verb","DELA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)
	SSstatistics.add_field_details("admin_verb","MPWN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_tog_aliens()
	set category = "Server"
	set name = "Toggle Aliens"
	if(toggle_config_value(/decl/config/toggle/aliens_allowed))
		log_admin("[key_name(src)] has turned aliens on.")
		message_admins("[key_name_admin(src)] has turned aliens on.", 0)
	else
		log_admin("[key_name(src)] has turned aliens off.")
		message_admins("[key_name_admin(src)] has turned aliens off.", 0)

	SSstatistics.add_field_details("admin_verb","TAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(var/mob/M in SSmobs.mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if (GAME_STATE < RUNLEVEL_GAME)
		alert("Wait until the game starts")
		return
	if (ishuman(M))
		var/mob/living/human/H = M
		var/obj/item/card/id/id = H.GetIdCard()
		if(id)
			id.icon_state = "gold"
			id.access = get_all_accesses()
		else
			id = new/obj/item/card/id(M);
			id.icon_state = "gold"
			id.access = get_all_accesses()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.SetName("[id.registered_name]'s ID Card ([id.assignment])")
			H.equip_to_slot_or_del(id, slot_wear_id_str)
	else
		alert("Invalid mob")
	SSstatistics.add_field_details("admin_verb","GFA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_and_message_admins("has granted [M.key] full access.")

/client/proc/cmd_assume_direct_control(var/mob/M in SSmobs.mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))	return
	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/observer/ghost/ghost = new/mob/observer/ghost(M,1)
			ghost.ckey = M.ckey
	log_and_message_admins("assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if(isghost(adminmob))
		qdel(adminmob)
	SSstatistics.add_field_details("admin_verb","ADC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!






/client/proc/cmd_admin_areatest()
	set category = "Mapping"
	set name = "Test areas"

	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	for(var/area/A in global.areas)
		if(!(A.type in areas_all))
			areas_all.Add(A.type)

	for(var/obj/machinery/power/apc/APC in SSmachines.machinery)
		var/area/A = get_area(APC)
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/alarm/alarm in SSmachines.machinery)
		var/area/A = get_area(alarm)
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/network/requests_console/RC in SSmachines.machinery)
		var/area/A = get_area(RC)
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in SSmachines.machinery)
		var/area/A = get_area(L)
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in SSmachines.machinery)
		var/area/A = get_area(LS)
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/radio/intercom/I in SSmachines.machinery)
		var/area/A = get_area(I)
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in SSmachines.machinery)
		var/area/A = get_area(C)
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	log_debug("<b>AREAS WITHOUT AN APC:</b>")
	for(var/areatype in areas_without_APC)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT AN AIR ALARM:</b>")
	for(var/areatype in areas_without_air_alarm)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT A REQUEST CONSOLE:</b>")
	for(var/areatype in areas_without_RC)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT ANY LIGHTS:</b>")
	for(var/areatype in areas_without_light)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT A LIGHT SWITCH:</b>")
	for(var/areatype in areas_without_LS)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT ANY INTERCOMS:</b>")
	for(var/areatype in areas_without_intercom)
		log_debug("* [areatype]")

	log_debug("<b>AREAS WITHOUT ANY CAMERAS:</b>")
	for(var/areatype in areas_without_camera)
		log_debug("* [areatype]")

/datum/admins/proc/cmd_admin_dress()
	set category = "Fun"
	set name = "Select equipment"

	if(!check_rights(R_FUN))
		return

	var/mob/living/human/H = input("Select mob.", "Select equipment.") as null|anything in global.human_mob_list
	if(!H)
		return

	var/decl/outfit/outfit = input("Select outfit.", "Select equipment.") as null|anything in decls_repository.get_decls_of_subtype_unassociated(/decl/outfit)
	if(!outfit)
		return

	var/reset_equipment = (outfit.outfit_flags & OUTFIT_RESET_EQUIPMENT)
	if(!reset_equipment)
		reset_equipment = alert("Do you wish to delete all current equipment first?", "Delete Equipment?","Yes", "No") == "Yes"

	SSstatistics.add_field_details("admin_verb","SEQ")
	dressup_human(H, outfit, reset_equipment)

/proc/dressup_human(var/mob/living/human/H, var/decl/outfit/outfit, var/undress = TRUE)
	if(!H || !outfit)
		return
	if(undress)
		H.delete_inventory(TRUE)
	outfit.equip_outfit(H)
	log_and_message_admins("changed the equipment of [key_name(H)] to [outfit.name].")

/client/proc/startSinglo()
	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/emitter/E in SSmachines.machinery)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field_generator/F in SSmachines.machinery)
		if(F.anchored)
			F.Varedit_start = 1
	spawn(3 SECONDS)
		for(var/obj/machinery/singularity_generator/G in SSmachines.machinery)
			if(G.anchored)
				new /obj/effect/singularity(get_turf(G), 1750)
				qdel(G)

	for(var/obj/machinery/rad_collector/Rad in SSmachines.machinery)
		if(Rad.anchored)
			if(!Rad.loaded_tank)
				Rad.loaded_tank = new /obj/item/tank/phoron(Rad)
				Rad.loaded_tank.air_contents.gas[/decl/material/solid/phoron] = 70
				Rad.drainratio = 0
			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in SSmachines.machinery)
		if(SMES.anchored)
			SMES.input_attempt = 1

/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs", "Ghost Mobs", "Clients"))
		if("Players")
			to_chat(usr, jointext(global.player_list,","))
		if("Admins")
			to_chat(usr, jointext(global.admins,","))
		if("Mobs")
			to_chat(usr, jointext(SSmobs.mob_list,","))
		if("Living Mobs")
			to_chat(usr, jointext(global.living_mob_list_,","))
		if("Dead Mobs")
			to_chat(usr, jointext(global.dead_mob_list_,","))
		if("Ghost Mobs")
			to_chat(usr, jointext(global.ghost_mob_list,","))
		if("Clients")
			to_chat(usr, jointext(global.clients,","))

/datum/admins/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the Runtime Viewer"

	if(!check_rights(R_DEBUG))
		return

	global.error_cache.show_to(usr.client)

/client/proc/cmd_analyse_health_panel()
	set category = "Debug"
	set name = "Analyse Health"
	set desc = "Get an advanced health reading on a human mob."

	var/mob/living/human/H = input("Select mob.", "Analyse Health") as null|anything in global.human_mob_list
	if(!H)	return

	cmd_analyse_health(H)

/client/proc/cmd_analyse_health(var/mob/living/human/H)

	if(!check_rights(R_DEBUG))
		return

	if(!H)	return

	var/dat = display_medical_data(H.get_raw_medical_data(), SKILL_MAX)

	dat += text("<BR><A href='byond://?src=\ref[];mach_close=scanconsole'>Close</A>", usr)
	show_browser(usr, dat, "window=scanconsole;size=430x600")

/client/proc/cmd_analyse_health_context(mob/living/human/H as mob in global.human_mob_list)
	set category = null
	set name = "Analyse Human Health"

	if(!check_rights(R_DEBUG))
		return
	if(!ishuman(H))	return
	cmd_analyse_health(H)
	SSstatistics.add_field_details("admin_verb","ANLS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/effect/debugmarker
	icon = 'icons/effects/lighting_overlay.dmi'
	icon_state = "blank"
	layer = HOLOMAP_LAYER
	alpha = 127

/client/var/list/image/powernet_markers = list()
/client/proc/visualpower()
	set category = "Debug"
	set name = "Visualize Powernets"

	if(!check_rights(R_DEBUG)) return
	visualpower_remove()
	powernet_markers = list()

	for(var/datum/powernet/PN in SSmachines.powernets)
		var/netcolor = rgb(rand(100,255),rand(100,255),rand(100,255))
		for(var/obj/structure/cable/C in PN.cables)
			var/image/I = image('icons/effects/lighting_overlay.dmi', get_turf(C), "blank")
			I.plane = DEFAULT_PLANE
			I.layer = EXPOSED_WIRE_LAYER
			I.alpha = 127
			I.color = netcolor
			I.maptext = "\ref[PN]"
			powernet_markers += I
	images += powernet_markers

/client/proc/visualpower_remove()
	set category = "Debug"
	set name = "Remove Powernets Visuals"

	images -= powernet_markers
	QDEL_NULL_LIST(powernet_markers)

/client/proc/spawn_material()
	set category = "Debug"
	set name = "Spawn Material Stack"
	if(!check_rights(R_DEBUG)) return

	var/decl/material/material = input("Select material to spawn") as null|anything in decls_repository.get_decls_of_subtype_unassociated(/decl/material)
	if(!istype(material))
		return
	material.create_object(get_turf(mob), 50)

/client/proc/force_ghost_trap_trigger()
	set category = "Debug"
	set name = "Force Ghost Trap Trigger"
	if(!check_rights(R_DEBUG)) return
	var/decl/ghosttrap/trap = input("Select a ghost trap.", "Force Ghost Trap Trigger") as null|anything in decls_repository.get_decl_paths_of_type(/decl/ghosttrap)
	if(!trap)
		return
	trap = GET_DECL(trap)
	trap.forced(mob)

/client/proc/spawn_exoplanet(exoplanet_type as anything in subtypesof(/datum/map_template/planetoid/random/exoplanet))
	set category = "Debug"
	set name = "Create Exoplanet"

	var/budget = input("Ruins budget. Default is 5, a budget of 0 will not spawn any ruins, 5 will spawn around 3-5 ruins:", "Ruins Budget", 5) as num | null

	if (isnull(budget) || budget < 0)
		budget = 5

	var/theme = input("Choose a theme:", "Theme") as null|anything in typesof(/datum/exoplanet_theme) | null

	if (!theme)
		theme = /datum/exoplanet_theme

	var/daycycle = alert("Should the planet have a day-night cycle?","Day Night Cycle", "Yes", "No")

	if (daycycle == "Yes")
		daycycle = TRUE
	else
		daycycle = FALSE

	var/last_chance = alert("Spawn exoplanet?", "Final Confirmation", "Yes", "Cancel")

	if (last_chance == "Cancel")
		return

	//#TODO: This definitely could be improved.
	var/datum/map_template/planetoid/random/exoplanet/planet_template = SSmapping.get_template_by_type(exoplanet_type)
	var/datum/planetoid_data/PD = planet_template.create_planetoid_instance()
	if(planet_template.subtemplate_budget != budget)
		PD._budget_override = budget
	if(theme)
		PD._theme_forced = theme
	planet_template.load_new_z(gen_data = PD)
	if(!daycycle)
		SSdaycycle.remove_level(PD.get_linked_level_zs(), PD.daycycle_id)

/client/proc/display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Display del's log of everything that's passed through it."

	if(!check_rights(R_DEBUG))
		return

	. = list("<B>List of things that have gone through qdel this round</B><BR><BR><ol>")
	sortTim(SSgarbage.items, cmp = /proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		. += "<li><u>[path]</u><ul>"
		if(I.failures)
			. += "<li>Failures: [I.failures]</li>"
		. += "<li>qdel() Count: [I.qdels]</li>"
		if(I.early_destroy)
			. += "<li>Early destroy count: [I.early_destroy]</li>"
		if(I.qdels)
			. += "<li>Average Destroy() Cost: [I.destroy_time / I.qdels]ms/call</li>"
		. += "<li>Destroy() Cost: [I.destroy_time]ms</li>"
		if(I.hard_deletes)
			. += "<li>Total Hard Deletes [I.hard_deletes]</li>"
			. += "<li>Time Spent Hard Deleting: [I.hard_delete_time]ms</li>"
		if(I.slept_destroy)
			. += "<li>Sleeps: [I.slept_destroy]</li>"
		if(I.no_respect_force)
			. += "<li>Ignored force: [I.no_respect_force]</li>"
		if(I.no_hint)
			. += "<li>No hint: [I.no_hint]</li>"
		. += "</ul></li>"

	. += "</ol>"

	show_browser(usr, JOINTEXT(.), "window=dellog")

/client/proc/toggle_browser_inspect()
	set category = "Debug"
	set name = "Toggle Browser Inspect"

	#if DM_VERSION >= 516

	var/browser_options = winget(src, null, "browser-options")

	if(findtext(browser_options, "devtools"))
		// Disable the dev tools.
		winset(src, null, list("browser-options" = "-devtools"))
		message_admins("[key_name_admin(usr)] has disabled Browser Inspection.")
	else
		// Enable the dev tools.
		winset(src, null, list("browser-options" = "+devtools"))
		message_admins("[key_name_admin(usr)] has enabled Browser Inspection.")

	#else

	alert("Browser Inspection is not supported in this version of BYOND, please update to 516 or later.")

	#endif