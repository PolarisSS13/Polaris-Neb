/obj/item/gun/projectile
	name = "gun"
	desc = "A gun that fires bullets."
	icon = 'icons/obj/guns/pistol.dmi'
	origin_tech = @'{"combat":2,"materials":2}'
	w_class = ITEM_SIZE_NORMAL
	material = /decl/material/solid/metal/steel
	screen_shake = 1
	space_recoil = 1
	combustion = 1

	var/caliber = CALIBER_PISTOL		//determines which casings will fit
	var/handle_casings = EJECT_CASINGS	//determines how spent casings should be handled
	var/load_method = SINGLE_CASING|SPEEDLOADER //1 = Single shells, 2 = box or quick loader, 3 = magazine
	var/obj/item/ammo_casing/chambered = null

	//For SINGLE_CASING or SPEEDLOADER guns
	var/max_shells = 0			//the number of casings that will fit inside
	var/ammo_type = null		//the type of ammo that the gun comes preloaded with
	var/list/loaded = list()	//stored ammo
	var/starts_loaded = 1		//whether the gun starts loaded or not, can be overridden for guns crafted in-game
	var/load_sound = 'sound/weapons/guns/interaction/bullet_insert.ogg'

	//For MAGAZINE guns
	var/magazine_type = null	//the type of magazine that the gun comes preloaded with
	var/obj/item/ammo_magazine/ammo_magazine = null //stored magazine
	var/allowed_magazines		//magazine types that may be loaded. Can be a list or single path
	var/auto_eject = 0			//if the magazine should automatically eject itself when empty.
	var/auto_eject_sound = null
	var/mag_insert_sound = 'sound/weapons/guns/interaction/pistol_magin.ogg'
	var/mag_remove_sound = 'sound/weapons/guns/interaction/pistol_magout.ogg'
	var/manual_unload = TRUE //Whether or not the gun can be unloaded by hand.

	var/is_jammed = 0           //Whether this gun is jammed
	var/jam_chance = 0          //Chance it jams on fire
	var/ammo_indicator	   //if true, draw ammo indicator overlays
	//TODO generalize ammo icon states for guns
	//var/magazine_states = 0
	//var/list/icon_keys = list()		//keys
	//var/list/ammo_states = list()	//values

/obj/item/gun/projectile/Initialize()
	. = ..()
	if (starts_loaded)
		if(ispath(ammo_type) && (load_method & (SINGLE_CASING|SPEEDLOADER)))
			for(var/i in 1 to max_shells)
				loaded += new ammo_type(src)
		if(ispath(magazine_type) && (load_method & MAGAZINE))
			ammo_magazine = new magazine_type(src)
	update_icon()

/obj/item/gun/projectile/Destroy()
	chambered = null
	loaded.Cut()
	ammo_magazine = null
	return ..()

/obj/item/gun/projectile/consume_next_projectile()
	if(!is_jammed && prob(jam_chance))
		src.visible_message("<span class='danger'>\The [src] jams!</span>")
		is_jammed = 1
		var/mob/user = loc
		if(istype(user))
			if(prob(user.skill_fail_chance(SKILL_WEAPONS, 100, SKILL_PROF)))
				return null
			else
				to_chat(user, "<span class='notice'>You reflexively clear the jam on \the [src].</span>")
				is_jammed = 0
				playsound(src.loc, 'sound/weapons/flipblade.ogg', 50, 1)
	if(is_jammed)
		return null
	//get the next casing
	if(loaded.len)
		chambered = loaded[1] //load next casing.
		if(handle_casings != HOLD_CASINGS)
			loaded -= chambered
	else if(ammo_magazine)
		if(!ammo_magazine.contents_initialized && ammo_magazine.initial_ammo > 0)
			chambered = new ammo_magazine.ammo_type(src)
			if(handle_casings == HOLD_CASINGS)
				ammo_magazine.stored_ammo += chambered
			ammo_magazine.initial_ammo--
		else if(length(ammo_magazine.stored_ammo))
			chambered = ammo_magazine.stored_ammo[length(ammo_magazine.stored_ammo)]
			if(handle_casings != HOLD_CASINGS)
				ammo_magazine.stored_ammo -= chambered

	if (chambered)
		return chambered.BB
	return null

