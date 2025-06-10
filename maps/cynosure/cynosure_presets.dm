

// Cameras
/obj/machinery/camera/network/civilian
	preset_channels = list(CAMERA_CHANNEL_SECURITY)

/obj/machinery/camera/network/command
	preset_channels = list(CAMERA_CHANNEL_COMMAND)
	req_access = list(access_heads)

/obj/machinery/camera/network/research/toxins
	preset_channels = list(CAMERA_CHANNEL_RESEARCH, CAMERA_CHANNEL_TOXINS)

/obj/machinery/camera/network/research/misc
	preset_channels = list(CAMERA_CHANNEL_RESEARCH, CAMERA_CHANNEL_MISC_RESEARCH)

/obj/machinery/camera/network/research_outpost
	preset_channels = list(CAMERA_CHANNEL_RESEARCH)

/obj/machinery/camera/network/engine
	preset_channels = list(CAMERA_CHANNEL_ENGINE)
	req_access = list(access_engine)

/obj/machinery/camera/network/cargo
	preset_channels = list(CAMERA_CHANNEL_SUPPLY)

/obj/machinery/camera/network/thunder
	preset_channels = list(CAMERA_CHANNEL_ENTERTAINMENT)

/obj/machinery/camera/network/telecom
	preset_channels = list(CAMERA_CHANNEL_SECURITY)

/obj/machinery/camera/network/prison
	preset_channels = list(CAMERA_CHANNEL_SECURITY)

/obj/machinery/camera/network/interrogation
	preset_channels = list(CAMERA_CHANNEL_SECURITY)

/obj/machinery/camera/network/basement
	preset_channels = list(CAMERA_CHANNEL_BASEMENT_FLOOR)

/obj/machinery/camera/network/ground_floor
	preset_channels = list(CAMERA_CHANNEL_GROUND_FLOOR)

/obj/machinery/camera/network/second_floor
	preset_channels = list(CAMERA_CHANNEL_SECOND_FLOOR)

/obj/machinery/camera/network/supply
	preset_channels = list(CAMERA_CHANNEL_SUPPLY)


// Power storage units
/obj/machinery/power/smes/buildable/preset/cynosure
	_fully_charged = TRUE
	_input_on = TRUE
	_input_maxed = TRUE
	_output_maxed = TRUE
	_output_on = TRUE
	uncreated_component_parts = list()

/obj/machinery/power/smes/buildable/preset/cynosure/engine_main
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 4)
	RCon_tag = "Reactor - Output"

/obj/machinery/power/smes/buildable/preset/cynosure/engine_loopback
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 1)
	RCon_tag = "Reactor - Internal"

/obj/machinery/power/smes/buildable/preset/cynosure/solar_west
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 1)
	RCon_tag = "Solar - West"

/obj/machinery/power/smes/buildable/preset/cynosure/solar_east
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 1)
	RCon_tag = "Solar - East"

// This is a backup battery that can be charged by engineers, located at the basement
/obj/machinery/power/smes/buildable/preset/cynosure/basement_backup
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 4)
	RCon_tag = "Basement Backup"
	_fully_charged = FALSE
	_input_on = FALSE
	_output_on = FALSE

// Regular substations get a low capacity coil that can run the department for about 15-30 minutes depending on power usage.
// Substations start in bypass mode, engineers have to set this up (can be done remotely)
/obj/machinery/power/smes/buildable/preset/cynosure/substation
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil/weak = 1)
	_fully_charged = FALSE
	_input_on = FALSE
	_output_on = FALSE

/obj/machinery/power/smes/buildable/preset/cynosure/substation/engineering
	RCon_tag = "Substation - Engineering"

/obj/machinery/power/smes/buildable/preset/cynosure/substation/atmospherics
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 1) // Atmospherics gets a regular coil, due to its power usage
	_fully_charged = TRUE
	_input_on = TRUE
	_output_on = TRUE

/obj/machinery/power/smes/buildable/preset/cynosure/substation/medical
	RCon_tag = "Substation - Medbay"

/obj/machinery/power/smes/buildable/preset/cynosure/substation/cargo
	RCon_tag = "Substation - Cargo"

/obj/machinery/power/smes/buildable/preset/cynosure/substation/security
	RCon_tag = "Substation - Security"

/obj/machinery/power/smes/buildable/preset/cynosure/substation/ai
	RCon_tag = "NO_TAG" // Hide it on the RCon program - it would make it too easy to kill the AI
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 1) // AI gets a regular coil, due to its power usage
	_fully_charged = TRUE
	_input_on = TRUE
	_output_on = TRUE

// This one does not have a bypass so it has to start enabled
/obj/machinery/power/smes/buildable/preset/cynosure/substation/xenoarch_outpost
	RCon_tag = "Substation - Xenoarchaeology Outpost"
	_fully_charged = TRUE
	_input_on = TRUE
	_output_on = TRUE

/obj/machinery/power/smes/buildable/preset/cynosure/substation/arrivals
	RCon_tag = "Substation - Arrivals"
	_fully_charged = TRUE
	_input_on = TRUE
	_output_on = TRUE

/obj/machinery/power/smes/buildable/preset/cynosure/substation/civilian
	RCon_tag = "Substation - Civilian"

/obj/machinery/power/smes/buildable/preset/cynosure/substation/research
	RCon_tag = "Substation - Research"

/obj/machinery/power/smes/buildable/preset/cynosure/substation/command
	RCon_tag = "Substation - Command"