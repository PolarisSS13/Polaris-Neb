
#define FLOOR_VALUE 0
#define WALL_VALUE 1
#define DOOR_VALUE 3
#define ROAD_VALUE 10
#define ARTIFACT_VALUE 11

#define TRANSLATE_COORD(X,Y) ((((Y) - 1) * limit_x) + (X))

/datum/exoplanet_theme/ruined_city
	name = "Ruined City"
	var/spooky_ambience = list(
		'sound/ambience/ominous1.ogg',
		'sound/ambience/ominous2.ogg',
		'sound/ambience/ominous3.ogg'
		)

/datum/exoplanet_theme/ruined_city/modify_template_whitelist(whitelist_flags)
	return whitelist_flags | TEMPLATE_TAG_ALIEN

/datum/exoplanet_theme/ruined_city/get_map_generators(/datum/planetoid_data/E)
	return list(/datum/random_map/city)

/datum/exoplanet_theme/ruined_city/after_map_generation(datum/planetoid_data/E)
	var/datum/level_data/LD = SSmapping.levels_by_id[E.surface_level_id]
	var/area/A = LD.get_base_area_instance()
	if(istype(A, world.area))
		PRINT_STACK_TRACE("Got '[world.area]' area as area for the surface level '[LD]' of planetoid '[E]'.") //Don't modify the ambience of the space area.
	LAZYDISTINCTADD(A.ambience, spooky_ambience)

/datum/exoplanet_theme/ruined_city/get_sensor_data()
	return "Extensive artificial structures detected on the surface."

/datum/exoplanet_theme/ruined_city/get_planet_image_extra(datum/planetoid_data/E)
	return image('icons/skybox/planet.dmi', "ruins")

// Generates a grid of roads with buildings between them
/datum/random_map/city
	descriptor = "ruined city"
	initial_wall_cell = 0
	initial_cell_char = -1
	var/max_building_size = 11	//Size of buildings in tiles. Must be odd number for building generation to work properly.
	var/buildings_number = 4	//Buildings per block
	var/list/blocks_x = list(2)	//coordinates for start of blocs
	var/list/blocks_y = list(2)
	var/list/building_types = list(
		/datum/random_map/maze/concrete = 90,
		/datum/random_map/maze/lab
		)
	var/list/building_maps

/datum/random_map/city/generate_map()
	var/block_size = buildings_number * max_building_size + 2
	var/num_blocks_x = round(limit_x/block_size)
	var/num_blocks_y = round(limit_y/block_size)

	//Get blocks borders coordinates
	for(var/i = 1 to num_blocks_x)
		blocks_x += blocks_x[i] + block_size + 1
	for(var/i = 1 to num_blocks_y)
		blocks_y += blocks_x[i] + block_size + 1
	blocks_x += limit_x - 1
	blocks_y += limit_y - 1

	//Draw roads
	for(var/x in blocks_x)
		if(x > limit_x)
			continue
		for(var/y = 1 to limit_y)
			if(x > 1)
				map[TRANSLATE_COORD(x-1,y)] = ROAD_VALUE
			map[TRANSLATE_COORD(x,y)] = ROAD_VALUE
			if(x < limit_x)
				map[TRANSLATE_COORD(x+1,y)] = ROAD_VALUE

	for(var/y in blocks_y)
		if(y > limit_y)
			continue
		for(var/x = 1 to limit_x)
			if(y > 1)
				map[TRANSLATE_COORD(x,y-1)] = ROAD_VALUE
			map[TRANSLATE_COORD(x,y)] = ROAD_VALUE
			if(y < limit_y)
				map[TRANSLATE_COORD(x,y+1)] = ROAD_VALUE

	//Place buildings
	for(var/i = 1 to blocks_x.len - 1)
		for(var/j = 1 to blocks_y.len - 1)
			for(var/k = 0 to buildings_number - 1)
				for(var/l = 0 to buildings_number - 1)
					var/building_x = blocks_x[i] + 1 + max_building_size * k
					var/building_y = blocks_y[j] + 1 + max_building_size * l
					var/building_size_x = pick(7,9,9,11,11,11)
					var/building_size_y = pick(7,9,9,11,11,11)
					if(building_x + building_size_x >= limit_x)
						continue
					if(building_y + building_size_y >= limit_y)
						continue
					var/building_type = pickweight(building_types)
					var/datum/random_map/building = new building_type(origin_x + building_x, origin_y + building_y, origin_z, building_size_x, building_size_y, TRUE, TRUE, use_area)
					LAZYADD(building_maps, building) // They're applied later to let buildings handle their own shit
	return 1