/obj/item/gun/projectile/handle_post_fire()
	..()
	if(chambered)
		chambered.expend()
		process_chambered()

/obj/item/gun/projectile/process_point_blank(obj/projectile, atom/movable/firer, atom/target)
	..()
	if(chambered && ishuman(target))
		var/mob/living/human/H = target
		var/zone = BP_CHEST
		if(isliving(firer))
			var/mob/living/user = firer
			zone = user.get_target_zone() || zone
		var/obj/item/organ/external/E = GET_EXTERNAL_ORGAN(H, zone)
		if(E)
			chambered.put_residue_on(E)
			H.apply_damage(3, BURN, used_weapon = "Gunpowder Burn", given_organ = E)

/obj/item/gun/projectile/handle_click_empty()
	..()
	process_chambered()

/obj/item/gun/projectile/proc/process_chambered()
	if (!chambered) return

	switch(handle_casings)
		if(EJECT_CASINGS) //eject casing onto ground.
			chambered.dropInto(loc)
			chambered.throw_at(get_ranged_target_turf(get_turf(src),turn(loc.dir,270),1), rand(0,1), 5)
			if(chambered.drop_sound)
				playsound(loc, pick(chambered.drop_sound), 50, 1)
		if(CYCLE_CASINGS) //cycle the casing back to the end.
			if(ammo_magazine)
				ammo_magazine.stored_ammo += chambered
			else
				loaded += chambered

	if(handle_casings != HOLD_CASINGS)
		chambered = null


//Attempts to load A into src, depending on the type of thing being loaded and the load_method
//Maybe this should be broken up into separate procs for each load method?
/obj/item/gun/projectile/proc/load_ammo(var/obj/item/A, mob/user)

	// This gun cannot be manually reloaded.
	if(caliber == CALIBER_UNUSABLE)
		return

	if(istype(A, /obj/item/ammo_magazine))
		. = TRUE
		var/obj/item/ammo_magazine/AM = A
		if(!(load_method & AM.mag_type) || caliber != AM.caliber)
			return //incompatible
		AM.create_initial_contents()

		switch(AM.mag_type)
			if(MAGAZINE)
				if((ispath(allowed_magazines) && !istype(A, allowed_magazines)) || (islist(allowed_magazines) && !is_type_in_list(A, allowed_magazines)))
					to_chat(user, "<span class='warning'>\The [A] won't fit into [src].</span>")
					return
				if(ammo_magazine)
					to_chat(user, "<span class='warning'>[src] already has a magazine loaded.</span>")//already a magazine here

					return
				if(!user.try_unequip(AM, src))
					return
				ammo_magazine = AM
				user.visible_message("[user] inserts [AM] into [src].", "<span class='notice'>You insert [AM] into [src].</span>")
				playsound(loc, mag_insert_sound, 50, 1)
			if(SPEEDLOADER)
				if(loaded.len >= max_shells)
					to_chat(user, "<span class='warning'>[src] is full!</span>")
					return
				var/count = 0
				for(var/obj/item/ammo_casing/C in AM.stored_ammo)
					if(loaded.len >= max_shells)
						break
					if(C.caliber == caliber)
						C.forceMove(src)
						loaded += C
						AM.stored_ammo -= C //should probably go inside an ammo_magazine proc, but I guess less proc calls this way...
						count++
				if(count)
					user.visible_message("[user] reloads [src].", "<span class='notice'>You load [count] round\s into [src].</span>")
					playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
		AM.update_icon()
	else if(istype(A, /obj/item/ammo_casing))
		. = TRUE
		var/obj/item/ammo_casing/C = A
		if(!(load_method & SINGLE_CASING) || caliber != C.caliber)
			return //incompatible
		if(loaded.len >= max_shells)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return
		if(!user.try_unequip(C, src))
			return
		loaded.Insert(1, C) //add to the head of the list
		user.visible_message("[user] inserts \a [C] into [src].", "<span class='notice'>You insert \a [C] into [src].</span>")
		playsound(loc, load_sound, 50, 1)

	update_icon()

