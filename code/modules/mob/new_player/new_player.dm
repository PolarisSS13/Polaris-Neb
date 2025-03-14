/mob/new_player
	universal_speak = TRUE
	mob_sort_value = 10
	invisibility = INVISIBILITY_ABSTRACT
	is_spawnable_type = FALSE
	simulated = FALSE
	density = FALSE
	stat = DEAD
	movement_handlers = list()
	anchored = TRUE	//  don't get pushed around
	virtual_mob = null // Hear no evil, speak no evil
	is_spawnable_type = FALSE

	var/ready = 0
	/// Referenced when you want to delete the new_player later on in the code.
	var/spawning = 0
	/// Player counts for the Lobby tab
	var/totalPlayers = 0
	var/totalPlayersReady = 0
	var/show_invalid_jobs = 0
	var/decl/music_track/current_lobby_track
	var/datum/browser/panel

INITIALIZE_IMMEDIATE(/mob/new_player)
/mob/new_player/Initialize()
	. = ..()
	forceMove(null)
	verbs += /mob/proc/toggle_antag_pool

/mob/new_player/Destroy()
	QDEL_NULL(panel)
	. = ..()

/mob/new_player/proc/show_lobby_menu(force = FALSE)
	if(!SScharacter_setup.initialized && !force)
		return // Not ready yet.

	var/output = list("<div align='center'>")

	var/decl/lobby_handler/lobby_handler = GET_DECL(global.using_map.lobby_handler)
	var/lobby_header = lobby_handler.get_lobby_header(src)
	if(lobby_header)
		output += lobby_header
	for(var/datum/lobby_option/option in lobby_handler.lobby_options)
		if(!option.visible(src))
			continue
		var/option_string = option.get_lobby_menu_string(src)
		if(option_string)
			output += option_string
	var/lobby_footer = lobby_handler.get_lobby_footer(src)
	if(lobby_footer)
		output += lobby_footer
	output += "</div>"

	if(!panel)
		panel = new(src, "Welcome","Welcome to [global.using_map.full_name]", 560, 280, src)
	panel.set_window_options("can_close=0")
	panel.set_content(JOINTEXT(output))
	panel.open()

/mob/new_player/Stat()
	. = ..()

	if(statpanel("Lobby"))
		if(check_rights(R_INVESTIGATE, 0, src))
			stat("Game Mode:", "[SSticker.mode ? SSticker.mode.name : SSticker.master_mode] ([SSticker.master_mode])")
		else
			stat("Game Mode:", PUBLIC_GAME_MODE)
		var/list/additional_antag_ids = list()
		for(var/antag_type in global.additional_antag_types)
			var/decl/special_role/antag = GET_DECL(antag_type)
			additional_antag_ids |= lowertext(antag.name)
		var/extra_antags = list2params(additional_antag_ids)
		stat("Added Antagonists:", extra_antags ? extra_antags : "None")

		if(GAME_STATE <= RUNLEVEL_LOBBY)
			stat("Time To Start:", "[round(SSticker.pregame_timeleft/10)][SSticker.round_progressing ? "" : " (DELAYED)"]")
			stat("Players: [totalPlayers]", "Players Ready: [totalPlayersReady]")
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in global.player_list)
				var/highjob
				if(player.client && player.client.prefs && player.client.prefs.job_high)
					highjob = " as [player.client.prefs.job_high]"
				stat("[player.key]", (player.ready)?("(Playing[highjob])"):(null))
				totalPlayers++
				if(player.ready)totalPlayersReady++

