/obj/item/mech_storage
	storage    = /datum/storage/mech
	anchored   = TRUE
	max_health = ITEM_HEALTH_NO_DAMAGE
	obj_flags  = OBJ_FLAG_NO_STORAGE

/obj/item/mech_component/chassis/Adjacent(var/atom/neighbor, var/recurse = 1) //For interaction purposes we consider body to be adjacent to whatever holder mob is adjacent
	var/mob/living/exosuit/E = loc
	if(istype(E))
		. = E.Adjacent(neighbor, recurse)
	return . || ..()

/obj/item/mech_storage/Adjacent(var/atom/neighbor, var/recurse = 1) //in order to properly retrieve items
	var/obj/item/mech_component/chassis/C = loc
	if(istype(C))
		. = C.Adjacent(neighbor, recurse-1)
	return . || ..()

/obj/item/mech_component/chassis
	name = "body"
	icon_state = "loader_body"
	gender = NEUTER
	material = /decl/material/solid/metal/steel
	has_hardpoints = list(HARDPOINT_BACK, HARDPOINT_LEFT_SHOULDER, HARDPOINT_RIGHT_SHOULDER)

	var/mech_health = 300
	var/obj/item/cell/cell
	var/obj/item/robot_parts/robot_component/diagnosis_unit/diagnostics
	var/obj/item/robot_parts/robot_component/armour/exosuit/m_armour
	var/obj/machinery/portable_atmospherics/canister/air_supply
	var/obj/item/mech_storage/storage_compartment
	var/datum/gas_mixture/cockpit
	var/transparent_cabin = FALSE
	var/hide_pilot =        FALSE
	var/hatch_descriptor = "cockpit"
	var/list/pilot_positions
	var/pilot_coverage = 100
	var/min_pilot_size = MOB_SIZE_SMALL
	var/max_pilot_size = MOB_SIZE_LARGE
	var/climb_time = 25

/obj/item/mech_component/chassis/Initialize()
	. = ..()
	if(isnull(pilot_positions))
		pilot_positions = list(
			list(
				"[NORTH]" = list("x" = 8, "y" = 0),
				"[SOUTH]" = list("x" = 8, "y" = 0),
				"[EAST]"  = list("x" = 8, "y" = 0),
				"[WEST]"  = list("x" = 8, "y" = 0)
			)
		)
	if(pilot_coverage >= 100) //Open cockpits dont get to have air
		cockpit = new
		cockpit.volume = 200
		if(loc)
			var/datum/gas_mixture/air = loc.return_air()
			if(air)
				//Essentially at this point its like we created a vacuum, but realistically making a bottle doesnt actually increase volume of a room and neither should a mech
				for(var/g in air.gas)
					cockpit.gas[g] = (air.gas[g] / air.volume) * cockpit.volume

				cockpit.temperature = air.temperature
				cockpit.update_values()

		air_supply = new /obj/machinery/portable_atmospherics/canister/air(src)
	storage_compartment = new(src)

/obj/item/mech_component/chassis/Destroy()
	QDEL_NULL(cell)
	QDEL_NULL(diagnostics)
	QDEL_NULL(m_armour)
	QDEL_NULL(air_supply)
	QDEL_NULL(storage_compartment)
	. = ..()

/obj/item/mech_component/chassis/update_components()
	diagnostics = locate() in src
	cell =        locate() in src
	m_armour =    locate() in src
	air_supply =  locate() in src
	storage_compartment = locate() in src

/obj/item/mech_component/chassis/show_missing_parts(var/mob/user)
	. = list()
	if(!cell)
		. += SPAN_WARNING("It is missing a power cell.")
	if(!diagnostics)
		. += SPAN_WARNING("It is missing a diagnostics unit.")
	if(!m_armour)
		. += SPAN_WARNING("It is missing exosuit armour plating.")