//attempts to unload src. If allow_dump is set to 0, the speedloader unloading method will be disabled
/obj/item/gun/projectile/proc/unload_ammo(mob/user, var/allow_dump=1)

	. = FALSE
	if(is_jammed)
		user.visible_message("\The [user] begins to unjam [src].", "You clear the jam and unload [src].")
		if(!do_after(user, 4, src))
			return
		is_jammed = 0
		playsound(src.loc, 'sound/weapons/flipblade.ogg', 50, 1)

	if(ammo_magazine)
		user.put_in_hands(ammo_magazine)
		user.visible_message("[user] removes [ammo_magazine] from [src].", "<span class='notice'>You remove [ammo_magazine] from [src].</span>")
		playsound(loc, mag_remove_sound, 50, 1)
		ammo_magazine.update_icon()
		ammo_magazine = null
		. = TRUE

	else if(length(loaded))
		//presumably, if it can be speed-loaded, it can be speed-unloaded.
		if(allow_dump && (load_method & SPEEDLOADER))
			var/count = 0
			var/turf/T = get_turf(user)
			if(T)
				for(var/obj/item/ammo_casing/C in loaded)
					if(LAZYLEN(C.drop_sound))
						playsound(loc, pick(C.drop_sound), 50, 1)
					C.forceMove(T)
					count++
				loaded.Cut()
			if(count)
				user.visible_message("[user] unloads [src].", "<span class='notice'>You unload [count] round\s from [src].</span>")
				. = TRUE
		else if(load_method & SINGLE_CASING)
			var/obj/item/ammo_casing/C = loaded[loaded.len]
			loaded.len--
			user.put_in_hands(C)
			user.visible_message("[user] removes \a [C] from [src].", "<span class='notice'>You remove \a [C] from [src].</span>")
			. = TRUE
	if(.)
		update_icon()

/obj/item/gun/projectile/proc/try_remove_silencer(mob/user)
	if(!istype(user) || !istype(silencer, /obj/item))
		return FALSE
	if(!user.is_holding_offhand(src))
		return FALSE
	if(!user.check_dexterity(DEXTERITY_COMPLEX_TOOLS, TRUE))
		return FALSE
	to_chat(user, SPAN_NOTICE("You unscrew \the [silencer] from \the [src]."))
	user.put_in_hands(silencer)
	silencer = initial(silencer)
	w_class = initial(w_class)
	update_icon()
	return TRUE

/obj/item/gun/projectile/proc/can_have_silencer()
	return FALSE

/obj/item/gun/projectile/attackby(var/obj/item/used_item, mob/user)

	if(load_ammo(used_item, user))
		return TRUE

	if(istype(used_item, /obj/item/silencer))

		if(istype(silencer, /obj/item))
			to_chat(user, SPAN_WARNING("\The [src] already has \a [silencer] attached."))
			return TRUE

		if(silencer)
			to_chat(user, SPAN_WARNING("\The [src] does not need a silencer; it is already silent."))
			return TRUE

		if(!can_have_silencer())
			to_chat(user, SPAN_WARNING("\The [src] cannot be fitted with a silencer."))
			return TRUE

		if(!(src in user.get_held_items()))	//if we're not in his hands
			to_chat(user, SPAN_WARNING("You'll need \the [src] in your hands to do that."))
			return TRUE

		if(user.try_unequip(used_item, src))
			to_chat(user, SPAN_NOTICE("You screw \the [used_item] onto \the [src]."))
			silencer = used_item
			w_class = ITEM_SIZE_NORMAL
			update_icon()
		return TRUE

	. = ..()