/mob/new_player/Topic(href, href_list) // This is a full override; does not call parent.
	if(usr != src || !client)
		return TOPIC_NOACTION

	if(href_list["lobby_changelog"])
		client.changes()
		return

	if(href_list["lobby_setup"])
		client.prefs.open_setup_window(src)
		return 1

	if(href_list["lobby_ready"])
		if(GAME_STATE <= RUNLEVEL_LOBBY)
			ready = !ready
		show_lobby_menu()

	if(href_list["refresh"])
		show_lobby_menu()

	if(href_list["lobby_observe"])
		if(GAME_STATE < RUNLEVEL_LOBBY)
			to_chat(src, SPAN_WARNING("Please wait for server initialization to complete..."))
			return

		var/respawn_delay = get_config_value(/decl/config/num/respawn_delay)
		if(!respawn_delay || client.holder || alert(src,"Are you sure you wish to observe? You will have to wait [respawn_delay] minute\s before being able to respawn!","Player Setup","Yes","No") == "Yes")
			if(!client)	return 1
			var/mob/observer/ghost/observer = new()

			spawning = 1
			sound_to(src, sound(null, repeat = 0, wait = 0, volume = 85, channel = sound_channels.lobby_channel))// MAD JAMS cant last forever yo

			observer.started_as_observer = 1
			close_spawn_windows()
			var/decl/spawnpoint/spawnpoint = GET_DECL(/decl/spawnpoint/observer)
			var/turf/T = SAFEPICK(spawnpoint.get_spawn_turfs(src))
			if(istype(T))
				to_chat(src, SPAN_NOTICE("Now teleporting."))
				observer.forceMove(T)
			else
				to_chat(src, SPAN_DANGER("Could not locate an observer spawn point. Use the Teleport verb to jump to the map."))
			observer.timeofdeath = world.time // Set the time of death so that the respawn timer works correctly.

			if(isnull(client.holder))
				announce_ghost_joinleave(src)

			var/mob/living/human/dummy/mannequin = get_mannequin(client.ckey)
			if(mannequin)
				client.prefs.dress_preview_mob(mannequin)
				observer.set_appearance(mannequin)

			if(client.prefs.be_random_name)
				client.prefs.real_name = client.prefs.get_random_name()
			observer.real_name = client.prefs.real_name
			observer.SetName(observer.real_name)
			if(!client.holder && !get_config_value(/decl/config/toggle/antag_hud_allowed))           // For new ghosts we remove the verb from even showing up if it's not allowed.
				observer.verbs -= /mob/observer/ghost/verb/toggle_antagHUD        // Poor guys, don't know what they are missing!
			observer.key = key
			qdel(src)

			return 1

	if(href_list["lobby_join"])
		if(GAME_STATE != RUNLEVEL_GAME)
			to_chat(usr, SPAN_DANGER("The round is either not ready, or has already finished..."))
			return
		LateChoices() //show the latejoin job selection menu

	if(href_list["lobby_crew"])
		ViewManifest()

	if(href_list["SelectedJob"])
		var/datum/job/job = SSjobs.get_by_title(href_list["SelectedJob"])

		if(!SSjobs.check_general_join_blockers(src, job))
			return FALSE

		var/decl/species/S = client.prefs.get_species_decl()
		if(!check_species_allowed(S))
			return 0

		AttemptLateSpawn(job, client.prefs.spawnpoint)
		return

	if(!ready && href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)

	if(href_list["invalid_jobs"])
		show_invalid_jobs = !show_invalid_jobs
		LateChoices()