/obj/item/mech_component/chassis/proc/update_air(var/take_from_supply)

	var/changed
	if(!cockpit)
		return
	if(!take_from_supply || pilot_coverage < 100)
		var/turf/T = get_turf(src)
		if(!T)
			return
		cockpit.equalize(T.return_air())
		changed = TRUE
	else if(air_supply)
		var/env_pressure = cockpit.return_pressure()
		var/pressure_delta = air_supply.release_pressure - env_pressure
		if(pressure_delta > 0)
			if(air_supply.air_contents.temperature > 0)
				var/transfer_moles = calculate_transfer_moles(air_supply.air_contents, cockpit, pressure_delta)
				transfer_moles = min(transfer_moles, (air_supply.release_flow_rate/air_supply.air_contents.volume)*air_supply.air_contents.total_moles)
				pump_gas_passive(air_supply, air_supply.air_contents, cockpit, transfer_moles)
				changed = TRUE
		else if(pressure_delta < 0) //Release overpressure.
			var/turf/T = get_turf(src)
			if(!T)
				return
			var/datum/gas_mixture/t_air = T.return_air()
			if(t_air)
				pressure_delta = min(env_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //Location is at a lower pressure (so we can vent into it)
				var/transfer_moles = calculate_transfer_moles(cockpit, t_air, pressure_delta)
				var/datum/gas_mixture/removed = cockpit.remove(transfer_moles)
				if(!removed)
					return
				if(t_air)
					t_air.merge(removed)
				else //just delete the cabin gas, we are somewhere with invalid air, so they wont mind the additional nothingness
					qdel(removed)
				changed = TRUE
	if(changed)
		cockpit.react()

/obj/item/mech_component/chassis/ready_to_install()
	return (cell && diagnostics && m_armour)

/obj/item/mech_component/chassis/prebuild()
	diagnostics = new(src)
	cell = new /obj/item/cell/exosuit(src)
	cell.charge = cell.maxcharge

/obj/item/mech_component/chassis/attackby(var/obj/item/used_item, var/mob/user)
	if(istype(used_item,/obj/item/robot_parts/robot_component/diagnosis_unit))
		if(diagnostics)
			to_chat(user, SPAN_WARNING("\The [src] already has a diagnostic system installed."))
			return TRUE
		if(install_component(used_item, user))
			diagnostics = used_item
			return TRUE
		return FALSE
	else if(istype(used_item, /obj/item/cell))
		if(cell)
			to_chat(user, SPAN_WARNING("\The [src] already has a cell installed."))
			return TRUE
		if(install_component(used_item,user))
			cell = used_item
			return TRUE
		return FALSE
	else if(istype(used_item, /obj/item/robot_parts/robot_component/armour/exosuit))
		if(m_armour)
			to_chat(user, SPAN_WARNING("\The [src] already has armour installed."))
			return TRUE
		if(install_component(used_item, user))
			m_armour = used_item
			return TRUE
		return FALSE
	else
		return ..()

/obj/item/mech_component/chassis/receive_mouse_drop(atom/dropping, mob/user, params)
	. = ..()
	if(!. && istype(dropping, /obj/machinery/portable_atmospherics/canister))
		var/obj/machinery/portable_atmospherics/canister/C = dropping
		if(pilot_coverage < 100)
			to_chat(user, SPAN_NOTICE("This type of chassis doesn't support internals."))
			return TRUE
		if(!C.anchored && do_after(user, 5, src))
			if(C.anchored)
				return
			to_chat(user, SPAN_NOTICE("You install the canister in \the [src]."))
			if(air_supply)
				air_supply.dropInto(get_turf(src))
				air_supply = null
			C.forceMove(src)
			update_components()
		return TRUE

/obj/item/mech_component/chassis/handle_mouse_drop(atom/over, mob/user, params)
	if(storage_compartment)
		return storage_compartment.handle_mouse_drop(over, user, params)
	. = ..()

/obj/item/mech_component/chassis/return_diagnostics(mob/user)
	..()
	if(diagnostics)
		to_chat(user, SPAN_NOTICE(" Diagnostics Unit Integrity: <b>[round(get_percent_health())]%</b>"))
	else
		to_chat(user, SPAN_WARNING(" Diagnostics Unit Missing or Non-functional."))
	if(m_armour)
		to_chat(user, SPAN_NOTICE(" Armor Integrity: <b>[round(m_armour.get_percent_health())]%</b>"))
	else
		to_chat(user, SPAN_WARNING(" Armor Missing or Non-functional."))
