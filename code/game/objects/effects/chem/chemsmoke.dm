/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////
/obj/effect/effect/smoke/chem
	icon = 'icons/effects/chemsmoke.dmi'
	opacity = FALSE
	layer = ABOVE_PROJECTILE_LAYER
	time_to_live = 300
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GRILLE | PASS_FLAG_GLASS //PASS_FLAG_GLASS is fine here, it's just so the visual effect can "flow" around glass
	var/splash_amount = 10 //atoms moving through a smoke cloud get splashed with up to 10 units of reagent
	var/turf/destination

/obj/effect/effect/smoke/chem/Initialize(mapload, smoke_duration, turf/dest_turf = null, icon/cached_icon = null)
	. = ..()

	create_reagents(500)

	if(cached_icon)
		icon = cached_icon

	set_dir(pick(global.cardinal))
	pixel_x = -32 + rand(-8, 8)
	pixel_y = -32 + rand(-8, 8)

	//switching opacity on after the smoke has spawned, and then turning it off before it is deleted results in cleaner
	//lighting and view range updates (Is this still true with the new lighting system?)
	set_opacity(1)

	//float over to our destination, if we have one
	destination = dest_turf
	if(destination)
		walk_to(src, destination)

/obj/effect/effect/smoke/chem/Destroy()
	walk(src, 0) // Because we might have called walk_to, we must stop the walk loop or BYOND keeps an internal reference to us forever.
	set_opacity(0)
	set_density(0)
	return ..()

/obj/effect/effect/smoke/chem/Move()
	var/list/oldlocs = view(1, src)
	. = ..()
	if(.)
		for(var/turf/T in view(1, src) - oldlocs)
			for(var/atom/movable/AM in T)
				if(!istype(AM, /obj/effect/effect/smoke/chem))
					reagents.splash(AM, splash_amount, copy = 1)
		if(loc == destination)
			bound_width = 96
			bound_height = 96

/obj/effect/effect/smoke/chem/Crossed(atom/movable/AM)
	..()
	if(AM.simulated && !istype(AM, /obj/effect/effect/smoke/chem))
		reagents.splash(AM, splash_amount, copy = 1)

/obj/effect/effect/smoke/chem/proc/initial_splash()
	for(var/turf/T in view(1, src))
		for(var/atom/movable/AM in T)
			if(!istype(AM, /obj/effect/effect/smoke/chem))
				reagents.splash(AM, splash_amount, copy = 1)

// Fades out the smoke smoothly using its alpha variable.
/obj/effect/effect/smoke/chem/end_of_life()
	if(QDELETED(src))
		return
	walk(src, 0) // Because we might have called walk_to, we must stop the walk loop or BYOND keeps an internal reference to us forever.
	set_opacity(0)
	set_density(0)
	animate(src, alpha = 0, time = 0.5 SECONDS)
	sleep(0.5 SECONDS)
	..()

/////////////////////////////////////////////
// Chem Smoke Effect System
/////////////////////////////////////////////
/datum/effect/effect/system/smoke_spread/chem
	smoke_type = /obj/effect/effect/smoke/chem
	var/obj/chemholder
	var/range
	var/list/targetTurfs
	var/list/wallList
	var/density
	var/show_log = 1

/datum/effect/effect/system/smoke_spread/chem/spores
	show_log = 0
	var/datum/seed/seed

/datum/effect/effect/system/smoke_spread/chem/spores/New(seed_id)
	if(seed_id)
		seed = SSplants.seeds[seed_id]
	if(!seed)
		qdel(src)
	..()

/datum/effect/effect/system/smoke_spread/chem/New()
	..()
	chemholder = new/obj()
	chemholder.create_reagents(500)

//Sets up the chem smoke effect
// Calculates the max range smoke can travel, then gets all turfs in that view range.
// Culls the selected turfs to a (roughly) circle shape, then calls smokeFlow() to make
// sure the smoke can actually path to the turfs. This culls any turfs it can't reach.
/datum/effect/effect/system/smoke_spread/chem/set_up(var/datum/reagents/carry = null, n = 10, c = 0, loca, direct)
	range = n * 0.3
	cardinals = c
	carry.trans_to_obj(chemholder, carry.total_volume, copy = 1)

	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(!location)
		return

	targetTurfs = new()

	//build affected area list
	for(var/turf/T in view(range, location))
		//cull turfs to circle
		if(sqrt((T.x - location.x)**2 + (T.y - location.y)**2) <= range)
			targetTurfs += T

	wallList = new()

	smokeFlow() //pathing check

	//set the density of the cloud - for diluting reagents
	density = max(1, targetTurfs.len / 4) //clamp the cloud density minimum to 1 so it cant multiply the reagents

	//Admin messaging
	var/contained = carry.get_reagents()
	var/area/A = get_area(location)

	var/where = "[A.proper_name] | [location.x], [location.y]"
	var/whereLink = "<A HREF='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>[where]</a>"

	if(show_log)
		var/atom/location = carry?.get_reaction_loc(CHEM_REACTION_FLAG_OVERFLOW_CONTAINER)
		if(location?.fingerprintslast)
			var/mob/M = get_mob_by_key(location.fingerprintslast)
			var/more = ""
			if(M)
				more = "(<A HREF='byond://?_src_=holder;adminmoreinfo=\ref[M]'>?</a>)"
			log_and_message_admins("A chemical smoke reaction has taken place in ([whereLink])[contained]. Last associated key is [location.fingerprintslast][more].")
		else
			log_and_message_admins("A chemical smoke reaction has taken place in ([whereLink]). No associated key.")