/mob/new_player/proc/AttemptLateSpawn(var/datum/job/job, var/spawning_at)
	if(src != usr)
		return 0

	if(GAME_STATE != RUNLEVEL_GAME)
		to_chat(usr, SPAN_WARNING("The round is either not ready, or has already finished."))
		return 0

	if(get_config_value(/decl/config/enum/server_whitelist) == CONFIG_SERVER_JOIN_WHITELIST && !check_server_whitelist(usr))
		alert("Non-whitelisted players are not permitted to join rounds except as observers.")
		return 0

	if(!get_config_value(/decl/config/toggle/on/enter_allowed))
		to_chat(usr, SPAN_WARNING("There is an administrative lock on entering the game!"))
		return 0

	if(!job || !job.is_available(client))
		alert("[job.title] is not available. Please try another.")
		return 0
	if(job.is_restricted(client.prefs, src))
		return

	var/decl/spawnpoint/spawnpoint = job.get_spawnpoint(client)
	if(!spawnpoint)
		to_chat(src, alert("That spawnpoint is unavailable. Please try another."))
		return 0

	var/turf/spawn_turf
	if(job.latejoin_at_spawnpoints)
		var/obj/S = job.get_roundstart_spawnpoint()
		spawn_turf = get_turf(S)
	else
		spawn_turf = SAFEPICK(spawnpoint.get_spawn_turfs(src))

	if(!spawn_turf || !job.no_warn_unsafe && !SSjobs.check_unsafe_spawn(src, spawn_turf))
		return

	// Just in case someone stole our position while we were waiting for input from alert() proc
	if(!job || !job.is_available(client))
		to_chat(src, alert("[job.title] is not available. Please try another."))
		return 0

	SSjobs.assign_role(src, job.title, 1)

	var/mob/living/character = create_character(spawn_turf)	//creates the human and transfers vars and mind
	if(!character)
		return 0

	character = SSjobs.equip_job_title(character, job.title, 1)					//equips the human
	SScustomitems.equip_custom_items(character)

	if(job.do_spawn_special(character, src, TRUE)) //This replaces the AI spawn logic with a proc stub. Refer to silicon.dm for the spawn logic.
		qdel(src)
		return

	SSticker.mode.handle_latejoin(character)
	global.universe.OnPlayerLatejoin(character)
	spawnpoint.after_join(character)
	if(job.create_record)
		if(!(ASSIGNMENT_ROBOT in job.event_categories))
			CreateModularRecord(character)
			SSticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
			if(spawnpoint.spawn_announcement)
				AnnounceArrival(character, job, spawnpoint.spawn_announcement)
		else if(spawnpoint.spawn_announcement)
			AnnounceCyborg(character, job, spawnpoint.spawn_announcement)

	RAISE_EVENT(/decl/observ/player_latejoin, character, job)
	log_and_message_admins("has joined the round as [character.mind.assigned_role].", character)

	qdel(src)

/mob/new_player/proc/AnnounceCyborg(var/mob/living/character, var/rank, var/join_message)
	if (GAME_STATE == RUNLEVEL_GAME)
		if(character.mind.role_alt_title)
			rank = character.mind.role_alt_title
		// can't use their name here, since cyborg namepicking is done post-spawn, so we'll just say "A new Cyborg has arrived"/"A new Android has arrived"/etc.
		do_telecomms_announcement(character, "A new[rank ? " [rank]" : " visitor" ] [join_message ? join_message : "has arrived"].", "Arrivals Announcement Computer")

