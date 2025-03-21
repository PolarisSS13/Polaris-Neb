/*
CONTAINS:
RSF

*/

/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/items/device/rcd.dmi'
	icon_state = "rcd"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	var/stored_matter = 30
	var/mode = 1
	w_class = ITEM_SIZE_NORMAL
	material = /decl/material/solid/organic/plastic
	matter = list(
		/decl/material/solid/metal/steel  = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/glass        = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/metal/silver = MATTER_AMOUNT_TRACE
	)

/obj/item/rsf/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(distance <= 1)
		. += "It currently holds [stored_matter]/30 fabrication-units."

/obj/item/rsf/attackby(obj/item/used_item, mob/user)
	if (istype(used_item, /obj/item/rcd_ammo))
		if ((stored_matter + 10) > 30)
			to_chat(user, "The RSF can't hold any more matter.")
			return TRUE
		qdel(used_item)
		stored_matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		to_chat(user, "The RSF now holds [stored_matter]/30 fabrication-units.")
		return TRUE
	return ..()

/obj/item/rsf/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if (mode == 1)
		mode = 2
		to_chat(user, "Changed dispensing mode to 'Drinking Glass'.")
		return
	if (mode == 2)
		mode = 3
		to_chat(user, "Changed dispensing mode to 'Paper'.")
		return
	if (mode == 3)
		mode = 4
		to_chat(user, "Changed dispensing mode to 'Pen'.")
		return
	if (mode == 4)
		mode = 5
		to_chat(user, "Changed dispensing mode to 'Dice Pack'.")
		return
	if (mode == 5)
		mode = 1
		to_chat(user, "Changed dispensing mode to 'Cigarette'.")
		return

/obj/item/rsf/afterattack(atom/A, mob/user, proximity)

	if(!proximity) return

	if(isrobot(user))
		var/mob/living/silicon/robot/robot = user
		if(robot.stat || !robot.cell || robot.cell.charge <= 0)
			return
	else
		if(stored_matter <= 0)
			return

	if(!istype(A, /obj/structure/table))
		if(!isturf(A))
			return
		var/turf/turf = A
		if(!turf.is_floor() || !turf.simulated)
			return

	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	var/used_energy = 0
	var/obj/product

	switch(mode)
		if(1)
			product = new /obj/item/clothing/mask/smokable/cigarette()
			used_energy = 10
		if(2)
			product = new /obj/item/chems/drinks/glass2()
			used_energy = 50
		if(3)
			product = new /obj/item/paper()
			used_energy = 10
		if(4)
			product = new /obj/item/pen()
			used_energy = 50
		if(5)
			product = new /obj/item/pill_bottle/dice()
			used_energy = 200

	to_chat(user, "Dispensing [product ? product : "product"]...")
	product.dropInto(A.loc)

	if(isrobot(user))
		var/mob/living/silicon/robot/robot = user
		if(robot.cell)
			robot.cell.use(used_energy)
	else
		stored_matter--
		to_chat(user, "The RSF now holds [stored_matter]/30 fabrication-units.")
