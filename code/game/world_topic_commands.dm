/decl/topic_command
	abstract_type = /decl/topic_command
	var/name
	var/has_params = FALSE

/// Returns TRUE if we can use this command, and FALSE otherwise
/decl/topic_command/proc/can_use(var/T, var/addr, var/master, var/key)
	if (has_params)
		if (copytext(T, 1, length(name) + 1) != name)
			return FALSE
	else if (T != name)
		return FALSE
	return TRUE

/decl/topic_command/proc/use(var/list/params)
	return FALSE

/decl/topic_command/proc/try_use(var/T, var/addr, var/master, var/key)
	if (!can_use(T, addr, master, key))
		return FALSE
	var/list/params
	if(has_params)
		params = params2list(T)
	return use(params)

/decl/topic_command/secure
	abstract_type = /decl/topic_command/secure

/decl/topic_command/secure/try_use(var/T, var/addr, var/master, var/key)
	if (!can_use(T, addr, master, key))
		return FALSE
	var/list/params = params2list(T)
	var/comms_password = get_config_value(/decl/config/text/comms_password)
	if (!comms_password)
		set_throttle(addr, 10 SECONDS, "Comms Not Enabled")
		return "Not Enabled"
	if (params["key"] != comms_password)
		set_throttle(addr, 30 SECONDS, "Bad Comms Key")
		return "Bad Key"
	return use(params)

/* * * * * * * *
* Public Topic Calls
* The following topic calls are available without a comms secret.
* * * * * * * */

/decl/topic_command/ping
	name = "ping"
	uid = "topic_command_ping"

/decl/topic_command/ping/use()
	var/x = 1
	for (var/client/C)
		x++
	return x

/decl/topic_command/players
	name = "players"
	uid = "topic_command_players"

/decl/topic_command/players/use()
	return global.clients.len

/decl/topic_command/status
	name = "status"
	uid = "topic_command_status"
	has_params = TRUE

/decl/topic_command/status/use(var/list/params)
	var/list/s = list()
	s["version"] = game_version
	s["mode"] =    PUBLIC_GAME_MODE
	s["respawn"] = get_config_value(/decl/config/toggle/on/abandon_allowed)
	s["enter"] =   get_config_value(/decl/config/toggle/on/enter_allowed)
	s["vote"] =    get_config_value(/decl/config/toggle/vote_mode)
	s["ai"] =      !!length(empty_playable_ai_cores)
	s["host"] =    get_config_value(/decl/config/text/hosted_by)

	// This is dumb, but spacestation13.com's banners break if player count isn't the 8th field of the reply, so... this has to go here.
	s["players"] = 0
	s["stationtime"] = stationtime2text()
	s["roundduration"] = roundduration2text()
	s["map"] = strip_improper(global.using_map.full_name) //Done to remove the non-UTF-8 text macros

	var/active = 0
	var/list/players = list()
	var/list/admins = list()
	var/legacy = params["status"] != "2"
	for(var/client/C in global.clients)
		if(C.holder)
			if(C.is_stealthed())
				continue	//so stealthmins aren't revealed by the hub
			admins[C.key] = C.holder.rank
		if(legacy)
			s["player[players.len]"] = C.key
		players += C.key
		if(isliving(C.mob))
			active++

	s["players"] = players.len
	s["admins"] = admins.len
	if(!legacy)
		s["playerlist"] = list2params(players)
		s["adminlist"] = list2params(admins)
		s["active_players"] = active

	return list2params(s)

/decl/topic_command/manifest
	name = "manifest"
	uid = "topic_command_manifest"

/decl/topic_command/manifest/use()
	var/list/positions = list()
	var/list/nano_crew_manifest = nano_crew_manifest()
	// We rebuild the list in the format external tools expect
	for(var/dept in nano_crew_manifest)
		var/list/dept_list = nano_crew_manifest[dept]
		if(dept_list.len > 0)
			positions[dept] = list()
			for(var/list/person in dept_list)
				positions[dept][person["name"]] = person["rank"]

	for(var/k in positions)
		positions[k] = list2params(positions[k]) // converts positions["heads"] = list("Bob"="Captain", "Bill"="CMO") into positions["heads"] = "Bob=Captain&Bill=CMO"

	return list2params(positions)

