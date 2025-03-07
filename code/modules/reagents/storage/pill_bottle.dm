/*
 * Pill Bottles
 */
/obj/item/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/items/storage/pillbottle.dmi'
	item_state = "contsolid"
	w_class = ITEM_SIZE_SMALL
	storage = /datum/storage/pillbottle
	obj_flags = OBJ_FLAG_HOLLOW
	material = /decl/material/solid/organic/plastic
	var/pop_sound = 'sound/effects/peelz.ogg'
	var/wrapper_color
	/// If a string, a label with this value will be added.
	var/labeled_name = null

/obj/item/pill_bottle/proc/pop_pill(var/mob/user)

	if(!storage)
		return FALSE

	var/target_mouth = (user.get_target_zone() == BP_MOUTH)
	if(target_mouth)
		if(!user.can_eat())
			to_chat(user, SPAN_WARNING("You can't eat anything!"))
			return TRUE
	else
		if(!user.get_empty_hand_slot())
			to_chat(user, SPAN_WARNING("You need an empty hand to take something from \the [src]."))
			return TRUE

	var/list/pills_here = filter_list(contents, /obj/item/chems/pill)
	if(!length(pills_here))
		to_chat(user, SPAN_WARNING("\The [src] is empty!"))
		return TRUE

	var/obj/item/chems/pill/pill = pick(pills_here)
	if(storage.remove_from_storage(user, pill, user))
		if(target_mouth)
			user.visible_message(SPAN_NOTICE("\The [user] pops a pill from \the [src]."))
			pill.use_on_mob(user, user)
		else
			if(user.put_in_inactive_hand(pill))
				to_chat(user, SPAN_NOTICE("You take \the [pill] out of \the [src]."))
			else
				pill.dropInto(loc)
				to_chat(user, SPAN_DANGER("You fumble around with \the [src] and drop \the [pill]."))
	return TRUE

/obj/item/pill_bottle/afterattack(mob/living/target, mob/living/user, proximity_flag)
	. = (proximity_flag && user == target && pop_pill(user)) || ..()

/obj/item/pill_bottle/attack_self(mob/user)
	. = pop_pill(user) || ..()

/obj/item/pill_bottle/Initialize()
	. = ..()
	update_icon()
	if(istext(labeled_name))
		attach_label(null, null, labeled_name)

/obj/item/pill_bottle/on_update_icon()
	. = ..()
	if(wrapper_color)
		add_overlay(overlay_image(icon, "pillbottle_wrap", wrapper_color, RESET_COLOR))

/obj/item/pill_bottle/proc/update_name_label()
	if(!labeled_name)
		name = base_name
		desc = base_desc
		return
	else if(length(labeled_name) > 10)
		var/short_label_name = copytext(labeled_name, 1, 11)
		name = "[base_name] ([short_label_name]...)"
	else
		name = "[base_name] ([labeled_name])"
	desc = "[base_desc] It is labeled \"[labeled_name]\"."

/obj/item/pill_bottle/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/flashlight/pen))
		var/tmp_label = sanitize_safe(input(user, "Enter a label for [name]", "Label", labeled_name), MAX_NAME_LEN)
		if(length(tmp_label) > 50)
			to_chat(user, "<span class='notice'>The label can be at most 50 characters long.</span>")
		else if(length(tmp_label) > 10)
			to_chat(user, "<span class='notice'>You set the label.</span>")
			labeled_name = tmp_label
			update_name_label()
		else
			to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
			labeled_name = tmp_label
			update_name_label()
		return TRUE
	return ..()