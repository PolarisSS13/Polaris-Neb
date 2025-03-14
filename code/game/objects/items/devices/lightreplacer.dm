
// Light Replacer (LR)
//
// ABOUT THE DEVICE
//
// This is a device supposedly to be used by Janitors and Janitor Cyborgs which will
// allow them to easily replace lights. This was mostly designed for Janitor Cyborgs since
// they don't have hands or a way to replace lightbulbs.
//
// HOW IT WORKS
//
// You attack a light fixture with it, if the light fixture is broken it will replace the
// light fixture with a working light; the broken light is then placed on the floor for the
// user to then pickup with a trash bag. If it's empty then it will just place a light in the fixture.
//
// HOW TO REFILL THE DEVICE
//
// It can be manually refilled or by clicking on a storage item containing lights.
// If it's part of a robot module, it will charge when the Robot is inside a Recharge Station.
//
// EMAGGED FEATURES
//
// NOTICE: The Cyborg cannot use the emagged Light Replacer and the light's explosion was nerfed. It cannot create holes in the station anymore.
//
// I'm not sure everyone will react the emag's features so please say what your opinions are of it.
//
// When emagged it will rig every light it replaces, which will explode when the light is on.
// This is VERY noticable, even the device's name changes when you emag it so if anyone
// examines you when you're holding it in your hand, you will be discovered.
// It will also be very obvious who is setting all these lights off, since only Janitor Borgs and Janitors have easy
// access to them, and only one of them can emag their device.
//
// The explosion cannot insta-kill anyone with 30% or more health.

#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3


/obj/item/lightreplacer
	name = "light replacer"
	desc = "A lightweight automated device, capable of interfacing with and rapidly replacing standard light installations."
	icon = 'icons/obj/items/light_replacer.dmi'
	icon_state = ICON_STATE_WORLD
	material = /decl/material/solid/metal/steel
	matter = list(
		/decl/material/solid/metal/silver = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/fiberglass = MATTER_AMOUNT_TRACE
	)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_LOWER_BODY
	origin_tech = @'{"magnets":3,"materials":2}'

	var/max_uses = 32
	var/uses = 32
	var/emagged = 0
	var/charge = 0

/obj/item/lightreplacer/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(distance <= 2)
		. += "It has [uses] light\s remaining."

/obj/item/lightreplacer/resolve_attackby(var/atom/A, mob/user)

	//Check for lights in a container, refilling our charges.
	if(A?.storage)
		var/amt_inserted = 0
		var/turf/T = get_turf(user)
		for(var/obj/item/light/L in A.storage.get_contents())
			if(!user.stat && src.uses < src.max_uses && L.status == 0)
				src.AddUses(1)
				amt_inserted++
				A.storage.remove_from_storage(user, L, T, TRUE)
				qdel(L)
		A.storage.finish_bulk_removal()
		if(amt_inserted)
			to_chat(user, "You insert [amt_inserted] light\s into \The [src]. It has [uses] light\s remaining.")
			add_fingerprint(user)
			return

	//Actually replace the light.
	if(istype(A, /obj/machinery/light/))
		var/obj/machinery/light/L = A
		if(isliving(user))
			var/mob/living/U = user
			ReplaceLight(L, U)
			add_fingerprint(user)
			return
	. = ..()

// TODO: Refactor this to check matter or maybe even just use the fabricator recipe for lights directly
/obj/item/lightreplacer/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, /obj/item/stack/material) && used_item.get_material_type() == /decl/material/solid/glass)
		var/obj/item/stack/G = used_item
		if(uses >= max_uses)
			to_chat(user, "<span class='warning'>\The [src] is full.</span>")
		else if(G.use(1))
			AddUses(16) //Autolathe converts 1 sheet into 16 lights. // TODO: Make this use matter instead
			to_chat(user, "<span class='notice'>You insert a piece of glass into \the [src]. You have [uses] light\s remaining.</span>")
		else
			to_chat(user, "<span class='warning'>You need one sheet of glass to replace lights.</span>")
		return TRUE

	if(istype(used_item, /obj/item/light))
		var/obj/item/light/L = used_item
		if(L.status == 0) // LIGHT OKAY
			if(uses < max_uses)
				if(!user.try_unequip(L))
					return TRUE
				AddUses(1)
				to_chat(user, "You insert \the [L] into \the [src]. You have [uses] light\s remaining.")
				qdel(L)
				return TRUE
		else
			to_chat(user, "You need a working light.")
			return TRUE
	return ..()

/obj/item/lightreplacer/attack_self(mob/user)
	to_chat(usr, "It has [uses] lights remaining.")
	return TRUE

/obj/item/lightreplacer/on_update_icon()
	. = ..()
	if(emagged)
		add_overlay("[icon_state]-emagged")

/obj/item/lightreplacer/proc/Use(var/mob/user)

	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	AddUses(-1)
	return 1

// Negative numbers will subtract
/obj/item/lightreplacer/proc/AddUses(var/amount = 1)
	uses = min(max(uses + amount, 0), max_uses)

/obj/item/lightreplacer/proc/Charge(var/mob/user, var/amount = 1)
	charge += amount
	if(charge > 6)
		AddUses(1)
		charge = 0

/obj/item/lightreplacer/proc/ReplaceLight(var/obj/machinery/light/target, var/mob/living/U)

	if(target.get_status() == LIGHT_OK)
		to_chat(U, "There is a working [target.get_fitting_name()] already inserted.")
	else if(!CanUse(U))
		to_chat(U, "\The [src]'s refill light blinks red.")
	else if(Use(U))
		to_chat(U, "<span class='notice'>You replace the [target.get_fitting_name()] with \the [src].</span>")

		if(target.lightbulb)
			target.remove_bulb()

		var/obj/item/light/L = new target.light_type()
		L.rigged = emagged
		target.insert_bulb(L)


/obj/item/lightreplacer/emag_act(var/remaining_charges, var/mob/user)
	emagged = !emagged
	playsound(src.loc, "sparks", 100, 1)
	update_icon()
	return 1

//Can you use it?

/obj/item/lightreplacer/proc/CanUse(var/mob/living/user)
	src.add_fingerprint(user)
	//Not sure what else to check for. Maybe if clumsy?
	if(uses > 0)
		return 1
	else
		return 0

#undef LIGHT_OK
#undef LIGHT_EMPTY
#undef LIGHT_BROKEN
#undef LIGHT_BURNED
