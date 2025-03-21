/obj/item/clothing/shoes/magboots/vox
	name = "vox magclaws"
	desc = "A pair of heavy, jagged, armoured foot pieces, seemingly suitable for a velociraptor."
	icon = 'mods/species/vox/icons/clothing/boots_vox.dmi'
	action_button_name = "Toggle Magclaws"
	bodytype_equip_flags = BODY_EQUIP_FLAG_VOX

/obj/item/clothing/shoes/magboots/vox/attack_self(mob/user)
	if(magpulse)
		item_flags &= ~ITEM_FLAG_NOSLIP
		magpulse = FALSE
		canremove = TRUE
		to_chat(user, "You relax your deathgrip on the flooring.")
	else
		if(!ishuman(user))
			return
		var/mob/living/human/H = user
		var/obj/item/shoes = H.get_equipped_item(slot_shoes_str)
		if(shoes != src)
			to_chat(user, "You will have to put on \the [src] before you can do that.")
			return
		item_flags |= ITEM_FLAG_NOSLIP
		magpulse = TRUE
		canremove = FALSE
		to_chat(user, "You dig your claws deeply into the flooring, bracing yourself.")
		to_chat(user, "It would be hard to take off \the [src] without relaxing your grip first.")
	update_icon()
	user.update_action_buttons()

//In case they somehow come off while enabled.
/obj/item/clothing/shoes/magboots/vox/dropped(mob/user as mob)
	..()
	if(magpulse)
		user.visible_message( \
			SPAN_NOTICE("\The [src] go limp as they are removed from \the [user]'s feet."), \
			SPAN_NOTICE("\The [src] go limp as they are removed from your feet."))
		item_flags &= ~ITEM_FLAG_NOSLIP
		magpulse = FALSE
		canremove = TRUE
		update_icon()

/obj/item/clothing/shoes/magboots/vox/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if (magpulse)
		. += "It would be hard to take these off without relaxing your grip first."
