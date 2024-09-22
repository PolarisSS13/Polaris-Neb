/obj/abstract/map_data/cynosure
	height = 3

/datum/level_data/player_level/cynosure
	abstract_type = /datum/level_data/player_level/cynosure
	use_global_exterior_ambience = FALSE
	ambient_light_level = 0.7
	ambient_light_color = "#8497ec"
	base_turf = /turf/floor/natural/dirt
	exterior_atmosphere = list(
		/decl/material/gas/oxygen =   MOLES_O2STANDARD,
		/decl/material/gas/nitrogen = MOLES_N2STANDARD
	)
	strata = /decl/strata/sedimentary
	daycycle_id = "cynosure"
	daycycle_type = /datum/daycycle/cynosure
	base_area = null

/datum/daycycle/cynosure
	cycle_duration = 2 HOURS // 1 hour of daylight, 1 hour of night

/datum/daycycle/cynosure/New()
	time_in_cycle = rand(cycle_duration)
	..()

/datum/level_data/player_level/cynosure/generate_level()
	world.log << "generating Sif level [name]"
	. = ..()
	world.log << "done!"

/datum/level_data/player_level/cynosure/caves
	name = "Cynosure - Underground"
	level_id = "southern_cross_underground"
	level_generators = list(
		/datum/random_map/automata/cave_system,
		/datum/random_map/noise/sif/underground
	)

/datum/level_data/player_level/cynosure/caves/generate_level()
	. = ..()
	//new /datum/random_map/noise/ore(1, 1, level_z, 64, 64) // Create the mining ore distribution map.

/datum/level_data/player_level/cynosure/station
	name = "Cynosure - Station Ground Level"
	level_id = "southern_cross_station"
	connected_levels = list("southern_cross_wilderness" = NORTH)

/datum/level_data/player_level/cynosure/upper
	name = "Cynosure - Station Upper Level"
	level_id = "southern_cross_upper"

/datum/level_data/player_level/cynosure/wilderness
	name = "Cynosure - Wilderness"
	level_id = "southern_cross_wilderness"
	connected_levels = list("southern_cross_station" = SOUTH)
	level_generators = list(/datum/random_map/noise/sif/forest)

/obj/abstract/level_data_spawner/cynosure_caves
	level_data_type = /datum/level_data/player_level/cynosure/caves

/obj/abstract/level_data_spawner/cynosure_station
	level_data_type = /datum/level_data/player_level/cynosure/station

/obj/abstract/level_data_spawner/cynosure_upper
	level_data_type = /datum/level_data/player_level/cynosure/upper

/obj/abstract/level_data_spawner/cynosure_wilderness
	level_data_type = /datum/level_data/player_level/cynosure/wilderness
