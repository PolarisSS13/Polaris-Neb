/obj/item/implantpad
	name = "implant pad"
	desc = "Used to reprogram implants."
	icon = 'icons/obj/items/implant/implantpad.dmi'
	icon_state = ICON_STATE_WORLD
	w_class = ITEM_SIZE_SMALL
	material = /decl/material/solid/metal/steel
	var/obj/item/implant/imp

/obj/item/implantpad/on_update_icon()
	. = ..()
	if(imp)
		add_overlay("[icon_state]-imp")

/obj/item/implantpad/attack_hand(mob/user)
	if(!imp || (src in user.get_held_items()) || !user.check_dexterity(DEXTERITY_HOLD_ITEM, TRUE))
		return ..()
	user.put_in_active_hand(imp)
	imp.add_fingerprint(user)
	add_fingerprint(user)
	imp = null
	update_icon()
	return TRUE

/obj/item/implantpad/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, /obj/item/implantcase))
		var/obj/item/implantcase/C = used_item
		if(!imp && C.imp)
			C.imp.forceMove(src)
			imp = C.imp
			C.imp = null
		else if (imp && !C.imp)
			imp.forceMove(C)
			C.imp = imp
			imp = null
		C.update_icon()
		. = TRUE
	else if(istype(used_item, /obj/item/implanter))
		var/obj/item/implanter/C = used_item
		if(!imp && C.imp)
			C.imp.forceMove(src)
			imp = C.imp
			C.imp = null
		else if (imp && !C.imp)
			imp.forceMove(C)
			C.imp = imp
			imp = null
		C.update_icon()
		. = TRUE
	else if(istype(used_item, /obj/item/implant) && user.try_unequip(used_item, src))
		imp = used_item
		. = TRUE
	if(.)
		update_icon()
		return TRUE
	return ..()

/obj/item/implantpad/attack_self(mob/user)
	if (imp)
		imp.interact(user)
	else
		to_chat(user,"<span class='warning'>There's no implant loaded in \the [src].</span>")