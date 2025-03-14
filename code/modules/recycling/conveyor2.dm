var/global/list/all_conveyors = list()
var/global/list/all_conveyor_switches = list()

//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//note that corner pieces transfer stuff clockwise when running forward, and anti-clockwise backwards.

/obj/machinery/conveyor
	icon = 'icons/obj/machines/conveyor_mapped.dmi'
	icon_state = "conveyor0"
	name = "conveyor belt"
	desc = "A conveyor belt."
	layer = BELOW_OBJ_LAYER	// so they appear under stuff
	anchored = TRUE
	var/operating = 0  // 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1   // true if can operate (no broken segments in this belt run)
	var/forwards       // this is the default (forward) direction, set by the map dir
	var/backwards      // hopefully self-explanatory
	var/movedir        // the actual direction to move stuff in
	var/list/affecting // the list of all items that will be moved this ptick

/obj/machinery/conveyor/centcom_auto
	id_tag = "round_end_belt"

	// create a conveyor
/obj/machinery/conveyor/Initialize(mapload, newdir, on = 0)
	. = ..(mapload)
	icon = 'icons/obj/recycling.dmi'
	global.all_conveyors += src
	if(newdir)
		set_dir(newdir)
	if(dir & (dir-1)) // Diagonal. Forwards is *away* from dir, curving to the right.
		forwards = turn(dir, 135)
		backwards = turn(dir, 45)
	else
		forwards = dir
		backwards = turn(dir, 180)
	if(on)
		operating = 1
		setmove()

/obj/machinery/conveyor/Destroy()
	global.all_conveyors -= src
	. = ..()

/obj/machinery/conveyor/proc/setmove()
	if(operating == 1)
		movedir = forwards
	else if(operating == -1)
		movedir = backwards
	else operating = 0
	update_icon()

/obj/machinery/conveyor/on_update_icon()
	if(stat & BROKEN)
		icon_state = "conveyor-broken"
		operating = 0
		return
	if(!operable)
		operating = 0
	if(stat & NOPOWER)
		operating = 0
	icon_state = "conveyor[operating]"

	// machine process
	// move items to the target location
/obj/machinery/conveyor/Process()
	if(stat & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	use_power_oneoff(100)

	affecting = loc.contents - src		// moved items will be all in loc
	spawn(1)	// slight delay to prevent infinite propagation due to map order	//TODO: please no spawn() in process(). It's a very bad idea
		var/items_moved = 0
		for(var/atom/movable/A in affecting)
			if(!A.anchored)
				if(A.loc == src.loc) // prevents the object from being affected if it's not currently here.
					step(A,movedir)
					items_moved++
			if(items_moved >= 10)
				break

/obj/machinery/conveyor/grab_attack(obj/item/grab/grab, mob/user)
	step(grab.affecting, get_dir(grab.affecting.loc, src))
	return TRUE

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(var/obj/item/used_item, mob/user)
	if(IS_CROWBAR(used_item))
		if(!(stat & BROKEN))
			var/obj/item/conveyor_construct/C = new/obj/item/conveyor_construct(src.loc)
			C.id_tag = id_tag
			transfer_fingerprints_to(C)
		to_chat(user, "<span class='notice'>You remove the conveyor belt.</span>")
		qdel(src)
	else
		user.try_unequip(used_item, get_turf(src))
	return TRUE

// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same id_tag
/obj/machinery/conveyor/set_broken(new_state)
	. = ..()
	if(. && new_state)
		var/obj/machinery/conveyor/C = locate() in get_step(src, dir)
		if(C)
			C.set_operable(dir, id_tag, 0)

		C = locate() in get_step(src, turn(dir,180))
		if(C)
			C.set_operable(turn(dir,180), id_tag, 0)

//set the operable var if id_tag matches, propagating in the given direction

/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)

	if(id_tag != match_id)
		return
	operable = op

	update_icon()
	var/obj/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
		C.set_operable(stepdir, id_tag, op)

// the conveyor control switch

/obj/machinery/conveyor_switch

	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	anchored = TRUE
	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
	var/operated = 1			// true if just operated
	var/list/conveyors		    // the list of converyors that are controlled by this switch

/obj/machinery/conveyor_switch/Initialize(mapload, newid)
	..(mapload)
	global.all_conveyor_switches += src
	if(!id_tag)
		id_tag = newid
	update_icon()
	. = INITIALIZE_HINT_LATELOAD

/obj/machinery/conveyor_switch/LateInitialize()
	. = ..()
	conveyors = list()
	for(var/obj/machinery/conveyor/C in global.all_conveyors)
		if(C.id_tag == id_tag)
			conveyors += C

/obj/machinery/conveyor_switch/Destroy()
	global.all_conveyor_switches -= src
	. = ..()

// update the icon depending on the position

/obj/machinery/conveyor_switch/on_update_icon()
	if(position<0)
		icon_state = "switch-rev"
	else if(position>0)
		icon_state = "switch-fwd"
	else
		icon_state = "switch-off"


// timed process
// if the switch changed, update the linked conveyors

/obj/machinery/conveyor_switch/Process()
	if(!operated)
		return
	operated = 0

	for(var/obj/machinery/conveyor/C in conveyors)
		C.operating = position
		C.setmove()

