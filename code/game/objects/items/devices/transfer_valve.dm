/obj/item/transfer_valve
	name = "tank transfer valve"
	desc = "A small, versatile valve with dual-headed heat-resistant pipes. This mechanism is the standard size for coupling with portable gas tanks."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "valve_1"
	material = /decl/material/solid/metal/stainlesssteel
	var/obj/item/tank/tank_one
	var/obj/item/tank/tank_two
	var/obj/item/assembly/attached_device
	var/weakref/attacher_ref = null
	var/valve_open = 0
	var/toggle = 1
	movable_flags = MOVABLE_FLAG_PROXMOVE

/obj/item/transfer_valve/Destroy()
	if(!QDELETED(tank_one))
		QDEL_NULL(tank_one)
	else
		tank_one = null
	if(!QDELETED(tank_two))
		QDEL_NULL(tank_two)
	else
		tank_two = null
	if(!QDELETED(attached_device))
		QDEL_NULL(attached_device)
	else
		attached_device = null
	attacher_ref = null
	return ..()

/obj/item/transfer_valve/attackby(obj/item/used_item, mob/user)
	var/turf/location = get_turf(src) // For admin logs
	if(istype(used_item, /obj/item/tank))
		var/T1_weight = 0
		var/T2_weight = 0
		if(tank_one && tank_two)
			to_chat(user, "<span class='warning'>There are already two tanks attached, remove one first.</span>")
			return TRUE

		if(!user.try_unequip(used_item, src))
			return TRUE
		if(!tank_one)
			tank_one = used_item
		else
			tank_two = used_item
			message_admins("[key_name_admin(user)] attached both tanks to a transfer valve. (<A HREF='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>JMP</a>)")
			log_game("[key_name_admin(user)] attached both tanks to a transfer valve.")
		to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")

		T1_weight = tank_one.w_class
		if(tank_two)
			T2_weight = tank_two.w_class

		src.w_class = max(initial(src.w_class),T1_weight,T2_weight) //gets w_class of biggest object, because you shouldn't be able to just shove tanks in and have them be tiny.
		. = TRUE
//TODO: Have this take an assemblyholder
	else if(isassembly(used_item))
		var/obj/item/assembly/A = used_item
		if(A.secured)
			to_chat(user, "<span class='notice'>The device is secured.</span>")
			return TRUE
		if(attached_device)
			to_chat(user, "<span class='warning'>There is already an device attached to the valve, remove it first.</span>")
			return TRUE
		if(!user.try_unequip(used_item, src))
			return TRUE
		attached_device = A
		to_chat(user, "<span class='notice'>You attach \the [used_item] to the valve controls and secure it.</span>")
		A.holder = src
		A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).

		global.bombers += "[key_name(user)] attached a [used_item] to a transfer valve."
		message_admins("[key_name_admin(user)] attached a [used_item] to a transfer valve. (<A HREF='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>JMP</a>)")
		log_game("[key_name_admin(user)] attached a [used_item] to a transfer valve.")
		attacher_ref = weakref(user)
		. = TRUE
	if(.)
		update_icon()
		SSnano.update_uis(src) // update all UIs attached to src
		return TRUE
	return ..()


/obj/item/transfer_valve/HasProximity(atom/movable/AM)
	. = ..()
	if(. && attached_device)
		attached_device.HasProximity(AM)

/obj/item/transfer_valve/attack_self(mob/user)
	ui_interact(user)

/obj/item/transfer_valve/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	// this is the data which will be sent to the ui
	var/data[0]
	data["attachmentOne"] = tank_one ? tank_one.name : null
	data["attachmentTwo"] = tank_two ? tank_two.name : null
	data["valveAttachment"] = attached_device ? attached_device.name : null
	data["valveOpen"] = valve_open ? 1 : 0

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "transfer_valve.tmpl", "Tank Transfer Valve", 460, 280)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		//ui.set_auto_update(1)

