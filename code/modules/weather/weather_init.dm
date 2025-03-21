INITIALIZE_IMMEDIATE(/obj/abstract/weather_system)
/obj/abstract/weather_system/Initialize(var/ml, var/target_z, var/initial_weather, var/list/banned)
	SSweather.register_weather_system(src)

	. = ..()

	set_invisibility(INVISIBILITY_NONE)

	if(prob(20)) // arbitrary chance to already have some degree of wind when the weather system starts
		wind_direction = pick(global.alldirs)
		wind_strength = rand(1,5)

	banned_weather_conditions = banned

	// Bookkeeping/rightclick guards.
	verbs.Cut()
	forceMove(null)
	lightning_overlay = new
	vis_contents_additions = list(src, lightning_overlay)

	// Initialize our state machine.
	weather_system = add_state_machine(src, /datum/state_machine/weather)
	weather_system.set_state(initial_weather || /decl/state/weather/calm)

	// Track our affected z-levels.
	affecting_zs = SSmapping.get_connected_levels(target_z)

	// If we're post-init, init immediately.
	if(SSweather.initialized)
		addtimer(CALLBACK(src, PROC_REF(init_weather)), 0)

// Start the weather effects from the highest point; they will propagate downwards during update.
/obj/abstract/weather_system/proc/init_weather()
	// Track all z-levels.
	for(var/highest_z in affecting_zs)
		var/turfcount = 0
		if(HasAbove(highest_z))
			continue
		// Update turf weather.
		var/datum/level_data/level = SSmapping.levels_by_z[highest_z]
		for(var/turf/T as anything in block(level.level_inner_min_x, level.level_inner_min_y, highest_z, level.level_inner_max_x, level.level_inner_max_y, highest_z))
			T.update_weather(src)
			turfcount++
			CHECK_TICK
		log_debug("Initialized weather for [turfcount] turf\s from z[highest_z].")
