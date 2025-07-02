/mob/proc/get_visible_pronouns(hideflags)
	//suits/masks/helmets make it hard to tell their gender
	if((hideflags & HIDEJUMPSUIT) && (hideflags & HIDEFACE))
		return GET_DECL(/decl/pronouns)
	return get_pronouns()

/mob/proc/get_visible_pronouns_for_viewer(mob/viewer, hideflags)
	if(viewer == src)
		return GET_DECL(/decl/pronouns/self)
	return get_visible_pronouns(hideflags)

/mob/proc/get_equipment_visibility()
	. = 0
	for(var/obj/item/thing in get_equipped_items(include_carried = FALSE))
		. |= thing.flags_inv
	return . & EQUIPMENT_VISIBILITY_FLAGS

/mob/proc/get_examined_worn_held_items(mob/user, distance, infix, suffix, hideflags, decl/pronouns/pronouns)
	. = list()
	var/slot_datums = get_inventory_slots()
	if(length(slot_datums))
		for(var/slot in slot_datums)
			var/datum/inventory_slot/inv_slot = slot_datums[slot]
			if(!inv_slot || inv_slot.skip_on_inventory_display)
				continue
			var/slot_desc = inv_slot.get_examined_string(src, user, distance, hideflags, pronouns)
			if(slot_desc)
				. += slot_desc
	if(buckled)
		if(user == src)
			. += SPAN_WARNING("You are [html_icon(buckled)] buckled to [buckled]!")
		else
			. += SPAN_WARNING("[pronouns.He] [pronouns.is] [html_icon(buckled)] buckled to [buckled]!")

/mob/proc/get_other_examine_strings(mob/user, distance, infix, suffix, hideflags, decl/pronouns/pronouns)
	return list()

// We add a default parameter here for hidden inventory flags.
/mob/get_examine_header(mob/user, distance, infix, suffix, hideflags)
	return ..(user, distance, infix, suffix)

/mob/get_examine_strings(mob/user, distance, infix, suffix)

	SHOULD_CALL_PARENT(FALSE)
	. = list()

	// Collect equipment visibility flags.
	var/hideflags = get_equipment_visibility()
	//no accuately spotting headsets from across the room.
	if(distance > 3)
		hideflags |= HIDEEARS

	// Show our equipment, held items, desc, etc.
	var/decl/pronouns/pronouns = get_visible_pronouns_for_viewer(user, hideflags) // handles second-person if src == user
	var/list/examine_items = get_examined_worn_held_items(user, distance, infix, suffix, hideflags, pronouns)
	if(length(examine_items))
		. += examine_items
	var/list/other_items = get_other_examine_strings(user, distance, infix, suffix, hideflags, pronouns)
	if(length(other_items))
		. += other_items