/obj/item/transfer_valve/Topic(href, href_list)
	..()
	if ( usr.stat || usr.restrained() )
		return 0
	if (src.loc != usr)
		return 0
	if(tank_one && href_list["tankone"])
		remove_tank(tank_one)
	else if(tank_two && href_list["tanktwo"])
		remove_tank(tank_two)
	else if(href_list["open"])
		toggle_valve()
	else if(attached_device)
		if(href_list["rem_device"])
			attached_device.dropInto(loc)
			attached_device.holder = null
			attached_device = null
			update_icon()
		if(href_list["device"])
			attached_device.attack_self(usr)
	return 1 // Returning 1 sends an update to attached UIs

/obj/item/transfer_valve/proc/process_activation(var/obj/item/activator)
	if(toggle)
		toggle = 0
		toggle_valve()
		spawn(50) // To stop a signal being spammed from a proxy sensor constantly going off or whatever
			toggle = 1

/obj/item/transfer_valve/on_update_icon()
	. = ..()
	underlays.Cut()

	if(!tank_one && !tank_two && !attached_device)
		icon_state = "valve_1"
		return
	icon_state = "valve"

	if(tank_one)
		add_overlay(new/mutable_appearance(tank_one))
	if(tank_two)
		var/icon/J = new(icon, icon_state = "[tank_two.icon_state]")
		J.Shift(WEST, 13)
		underlays += J
	if(attached_device)
		add_overlay("device")

/obj/item/transfer_valve/proc/remove_tank(obj/item/tank/T)
	if(tank_one == T)
		split_gases()
		tank_one = null
	else if(tank_two == T)
		split_gases()
		tank_two = null
	else
		return

	if(!tank_one && !tank_two) src.w_class = initial(src.w_class) //returns it to just the transfer valve size
	T.dropInto(loc)
	update_icon()

/obj/item/transfer_valve/proc/merge_gases()
	if(valve_open)
		return
	tank_two.air_contents.volume += tank_one.air_contents.volume
	var/datum/gas_mixture/temp = tank_one.remove_air_ratio(1)
	tank_two.assume_air(temp)
	valve_open = 1

/obj/item/transfer_valve/proc/split_gases()
	if(!valve_open)
		return

	valve_open = 0

	if(QDELETED(tank_one) || QDELETED(tank_two))
		return

	var/ratio1 = tank_one.air_contents.volume/tank_two.air_contents.volume
	var/datum/gas_mixture/temp = tank_two.remove_air_ratio(ratio1)
	tank_two.air_contents.volume -=  tank_one.air_contents.volume
	tank_one.assume_air(temp)

	/*
	Exadv1: I know this isn't how it's going to work, but this was just to check
	it explodes properly when it gets a signal (and it does).
	*/

/obj/item/transfer_valve/proc/toggle_valve()
	if(!valve_open && (tank_one && tank_two))
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)

		var/attacher_name = ""
		var/mob/attacher = attacher_ref.resolve()
		if(!attacher)
			attacher_name = "Unknown"
		else
			attacher_name = "[attacher.name]([attacher.ckey])"

		var/log_str = "Bomb valve opened in <A HREF='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.proper_name]</a> "
		log_str += "with [attached_device ? attached_device : "no device"] attacher: [attacher_name]"

		if(attacher)
			log_str += "(<A HREF='byond://?_src_=holder;adminmoreinfo=\ref[attacher]'>?</A>)"

		var/mob/mob = get_mob_by_key(src.fingerprintslast)
		var/last_touch_info = ""
		if(mob)
			last_touch_info = "(<A HREF='byond://?_src_=holder;adminmoreinfo=\ref[mob]'>?</A>)"

		log_str += " Last touched by: [src.fingerprintslast][last_touch_info]"
		global.bombers += log_str
		message_admins(log_str, 0, 1)
		log_game(log_str)
		merge_gases()

	else if(valve_open==1 && (tank_one && tank_two))
		split_gases()

	src.update_icon()
