/decl/machine_construction/default/panel_closed/door
	needs_board = "door"
	down_state = /decl/machine_construction/default/panel_open/door
	var/hacking_state = /decl/machine_construction/default/panel_closed/door/hacking

/decl/machine_construction/default/panel_closed/door/attackby(obj/item/used_item, mob/user, obj/machinery/machine)
	if(IS_SCREWDRIVER(used_item))
		TRANSFER_STATE(hacking_state)
		playsound(get_turf(machine), 'sound/items/Screwdriver.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("You release some of the logic wiring on \the [machine]. The cover panel remains closed."))
		machine.update_icon()
		return TRUE
	if(IS_WRENCH(used_item))
		TRANSFER_STATE(down_state)
		playsound(get_turf(machine), 'sound/items/Crowbar.ogg', 50, 1)
		machine.panel_open = TRUE
		to_chat(user, SPAN_NOTICE("You open the main cover panel on \the [machine], exposing the internals."))
		machine.queue_icon_update()
		return TRUE
	if(istype(used_item, /obj/item/part_replacer))
		var/obj/item/part_replacer/replacer = used_item
		if(replacer.remote_interaction)
			machine.part_replacement(user, replacer)
		for(var/line in machine.get_part_info_strings(user))
			to_chat(user, line)
		return TRUE
	return FALSE

/decl/machine_construction/default/panel_closed/door/mechanics_info()
	. = list()
	. += "Use a screwdriver to open a small hatch and expose some logic wires."
	. += "Use a wrench to open the main cover."
	. += "Use a parts replacer to view installed parts."

/decl/machine_construction/default/panel_closed/door/hacking
	up_state = /decl/machine_construction/default/panel_closed/door

/decl/machine_construction/default/panel_closed/door/hacking/attackby(obj/item/used_item, mob/user, obj/machinery/machine)
	if(IS_SCREWDRIVER(used_item))
		TRANSFER_STATE(up_state)
		playsound(get_turf(machine), 'sound/items/Screwdriver.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("You tuck the exposed wiring back into \the [machine] and screw the hatch back into place."))
		machine.queue_icon_update()
		return TRUE
	return FALSE

/decl/machine_construction/default/panel_closed/door/hacking/mechanics_info()
	. = list()
	. += "Use a screwdriver close the hatch and tuck the exposed wires back in."

/decl/machine_construction/default/panel_open/door
	needs_board = "door"
	up_state = /decl/machine_construction/default/panel_closed/door