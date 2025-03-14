/obj/structure/stasis_cage
	name = "stasis cage"
	desc = "A high-tech animal cage, designed to keep contained fauna docile and safe."
	icon = 'icons/obj/stasis_cage.dmi'
	icon_state = "stasis_cage"
	density = TRUE
	layer = ABOVE_OBJ_LAYER

	var/mob/living/simple_animal/contained

/obj/structure/stasis_cage/Initialize()
	. = ..()

	var/mob/living/simple_animal/A = locate() in loc
	if(A)
		contain(A)

/obj/structure/stasis_cage/attackby(obj/item/used_item, mob/user)
	if(contained && istype(used_item, /obj/item/scanner/xenobio))
		return contained.attackby(used_item, user)
	. = ..()

/obj/structure/stasis_cage/attack_hand(var/mob/user)
	if(!user.check_dexterity(DEXTERITY_SIMPLE_MACHINES, TRUE))
		return ..()
	try_release(user)
	return TRUE

/obj/structure/stasis_cage/attack_robot(var/mob/user)
	if(CanPhysicallyInteract(user))
		try_release(user)
		return TRUE

/obj/structure/stasis_cage/proc/try_release(mob/user)
	if(!contained)
		to_chat(user, SPAN_NOTICE("There's no animals inside \the [src]"))
		return
	user.visible_message("[user] begins undoing the locks and latches on \the [src].")
	if(do_after(user, 20, src))
		user.visible_message("[user] releases \the [contained] from \the [src]!")
		release()

/obj/structure/stasis_cage/on_update_icon()
	..()
	if(contained)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = initial(icon_state)

/obj/structure/stasis_cage/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(contained)
		. += "\The [contained] is kept inside."

/obj/structure/stasis_cage/proc/contain(var/mob/living/simple_animal/animal)
	if(contained || !istype(animal))
		return

	contained = animal
	animal.forceMove(src)
	animal.in_stasis = 1
	update_icon()

/obj/structure/stasis_cage/proc/release()
	if(!contained)
		return

	contained.dropInto(src)
	contained.in_stasis = 0
	contained = null
	update_icon()

/obj/structure/stasis_cage/Destroy()
	release()
	return ..()

/mob/living/simple_animal/handle_mouse_drop(atom/over, mob/user, params)
	if(istype(over, /obj/structure/stasis_cage))
		var/obj/structure/stasis_cage/cage = over
		if(!stat && !istype(buckled, /obj/effect/energy_net))
			to_chat(user, SPAN_WARNING("It's going to be difficult to convince \the [src] to move into \the [cage] without capturing it in a net."))
			return TRUE
		user.visible_message( \
			SPAN_NOTICE("\The [user] begins stuffing \the [src] into \the [cage]."), \
			SPAN_NOTICE("You begin stuffing \the [src] into \the [cage]."))
		Bumped(user)
		if(do_after(user, 20, cage))
			cage.visible_message( \
				SPAN_NOTICE("\The [user] has stuffed \the [src] into \the [cage]."), \
				SPAN_NOTICE("You have stuffed \the [src] into \the [cage]."))
			cage.contain(src)
		return TRUE
	. = ..()