/obj/item/gun/projectile/attack_self(mob/user)
	if(length(firemodes) <= 1)
		if(manual_unload && unload_ammo(user))
			return TRUE
		if(try_remove_silencer(user))
			return TRUE
	return ..()

/obj/item/gun/projectile/attack_hand(mob/user)
	if(src in user.get_inactive_held_items())
		if(manual_unload && unload_ammo(user, allow_dump = FALSE))
			return TRUE
		if(try_remove_silencer(user))
			return TRUE
	return ..()

/obj/item/gun/projectile/afterattack(atom/A, mob/living/user)
	..()
	if(auto_eject && ammo_magazine && !ammo_magazine.get_stored_ammo_count())
		ammo_magazine.dropInto(loc)
		user.visible_message(
			"[ammo_magazine] falls out and clatters on the floor!",
			"<span class='notice'>[ammo_magazine] falls out and clatters on the floor!</span>"
			)
		if(auto_eject_sound)
			playsound(user, auto_eject_sound, 40, 1)
		ammo_magazine.update_icon()
		ammo_magazine = null
		update_icon() //make sure to do this after unsetting ammo_magazine

/obj/item/gun/projectile/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(is_jammed && user.skill_check(SKILL_WEAPONS, SKILL_BASIC))
		. += SPAN_WARNING("It looks jammed.")
	if(ammo_magazine)
		. += "It has \a [ammo_magazine] loaded."
	if(user.skill_check(SKILL_WEAPONS, SKILL_ADEPT))
		. += "Has [getAmmo()] round\s remaining."

/obj/item/gun/projectile/proc/getAmmo()
	var/bullets = 0
	if(loaded)
		bullets += loaded.len
	if(ammo_magazine)
		bullets += ammo_magazine.get_stored_ammo_count()
	if(chambered)
		bullets += 1
	return bullets

/obj/item/gun/projectile/on_update_icon()
	..()
	if(ammo_indicator)
		add_overlay(get_ammo_indicator())

/obj/item/gun/projectile/proc/get_ammo_indicator()
	var/base_state = get_world_inventory_state()
	if(!ammo_magazine || !ammo_magazine.get_stored_ammo_count())
		return mutable_appearance(icon, "[base_state]_ammo_bad")
	else if(LAZYLEN(ammo_magazine.get_stored_ammo_count()) <= 0.5 * ammo_magazine.max_ammo)
		return mutable_appearance(icon, "[base_state]_ammo_warn")
	else
		return mutable_appearance(icon, "[base_state]_ammo_ok")

/obj/item/gun/projectile/get_alt_interactions(mob/user)
	. = ..()
	if(isitem(silencer))
		LAZYADD(., /decl/interaction_handler/projectile/remove_silencer)
	if(ammo_magazine || length(loaded))
		LAZYADD(., /decl/interaction_handler/projectile/unload_ammo)

/decl/interaction_handler/projectile
	abstract_type = /decl/interaction_handler/projectile
	expected_target_type = /obj/item/gun/projectile

/decl/interaction_handler/projectile/remove_silencer
	name = "Remove Silencer"
	examine_desc = "remove the silencer"

/decl/interaction_handler/projectile/remove_silencer/invoked(atom/target, mob/user, obj/item/prop)
	var/obj/item/gun/projectile/gun = target
	gun.try_remove_silencer(user)

/decl/interaction_handler/projectile/unload_ammo
	name = "Remove Ammunition"
	examine_desc = "unload the ammunition"

/decl/interaction_handler/projectile/unload_ammo/invoked(atom/target, mob/user, obj/item/prop)
	var/obj/item/gun/projectile/gun = target
	gun.unload_ammo(user)