/mob/new_player/proc/LateChoices()
	var/name = client.prefs.be_random_name ? "friend" : client.prefs.real_name

	var/list/header = list("<html><body><center>")
	header += "<b>Welcome, [name].<br></b>"
	header += "Round Duration: [roundduration2text()]<br>"

	if(SSevac.evacuation_controller)
		if(SSevac.evacuation_controller.has_evacuated())
			header += "<font color='red'><b>The [station_name()] has been evacuated.</b></font><br>"
		else if(SSevac.evacuation_controller.is_evacuating())
			if(SSevac.evacuation_controller.emergency_evacuation) // Emergency shuttle is past the point of no recall
				header += "<font color='red'>The [station_name()] is currently undergoing evacuation procedures.</font><br>"
			else                                           // Crew transfer initiated
				header += "<font color='red'>The [station_name()] is currently undergoing crew transfer procedures.</font><br>"

	var/list/dat = list()
	dat += "Choose from the following open/valid positions:<br>"
	dat += "<a href='byond://?src=\ref[src];invalid_jobs=1'>[show_invalid_jobs ? "Hide":"Show"] unavailable jobs</a><br>"
	dat += "<table>"
	var/list/job_summaries = list()
	var/list/hidden_reasons = list()
	if(length(SSjobs.primary_job_datums))
		dat += "<tr><td colspan = 3><b>[global.using_map.station_name]:</b></td></tr>"

		// MAIN MAP JOBS
		for(var/datum/job/job in SSjobs.primary_job_datums)

			var/summary = job.get_join_link(client, "byond://?src=\ref[src];SelectedJob=[job.title]", show_invalid_jobs)
			if(summary)

				var/decl/department/dept = job.primary_department && SSjobs.get_department_by_type(job.primary_department)
				var/summary_key = (dept || "No Department")
				var/list/existing_summaries = job_summaries[summary_key]
				if(!existing_summaries)
					existing_summaries = list()
					job_summaries[summary_key] = existing_summaries
				if(job.head_position)
					existing_summaries.Insert(1, summary)
				else
					existing_summaries.Add(summary)
			else
				for(var/raisin in job.get_unavailable_reasons(client))
					hidden_reasons[raisin] = TRUE

		var/added_job = FALSE
		if(length(job_summaries))
			job_summaries = sortTim(job_summaries, /proc/cmp_departments_dsc, FALSE)
			for(var/job_category in job_summaries)
				if(length(job_summaries[job_category]))
					var/decl/department/job_dept = job_category
					// TODO: use bgcolor='[job_dept.display_color]' when less pastel/bright colours are chosen.
					dat += "<tr><td bgcolor='#333333' colspan = 3><b><font color = '#ffffff'><center>[istype(job_dept) ? job_dept.name : job_dept]</center></font></b></td></tr>"
					dat += job_summaries[job_category]
					added_job = TRUE

		if(!added_job)
			dat += "<tr><td colspan = 3>No available positions.</td></tr>"
	// END MAIN MAP JOBS

	// SUBMAP JOBS
	var/list/ordered_submaps = null
	if(length(SSmapping.submaps))
		ordered_submaps = sortTim(SSmapping.submaps.Copy(), /proc/cmp_submap_asc)
	for(var/datum/submap/submap as anything in ordered_submaps)
		if(submap?.available())
			dat += "<tr><td colspan = 3><b>[submap.name] ([submap.archetype.name]):</b></td></tr>"
			job_summaries = list()
			for(var/otherthing in submap.jobs)
				var/datum/job/job = submap.jobs[otherthing]
				var/summary = job.get_join_link(client, "byond://?src=\ref[submap];joining=\ref[src];join_as=[otherthing]", show_invalid_jobs)
				if(summary && summary != "")
					LAZYADD(job_summaries, summary)
				else
					for(var/raisin in job.get_unavailable_reasons(client))
						hidden_reasons[raisin] = TRUE

			if(LAZYLEN(job_summaries))
				dat += job_summaries
			else
				dat += "<tr><td colspan = 3>No available positions.</td></tr>"
	// END SUBMAP JOBS

	dat += "</table></center>"
	if(LAZYLEN(hidden_reasons))
		var/list/additional_dat = list("<br><b>Some roles have been hidden from this list for the following reasons:</b><br>")
		for(var/raisin in hidden_reasons)
			additional_dat += "[raisin]<br>"
		additional_dat += "<br>"
		dat = additional_dat + dat
	dat = header + dat
	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 450, 640)
	popup.set_content(jointext(dat, null))
	popup.open(0)

/mob/new_player/proc/create_character(var/turf/spawn_turf)
	spawning = 1
	close_spawn_windows()

	var/mob/living/human/new_character

	var/decl/species/chosen_species
	if(client.prefs.species)
		chosen_species = client.prefs.get_species_decl()

	if(!spawn_turf)
		var/datum/job/job = SSjobs.get_by_title(mind.assigned_role)
		if(!job)
			job = SSjobs.get_by_title(global.using_map.default_job_title)
		var/decl/spawnpoint/spawnpoint = job.get_spawnpoint(client, client.prefs.ranks[job.title])
		spawn_turf = DEFAULTPICK(spawnpoint.get_spawn_turfs(src), get_random_spawn_turf(SPAWN_FLAG_JOBS_CAN_SPAWN))

	if(chosen_species)
		if(!check_species_allowed(chosen_species))
			spawning = 0 //abort
			return null
		new_character = new(spawn_turf, chosen_species.uid)

	if(!new_character)
		new_character = new(spawn_turf)

	new_character.lastarea = get_area(spawn_turf)

	if(global.random_players)
		var/decl/species/current_species = client.prefs.get_species_decl()
		var/decl/pronouns/pronouns = pick(current_species.available_pronouns)
		client.prefs.gender = pronouns.name
		client.prefs.real_name = client.prefs.get_random_name()
		client.prefs.randomize_appearance_and_body_for(new_character)
	client.prefs.copy_to(new_character)

	sound_to(src, sound(null, repeat = 0, wait = 0, volume = 85, channel = sound_channels.lobby_channel))// MAD JAMS cant last forever yo

	if(mind)
		mind.active = 0 //we wish to transfer the key manually
		var/memory = client.prefs.records[PREF_MEM_RECORD]
		if(memory)
			mind.StoreMemory(memory)
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active

	// Do the initial caching of the player's body icons.
	new_character.force_update_limbs()
	new_character.try_refresh_visible_overlays()

	new_character.key = key		//Manually transfer the key to log them in
	return new_character

