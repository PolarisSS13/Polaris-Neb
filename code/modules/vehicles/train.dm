/obj/vehicle/train
	name = "train"
	dir = EAST

	move_delay = 1

	current_health = 100
	max_health = 100
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5

	var/passenger_allowed = 1

	var/active_engines = 0
	var/train_length = 0

	var/obj/vehicle/train/lead
	var/obj/vehicle/train/tow

/obj/vehicle/train/user_buckle_mob(mob/living/M, mob/user)
	return load(M)

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/train/Initialize()
	. = ..()
	for(var/obj/vehicle/train/T in orange(1, src))
		if(T.lead || T.is_train_head())
			latch(T)

/obj/vehicle/train/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if (lead)
		. += SPAN_NOTICE("It is hitched to \the [lead].")
	if (tow)
		. += SPAN_NOTICE("It is towing \the [tow].")

/obj/vehicle/train/Move()
	var/old_loc = get_turf(src)
	if(..())
		if(tow)
			tow.Move(old_loc)
		return 1
	else
		if(lead)
			unattach()
		return 0

/obj/vehicle/train/Bump(atom/Obstacle)
	if(!istype(Obstacle, /atom/movable))
		return
	var/atom/movable/A = Obstacle

	if(!A.anchored)
		var/turf/T = get_step(A, dir)
		if(isturf(T))
			A.Move(T)	//bump things away when hit

	if(emagged)
		if(isliving(A))
			var/mob/living/M = A
			visible_message("<span class='warning'>[src] knocks over [M]!</span>")
			var/def_zone = ran_zone()
			M.apply_effects(5, 5)				//knock people down if you hit them
			M.apply_damage(22 / move_delay, BRUTE, def_zone)	// and do damage according to how fast the train is going
			if(ishuman(load))
				var/mob/living/D = load
				to_chat(D, "<span class='warning'>You hit [M]!</span>")
				msg_admin_attack("[D.name] ([D.ckey]) hit [M.name] ([M.ckey]) with [src]. (<A HREF='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")


//-------------------------------------------
// Vehicle procs
//-------------------------------------------
/obj/vehicle/train/explode()
	if (tow)
		tow.unattach()
	unattach()
	..()


//-------------------------------------------
// Interaction procs
//-------------------------------------------
/obj/vehicle/train/relaymove(mob/user, direction)
	if(user.incapacitated())
		return 0

	var/turf/T = get_step_to(src, get_step(src, direction))
	if(!T)
		to_chat(user, "You can't find a clear area to step onto.")
		return 0

	if(user != load)
		if(user in src)		//for handling players stuck in src - this shouldn't happen - but just in case it does
			user.forceMove(T)
			return 1
		return 0

	unload(user, direction)

	to_chat(user, "<span class='notice'>You climb down from [src].</span>")
	return 1

/obj/vehicle/train/handle_mouse_drop(atom/over, mob/user, params)
	if(istype(over, /obj/vehicle/train))
		var/obj/vehicle/train/beep = over
		beep.latch(src, user)
		return TRUE
	. = ..()

/obj/vehicle/train/receive_mouse_drop(atom/dropping, mob/user, params)
	. = ..()
	if(!. && istype(dropping, /atom/movable))
		if(!load(dropping))
			to_chat(user, SPAN_WARNING("You were unable to load \the [dropping] onto \the [src]."))
		return TRUE

/obj/vehicle/train/attack_hand(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	if(!CanPhysicallyInteract(user))
		return FALSE
	if(user != load && (user in src))
		user.forceMove(loc)
	else if(load)
		unload(user)
	else if(!load && !user.buckled)
		load(user)
	return TRUE

/obj/vehicle/train/verb/unlatch_v()
	set name = "Unlatch"
	set desc = "Unhitches this train from the one in front of it."
	set category = "Object"
	set src in view(1)

	if(!ishuman(usr))
		return

	if(!CanPhysicallyInteract(usr))
		return

	unattach(usr)

//-------------------------------------------
// Latching/unlatching procs
//-------------------------------------------

//attempts to attach src as a follower of the train T
//Note: there is a modified version of this in code\modules\vehicles\cargo_train.dm specifically for cargo train engines
/obj/vehicle/train/proc/attach_to(obj/vehicle/train/T, mob/user)
	if (get_dist(src, T) > 1)
		to_chat(user, "<span class='warning'>[src] is too far away from [T] to hitch them together.</span>")
		return

	if (lead)
		to_chat(user, "<span class='warning'>\The [src] is already hitched to something.</span>")
		return

	if (T.tow)
		to_chat(user, "<span class='warning'>\The [T] is already towing something.</span>")
		return

	//check for cycles.
	var/obj/vehicle/train/next_car = T
	while (next_car)
		if (next_car == src)
			to_chat(user, "<span class='warning'>That seems very silly.</span>")
			return
		next_car = next_car.lead

	//latch with src as the follower
	lead = T
	T.tow = src
	set_dir(lead.dir)

	if(user)
		to_chat(user, "<span class='notice'>You hitch \the [src] to \the [T].</span>")

	update_stats()


//detaches the train from whatever is towing it
/obj/vehicle/train/proc/unattach(mob/user)
	if (!lead)
		to_chat(user, "<span class='warning'>\The [src] is not hitched to anything.</span>")
		return

	lead.tow = null
	lead.update_stats()

	to_chat(user, "<span class='notice'>You unhitch \the [src] from \the [lead].</span>")
	lead = null

	update_stats()

/obj/vehicle/train/proc/latch(obj/vehicle/train/T, mob/user)
	if(!istype(T) || !Adjacent(T))
		return 0

	T.attach_to(src, user)

//returns 1 if this is the lead car of the train
/obj/vehicle/train/proc/is_train_head()
	if (lead)
		return 0
	return 1

//-------------------------------------------------------
// Stat update procs
//
// Used for updating the stats for how long the train is.
// These are useful for calculating speed based on the
// size of the train, to limit super long trains.
//-------------------------------------------------------
/obj/vehicle/train/update_stats()
	//first, seek to the end of the train
	var/obj/vehicle/train/T = src
	while(T.tow)
		//check for cyclic train.
		if (T.tow == src)
			lead.tow = null
			lead.update_stats()

			lead = null
			update_stats()
			return
		T = T.tow

	//now walk back to the front.
	var/active_engines = 0
	var/train_length = 0
	while(T)
		train_length++
		if (T.powered && T.on)
			active_engines++
		T.update_car(train_length, active_engines)
		T = T.lead

/obj/vehicle/train/proc/update_car(var/train_length, var/active_engines)
	return
