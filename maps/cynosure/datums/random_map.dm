/datum/random_map/noise/sif
	descriptor = "Sif plains (roundstart)"
	smoothing_iterations = 3
	target_turf_type = /turf/unsimulated/mask
	smooth_single_tiles = TRUE

/datum/random_map/noise/sif/cleanup()
	..()
	// Round down to 1-9.
	for(var/x = 1, x <= limit_x, x++)
		for(var/y = 1, y <= limit_y, y++)
			var/current_cell = TRANSLATE_COORD(x,y)
			var/current_val = map[current_cell]
			map[current_cell] = min(9,max(0,round((current_val/cell_range)*10)))
			CHECK_TICK

/datum/random_map/noise/sif/get_appropriate_path(var/value)
	switch(value)
		if(0)
			return /turf/floor/mud
		if(1 to 2)
			return /turf/floor/dirt
		if(3 to 5)
			return /turf/floor/grass/sif
		if(6 to 8)
			return /turf/floor/grass/wild/sif
		if(9)
			return /turf/floor/snow

/datum/random_map/noise/sif/get_additional_spawns(var/value, var/turf/T)
	if(prob(45) || T.density)
		return
	switch(value)
		if(1 to 2)
			if(prob(1))
				new /obj/structure/flora/sif/eyes(T)
			else if(prob(1))
				new /obj/structure/flora/mushroom(T)
		if(3 to 4)
			if(prob(1))
				new /obj/structure/flora/sif/eyes(T)
			else if(prob(1))
				new /obj/structure/flora/sif/tendrils(T)
			else if(prob(1))
				new /obj/structure/flora/mushroom(T)
		if(5 to 6)
			if(prob(1))
				new /obj/structure/flora/tree/sif(T)
			else if(prob(1))
				new /obj/structure/flora/sif/tendrils(T)
			else if(prob(1))
				new /obj/structure/flora/sif/frostbelle(T)
			else if (prob(1))
				new /obj/structure/flora/sif/eyes(T)
		if(7 to 8)
			if(prob(5))
				new /obj/structure/flora/tree/sif(T)
			else if(prob(1))
				new /obj/structure/flora/sif/frostbelle(T)
			else if(prob(1))
				new /obj/structure/flora/sif/eyes(T)
			else if(prob(1))
				new /obj/structure/flora/sif/tendrils(T)

/datum/random_map/noise/sif/forest
	descriptor = "Sif forest (roundstart)"

/datum/random_map/noise/sif/forest/get_appropriate_path(var/value)
	switch(value)
		if(0 to 3)
			return /turf/floor/grass/sif
		if(4 to 6)
			return /turf/floor/grass/wild/sif
		if(7 to 9)
			return /turf/floor/snow

/datum/random_map/noise/sif/forest/get_additional_spawns(var/value, var/turf/T)
	if(prob(25) || T.density)
		return
	switch(value)
		if(0 to 5)
			if(value >= 3 && prob(5))
				new /obj/structure/flora/tree/sif(T)
				return
			if(prob(1))
				new /obj/structure/flora/sif/eyes(T)
			else if(prob(1))
				new /obj/structure/flora/sif/tendrils(T)
			else if(prob(1))
				new /obj/structure/flora/mushroom(T)
		if(6 to 9)
			if(prob((value <= 7) ? 15 : 35))
				new /obj/structure/flora/tree/sif(T)
				return
			if(prob(1))
				new /obj/structure/flora/sif/frostbelle(T)
			else if(prob(1))
				new /obj/structure/flora/sif/eyes(T)
			else if(prob(1))
				new /obj/structure/flora/sif/tendrils(T)

/datum/random_map/noise/sif/underground
	descriptor = "Sif underground (roundstart)"
	target_turf_type = /turf/wall/natural

/datum/random_map/noise/sif/underground/get_appropriate_path(var/value)
	switch(value)
		if(0 to 2)
			return /turf/floor/mud
		if(3 to 4)
			return /turf/floor/dirt

/datum/random_map/noise/sif/underground/get_additional_spawns(var/value, var/turf/T)
	if(value <= 1 && prob(30)) // Mud is very fun-gy.
		new /obj/structure/flora/mushroom(T)
	else if(!prob(30))
		var/mushroom_prob = 0
		switch(value)
			if(2)
				mushroom_prob = 8
			if(3)
				mushroom_prob = 4
			if(4 to 6)
				mushroom_prob = 2
			if(7)
				mushroom_prob = 1
		if(mushroom_prob && prob(mushroom_prob))
			new /obj/structure/flora/mushroom(T)
		else if(prob(0.1))
			new /obj/structure/flora/sif/subterranean(T)