/mob/new_player/proc/ViewManifest()
	var/dat = "<div align='center'>"
	dat += html_crew_manifest(OOC = 1)
	//show_browser(src, dat, "window=manifest;size=370x420;can_close=1")
	var/datum/browser/popup = new(src, "Crew Manifest", "Crew Manifest", 370, 420, src)
	popup.add_stylesheet("nano_shared", 'nano/css/shared.css')
	popup.set_content(dat)
	popup.open()

/mob/new_player/Move()
	return 0

/mob/new_player/proc/close_spawn_windows()
	close_browser(src, "window=latechoices") //closes late choices window
	close_browser(src, "window=preferences_window") //closes preferences window
	if(client?.prefs)
		client.prefs.close_load_dialog(src)
	panel.close()

/mob/new_player/proc/check_species_allowed(var/decl/species/S, var/show_alert=1)
	if(!S.is_available_for_join() && !has_admin_rights())
		if(show_alert)
			to_chat(src, alert("Your current species, [S.name], is not available for play."))
		return 0
	if(!is_alien_whitelisted(src, S))
		if(show_alert)
			to_chat(src, alert("You are currently not whitelisted to play [S.name_plural]."))
		return 0
	return 1

/mob/new_player/get_species_name()
	SHOULD_CALL_PARENT(FALSE)
	var/decl/species/chosen_species
	if(client.prefs.species)
		chosen_species = client.prefs.get_species_decl()
	if(!chosen_species || !check_species_allowed(chosen_species, 0))
		return global.using_map.default_species
	return chosen_species.name

/mob/new_player/hear_say(var/message, var/verb = "says", var/decl/language/language = null, var/italics = 0, var/mob/speaker = null)
	return

/mob/new_player/hear_radio(var/message, var/verb="says", var/decl/language/language=null, var/part_a, var/part_b, var/part_c, var/mob/speaker = null, var/hard_to_hear = 0, var/vname ="", var/vsource)
	return

/mob/new_player/show_message(msg, type, alt, alt_type)
	return

/mob/new_player/MayRespawn()
	return 1

/mob/new_player/touch_map_edge(var/overmap_id = OVERMAP_ID_SPACE)
	return

/mob/new_player/say(var/message)
	sanitize_and_communicate(/decl/communication_channel/ooc, client, message)

/mob/new_player/verb/next_lobby_track()
	set name = "Play Different Lobby Track"
	set category = "OOC"

	if(get_preference_value(/datum/client_preference/play_lobby_music) == PREF_NO)
		return
	var/decl/music_track/new_track = global.using_map.get_lobby_track(current_lobby_track || global.using_map.lobby_track.type)
	if(new_track)
		current_lobby_track = new_track
		new_track.play_to(src)

/mob/new_player/handle_reading_literacy(var/mob/user, var/text_content, var/skip_delays, var/digital = FALSE)
	. = text_content

/mob/new_player/handle_writing_literacy(var/mob/user, var/text_content, var/skip_delays)
	. = text_content

/mob/new_player/get_admin_job_string()
	return "New player"

/mob/new_player/change_mob_type(var/new_type, var/turf/location, var/new_name, var/delete_old_mob = FALSE, var/subspecies)
	to_chat(usr, SPAN_WARNING("You cannot convert players who have not entered the game yet!"))
	return FALSE
