// Disposal pipes

/obj/structure/disposalpipe
	icon = 'icons/obj/pipes/disposal_pipe.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = TRUE
	density = FALSE
	max_health = 10
	level = LEVEL_BELOW_PLATING
	dir = 0				// dir will contain dominant direction for junction pipes
	alpha = 192 // Plane and alpha modified for mapping, reset to normal on spawn.
	layer = ABOVE_TILE_LAYER
	var/dpdir = 0		// bitmask of pipe directions
	var/base_icon_state	// initial icon state on map
	var/sort_type = ""
	var/turn = DISPOSAL_FLIP_NONE
	var/flipped_state // If it has a mirrored version, this is the typepath for it.
	// new pipe, set the icon_state as on map

/obj/structure/disposalpipe/Initialize()
	. = ..()
	alpha = 255
	layer = DISPOSALS_PIPE_LAYER
	base_icon_state = icon_state
	update_icon()

// pipe is deleted
// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		// holder was present
		H.active = 0
		var/turf/T = src.loc
		if(T.density)
			// deleting pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(0)
			qdel(H)
			return ..()

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)
	. = ..()

/obj/structure/disposalpipe/proc/on_build()
	update()
	update_icon()

	// returns the direction of the next pipe object, given the entrance dir
	// by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(var/fromdir)
	return dpdir & (~turn(fromdir, 180))

	// transfer the holder through this pipe segment
	// overriden for special behaviour
	//
/obj/structure/disposalpipe/proc/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.set_dir(nextdir)
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P


	// update the icon_state to reflect hidden status
/obj/structure/disposalpipe/proc/update()
	var/turf/T = loc
	if(istype(T))
		hide(!T.is_plating() && !T.is_open()) // space never hides pipes

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
/obj/structure/disposalpipe/hide(var/intact)
	set_invisibility(intact ? 101: 0)	// hide if floor is intact
	update_icon()

// expel the held objects into a turf
// called when there is a break in the pipe
/obj/structure/disposalpipe/proc/expel(var/obj/structure/disposalholder/H, var/turf/T, var/direction)
	if(!istype(H))
		return

	// Turf may have been exploded due to async calls.
	if(!istype(T))
		T = get_turf(src)
		if(!T && !QDELETED(H))
			qdel(H)
			return

	// Empty the holder if it is expelled into a dense turf.
	// Leaving it intact and sitting in a wall is stupid.
	if(T.density)
		for(var/atom/movable/AM in H)
			AM.dropInto(T)
			AM.pipe_eject(0)
		qdel(H)
		return


	if(!T.is_plating() && istype(T,/turf/floor)) //intact floor, pop the tile
		var/turf/floor/F = T
		F.break_tile()
		new /obj/item/stack/tile(H)	// add to holder so it will be thrown with other stuff

	var/turf/target
	if(direction)		// direction is specified
		if(isspaceturf(T)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else						// otherwise limit to 10 tiles
			target = get_ranged_target_turf(T, direction, 10)

		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		if(H)
			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(direction)
				spawn(1)
					if(AM)
						AM.throw_at(target, 100, 1)
			H.vent_gas(T)
			qdel(H)

	else	// no specified direction, so throw in random direction
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		if(H)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

				AM.forceMove(T)
				AM.pipe_eject(0)
				spawn(1)
					if(AM)
						AM.throw_at(target, 5, 1)
			H.vent_gas(T)	// all gas vent to turf
			qdel(H)
	return

// call to break the pipe
// will expel any holder inside at the time
// then delete the pipe
// remains : set to leave broken pipe pieces in place
/obj/structure/disposalpipe/proc/broken(var/remains = 0)
	if(remains)
		for(var/D in global.cardinal)
			if(D & dpdir)
				var/obj/structure/disposalpipe/broken/P = new(src.loc)
				P.set_dir(D)

	src.set_invisibility(INVISIBILITY_ABSTRACT)	// make invisible (since we won't delete the pipe immediately)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		// holder was present
		H.active = 0
		var/turf/T = src.loc
		if(T.density)
			// broken pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(0)
			qdel(H)
			return

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)

	QDEL_IN(src, 2) // delete pipe after 2 ticks to ensure expel proc finished