//Runs the chem smoke effect
// Spawns damage over time loop for each reagent held in the cloud.
// Applies reagents to walls that affect walls (only plant-b-gone at the moment).
// Also calculates target locations to spawn the visual smoke effect on, so the whole area
// is covered fairly evenly.
/datum/effect/effect/system/smoke_spread/chem/start()
	if(!location)
		return

	if(LAZYLEN(chemholder.reagents.reagent_volumes))
		for(var/turf/T in (wallList|targetTurfs))
			chemholder.reagents.touch_turf(T)

	var/color = chemholder.reagents.get_color() //build smoke icon
	var/icon/I
	if(color)
		I = icon('icons/effects/chemsmoke.dmi')
		I += color
	else
		I = icon('icons/effects/96x96.dmi', "smoke")

	//Calculate smoke duration
	var/smoke_duration = 150

	var/pressure = 0
	var/datum/gas_mixture/environment = location.return_air()
	if(environment) pressure = environment.return_pressure()
	smoke_duration = clamp(smoke_duration*pressure/(ONE_ATMOSPHERE/3), 5, smoke_duration)

	var/const/arcLength = 2.3559 //distance between each smoke cloud

	for(var/i = 0, i < range, i++) //calculate positions for smoke coverage - then spawn smoke
		var/radius = i * 1.5
		if(!radius)
			spawn(0)
				spawnSmoke(location, I, 1, 1)
			continue

		var/offset = 0
		var/points = round((radius * 2 * M_PI) / arcLength)
		var/angle = round(ToDegrees(arcLength / radius), 1)

		if(!IsInteger(radius))
			offset = 45		//degrees

		for(var/j = 0, j < points, j++)
			var/a = (angle * j) + offset
			var/x = round(radius * cos(a) + location.x, 1)
			var/y = round(radius * sin(a) + location.y, 1)
			var/turf/T = locate(x,y,location.z)
			if(!T)
				continue
			if(T in targetTurfs)
				spawn(0)
					spawnSmoke(T, I, range)

//------------------------------------------
// Randomizes and spawns the smoke effect.
// Also handles deleting the smoke once the effect is finished.
//------------------------------------------
/datum/effect/effect/system/smoke_spread/chem/proc/spawnSmoke(var/turf/T, var/icon/I, var/smoke_duration, var/dist = 1, var/splash_initial=0, var/obj/effect/effect/smoke/chem/passed_smoke)

	var/obj/effect/effect/smoke/chem/smoke
	if(passed_smoke)
		smoke = passed_smoke
	else
		smoke = new /obj/effect/effect/smoke/chem(location, smoke_duration + rand(0, 20), T, I)

	if(LAZYLEN(chemholder.reagents.reagent_volumes))
		chemholder.reagents.trans_to_obj(smoke, chemholder.reagents.total_volume / dist, copy = 1) //copy reagents to the smoke so mob/breathe() can handle inhaling the reagents

	//Kinda ugly, but needed unless the system is reworked
	if(splash_initial)
		smoke.initial_splash()


/datum/effect/effect/system/smoke_spread/chem/spores/spawnSmoke(var/turf/T, var/icon/I, var/smoke_duration, var/dist = 1)
	var/obj/effect/effect/smoke/chem/spores = new /obj/effect/effect/smoke/chem(location)
	spores.SetName("cloud of [seed.product_name] [seed.seed_noun]")
	..(T, I, smoke_duration, dist, passed_smoke=spores)


/datum/effect/effect/system/smoke_spread/chem/proc/smokeFlow() // Smoke pathfinder. Uses a flood fill method based on zones to quickly check what turfs the smoke (airflow) can actually reach.

	var/list/pending = new()
	var/list/complete = new()

	pending += location

	var/airblock // zeroed by ATMOS_CANPASS_TURF
	while(pending.len)
		for(var/turf/current in pending)
			for(var/D in global.cardinal)
				var/turf/target = get_step(current, D)
				if(wallList)
					if(istype(target, /turf/wall))
						if(!(target in wallList))
							wallList += target
						continue

				if(target in pending)
					continue
				if(target in complete)
					continue
				if(!(target in targetTurfs))
					continue
				ATMOS_CANPASS_TURF(airblock, current, target)
				if(airblock) //this is needed to stop chemsmoke from passing through thin window walls
					continue
				ATMOS_CANPASS_TURF(airblock, target, current)
				if(airblock)
					continue
				pending += target

			pending -= current
			complete += current

	targetTurfs = complete

	return
