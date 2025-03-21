/obj/item/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	item_flags = ITEM_FLAG_NO_BLUDGEON
	w_class = ITEM_SIZE_SMALL
	origin_tech = @'{"esoteric":2}'
	material = /decl/material/solid/organic/plastic
	matter = list(
		/decl/material/solid/silicon = MATTER_AMOUNT_TRACE
	)
	var/datum/wires/explosive/c4/wires = null
	var/timer = 10
	var/atom/target = null
	var/open_panel = 0
	var/image_overlay = null

/obj/item/plastique/Initialize()
	. = ..()
	wires = new(src)
	image_overlay = image('icons/obj/assemblies.dmi', "plastic-explosive2")

/obj/item/plastique/Destroy()
	qdel(wires)
	wires = null
	return ..()

/obj/item/plastique/attackby(var/obj/item/used_item, var/mob/user)
	if(IS_SCREWDRIVER(used_item))
		open_panel = !open_panel
		to_chat(user, "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>")
		return TRUE
	else if(IS_WIRECUTTER(used_item) || IS_MULTITOOL(used_item) || istype(used_item, /obj/item/assembly/signaler ))
		return wires.Interact(user)
	else
		return ..()

/obj/item/plastique/attack_self(mob/user)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(user.get_active_held_item() == src)
		newtime = clamp(newtime, 10, 60000)
		timer = newtime
		to_chat(user, "Timer set for [timer] seconds.")

/obj/item/plastique/afterattack(atom/movable/target, mob/user, flag)
	if (!flag)
		return
	if (ismob(target) || target.storage || istype(target, /obj/item/clothing/webbing))
		return
	if(isturf(target))
		var/turf/target_turf = target
		if(!target_turf.simulated)
			return

	to_chat(user, "Planting explosives...")
	user.do_attack_animation(target)

	if(do_after(user, 50, target) && in_range(user, target))
		if(!user.try_unequip(src))
			return
		src.target = target
		forceMove(null)

		if (ismob(target))
			admin_attack_log(user, target, "Planted \a [src] with a [timer] second fuse.", "Had \a [src] with a [timer] second fuse planted on them.", "planted \a [src] with a [timer] second fuse on")
			user.visible_message("<span class='danger'>[user.name] finished planting an explosive on [target.name]!</span>")
			log_game("[key_name(user)] planted [src.name] on [key_name(target)] with [timer] second fuse")

		else
			log_and_message_admins("planted \a [src] with a [timer] second fuse on \the [target].")

		target.overlays += image_overlay
		to_chat(user, "Bomb has been planted. Timer counting down from [timer].")
		run_timer()

/obj/item/plastique/proc/explode(var/location)
	if(!target)
		target = get_atom_on_turf(src)
	if(!target)
		target = src
	if(location)
		explosion(location, -1, -1, 2, 3)

	if(target)
		if (istype(target, /turf))
			target.physically_destroyed()
		else if(isliving(target))
			target.explosion_act(2) // c4 can't gib mobs anymore.
		else
			target.explosion_act(1)
	// TODO: vis contents instead of diddling overlays directly.
	if(!QDELETED(target))
		target.overlays -= image_overlay
	qdel(src)

/obj/item/plastique/proc/run_timer() //Basically exists so the C4 will beep when running. Better idea than putting sleeps in attackby.
	set waitfor = 0
	var/T = timer
	while(T > 0)
		sleep(1 SECOND)
		if(target)
			playsound(target, 'sound/items/timer.ogg', 50)
		else
			playsound(loc, 'sound/items/timer.ogg', 50)
		T--
	explode(get_turf(target))

/obj/item/plastique/use_on_mob(mob/living/target, mob/living/user, animate = TRUE)
	return FALSE