// pipe affected by explosion
/obj/structure/disposalpipe/explosion_act(severity)
	SHOULD_CALL_PARENT(FALSE)
	if(severity == 1)
		broken(0)
	else
		take_damage(rand(5,15))

/obj/structure/disposalpipe/proc/can_deconstruct()
	var/turf/T = get_turf(src)
	return T.is_plating() // prevent interaction with T-scanner revealed pipes

//attack by item
//weldingtool: unfasten and convert to obj/disposalconstruct
/obj/structure/disposalpipe/attackby(var/obj/item/used_item, var/mob/user)
	if(!istype(used_item, /obj/item/weldingtool))
		return ..()
	if(!can_deconstruct())
		return TRUE
	src.add_fingerprint(user, 0, used_item)
	var/obj/item/weldingtool/welder = used_item
	if(welder.weld(0,user))
		playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
		to_chat(user, "You begin slicing \the [src].")
		if(!do_after(user, 3 SECONDS, src))
			to_chat(user, "You must stay still while welding the pipe.")
			return TRUE
		if(!welder.isOn())
			return TRUE
		welded()
		return TRUE
	to_chat(user, "You need more welding fuel to cut the pipe.")
	return TRUE

	// called when pipe is cut with welder
/obj/structure/disposalpipe/proc/welded()
	var/obj/structure/disposalconstruct/C = new (src.loc, src)
	src.transfer_fingerprints_to(C)
	C.set_density(0)
	C.anchored = TRUE
	C.update()

	qdel(src)

/obj/structure/disposalpipe/hides_under_flooring()
	return 1

// a straight or bent segment
/obj/structure/disposalpipe/segment
	desc = "A linear segment of disposal piping that simply moves things from one end to the other."
	icon_state = "pipe-s" // Sadly this var stores state. "pipe-c" is corner. Should be changed, but requires huge map diff.
	turn = DISPOSAL_FLIP_FLIP

/obj/structure/disposalpipe/segment/Initialize()
	. = ..()
	if(icon_state == "pipe-s")
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)
		turn = DISPOSAL_FLIP_RIGHT

	update()
	return

/obj/structure/disposalpipe/segment/bent
	icon_state = "pipe-c"

///// Z-Level stuff
/obj/structure/disposalpipe/up
	icon_state = "pipe-u"

/obj/structure/disposalpipe/up/Initialize()
	. = ..()
	dpdir = dir | UP
	update()
	return

/obj/structure/disposalpipe/up/nextdir(var/fromdir)
	var/nextdir
	if(fromdir == DOWN)
		nextdir = dir
	else
		nextdir = UP
	return nextdir

/obj/structure/disposalpipe/up/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.set_dir(nextdir)

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == UP)
		T = GetAbove(src)
		if(!T)
			H.forceMove(loc)
			return
		else
			for(var/obj/structure/disposalpipe/down/F in T)
				P = F

	else
		T = get_step(src.loc, H.dir)
		P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P

/obj/structure/disposalpipe/down
	icon_state = "pipe-d"

/obj/structure/disposalpipe/down/Initialize()
	. = ..()
	dpdir = dir | DOWN
	update()
	return

/obj/structure/disposalpipe/down/nextdir(var/fromdir)
	var/nextdir
	if(fromdir == UP)
		nextdir = dir
	else
		nextdir = DOWN
	return nextdir

/obj/structure/disposalpipe/down/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.set_dir(nextdir)

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == DOWN)
		T = GetBelow(src)
		if(!T)
			H.forceMove(src.loc)
			return
		else
			for(var/obj/structure/disposalpipe/up/F in T)
				P = F
	else
		T = get_step(src.loc, H.dir)
		P = H.findpipe(T)
	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)
		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P
///// Z-Level stuff

/obj/structure/disposalpipe/junction/yjunction
	icon_state = "pipe-y"
	turn = DISPOSAL_FLIP_LEFT|DISPOSAL_FLIP_RIGHT
	flipped_state = null

/obj/structure/disposalpipe/junction/mirrored
	icon_state = "pipe-j2"
	flipped_state = /obj/structure/disposalpipe/junction
	turn = DISPOSAL_FLIP_LEFT|DISPOSAL_FLIP_FLIP

