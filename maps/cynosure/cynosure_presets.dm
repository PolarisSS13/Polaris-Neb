/datum/map/southern_cross
	default_telecomms_channels = list(
		COMMON_FREQUENCY_DATA,
		list("name" = "Entertainment", "key" = "z", "frequency" = 1461, "color" = COMMS_COLOR_ENTERTAIN, "span_class" = CSS_CLASS_RADIO, "receive_only" = TRUE),
		list("name" = "Command",       "key" = "c", "frequency" = 1353, "color" = COMMS_COLOR_COMMAND,   "span_class" = "comradio", "secured" = access_bridge),
		list("name" = "Security",      "key" = "s", "frequency" = 1359, "color" = COMMS_COLOR_SECURITY,  "span_class" = "secradio", "secured" = access_security),
		list("name" = "Engineering",   "key" = "e", "frequency" = 1357, "color" = COMMS_COLOR_ENGINEER,  "span_class" = "engradio", "secured" = access_engine),
		list("name" = "Medical",       "key" = "m", "frequency" = 1355, "color" = COMMS_COLOR_MEDICAL,   "span_class" = "medradio", "secured" = access_medical),
		list("name" = "Science",       "key" = "n", "frequency" = 1351, "color" = COMMS_COLOR_SCIENCE,   "span_class" = "sciradio", "secured" = access_research),
		list("name" = "Service",       "key" = "v", "frequency" = 1349, "color" = COMMS_COLOR_SERVICE,   "span_class" = "srvradio", "secured" = access_bar),
		list("name" = "Supply",        "key" = "u", "frequency" = 1347, "color" = COMMS_COLOR_SUPPLY,    "span_class" = "supradio", "secured" = access_cargo),
		list("name" = "Exploration",   "key" = "x", "frequency" = 1361, "color" = COMMS_COLOR_EXPLORER , "span_class" = "EXPradio", "secured" = access_eva),
		list("name" = "AI Private",    "key" = "p", "frequency" = 1343, "color" = COMMS_COLOR_AI,        "span_class" = "airadio",  "secured" = access_ai_upload)
	)

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

//
// Cameras
//

// Networks
/obj/machinery/camera/network/basement
	preset_channels = list(CAMERA_CHANNEL_BASEMENT_FLOOR)

/obj/machinery/camera/network/ground_floor
	preset_channels = list(CAMERA_CHANNEL_GROUND_FLOOR)

/obj/machinery/camera/network/second_floor
	preset_channels = list(CAMERA_CHANNEL_SECOND_FLOOR)

/obj/machinery/camera/network/supply
	preset_channels = list(CAMERA_CHANNEL_SUPPLY)
