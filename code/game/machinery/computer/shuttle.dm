/obj/machinery/computer/shuttle
	name = "Shuttle"
	desc = "For shuttle control."
	icon_keyboard = "tech_key"
	icon_screen = "shuttle"
	light_color = "#00ffff"
	construct_state = null
	var/auth_need = 3.0
	var/list/authorized = list(  )


/obj/machinery/computer/shuttle/attackby(var/obj/item/used_item, var/mob/user)
	if(stat & (BROKEN|NOPOWER))	return TRUE

	var/datum/evacuation_controller/shuttle/evac_control = SSevac.evacuation_controller
	if(!istype(evac_control))
		to_chat(user, "<span class='danger'>This console should not be in use on this map. Please report this to a developer.</span>")
		return TRUE

	if(!istype(used_item, /obj/item/card)) // don't try to get an ID card if we're an emag
		used_item = used_item.GetIdCard() // handles stored IDs in  modcomps and similar

	if ((!istype(used_item, /obj/item/card) || evac_control.has_evacuated() || !user))
		return FALSE

	if (istype(used_item, /obj/item/card/id))
		var/obj/item/card/id/id_card = used_item
		if(!LAZYISIN(id_card.access, access_bridge)) //doesn't have this access
			to_chat(user, "The access level of [id_card.registered_name]\'s card is not high enough.")
			return TRUE

		var/choice = alert(user, "Would you like to (un)authorize a shortened launch time? [auth_need - authorized.len] authorization\s are still needed. Use abort to cancel all authorizations.", "Shuttle Launch", "Authorize", "Repeal", "Abort")
		if(evac_control.is_prepared() && user.get_active_held_item() != used_item)
			return TRUE
		switch(choice)
			if("Authorize")
				src.authorized -= id_card.registered_name
				src.authorized += id_card.registered_name
				if (src.auth_need - src.authorized.len > 0)
					message_admins("[key_name_admin(user)] has authorized early shuttle launch")
					log_game("[user.ckey] has authorized early shuttle launch")
					to_world("<span class='notice'><b>Alert: [auth_need - authorized.len] authorizations needed until shuttle is launched early</b></span>")
				else
					message_admins("[key_name_admin(user)] has launched the shuttle")
					log_game("[user.ckey] has launched the shuttle early")
					to_world("<span class='notice'><b>Alert: Shuttle launch time shortened to 10 seconds!</b></span>")
					evac_control.set_launch_time(world.time+100)
					//src.authorized = null
					qdel(src.authorized)
					src.authorized = list(  )

			if("Repeal")
				src.authorized -= id_card.registered_name
				to_world("<span class='notice'><b>Alert: [auth_need - authorized.len] authorizations needed until shuttle is launched early</b></span>")

			if("Abort")
				to_world("<span class='notice'><b>All authorizations to shortening time for shuttle launch have been revoked!</b></span>")
				src.authorized.len = 0
				src.authorized = list(  )
		return TRUE

	else if (istype(used_item, /obj/item/card/emag) && !emagged)
		var/choice = alert(user, "Would you like to launch the shuttle?","Shuttle control", "Launch", "Cancel")

		if(!emagged && !evac_control.is_prepared() && user.get_active_held_item() == used_item && choice == "Launch")
			to_world("<span class='notice'><b>Alert: Shuttle launch time shortened to 10 seconds!</b></span>")
			evac_control.set_launch_time(world.time+100)
			emagged = 1
		return TRUE
	return FALSE