//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	desc = "A three-way segment of disposal piping that merges two incoming directions into a third outgoing one."
	icon_state = "pipe-j1"
	turn = DISPOSAL_FLIP_RIGHT|DISPOSAL_FLIP_FLIP
	flipped_state = /obj/structure/disposalpipe/junction/mirrored

/obj/structure/disposalpipe/junction/Initialize()
	. = ..()
	if(icon_state == "pipe-j1")
		dpdir = dir | turn(dir, -90) | turn(dir,180)
		turn = DISPOSAL_FLIP_RIGHT|DISPOSAL_FLIP_FLIP
	else if(icon_state == "pipe-j2")
		dpdir = dir | turn(dir, 90) | turn(dir,180)
		turn = DISPOSAL_FLIP_LEFT|DISPOSAL_FLIP_FLIP
	else // pipe-y
		dpdir = dir | turn(dir,90) | turn(dir, -90)
		turn = DISPOSAL_FLIP_LEFT|DISPOSAL_FLIP_RIGHT
	update()
	return


	// next direction to move
	// if coming in from secondary dirs, then next is primary dir
	// if coming in from primary dir, then next is equal chance of other dirs

/obj/structure/disposalpipe/junction/nextdir(var/fromdir)
	var/flipdir = turn(fromdir, 180)
	if(flipdir != dir)	// came from secondary dir
		return dir		// so exit through primary
	else				// came from primary
						// so need to choose either secondary exit
		var/mask = ..(fromdir)

		// find a bit which is set
		var/setbit = 0
		if(mask & NORTH)
			setbit = NORTH
		else if(mask & SOUTH)
			setbit = SOUTH
		else if(mask & EAST)
			setbit = EAST
		else
			setbit = WEST

		if(prob(50))	// 50% chance to choose the found bit or the other one
			return setbit
		else
			return mask & (~setbit)

/obj/structure/disposalpipe/tagger
	name = "package tagger"
	desc = "A pipe that tags things passing through it with a sorting tag."
	icon_state = "pipe-tagger"
	var/sort_tag = ""
	var/partial = 0
	turn = DISPOSAL_FLIP_FLIP

/obj/structure/disposalpipe/tagger/proc/updatedesc()
	desc = initial(desc)
	if(sort_tag)
		desc += "\nIt's tagging objects with the '[sort_tag]' tag."

/obj/structure/disposalpipe/tagger/proc/updatename()
	if(sort_tag)
		SetName("[initial(name)] ([sort_tag])")
	else
		SetName(initial(name))

/obj/structure/disposalpipe/tagger/Initialize()
	. = ..()
	dpdir = dir | turn(dir, 180)
	if(sort_tag) global.tagger_locations |= sort_tag
	updatename()
	updatedesc()
	update()

/obj/structure/disposalpipe/tagger/attackby(var/obj/item/used_item, var/mob/user)
	if(!istype(used_item, /obj/item/destTagger))
		return ..()
	var/obj/item/destTagger/tagger = used_item
	if(tagger.current_tag)// Tag set
		sort_tag = tagger.current_tag
		playsound(src.loc, 'sound/machines/twobeep.ogg', 100, 1)
		to_chat(user, SPAN_NOTICE("Changed tag to '[sort_tag]'."))
		updatename()
		updatedesc()
	return TRUE

/obj/structure/disposalpipe/tagger/transfer(var/obj/structure/disposalholder/H)
	if(sort_tag)
		if(partial)
			H.setpartialtag(sort_tag)
		else
			H.settag(sort_tag)
	return ..()

/obj/structure/disposalpipe/tagger/partial //needs two passes to tag
	name = "partial package tagger"
	desc = "A pipe that tags things passing through it with a sorting tag... but only the second time around."
	icon_state = "pipe-tagger-partial"
	partial = 1
	turn = DISPOSAL_FLIP_FLIP

/obj/structure/disposalpipe/diversion_junction
	name = "diversion junction"
	icon_state = "pipe-j1s"
	desc = "An underfloor disposal pipe with a flip mechanism."

	var/active = 0
	var/active_dir = 0
	var/inactive_dir = 0
	var/sortdir = 0
	var/id_tag
	var/obj/machinery/disposal_switch/linked
	turn = DISPOSAL_FLIP_FLIP | DISPOSAL_FLIP_RIGHT
	flipped_state = /obj/structure/disposalpipe/diversion_junction/flipped

