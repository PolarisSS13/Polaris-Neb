/obj/item/gun/launcher/sealant
	name             = "sealant gun"
	desc             = "A heavy, unwieldy device used to spray metal foam sealant onto hull breaches or damaged flooring."
	icon             = 'icons/obj/guns/sealant_gun.dmi'
	icon_state       = ICON_STATE_WORLD
	autofire_enabled = TRUE
	has_safety       = FALSE
	waterproof       = TRUE
	w_class          = ITEM_SIZE_GARGANTUAN
	obj_flags        = OBJ_FLAG_NO_STORAGE
	slot_flags       = SLOT_BACK
	fire_sound       = 'sound/effects/refill.ogg'
	screen_shake     = FALSE
	release_force    = 5
	fire_delay       = 1

	var/foam_charges_per_shot = 1
	var/obj/item/sealant_tank/loaded_tank

/obj/item/gun/launcher/sealant/on_update_icon()
	update_world_inventory_state()
	. = ..()
	if(loaded_tank)
		add_overlay("[icon_state]-tank")

/obj/item/gun/launcher/sealant/apply_additional_mob_overlays(mob/living/user_mob, bodytype, image/overlay, slot, bodypart, use_fallback_if_icon_missing = TRUE)
	if(overlay && loaded_tank)
		var/tank_state = "[overlay.icon_state]-tank"
		if(check_state_in_icon(tank_state, overlay.icon))
			overlay.overlays += image(overlay.icon, tank_state)
	..()

/obj/item/gun/launcher/sealant/mapped
	loaded_tank = /obj/item/sealant_tank/mapped

/obj/item/gun/launcher/sealant/consume_next_projectile()
	if(loaded_tank?.foam_charges >= foam_charges_per_shot)
		loaded_tank.foam_charges -= foam_charges_per_shot
		. = new /obj/item/sealant(src)

/obj/item/gun/launcher/sealant/Initialize()
	. = ..()
	if(ispath(loaded_tank))
		loaded_tank = new loaded_tank(src)
	update_icon()

/obj/item/gun/launcher/sealant/Destroy()
	QDEL_NULL(loaded_tank)
	. = ..()

/obj/item/gun/launcher/sealant/attack_hand(mob/user)
	if(!(src in user.get_held_items()) || !loaded_tank || !user.check_dexterity(DEXTERITY_HOLD_ITEM, TRUE))
		return ..()
	unload_tank(user)
	return TRUE

/obj/item/gun/launcher/sealant/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(loc == user)
		if(loaded_tank)
			. += SPAN_NOTICE("The loaded tank has about [loaded_tank.foam_charges] liter\s of sealant left.")
		else
			. += SPAN_WARNING("\The [src] has no sealant loaded.")

/obj/item/gun/launcher/sealant/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, /obj/item/sealant_tank) && user.try_unequip(used_item, src))
		loaded_tank = used_item
		to_chat(user, SPAN_NOTICE("You slot \the [loaded_tank] into \the [src]."))
		update_icon()
		return TRUE
	. = ..()

/obj/item/gun/launcher/sealant/attack_self(mob/user)
	if(loaded_tank)
		unload_tank(user)
		return TRUE
	. = ..()

/obj/item/gun/launcher/sealant/proc/unload_tank(var/mob/user)
	if(!loaded_tank)
		to_chat(user, SPAN_WARNING("\The [src] has no tank loaded."))
		return

	loaded_tank.dropInto(get_turf(src))
	user.put_in_hands(loaded_tank)
	to_chat(user, SPAN_NOTICE("You pop \the [loaded_tank] out of \the [src]."))
	loaded_tank = null
	update_icon()
