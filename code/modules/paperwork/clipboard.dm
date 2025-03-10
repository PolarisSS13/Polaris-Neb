/obj/item/clipboard
	name                    = "clipboard"
	desc                    = "It's a board with a clip used to organise papers."
	icon                    = 'icons/obj/items/clipboard.dmi'
	icon_state              = "clipboard"
	item_state              = "clipboard"
	w_class                 = ITEM_SIZE_SMALL
	throw_speed             = 3
	throw_range             = 10
	slot_flags              = SLOT_LOWER_BODY
	material_alteration     = MAT_FLAG_ALTERATION_COLOR
	material                = /decl/material/solid/organic/wood/oak
	drop_sound              = 'sound/foley/tooldrop5.ogg'
	pickup_sound            = 'sound/foley/paperpickup2.ogg'

	var/obj/item/stored_pen        //The stored pen.
	var/list/papers
	var/tmp/max_papers = 50

/obj/item/clipboard/Initialize(ml, material_key)
	. = ..()
	update_icon()

/obj/item/clipboard/Destroy()
	QDEL_NULL_LIST(papers)
	stored_pen = null
	return ..()

/obj/item/clipboard/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(stored_pen)
		. += "It's holding \a [stored_pen]."
	if(!LAZYLEN(papers))
		. += "It contains [length(papers)] / [max_papers] paper\s."
	else
		. += "It has room for [max_papers] paper\s."

/obj/item/clipboard/proc/top_paper()
	return LAZYACCESS(papers, 1)

/obj/item/clipboard/proc/push_paper(var/obj/item/P)
	LAZYINSERT(papers, P, 1)
	updateUsrDialog()
	update_icon()

/obj/item/clipboard/proc/pop_paper()
	. = top_paper()
	LAZYREMOVE(papers, 1)
	updateUsrDialog()
	update_icon()

/obj/item/clipboard/on_update_icon()
	..()
	var/obj/item/top_paper = top_paper()
	if(top_paper)
		var/mutable_appearance/I = new /mutable_appearance(top_paper)
		I.appearance_flags |= RESET_COLOR
		I.plane = FLOAT_PLANE
		I.layer = FLOAT_LAYER
		I.pixel_x = 0
		I.pixel_y = 0
		I.pixel_w = 0
		I.pixel_z = 0 //randpixel
		add_overlay(I)
	if(stored_pen)
		add_overlay(overlay_image(icon, "clipboard_pen", stored_pen.color, RESET_COLOR))
	add_overlay(overlay_image(icon, "clipboard_over", flags=RESET_COLOR))

/obj/item/clipboard/attackby(obj/item/used_item, mob/user)
	var/obj/item/top_paper = top_paper()
	if(istype(used_item, /obj/item/paper) || istype(used_item, /obj/item/photo))
		if(!user.try_unequip(used_item, src))
			return TRUE
		push_paper(used_item)
		to_chat(user, SPAN_NOTICE("You clip the [used_item] onto \the [src]."))
		return TRUE

	else if(top_paper?.attackby(used_item, user))
		updateUsrDialog()
		update_icon()
		return TRUE

	else if(IS_PEN(used_item) && add_pen(used_item, user)) //If we don't have any paper, and hit it with a pen, try slotting it in
		return TRUE

	return ..()

/obj/item/clipboard/attack_self(mob/user)
	if(CanPhysicallyInteractWith(user, src))
		interact(user)
		return TRUE

/obj/item/clipboard/interact(mob/user)
	var/dat = "<title>Clipboard</title>"
	if(stored_pen)
		dat += "<A href='byond://?src=\ref[src];pen=1'>Remove Pen</A><BR><HR>"
	else
		dat += "<A href='byond://?src=\ref[src];addpen=1'>Add Pen</A><BR><HR>"

	dat += "<TABLE style='table-layout:fixed; white-space:nowrap;'>"
	for(var/i = 1 to LAZYLEN(papers))
		var/obj/item/P = papers[i]
		dat += "<TR><TD style='width:45%; overflow:hidden; text-overflow:ellipsis;'><A href='byond://?src=\ref[src];examine=\ref[P]'>[P.name]</A></TD>"
		if(i == 1)
			dat += "<TD/><TD><A href='byond://?src=\ref[src];write=\ref[P]'>Write</A></TD>"
		else
			dat += "<TD/><TD/>"
		dat += "<TD><A href='byond://?src=\ref[src];remove=\ref[P]'>Remove</A></TD><TD><A href='byond://?src=\ref[src];rename=\ref[P]'>Rename</A></TD></TR>"
	dat += "</TABLE>"

	user.set_machine(src)
	show_browser(user, dat, "window=[initial(name)]")
	onclose(user, initial(name))
	add_fingerprint(user)
	return