/obj/structure/disposalpipe/diversion_junction/proc/updatedesc()
	desc = initial(desc)
	if(sort_type)
		desc += "\nIt's currently [active ? "" : "in"]active!"

/obj/structure/disposalpipe/diversion_junction/proc/updatedir()
	inactive_dir = dir
	active_dir = turn(inactive_dir, 180)
	if(icon_state == "pipe-j1s")
		sortdir = turn(inactive_dir, -90)
	else if(icon_state == "pipe-j2s")
		sortdir = turn(inactive_dir, 90)

	dpdir = sortdir | inactive_dir | active_dir

/obj/structure/disposalpipe/diversion_junction/Initialize()
	. = ..()
	global.diversion_junctions += src
	updatedir()
	updatedesc()
	update()

/obj/structure/disposalpipe/diversion_junction/on_build()
	..()
	updatedir()
	updatedesc()

/obj/structure/disposalpipe/diversion_junction/Destroy()
	global.diversion_junctions -= src
	if(linked)
		linked.junctions.Remove(src)
	linked = null
	return ..()

/obj/structure/disposalpipe/diversion_junction/attackby(var/obj/item/used_item, var/mob/user)
	if(!istype(used_item, /obj/item/disposal_switch_construct))
		return ..()
	var/obj/item/disposal_switch_construct/switchcon = used_item
	if(switchcon.id_tag)
		id_tag = switchcon.id_tag
		playsound(src.loc, 'sound/machines/twobeep.ogg', 100, TRUE)
		user.visible_message("<span class='notice'>\The [user] changes \the [src]'s tag.</span>")
	return TRUE


/obj/structure/disposalpipe/diversion_junction/nextdir(var/fromdir, var/sortTag)
	if(fromdir != sortdir)
		if(active)
			return sortdir
		else
			return inactive_dir
	else
		return inactive_dir

/obj/structure/disposalpipe/diversion_junction/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	H.set_dir(nextdir)
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else
		H.forceMove(T)
		return null

	return P

/obj/structure/disposalpipe/diversion_junction/flipped //for easier and cleaner mapping
	icon_state = "pipe-j2s"
	turn = DISPOSAL_FLIP_FLIP | DISPOSAL_FLIP_LEFT
	flipped_state = /obj/structure/disposalpipe/diversion_junction

//a three-way junction that sorts objects
/obj/structure/disposalpipe/sortjunction
	name = "sorting junction"
	icon_state = "pipe-j1s"
	desc = "An underfloor disposal pipe with a package sorting mechanism."

	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0
	turn = DISPOSAL_FLIP_RIGHT|DISPOSAL_FLIP_FLIP
	flipped_state = /obj/structure/disposalpipe/sortjunction/flipped

/obj/structure/disposalpipe/sortjunction/proc/updatedesc()
	desc = initial(desc)
	if(sort_type)
		desc += "\nIt's filtering objects with the '[sort_type]' tag."

/obj/structure/disposalpipe/sortjunction/proc/updatename()
	if(sort_type)
		SetName("[initial(name)] ([sort_type])")
	else
		SetName(initial(name))

/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
	else if(icon_state == "pipe-j2s")
		sortdir = turn(posdir, 90)

	dpdir = sortdir | posdir | negdir

/obj/structure/disposalpipe/sortjunction/Initialize()
	. = ..()
	if(sort_type) global.tagger_locations |= sort_type

	updatedir()
	updatename()
	updatedesc()
	update()

/obj/structure/disposalpipe/sortjunction/on_build()
	..()
	updatedir()
	updatedesc()
	updatename()

/obj/structure/disposalpipe/sortjunction/attackby(var/obj/item/used_item, var/mob/user)
	if(!istype(used_item, /obj/item/destTagger))
		return ..()
	var/obj/item/destTagger/tagger = used_item
	if(tagger.current_tag)// Tag set
		sort_type = tagger.current_tag
		playsound(src.loc, 'sound/machines/twobeep.ogg', 100, TRUE)
		to_chat(user, SPAN_NOTICE("Changed filter to '[sort_type]'."))
		updatename()
		updatedesc()
	return TRUE