// attack with hand, switch position
/obj/machinery/conveyor_switch/interface_interact(mob/user)
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE
	do_switch()
	operated = 1
	update_icon()

	// find any switches with same id_tag as this one, and set their positions to match us
	for(var/obj/machinery/conveyor_switch/S in global.all_conveyor_switches)
		if(S.id_tag == src.id_tag)
			S.position = position
			S.update_icon()
	return TRUE

/obj/machinery/conveyor_switch/proc/do_switch(mob/user)
	if(position == 0)
		if(last_pos < 0)
			position = 1
			last_pos = 0
		else
			position = -1
			last_pos = 0
	else
		last_pos = position
		position = 0

/obj/machinery/conveyor_switch/attackby(obj/item/used_item, mob/user, params)
	if(!IS_CROWBAR(used_item))
		return ..()
	var/obj/item/conveyor_switch_construct/C = new/obj/item/conveyor_switch_construct(src.loc)
	C.id_tag = id_tag
	transfer_fingerprints_to(C)
	to_chat(user, "<span class='notice'>You detach the conveyor switch.</span>")
	qdel(src)
	return TRUE

/obj/machinery/conveyor_switch/oneway
	var/convdir = 1 //Set to 1 or -1 depending on which way you want the convayor to go. (In other words keep at 1 and set the proper dir on the belts.)
	desc = "A conveyor control switch. It appears to only go in one direction."

/obj/machinery/conveyor_switch/oneway/do_switch(mob/user)
	if(position == 0)
		position = convdir
	else
		position = 0

//
// CONVEYOR CONSTRUCTION STARTS HERE
//

/obj/item/conveyor_construct
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor0"
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly. Must be linked to a conveyor control switch assembly before placement."
	w_class = ITEM_SIZE_HUGE
	material = /decl/material/solid/metal/steel
	matter = list(/decl/material/solid/organic/plastic = MATTER_AMOUNT_REINFORCEMENT)
	var/id_tag

/obj/item/conveyor_construct/attackby(obj/item/used_item, mob/user, params)
	if(!istype(used_item, /obj/item/conveyor_switch_construct))
		return ..()
	to_chat(user, "<span class='notice'>You link the switch to the conveyor belt assembly.</span>")
	var/obj/item/conveyor_switch_construct/C = used_item
	id_tag = C.id_tag
	return TRUE

/obj/item/conveyor_construct/afterattack(atom/A, mob/user, proximity)
	if(!proximity || !istype(A, /turf/floor) || user.incapacitated())
		return
	var/area/area = get_area(A)
	if(!istype(area) || (area.area_flags & AREA_FLAG_SHUTTLE))
		return FALSE
	var/cdir = get_dir(A, user)
	if(!(cdir in global.cardinal) || A == user.loc)
		return
	for(var/obj/machinery/conveyor/CB in A)
		if(CB.dir == cdir || CB.dir == turn(cdir,180))
			return
		cdir |= CB.dir
		qdel(CB)
	var/obj/machinery/conveyor/C = new/obj/machinery/conveyor(A,cdir)
	C.id_tag = id_tag
	transfer_fingerprints_to(C)
	qdel(src)

/obj/item/conveyor_switch_construct
	name = "two-way conveyor switch assembly"
	desc = "A conveyor control switch assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	w_class = ITEM_SIZE_HUGE
	material = /decl/material/solid/metal/steel
	var/id_tag

/obj/item/conveyor_switch_construct/Initialize()
	. = ..()
	id_tag = sequential_id("conveyor_switch_construct")

/obj/item/conveyor_switch_construct/afterattack(atom/A, mob/user, proximity)
	if(!proximity || !istype(A, /turf/floor) || user.incapacitated())
		return
	var/area/area = get_area(A)
	if(!istype(area) || (area.area_flags & AREA_FLAG_SHUTTLE))
		return FALSE
	var/found = 0
	for(var/obj/machinery/conveyor/C in view())
		if(C.id_tag == src.id_tag)
			found = 1
			break
	if(!found)
		to_chat(user, "[html_icon(src)]<span class=notice>The conveyor switch did not detect any linked conveyor belts in range.</span>")
		return
	var/obj/machinery/conveyor_switch/NC = new /obj/machinery/conveyor_switch(A, id_tag)
	transfer_fingerprints_to(NC)
	qdel(src)

/obj/item/conveyor_switch_construct/oneway
	name = "one-way conveyor switch assembly"
	desc = "A one-way conveyor control switch assembly."

/obj/item/conveyor_switch_construct/oneway/afterattack(atom/A, mob/user, proximity)
	if(!proximity || !istype(A, /turf/floor) || user.incapacitated())
		return
	var/area/area = get_area(A)
	if(!istype(area) || (area.area_flags & AREA_FLAG_SHUTTLE))
		return FALSE
	var/found = 0
	for(var/obj/machinery/conveyor/C in view())
		if(C.id_tag == src.id_tag)
			found = 1
			break
	if(!found)
		to_chat(user, "[html_icon(src)]<span class=notice>The conveyor switch did not detect any linked conveyor belts in range.</span>")
		return
	var/obj/machinery/conveyor_switch/oneway/NC = new /obj/machinery/conveyor_switch/oneway(A, id_tag)
	transfer_fingerprints_to(NC)
	qdel(src)