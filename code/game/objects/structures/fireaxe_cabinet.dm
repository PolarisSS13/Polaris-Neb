/obj/structure/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	icon = 'icons/obj/structures/fireaxe.dmi'
	icon_state = "fireaxe"
	anchored = TRUE
	density = FALSE
	obj_flags = OBJ_FLAG_MOVES_UNSUPPORTED
	directional_offset = @'{"NORTH":{"y":-32}, "SOUTH":{"y":32}, "EAST":{"x":-32}, "WEST":{"x":32}}'

	var/damage_threshold = 15
	var/open
	var/unlocked
	var/shattered
	var/obj/item/bladed/axe/fire/fireaxe

/obj/structure/fireaxecabinet/on_update_icon()
	..()
	if(fireaxe)
		add_overlay("fireaxe_item")
	if(shattered)
		add_overlay("fireaxe_window_broken")
	else if(!open)
		add_overlay("fireaxe_window")

/obj/structure/fireaxecabinet/Initialize()
	. = ..()
	fireaxe = new(src)
	update_icon()

/obj/structure/fireaxecabinet/attack_ai(var/mob/user)
	toggle_lock(user)

/obj/structure/fireaxecabinet/attack_hand(var/mob/user)
	if(!user.check_dexterity(DEXTERITY_SIMPLE_MACHINES, TRUE))
		return ..()
	if(!unlocked)
		to_chat(user, SPAN_WARNING("\The [src] is locked."))
	else
		toggle_open(user)
	return TRUE

/obj/structure/fireaxecabinet/handle_mouse_drop(atom/over, mob/user, params)
	if(over == user)
		if(!open)
			to_chat(user, SPAN_WARNING("\The [src] is closed."))
			return TRUE
		if(!fireaxe)
			to_chat(user, SPAN_WARNING("\The [src] is empty."))
			return TRUE
		user.put_in_hands(fireaxe)
		fireaxe = null
		update_icon()
		return TRUE
	. = ..()

/obj/structure/fireaxecabinet/Destroy()
	QDEL_NULL(fireaxe)
	. = ..()

/obj/structure/fireaxecabinet/dismantle_structure(mob/user)
	if(loc && !dismantled && !QDELETED(fireaxe))
		fireaxe.dropInto(loc)
		fireaxe = null
	. = ..()

/obj/structure/fireaxecabinet/attackby(var/obj/item/used_item, var/mob/user)

	if(IS_MULTITOOL(used_item))
		toggle_lock(user)
		return TRUE

	if(istype(used_item, /obj/item/bladed/axe/fire))
		if(open)
			if(fireaxe)
				to_chat(user, "<span class='warning'>There is already \a [fireaxe] inside \the [src].</span>")
			else if(user.try_unequip(used_item))
				used_item.forceMove(src)
				fireaxe = used_item
				to_chat(user, "<span class='notice'>You place \the [fireaxe] into \the [src].</span>")
				update_icon()
			return TRUE

	var/force = used_item.expend_attack_force(user)
	if(force)
		user.setClickCooldown(10)
		attack_animation(user)
		playsound(user, 'sound/effects/Glasshit.ogg', 50, 1)
		visible_message("<span class='danger'>[user] [pick(used_item.attack_verb)] \the [src]!</span>")
		if(damage_threshold > force)
			to_chat(user, "<span class='danger'>Your strike is deflected by the reinforced glass!</span>")
			return TRUE
		if(shattered)
			return TRUE
		shattered = 1
		unlocked = 1
		open = 1
		playsound(user, 'sound/effects/Glassbr3.ogg', 100, 1)
		update_icon()
		return TRUE

	return ..()

/obj/structure/fireaxecabinet/proc/toggle_open(var/mob/user)
	if(shattered)
		open = 1
		unlocked = 1
	else
		user.setClickCooldown(10)
		open = !open
		to_chat(user, "<span class='notice'>You [open ? "open" : "close"] \the [src].</span>")
	update_icon()

/obj/structure/fireaxecabinet/proc/toggle_lock(var/mob/user)


	if(open)
		return

	if(shattered)
		open = 1
		unlocked = 1
	else
		user.setClickCooldown(10)
		to_chat(user, "<span class='notice'>You begin [unlocked ? "enabling" : "disabling"] \the [src]'s maglock.</span>")

		if(!do_after(user, 20,src))
			return

		if(shattered) return

		unlocked = !unlocked
		playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
		to_chat(user, "<span class = 'notice'>You [unlocked ? "disable" : "enable"] the maglock.</span>")

	update_icon()