/datum/random_map/city/get_appropriate_path(var/value)
	if(value == ROAD_VALUE && prob(99))
		return /turf/floor/concrete/reinforced/road

/datum/random_map/city/get_additional_spawns(var/value, var/turf/floor/T)
	if(istype(T, /turf/floor/concrete/reinforced/road))
		if(prob(1))
			new/obj/structure/rubble/house(T)
		if(prob(5))
			T.set_floor_broken(TRUE)

/datum/random_map/city/apply_to_map()
	..()
	for(var/datum/random_map/building in building_maps)
		building.apply_to_map()

// Buildings
/turf/wall/concrete
	icon_state = "stone"
	floor_type = null
	material = /decl/material/solid/stone/concrete

/turf/wall/concrete/reinforced
	reinf_material = /decl/material/solid/metal/steel

//Generic ruin
/datum/random_map/maze/concrete
	wall_type =  /turf/wall/concrete
	floor_type = /turf/floor/concrete/reinforced
	preserve_map = 0

/datum/random_map/maze/concrete/get_appropriate_path(var/value)
	if(value == WALL_VALUE)
		if(prob(80))
			return /turf/wall/concrete
		else
			return /turf/floor/concrete/reinforced/damaged
	return ..()

/datum/random_map/maze/concrete/get_additional_spawns(var/value, var/turf/floor/T)
	if(!istype(T))
		return
	if(prob(10))
		new/obj/item/remains/xeno/charred(T)
	if((T.is_floor_broken() && prob(80)) || prob(10))
		new/obj/structure/rubble/house(T)
	if(prob(1))
		new/obj/abstract/landmark/exoplanet_spawn/animal(T)

//Artifact containment lab
/turf/wall/containment
	paint_color = COLOR_GRAY20
	floor_type = /turf/floor/fixed/alium/airless

/turf/wall/containment/Initialize(var/ml)
	. = ..(ml, /decl/material/solid/stone/concrete, /decl/material/solid/metal/aliumium)

/datum/random_map/maze/lab
	wall_type =  /turf/wall/containment
	floor_type = /turf/floor/fixed/alium/airless
	preserve_map = 0
	var/artifacts_to_spawn = 1

/datum/random_map/maze/lab/New(var/tx, var/ty, var/tz, var/tlx, var/tly, var/do_not_apply, var/do_not_announce, var/used_area)
	if(prob(10))
		artifacts_to_spawn = rand(2,3)
	..()

/datum/random_map/maze/lab/generate_map()
	..()
	for(var/x in 1 to limit_x - 1)
		for(var/y in 1 to limit_y - 1)
			var/value = map[TRANSLATE_COORD(x,y)]
			if(value != FLOOR_VALUE)
				continue
			var/list/neighbors = list()
			for(var/offset in list(list(0,1), list(0,-1), list(1,0), list(-1,0)))
				var/tmp_cell = TRANSLATE_COORD(x + offset[1], y+offset[2])
				var/char = LAZYACCESS(map, tmp_cell)
				if(char == FLOOR_VALUE || char == DOOR_VALUE)
					neighbors.Add(tmp_cell)
			if(length(neighbors) > 1)
				continue

			map[neighbors[1]] = DOOR_VALUE
			if(artifacts_to_spawn)
				map[TRANSLATE_COORD(x,y)] = ARTIFACT_VALUE
				artifacts_to_spawn--
	var/entrance_x = pick(rand(2,limit_x-1), 1, limit_x)
	var/entrance_y = pick(1, limit_y)
	if(entrance_x == 1 || entrance_x == limit_x)
		entrance_y = rand(2,limit_y-1)
	map[TRANSLATE_COORD(entrance_x,entrance_y)] = DOOR_VALUE

/datum/random_map/maze/lab/get_appropriate_path(var/value)
	if(value == ARTIFACT_VALUE)
		return floor_type
	if(value == DOOR_VALUE)
		return floor_type
	. = ..()

/datum/random_map/maze/lab/get_additional_spawns(var/value, var/turf/floor/T)
	if(!istype(T))
		return

	if(value == DOOR_VALUE)
		new/obj/machinery/door/airlock/alien(T)
		return

	if(value == ARTIFACT_VALUE)
		var/datum/artifact_find/A = new()
		new A.artifact_find_type(T)
		qdel(A)
		return

	if(value == FLOOR_VALUE)
		if(prob(20))
			new/obj/structure/rubble/lab(T)
		if(prob(20))
			new/obj/item/remains/xeno/charred(T)


#undef TRANSLATE_COORD