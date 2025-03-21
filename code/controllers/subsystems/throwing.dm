//ported from TG 28/10/2019

#define MAX_TICKS_TO_MAKE_UP 3 //how many missed ticks will we attempt to make up for this run.

SUBSYSTEM_DEF(throwing)
	name = "Throwing"
	priority = SS_PRIORITY_THROWING
	wait = 1
	flags = SS_NO_INIT|SS_KEEP_TIMING

	var/list/currentrun
	var/list/processing = list()

/datum/controller/subsystem/throwing/stat_entry()
	..("P:[processing.len]")

/datum/controller/subsystem/throwing/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/atom/movable/AM = currentrun[currentrun.len]
		var/datum/thrownthing/TT = currentrun[AM]
		currentrun.len--
		if (QDELETED(AM))
			if(!QDELETED(TT))
				qdel(TT) // handles removing from processing list
			if (MC_TICK_CHECK)
				return
			continue
		if (QDELETED(TT))
			if(!QDELETED(AM))
				AM.end_throw(TT)
				processing -= AM
			if (MC_TICK_CHECK)
				return
			continue

		TT.tick()

		if (MC_TICK_CHECK)
			return

	currentrun = null

/datum/thrownthing
	var/atom/movable/thrownthing
	var/atom/target
	var/turf/target_turf
	var/target_zone
	var/init_dir
	var/maxrange
	var/speed
	var/mob/thrower
	var/start_time
	var/dist_travelled = 0
	var/dist_x
	var/dist_y
	var/dx
	var/dy
	var/diagonal_error
	var/pure_diagonal
	var/datum/callback/callback
	var/paused = FALSE
	var/delayed_time = 0
	var/last_move = 0

/datum/thrownthing/New(var/atom/movable/thrownthing, var/atom/target, var/range, var/speed, var/mob/thrower, var/datum/callback/callback)
	..()
	src.thrownthing = thrownthing
	src.target = target
	src.target_turf = get_turf(target)
	src.init_dir = get_dir(thrownthing, target)
	src.maxrange = range
	src.speed = speed
	src.thrower = thrower
	src.callback = callback
	if(!QDELETED(thrower))
		src.target_zone = thrower.get_target_zone()

	dist_x = abs(target.x - thrownthing.x)
	dist_y = abs(target.y - thrownthing.y)
	dx = (target.x > thrownthing.x) ? EAST : WEST
	dy = (target.y > thrownthing.y) ? NORTH : SOUTH//same up to here

	if (dist_x == dist_y)
		pure_diagonal = TRUE

	else if(dist_x <= dist_y)
		var/olddist_x = dist_x
		var/olddx = dx
		dist_x = dist_y
		dist_y = olddist_x
		dx = dy
		dy = olddx

	diagonal_error = dist_x/2 - dist_y

	start_time = world.time

/datum/thrownthing/Destroy()
	SSthrowing.processing -= thrownthing
	thrownthing.end_throw(src)
	thrownthing = null
	target = null
	thrower = null
	callback = null
	return ..()

/datum/thrownthing/proc/tick()
	var/atom/movable/AM = thrownthing
	if (!isturf(AM.loc) || !AM.throwing)
		finalize()
		return

	if(paused)
		delayed_time += world.time - last_move
		return

	if (dist_travelled && hitcheck(get_turf(thrownthing))) //to catch sneaky things moving on our tile while we slept
		finalize()
		return

	var/atom/step

	last_move = world.time

	//calculate how many tiles to move, making up for any missed ticks.
	var/tilestomove = NONUNIT_CEILING(min(((((world.time+world.tick_lag) - start_time + delayed_time) * speed) - (dist_travelled ? dist_travelled : -1)), speed*MAX_TICKS_TO_MAKE_UP) * (world.tick_lag * SSthrowing.wait), 1)
	while (tilestomove-- > 0)
		if (dist_travelled >= maxrange || AM.loc == target_turf)
			finalize()
			return

		if (dist_travelled <= max(dist_x, dist_y)) //if we haven't reached the target yet we home in on it, otherwise we use the initial direction
			step = get_step(AM, get_dir(AM, target_turf))
		else
			step = get_step(AM, init_dir)

		if (!pure_diagonal) // not a purely diagonal trajectory and we don't want all diagonal moves to be done first
			if (diagonal_error >= 0 && max(dist_x,dist_y) - dist_travelled != 1) //we do a step forward unless we're right before the target
				step = get_step(AM, dx)
			diagonal_error += (diagonal_error < 0) ? dist_x/2 : -dist_y

		if (!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
			finalize()
			return

		if (hitcheck(step))
			finalize()
			return

		AM.Move(step, get_dir(AM, step))

		if (!AM.throwing) // we hit something during our move
			return

		dist_travelled++

/datum/thrownthing/proc/finalize(hit = FALSE, t_target = null)
	set waitfor = FALSE
	//done throwing, either because it hit something or it finished moving
	if(QDELETED(thrownthing))
		return

	thrownthing.throwing = null

	if (!hit)
		for (var/atom/thing as anything in get_turf(thrownthing)) //looking for our target on the turf we land on.
			if (thing == target)
				hit = TRUE
				thrownthing.throw_impact(thing, src)
				break

		if(QDELETED(thrownthing))
			return

		if(!hit)
			thrownthing.throw_impact(get_turf(thrownthing), src)  // we haven't hit something yet and we still must, let's hit the ground.
			if(!QDELETED(thrownthing))
				thrownthing.space_drift(init_dir)

	if(t_target && !QDELETED(thrownthing))
		thrownthing.throw_impact(t_target, src)

	if (callback)
		callback.Invoke()

	if(!QDELETED(thrownthing))
		thrownthing.fall()

	thrownthing.end_throw(src)
	qdel(src)

/datum/thrownthing/proc/hit_atom(atom/A)
	finalize(hit=TRUE, t_target=A)

/datum/thrownthing/proc/hitcheck(var/turf/T)
	var/atom/movable/hit_thing
	for (var/thing in T)
		var/atom/movable/AM = thing
		if (AM == thrownthing || (AM == thrower && !ismob(thrownthing)))
			continue
		if (!AM.density || AM.throwpass)
			continue
		if((AM.atom_flags & ATOM_FLAG_CHECKS_BORDER) && !(get_dir(AM, thrownthing) & AM.dir))
			continue
		if(!hit_thing || AM.layer > hit_thing.layer)
			hit_thing = AM

	if(hit_thing)
		finalize(hit=TRUE, t_target=hit_thing)
		return TRUE