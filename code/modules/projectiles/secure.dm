/obj/item/gun
	var/list/authorized_modes = list(ALWAYS_AUTHORIZED) // index of this list should line up with firemodes, unincluded firemodes at the end will use default
	var/default_mode_authorization = UNAUTHORIZED
	var/registered_owner
	var/standby

/obj/item/gun/Initialize()
	if(is_secure_gun())
		if(!authorized_modes)
			authorized_modes = list()

		for(var/i = authorized_modes.len + 1 to firemodes.len)
			authorized_modes.Add(default_mode_authorization)

		set_extension(src, /datum/extension/network_device/lazy)
		verbs |= /obj/item/gun/proc/network_setup

	. = ..()

/obj/item/gun/Destroy()
	global.registered_weapons -= src
	. = ..()

/obj/item/gun/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(distance <= 0 && is_secure_gun())
		. += "The registration screen shows, \"" + (registered_owner ? "[registered_owner]" : "unregistered") + "\"."

/obj/item/gun/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, /obj/item/card/id) && is_secure_gun())
		user.visible_message("[user] swipes an ID through \the [src].", range = 3)
		if(!registered_owner)
			var/obj/item/card/id/id = used_item
			global.registered_weapons += src
			verbs += /obj/item/gun/proc/reset_registration
			registered_owner = id.registered_name
			to_chat(user, SPAN_NOTICE("\The [src] chimes quietly as it registers to \"[registered_owner]\"."))
			return TRUE
		else
			to_chat(user, SPAN_NOTICE("\The [src] buzzes quietly, refusing to register without first being reset."))
			return TRUE
	else
		return ..()

/obj/item/gun/emag_act(var/charges, var/mob/user)
	if(!charges)
		return NO_EMAG_ACT

	if(is_secure_gun())
		registered_owner = null
		global.registered_weapons -= src
		verbs -= /obj/item/gun/proc/reset_registration
		req_access.Cut()
		to_chat(user, SPAN_NOTICE("\The [src]'s authorization chip fries, giving you full access."))
		return 1

	return ..()


/obj/item/gun/proc/reset_registration()
	set name = "Reset Registration"
	set category = "Object"
	set src in usr

	if(issilicon(usr))
		to_chat(usr, SPAN_WARNING("You are not permitted to modify weapon registrations."))
		return

	usr.visible_message("[usr] presses the reset button on \the [src].", range = 3)
	if(!allowed(usr))
		to_chat(usr, SPAN_WARNING("\The [src] buzzes quietly, refusing your access."))
		return

	to_chat(usr, SPAN_NOTICE("\The [src] chimes quietly as its registration resets."))
	registered_owner = null
	global.registered_weapons -= src
	verbs -= /obj/item/gun/proc/reset_registration


/obj/item/gun/proc/authorize(var/mode, var/authorized, var/by)
	if(mode < 1 || mode > authorized_modes.len || authorized_modes[mode] == authorized)
		return FALSE

	authorized_modes[mode] = authorized

	if(mode == sel_mode && !authorized)
		switch_firemodes()

	var/mob/user = get_recursive_loc_of_type(/mob)
	if(user)
		to_chat(user, SPAN_NOTICE("Your [src.name] has been [authorized ? "granted" : "denied"] [firemodes[mode]] fire authorization by [by]."))

	return TRUE

/obj/item/gun/proc/is_secure_gun()
	return length(req_access)

/obj/item/gun/proc/free_fire()
	var/decl/security_state/security_state = GET_DECL(global.using_map.security_state)
	return security_state.current_security_level_is_same_or_higher_than(security_state.high_security_level)

/obj/item/gun/get_next_firemode()
	if(!is_secure_gun())
		return ..()
	. = sel_mode
	do
		.++
		if(. > authorized_modes.len)
			. = 1
		if(. == sel_mode) // just in case all modes are unauthorized
			return null
	while (!authorized_modes[.] && !free_fire())

/obj/item/gun/proc/get_network()
	var/datum/extension/network_device/D = get_extension(src, /datum/extension/network_device)
	if(D)
		return D.get_network()

/obj/item/gun/proc/network_setup()
	set name = "Setup Secure Gun Network"
	set category = "Object"
	set src in usr

	var/datum/extension/network_device/D = get_extension(src, /datum/extension/network_device)
	if(D)
		D.ui_interact(usr)
	else
		to_chat(usr, SPAN_WARNING("\The [src] is not network capable."))