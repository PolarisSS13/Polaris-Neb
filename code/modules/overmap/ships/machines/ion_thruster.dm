/datum/extension/ship_engine/ion_thruster
	expected_type = /obj/machinery/ion_thruster

/datum/extension/ship_engine/ion_thruster/burn(var/partial = 1)
	var/obj/machinery/ion_thruster/thruster = holder
	if(istype(thruster) && thruster.get_thrust(partial))
		return get_exhaust_velocity() * thruster.thrust_effectiveness
	return 0

/datum/extension/ship_engine/ion_thruster/get_exhaust_velocity()
	. = 300 // Arbitrary value based on being slightly less than a default configuration gas engine.

/datum/extension/ship_engine/ion_thruster/get_specific_wet_mass()
	. = 1.5 // Arbitrary value based on being slightly less than a default configuration gas engine.

/datum/extension/ship_engine/ion_thruster/has_fuel()
	var/obj/machinery/ion_thruster/thruster = holder
	. = istype(thruster) && !(thruster.stat & NOPOWER)

/datum/extension/ship_engine/ion_thruster/get_status()
	. = list()
	. += ..()
	var/obj/machinery/ion_thruster/thruster = holder
	if(!istype(thruster))
		. += "Hardware failure - check machinery."
	else if(thruster.stat & NOPOWER)
		. += "Insufficient power or hardware offline."
	else
		. += "Online."
	return jointext(.,"<br>")

/obj/machinery/ion_thruster
	name = "ion thruster"
	desc = "An advanced propulsion device, using energy and minute amounts of gas to generate thrust."
	icon = 'icons/obj/ship_engine.dmi'
	icon_state = "nozzle2"
	density = TRUE
	power_channel = ENVIRON
	idle_power_usage = 100
	anchored = TRUE
	construct_state = /decl/machine_construction/default/panel_closed
	use_power = POWER_USE_IDLE

	// TODO: modify these with upgraded parts?
	var/thrust_limit = 1
	var/thrust_cost = 750
	var/thrust_effectiveness = 1

/obj/machinery/ion_thruster/attackby(obj/item/used_item, mob/user)
	if(IS_MULTITOOL(used_item) && !panel_open)
		var/datum/extension/ship_engine/engine = get_extension(src, /datum/extension/ship_engine)
		if(engine.sync_to_ship())
			to_chat(user, SPAN_NOTICE("\The [src] emits a ping as it syncs its controls to a nearby ship."))
		else
			to_chat(user, SPAN_WARNING("\The [src] flashes an error!"))
		return TRUE

	. = ..()

/obj/machinery/ion_thruster/proc/get_thrust()
	if(use_power && !(stat & NOPOWER))
		use_power_oneoff(thrust_cost)
		return thrust_limit
	return 0

/obj/machinery/ion_thruster/on_update_icon()
	cut_overlays()
	if(!(stat & (NOPOWER | BROKEN)))
		add_overlay(emissive_overlay(icon, "ion_glow"))
		z_flags |= ZMM_MANGLE_PLANES
	else
		z_flags &= ~ZMM_MANGLE_PLANES

/obj/machinery/ion_thruster/power_change()
	. = ..()
	queue_icon_update()

/obj/machinery/ion_thruster/Initialize()
	. = ..()
	set_extension(src, /datum/extension/ship_engine/ion_thruster, "ion thruster")

/obj/item/stock_parts/circuitboard/engine/ion
	name = "circuitboard (ion thruster)"
	board_type = "machine"
	icon = 'icons/obj/modules/module_controller.dmi'
	build_path = /obj/machinery/ion_thruster
	origin_tech = @'{"powerstorage":1,"engineering":2}'
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/capacitor = 2)
	matter = list(
		/decl/material/solid/gemstone/diamond = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/metal/gold =       MATTER_AMOUNT_TRACE,
		/decl/material/solid/metal/silver =     MATTER_AMOUNT_TRACE
	)
