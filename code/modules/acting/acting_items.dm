/obj/machinery/acting/wardrobe
	name = "wardrobe dispenser"
	desc = "A machine that dispenses holo-clothing for those in need."
	icon = 'icons/obj/machines/vending/cartridges.dmi'
	icon_state = ICON_STATE_WORLD
	anchored = TRUE
	density = TRUE
	var/active = 1

/obj/machinery/acting/wardrobe/attack_hand(var/mob/user)
	SHOULD_CALL_PARENT(FALSE)
	user.show_message("You push a button and watch patiently as the machine begins to hum.")
	if(active)
		active = FALSE
		addtimer(CALLBACK(src, PROC_REF(dispense)), 3 SECONDS)
	return TRUE

/obj/machinery/acting/wardrobe/proc/dispense()
	new /obj/item/backpack/chameleon/sydie_kit(src.loc)
	src.visible_message("\The [src] beeps, dispensing a small box onto the floor.", "You hear a beeping sound followed by a thumping noise of some kind.")
	active = TRUE

/obj/machinery/acting/changer
	name = "Quickee's Plastic Surgeon"
	desc = "For when you need to be someone else right now."
	icon = 'icons/obj/machines/fabricators/bioprinter.dmi'
	icon_state = "bioprinter"
	anchored = TRUE
	density = TRUE

/obj/machinery/acting/changer/attack_hand(var/mob/user)
	SHOULD_CALL_PARENT(FALSE)
	if(!ishuman(user))
		return ..()
	var/mob/living/human/H = user
	H.change_appearance(APPEARANCE_ALL, H.loc, H, state = global.z_topic_state)
	var/getName = sanitize(input(H, "Would you like to change your name to something else?", "Name change") as null|text, MAX_NAME_LEN)
	if(getName)
		H.real_name = getName
		H.SetName(getName)
		if(H.mind)
			H.mind.name = H.name
	return TRUE

/obj/machinery/acting/changer/mirror
	name = "Mirror of Many Faces"
	desc = "For when you need to be someone else right now."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror_broke"
	anchored = TRUE
	density = FALSE
