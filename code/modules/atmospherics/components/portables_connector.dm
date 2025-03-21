/obj/machinery/atmospherics/portables_connector
	icon = 'icons/atmos/connector.dmi'
	icon_state = "map_connector"

	name = "connector port"
	desc = "A connector port with a flexible tube that can be attached to portable atmospherics devices using a wrench."

	dir = SOUTH
	initialize_directions = SOUTH

	var/atom/movable/connected_device
	var/on = 0
	use_power = POWER_USE_OFF
	interact_offline = TRUE

	uncreated_component_parts = null
	frame_type = /obj/item/pipe
	construct_state = /decl/machine_construction/pipe

	level = LEVEL_BELOW_PLATING

	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_FUEL
	build_icon_state = "connector"

	pipe_class = PIPE_CLASS_UNARY

/obj/machinery/atmospherics/portables_connector/on_update_icon()
	icon_state = "connector"
	build_device_underlays(FALSE)

/obj/machinery/atmospherics/portables_connector/hide(var/i)
	update_icon()

/obj/machinery/atmospherics/portables_connector/Process()
	..()
	if(!on)
		return
	if(!connected_device)
		on = 0
		return
	update_networks()
	return 1

/obj/machinery/atmospherics/portables_connector/Destroy()
	if(connected_device)
		var/datum/extension/atmospherics_connection/connection = get_extension(connected_device, /datum/extension/atmospherics_connection)
		connection?.disconnect()
	. = ..()

/obj/machinery/atmospherics/portables_connector/return_network(obj/machinery/atmospherics/reference)
	. = ..()
	if(reference == connected_device) // Legacy carryover; unsure why this is supported, though.
		if(LAZYLEN(nodes_to_networks))
			return nodes_to_networks[nodes_to_networks[1]]

/obj/machinery/atmospherics/portables_connector/return_network_air(datum/pipe_network/reference)
	if(connected_device)
		var/datum/extension/atmospherics_connection/connection = get_extension(connected_device, /datum/extension/atmospherics_connection)
		if(connection)
			return list(connection.merged_mixture)

/obj/machinery/atmospherics/portables_connector/deconstruction_pressure_check()
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	if ((int_air.return_pressure()-env_air.return_pressure()) > (2 ATM))
		return FALSE
	return TRUE

/obj/machinery/atmospherics/portables_connector/cannot_transition_to(state_path, mob/user)
	if(state_path == /decl/machine_construction/default/deconstructed)
		if (connected_device)
			return SPAN_WARNING("You cannot unwrench \the [src], detach \the [connected_device] first.")
		if (locate(/obj/machinery/portable_atmospherics, src.loc))
			return MCS_BLOCK
	return ..()