/decl/topic_command/revision
	name = "revision"
	uid = "topic_command_revision"

/decl/topic_command/revision/use()
	var/list/L = list()
	L["gameid"] = game_id
	L["dm_version"] = DM_VERSION // DreamMaker version compiled in
	L["dm_build"] = DM_BUILD // DreamMaker build compiled in
	L["dd_version"] = world.byond_version // DreamDaemon version running on
	L["dd_build"] = world.byond_build // DreamDaemon build running on

	if(revdata.revision)
		L["revision"] = revdata.revision
		L["branch"] = revdata.branch
		L["date"] = revdata.date
	else
		L["revision"] = "unknown"

	return list2params(L)

/* * * * * * * *
* Admin Topic Calls
* The following topic calls are only available if a ban comms secret has been defined, supplied, and is correct.
* * * * * * * */
/decl/topic_command/ban
	name = "placepermaban"
	uid = "topic_command_placepermaban"
	has_params = TRUE

/decl/topic_command/ban/try_use(var/T, var/addr, var/master, var/key)
	if (!can_use(T, addr, master, key))
		return FALSE
	var/list/params = params2list(T)
	var/ban_comms_password = get_config_value(/decl/config/text/ban_comms_password)
	if(!ban_comms_password)
		set_throttle(addr, 10 SECONDS, "Bans Not Enabled")
		return "Not Enabled"
	if(params["bankey"] != ban_comms_password)
		set_throttle(addr, 30 SECONDS, "Bad Bans Key")
		return "Bad Key"
	return use(params)

/decl/topic_command/ban/use(var/list/params)
	var/target = ckey(params["target"])
	if(!target)
		return "No client provided."

	var/client/C
	for(var/client/K as anything in global.clients)
		if(K.ckey == target)
			C = K
			break
	if(!C)
		return "No client with that name found on server"
	if(!C.mob)
		return "Client missing mob"

	if(!_DB_ban_record(params["id"], "0", "127.0.0.1", 1, C.mob, -1, params["reason"]))
		return "Save failed"
	ban_unban_log_save("[params["id"]] has permabanned [C.ckey]. - Reason: [params["reason"]] - This is a ban until appeal.")
	notes_add(target,"[params["id"]] has permabanned [C.ckey]. - Reason: [params["reason"]] - This is a ban until appeal.",params["id"])
	qdel(C)

/* * * * * * * *
* Secure Topic Calls
* The following topic calls are only available if a comms secret has been defined, supplied, and is correct.
* * * * * * * */

/decl/topic_command/secure/laws
	name = "laws"
	uid = "topic_command_laws"
	has_params = TRUE

/decl/topic_command/secure/laws/use(var/list/params)
	var/list/match = text_find_mobs(params["laws"], /mob/living/silicon)

	if(!match.len)
		return "No matches"
	else if(match.len == 1)
		var/mob/living/silicon/S = match[1]
		var/info = list()
		info["name"] = S.name
		info["key"] = S.key

		if(isrobot(S))
			var/mob/living/silicon/robot/robot = S
			info["master"] = robot.connected_ai?.name
			info["sync"] = robot.lawupdate

		if(!S.laws)
			info["laws"] = null
			return list2params(info)

		var/list/lawset_parts = list(
			"ion" = S.laws.ion_laws,
			"inherent" = S.laws.inherent_laws,
			"supplied" = S.laws.supplied_laws
		)

		for(var/law_type in lawset_parts)
			var/laws = list()
			for(var/datum/ai_law/L in lawset_parts[law_type])
				laws += L.law
			info[law_type] = list2params(laws)

		info["zero"] = S.laws.zeroth_law ? S.laws.zeroth_law.law : null

		return list2params(info)

	else
		var/list/ret = list()
		for(var/mob/M in match)
			ret[M.key] = M.name
		return list2params(ret)

