/*
 * Locator
 */
/obj/item/locator
	name = "locator"
	desc = "Used to track those with locator implants."
	icon = 'icons/obj/items/device/locator.dmi'
	icon_state = ICON_STATE_WORLD
	var/temp = null
	var/frequency = 1451
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 20
	origin_tech = @'{"magnets":1}'
	material = /decl/material/solid/metal/aluminium

/obj/item/locator/attack_self(mob/user)
	user.set_machine(src)
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = {"
<B>Persistent Signal Locator</B><HR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

<A href='byond://?src=\ref[src];refresh=1'>Refresh</A>"}
	show_browser(user, dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/locator/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/turf/current_location = get_turf(usr)//What turf is the user on?
	if(!current_location||current_location.z==2)//If turf was not found or they're on z level 2.
		to_chat(usr, "\The [src] is malfunctioning.")
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && isturf(src.loc))))
		usr.set_machine(src)
		if (href_list["refresh"])
			src.temp = "<B>Persistent Signal Locator</B><HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				src.temp += "<B>Located Beacons:</B><BR>"

				for(var/obj/item/radio/beacon/radio in global.radio_beacons)
					if(!radio.functioning)
						continue
					if (radio.frequency == src.frequency)
						var/turf/tr = get_turf(radio)
						if (tr.z == sr.z && tr)
							var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									if (direct < 20)
										direct = "weak"
									else
										direct = "very weak"
							src.temp += "[radio.code]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += "<B>Extranneous Signals:</B><BR>"
				for (var/obj/item/implant/tracking/implant in global.tracking_implants)
					if (!implant.implanted || !(istype(implant.loc,/obj/item/organ/external) || ismob(implant.loc)))
						continue
					else
						var/mob/M = implant.loc
						if (M.stat == DEAD)
							if (M.timeofdeath + 6000 < world.time)
								continue

					var/turf/tr = get_turf(implant)
					if (tr.z == sr.z && tr)
						var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
						if (direct < 20)
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									direct = "weak"
							src.temp += "[implant.id]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += "<B>You are at \[[sr.x],[sr.y],[sr.z]\]</B> in orbital coordinates.<BR><BR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A><BR>"
			else
				src.temp += "<B><FONT color='red'>Processing Error:</FONT></B> Unable to locate orbital position.<BR>"
		else
			if (href_list["freq"])
				src.frequency += text2num(href_list["freq"])
				src.frequency = sanitize_frequency(src.frequency)
			else
				if (href_list["temp"])
					src.temp = null
		if (ismob(src.loc))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return