/obj/item/clipboard/proc/add_pen(var/obj/item/I, var/mob/user)
	if(!stored_pen && I.w_class <= ITEM_SIZE_TINY && IS_PEN(I) && user.try_unequip(I, src))
		stored_pen = I
		to_chat(user, SPAN_NOTICE("You slot \the [I] into \the [src]."))
		updateUsrDialog()
		update_icon()
		return TRUE
	else if(stored_pen)
		to_chat(user, SPAN_WARNING("There is already \a [stored_pen] in \the [src]."))
	else if(I.w_class > ITEM_SIZE_TINY)
		to_chat(user, SPAN_WARNING("\The [I] is too big to fit in \the [src]."))

/obj/item/clipboard/proc/remove_pen(var/mob/user)
	if(stored_pen && user.get_empty_hand_slot())
		to_chat(user, SPAN_NOTICE("You pull \the [stored_pen] from your [src]."))
		user.put_in_hands(stored_pen)
		. = stored_pen
		stored_pen = null
		updateUsrDialog()
		update_icon()
		return .
	else if(!stored_pen)
		to_chat(user, SPAN_WARNING("There is no pen in \the [src]."))
	else
		to_chat(user, SPAN_WARNING("Your hands are full."))

/obj/item/clipboard/DefaultTopicState()
	return global.physical_topic_state

/obj/item/clipboard/OnTopic(mob/user, href_list, datum/topic_state/state)
	. = ..()
	var/obj/item/tpaper = top_paper()

	if(href_list["pen"] && remove_pen(user))
		. = TOPIC_REFRESH

	else if(href_list["addpen"] && add_pen(user.get_accessible_pen(), user))
		. = TOPIC_REFRESH

	else if(href_list["write"])
		if(tpaper)
			var/obj/item/I = user.get_accessible_pen()
			//We can also use the stored pen if we have one and a free hand
			if(!I && IS_PEN(stored_pen))
				I = remove_pen(user)
			else if(!I)
				to_chat(user, SPAN_WARNING("You don't have a pen!"))
				return TOPIC_NOACTION

			if(I)
				tpaper.attackby(I, user)
				. = TOPIC_REFRESH
		else
			. = TOPIC_NOACTION

	else if(href_list["remove"])
		var/obj/item/P = locate(href_list["remove"])
		user.put_in_hands(P)
		papers.Remove(P)
		. = TOPIC_REFRESH

	else
		. = handle_paper_stack_shared_topics(user, href_list)

	//Update everything
	if(. & TOPIC_REFRESH)
		updateUsrDialog()
		update_icon()

/obj/item/clipboard/dropped(mob/user)
	. = ..()
	if(CanUseTopic(user, DefaultTopicState()))
		updateUsrDialog()
	else
		close_browser(user, initial(name))

/obj/item/clipboard/get_alt_interactions(mob/user)
	. = ..()
	if(stored_pen)
		LAZYADD(., /decl/interaction_handler/clipboard_remove_pen)

/decl/interaction_handler/clipboard_remove_pen
	name = "Remove Pen"
	expected_target_type = /obj/item/clipboard
	examine_desc = "remove the pen"

/decl/interaction_handler/clipboard_remove_pen/is_possible(atom/target, mob/user, obj/item/prop)
	. = ..()
	if(.)
		var/obj/item/clipboard/clipboard = target
		return !!clipboard.stored_pen

/decl/interaction_handler/clipboard_remove_pen/invoked(atom/target, mob/user, obj/item/prop)
	var/obj/item/clipboard/clipboard = target
	if(clipboard.stored_pen)
		clipboard.remove_pen(user)

// Subtypes below.
/obj/item/clipboard/ebony
	material = /decl/material/solid/organic/wood/ebony

/obj/item/clipboard/steel
	material = /decl/material/solid/metal/steel

/obj/item/clipboard/aluminium
	material = /decl/material/solid/metal/aluminium

/obj/item/clipboard/glass
	material = /decl/material/solid/glass

/obj/item/clipboard/plastic
	material = /decl/material/solid/organic/plastic