/decl/topic_command/secure/info
	name = "info"
	uid = "topic_command_info"
	has_params = TRUE

/decl/topic_command/secure/info/use(var/list/params)
	var/list/match = text_find_mobs(params["info"])

	if(!match.len)
		return "No matches"
	else if(match.len == 1)
		var/mob/M = match[1]
		var/info = list()
		info["key"] = M.key
		info["name"] = M.name == M.real_name ? M.name : "[M.name] ([M.real_name])"
		info["role"] = M.mind ? (M.mind.assigned_role ? M.mind.assigned_role : "No role") : "No mind"
		var/turf/MT = get_turf(M)
		info["loc"] = M.loc ? "[M.loc]" : "null"
		info["turf"] = MT ? "[MT] @ [MT.x], [MT.y], [MT.z]" : "null"
		info["area"] = MT ? "[MT.loc]" : "null"
		info["antag"] = M.mind ? (M.mind.get_special_role_name("Not antag")) : "No mind"
		info["hasbeenrev"] = M.mind ? M.mind.has_been_rev : "No mind"
		info["stat"] = M.stat
		info["type"] = M.type
		if(isliving(M))
			var/mob/living/L = M
			info["damage"] = list2params(list(
				oxy   = L.get_damage(OXY),
				tox   = L.get_damage(TOX),
				fire  = L.get_damage(BURN),
				brute = L.get_damage(BRUTE),
				clone = L.get_damage(CLONE),
				brain = L.get_damage(BRAIN)
			))
			if(ishuman(M))
				var/mob/living/human/H = M
				info["species"] = H.species.name
			else
				info["species"] = "non-human"
		else
			info["damage"] = "non-living"
			info["species"] = "non-human"
		info["gender"] = M.gender
		return list2params(info)
	else
		var/list/ret = list()
		for(var/mob/M in match)
			ret[M.key] = M.name
		return list2params(ret)

/decl/topic_command/secure/adminmsg
	name = "adminmsg"
	uid = "topic_command_adminmsg"
	has_params = TRUE

/decl/topic_command/secure/adminmsg/use(var/list/params)
	var/client/C
	var/req_ckey = ckey(params["adminmsg"])

	for(var/client/K in global.clients)
		if(K.ckey == req_ckey)
			C = K
			break
	if(!C)
		return "No client with that name on server"

	var/rank = params["rank"]
	if(!rank)
		rank = "Admin"
	if(rank == "Unknown")
		rank = "Staff"

	var/message =	SPAN_RED("[rank] PM from <b><a href='byond://?irc_msg=[params["sender"]]'>[params["sender"]]</a></b>: [params["msg"]]")
	var/amessage =  SPAN_BLUE("[rank] PM from <a href='byond://?irc_msg=[params["sender"]]'>[params["sender"]]</a> to <b>[key_name(C)]</b> : [params["msg"]]")

	C.received_irc_pm = world.time
	C.irc_admin = params["sender"]

	sound_to(C, 'sound/effects/adminhelp.ogg')
	to_chat(C, message)

	for(var/client/A in global.admins)
		if(A != C)
			to_chat(A, amessage)
	return "Message Successful"

/decl/topic_command/secure/notes
	name = "notes"
	uid = "topic_command_notes"
	has_params = TRUE

/decl/topic_command/secure/notes/use(var/list/params)
	return show_player_info_irc(ckey(params["notes"]))

/decl/topic_command/secure/age
	name = "age"
	uid = "topic_command_age"
	has_params = TRUE

/decl/topic_command/secure/age/use(var/list/params)
	var/age = get_player_age(params["age"])
	if(isnum(age))
		if(age >= 0)
			return "[age]"
		else
			return "Ckey not found"
	else
		return "Database connection failed or not set up"

/decl/topic_command/secure/prometheus_metrics
	name = "prometheus_metrics"
	uid = "topic_command_prometheus_metrics"

/decl/topic_command/secure/prometheus_metrics/use()
	var/static/decl/prometheus_metrics/prometheus_metrics = IMPLIED_DECL
	return prometheus_metrics.collect()