/obj/structure/disposalpipe/sortjunction/proc/divert_check(var/checkTag)
	return sort_type == checkTag

	// next direction to move
	// if coming in from negdir, then next is primary dir or sortdir
	// if coming in from posdir, then flip around and go back to posdir
	// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/sortjunction/nextdir(var/fromdir, var/sortTag)
	if(fromdir != sortdir)	// probably came from the negdir
		if(divert_check(sortTag))
			return sortdir
		else
			return posdir
	else				// came from sortdir
						// so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	H.set_dir(nextdir)
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P

//a three-way junction that filters all wrapped and tagged items
/obj/structure/disposalpipe/sortjunction/wildcard
	name = "wildcard sorting junction"
	desc = "An underfloor disposal pipe which filters all wrapped and tagged items."
	flipped_state = /obj/structure/disposalpipe/sortjunction/wildcard/flipped

/obj/structure/disposalpipe/sortjunction/wildcard/divert_check(var/checkTag)
	return checkTag != ""

//junction that filters all untagged items
/obj/structure/disposalpipe/sortjunction/untagged
	name = "untagged sorting junction"
	desc = "An underfloor disposal pipe which filters all untagged items."
	flipped_state = /obj/structure/disposalpipe/sortjunction/untagged/flipped

/obj/structure/disposalpipe/sortjunction/untagged/divert_check(var/checkTag)
	return checkTag == ""

/obj/structure/disposalpipe/sortjunction/flipped //for easier and cleaner mapping
	icon_state = "pipe-j2s"
	turn = DISPOSAL_FLIP_LEFT|DISPOSAL_FLIP_FLIP
	flipped_state = /obj/structure/disposalpipe/sortjunction

/obj/structure/disposalpipe/sortjunction/wildcard/flipped
	icon_state = "pipe-j2s"
	turn = DISPOSAL_FLIP_LEFT|DISPOSAL_FLIP_FLIP
	flipped_state = /obj/structure/disposalpipe/sortjunction/wildcard

/obj/structure/disposalpipe/sortjunction/untagged/flipped
	icon_state = "pipe-j2s"
	turn = DISPOSAL_FLIP_LEFT|DISPOSAL_FLIP_FLIP
	flipped_state = /obj/structure/disposalpipe/sortjunction/untagged

//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	desc = "A section of pneumatic piping made to connect to a bin or outlet."
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/Initialize()
	. = ..()
	dpdir = dir
	spawn(1)
		getlinked()

	update()
	return

/obj/structure/disposalpipe/trunk/proc/getlinked()
	linked = null
	var/obj/machinery/disposal/D = locate() in src.loc
	if(D)
		linked = D
		if (!D.trunk)
			D.trunk = src

	var/obj/structure/disposaloutlet/O = locate() in src.loc
	if(O)
		linked = O

	update()
	return

// Override can_deconstruct so we disallow trunkremoval when something's on top
/obj/structure/disposalpipe/trunk/can_deconstruct()
	. = ..()
	var/turf/T = get_turf(src)
	//Disposal constructors
	for(var/obj/structure/disposalconstruct/C in T)
		if(C.anchored)
			return FALSE
	// Disposal machinery
	for(var/obj/machinery/disposal/disposal in T)
		if(disposal.anchored)
			return FALSE

// would transfer to next pipe segment, but we are in a trunk
// if not entering from disposal bin,
// transfer to linked object (outlet or bin)
/obj/structure/disposalpipe/trunk/transfer(var/obj/structure/disposalholder/H)

	if(H.dir == DOWN)		// we just entered from a disposer
		return ..()		// so do base transfer proc
	// otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/O = linked
		if(istype(O) && (H))
			O.expel(H)	// expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			if(H)
				D.expel(H)	// expel at disposal
	else
		if(H)
			src.expel(H, src.loc, 0)	// expel at turf
	return null

	// nextdir

/obj/structure/disposalpipe/trunk/nextdir(var/fromdir)
	if(fromdir == DOWN)
		return dir
	else
		return 0

// a broken pipe
/obj/structure/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

/obj/structure/disposalpipe/broken/Initialize()
	. = ..()
	update()
	return

	// called when welded
	// for broken pipe, remove and turn into scrap

/obj/structure/disposalpipe/broken/welded()
	qdel(src)