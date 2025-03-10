/////////////////////////////////////////////
//Guest pass ////////////////////////////////
/////////////////////////////////////////////
/obj/item/card/id/guest
	name = "guest pass"
	desc = "Allows temporary access to restricted areas."
	color = COLOR_PALE_GREEN_GRAY
	detail_color = COLOR_GREEN

	var/list/temp_access = list() //to prevent agent cards stealing access as permanent
	var/expiration_time = 0
	var/expired = FALSE
	var/reason = "NOT SPECIFIED"

/obj/item/card/id/guest/GetAccess()
	return temp_access

/obj/item/card/id/guest/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if (expired)
		. += SPAN_WARNING("It expired at [worldtime2stationtime(expiration_time)].")
	else
		. += SPAN_NOTICE("This pass expires at [worldtime2stationtime(expiration_time)].")

/obj/item/card/id/guest/read()
	if (expired)
		to_chat(usr, SPAN_NOTICE("This pass expired at [worldtime2stationtime(expiration_time)]."))
	else
		to_chat(usr, SPAN_NOTICE("This pass expires at [worldtime2stationtime(expiration_time)]."))

	to_chat(usr, SPAN_NOTICE("It grants access to the following areas:"))
	for (var/A in temp_access)
		to_chat(usr, SPAN_NOTICE("[get_access_desc(A)]."))
	to_chat(usr, SPAN_NOTICE("Issuing reason: [reason]."))

/obj/item/card/id/guest/proc/expire()
	set_color(COLOR_BLACK)
	detail_color = COLOR_BLACK
	update_icon()

	expired = TRUE
	temp_access = initial(temp_access)

/////////////////////////////////////////////
//Guest pass terminal////////////////////////
/////////////////////////////////////////////

/obj/machinery/computer/guestpass
	name = "guest pass terminal"
	icon_state = "guest"
	icon_keyboard = null
	icon_screen = "pass"
	density = FALSE

	var/obj/item/card/id/giver
	var/list/accesses = list()
	var/giv_name = "NOT SPECIFIED"
	var/reason = "NOT SPECIFIED"
	var/duration_max = 60
	var/duration = 5

	var/list/internal_log = list()
	var/mode = 0  // 0 - making pass, 1 - viewing logs

/obj/machinery/computer/guestpass/Initialize()
	. = ..()
	uid = "[random_id("guestpass_serial_number",100,999)]-G[rand(10,99)]"

/obj/machinery/computer/guestpass/attackby(obj/used_item, mob/user)
	if(istype(used_item, /obj/item/card/id))
		if(!giver && user.try_unequip(used_item))
			used_item.forceMove(src)
			giver = used_item
			updateUsrDialog()
		else if(giver)
			to_chat(user, SPAN_WARNING("There is already ID card inside."))
		return TRUE
	return ..()

/obj/machinery/computer/guestpass/interface_interact(var/mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/computer/guestpass/ui_interact(var/mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=1)
	var/list/data = list()

	data["mode"] = mode
	data["internal_log"] = internal_log
	data["reason"] = reason
	data["duration"] = duration

	if(giver)
		data["giver"] = !!giver
		data["giver_name"] = giver.position || giver.assignment
		data["giv_name"] = giv_name

		var/list/giver_access = list()
		for(var/A in giver.access)
			giver_access.Add(list(list(
				"desc" = get_access_desc(A),
				"access" = A,
				"selected" = (A in accesses))))

		data["giver_access"] = giver_access

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "guestpass.tmpl", "Guest Pass Terminal", 600, 800)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/guestpass/OnTopic(var/mob/user, href_list, state)
	if (href_list["mode"])
		mode = text2num(href_list["mode"])
		. = TOPIC_REFRESH

	else if (href_list["giv_name"])
		var/nam = sanitize(input(user, "Person pass is issued to", "Name", giv_name) as text|null)
		if (nam && CanUseTopic(user, state))
			giv_name = nam
			. = TOPIC_REFRESH

	else if (href_list["reason"])
		var/reas = sanitize(input(user, "Reason why pass is issued", "Reason", reason) as text|null)
		if(reas && CanUseTopic(user, state))
			reason = reas
			. = TOPIC_REFRESH

	else if (href_list["duration"])
		var/dur = input(user, "Duration (in minutes) during which pass is valid (up to [duration_max] minutes).", "Duration") as num|null
		if (dur && CanUseTopic(user, state))
			if (dur > 0 && dur <= duration_max)
				duration = round(dur, 1)
				. = TOPIC_REFRESH
			else
				to_chat(user, SPAN_WARNING("Invalid duration."))

	else if (href_list["access"])
		var/A = href_list["access"]
		if (A in accesses)
			accesses.Remove(A)
		else if(giver && (A in giver.access))
			accesses.Add(A)
		. = TOPIC_REFRESH

	else if (href_list["id"])
		if (giver)
			giver.dropInto(user.loc)
			if(ishuman(user))
				user.put_in_hands(giver)
			giver = null
			accesses.Cut()
		else
			var/obj/item/used_item = user.get_active_held_item()
			if (istype(used_item, /obj/item/card/id) && user.try_unequip(used_item))
				used_item.forceMove(src)
				giver = used_item
		. = TOPIC_REFRESH

	else if (href_list["print"])
		var/dat = "<h3>Activity log of guest pass terminal #[uid]</h3><br>"
		for (var/entry in internal_log)
			dat += "[entry]<br><hr>"
		var/obj/item/paper/paper = new/obj/item/paper( loc )
		paper.SetName("activity log")
		paper.info = dat
		. = TOPIC_REFRESH

	else if (href_list["issue"])
		if (giver && accesses.len)
			var/number = add_zero(random_id("guestpass_id_number",1000,9999), 4)
			var/entry = "\[[stationtime2text()]\] Pass #[number] issued by [giver.registered_name] ([giver.assignment]) to [giv_name]. Reason: [reason]. Granted access to following areas: "
			var/list/access_descriptors = list()
			for (var/A in accesses)
				if (A in giver.access)
					access_descriptors += get_access_desc(A)
			entry += english_list(access_descriptors, and_text = ", ")
			entry += ". Expires at [worldtime2stationtime(world.time + duration MINUTES)]."
			internal_log.Add(entry)

			var/obj/item/card/id/guest/pass = new(src.loc)
			pass.temp_access = accesses.Copy()
			pass.registered_name = giv_name
			pass.expiration_time = world.time + duration MINUTES
			pass.reason = reason
			pass.SetName("guest pass #[number]")
			pass.assignment = "Guest"
			addtimer(CALLBACK(pass, TYPE_PROC_REF(/obj/item/card/id/guest, expire)), duration MINUTES, TIMER_UNIQUE)
			playsound(src.loc, 'sound/machines/ping.ogg', 25, 0)
			. = TOPIC_REFRESH
		else if(!giver)
			to_chat(user, SPAN_WARNING("Cannot issue pass without issuing ID."))
		else if(!accesses.len)
			to_chat(user, SPAN_WARNING("Cannot issue pass without at least one granted access permission."))