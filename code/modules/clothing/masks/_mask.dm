/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/clothing/mask/breath.dmi'
	icon_state = ICON_STATE_WORLD
	slot_flags = SLOT_FACE
	body_parts_covered = SLOT_FACE|SLOT_EYES
	blood_overlay_type = "maskblood"
	material = /decl/material/solid/fiberglass
	matter = list(/decl/material/solid/organic/plastic = MATTER_AMOUNT_REINFORCEMENT)
	origin_tech = @'{"materials":1,"engineering":1}'
	fallback_slot = slot_wear_mask_str

	var/voicechange = 0
	var/list/say_messages
	var/list/say_verbs
	var/down_gas_transfer_coefficient = 0
	var/down_body_parts_covered = 0
	var/down_item_flags = 0
	var/down_flags_inv = 0
	var/pull_mask = 0
	var/hanging = 0
	var/list/filtered_gases

/obj/item/clothing/mask/proc/filters_water()
	return FALSE

/obj/item/clothing/mask/Initialize()
	. = ..()
	if(pull_mask)
		action_button_name = "Adjust Mask"
		verbs += .verb/adjust_mask

/obj/item/clothing/mask/adjust_mob_overlay(mob/living/user_mob, bodytype, image/overlay, slot, bodypart, use_fallback_if_icon_missing = TRUE)
	if(overlay && hanging && slot == slot_wear_mask_str && check_state_in_icon("[overlay.icon_state]-down", overlay.icon))
		overlay.icon_state = "[overlay.icon_state]-down"
	. = ..()

/obj/item/clothing/mask/proc/filter_air(datum/gas_mixture/air)
	return

/obj/item/clothing/mask/verb/adjust_mask()
	set category = "Object"
	set name = "Adjust Mask"
	set src in usr

	if(!ismob(usr))
		return

	var/mob/user = usr
	if(!user.incapacitated(INCAPACITATION_DISABLED))
		if(!pull_mask)
			to_chat(usr, SPAN_NOTICE("You cannot pull down your [src.name]."))
			return
		else
			src.hanging = !src.hanging
			if (src.hanging)
				gas_transfer_coefficient = down_gas_transfer_coefficient
				body_parts_covered = down_body_parts_covered
				item_flags = down_item_flags
				flags_inv = down_flags_inv
				to_chat(usr, "You pull [src] below your chin.")
			else
				gas_transfer_coefficient = initial(gas_transfer_coefficient)
				body_parts_covered = initial(body_parts_covered)
				item_flags = initial(item_flags)
				flags_inv = initial(flags_inv)
				to_chat(usr, "You pull [src] up to cover your face.")
			update_clothing_icon()
			user.update_action_buttons()

/obj/item/clothing/mask/attack_self(mob/user)
	if(pull_mask)
		adjust_mask()