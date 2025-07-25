#define TANK_MAX_RELEASE_PRESSURE (3 ATM)
#define TANK_DEFAULT_RELEASE_PRESSURE ONE_ATMOSPHERE

/obj/machinery/oxygen_pump
	name = "emergency oxygen pump"
	icon = 'icons/obj/walllocker.dmi'
	desc = "A wall mounted oxygen pump with a retractable face mask that you can pull over your face in case of emergencies."
	icon_state = "emerg"

	anchored = TRUE

	var/obj/item/tank/tank
	var/mob/living/breather
	var/obj/item/clothing/mask/breath/contained

	var/spawn_type = /obj/item/tank/emergency/oxygen/engi
	var/mask_type = /obj/item/clothing/mask/breath/emergency
	var/icon_state_open = "emerg_open"
	var/icon_state_closed = "emerg"
	var/icon_state_active // TODO implement

	power_channel = ENVIRON
	idle_power_usage = 10
	active_power_usage = 120 // No idea what the realistic amount would be.
	directional_offset = @'{"NORTH":{"y":-24}, "SOUTH":{"y":28}, "EAST":{"x":24}, "WEST":{"x":-24}}'

/obj/machinery/oxygen_pump/Initialize()
	. = ..()
	tank = new spawn_type (src)
	contained = new mask_type (src)

/obj/machinery/oxygen_pump/Destroy()
	if(breather)
		breather.set_internals(null)
	if(tank)
		qdel(tank)
	if(breather)
		breather.drop_from_inventory(contained)
		src.visible_message(SPAN_NOTICE("The mask rapidly retracts just before \the [src] is destroyed!"))
	breather = null
	qdel(contained)
	contained = null
	return ..()

/obj/machinery/oxygen_pump/handle_mouse_drop(atom/over, mob/user, params)
	if(isliving(over) && can_apply_to_target(over, user))
		user.visible_message(SPAN_NOTICE("\The [user] begins placing the mask onto \the [over].."))
		if(do_mob(user, over, 25) && can_apply_to_target(over, user))
			user.visible_message(SPAN_NOTICE("\The [user] has placed \the [src] over \the [over]'s face."))
			attach_mask(over)
			add_fingerprint(user)
		return TRUE
	. = ..()

/obj/machinery/oxygen_pump/physical_attack_hand(mob/user)
	if((stat & MAINT) && tank)
		user.visible_message(SPAN_NOTICE("\The [user] removes \the [tank] from \the [src]."), SPAN_NOTICE("You remove \the [tank] from \the [src]."))
		user.put_in_hands(tank)
		src.add_fingerprint(user)
		tank.add_fingerprint(user)
		tank = null
		return TRUE
	if(breather)
		detach_mask(user)
		return TRUE
	return FALSE

/obj/machinery/oxygen_pump/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/oxygen_pump/proc/attach_mask(var/mob/living/subject)
	if(istype(subject))
		contained.dropInto(subject.loc)
		subject.equip_to_slot(contained, slot_wear_mask_str)
		if(tank)
			tank.forceMove(subject)
		breather = subject

/obj/machinery/oxygen_pump/proc/set_internals()
	if(isliving(breather))
		if(!breather.get_internals() && tank)
			breather.set_internals(tank)
		update_use_power(POWER_USE_ACTIVE)

/obj/machinery/oxygen_pump/proc/detach_mask(mob/user)
	if(tank)
		tank.forceMove(src)
	breather.drop_from_inventory(contained, src)
	if(user)
		visible_message(SPAN_NOTICE("\The [user] detaches \the [contained] and it rapidly retracts back into \the [src]!"))
	else
		visible_message(SPAN_NOTICE("\The [contained] rapidly retracts back into \the [src]!"))
	breather.refresh_hud_element(HUD_INTERNALS)
	breather = null
	update_use_power(POWER_USE_IDLE)

/obj/machinery/oxygen_pump/proc/can_apply_to_target(var/mob/living/target, mob/user)
	if(!user)
		user = target
	// Check target validity
	if(!GET_EXTERNAL_ORGAN(target, BP_HEAD))
		to_chat(user, SPAN_WARNING("\The [target] doesn't have a head."))
		return
	if(!target.check_has_mouth())
		to_chat(user, SPAN_WARNING("\The [target] doesn't have a mouth."))
		return
	if(!target.get_inventory_slot_datum(slot_wear_mask_str))
		to_chat(user, SPAN_WARNING("\The [target] cannot wear a mask."))
		return
	var/obj/item/mask = target.get_equipped_item(slot_wear_mask_str)
	if(mask && target != breather)
		to_chat(user, SPAN_WARNING("\The [target] is already wearing a mask."))
		return
	var/obj/item/head = target.get_equipped_item(slot_head_str)
	if(head && (head.body_parts_covered & SLOT_FACE))
		to_chat(user, SPAN_WARNING("Remove their [head] first."))
		return
	if(!tank)
		to_chat(user, SPAN_WARNING("There is no tank in \the [src]."))
		return
	if(stat & MAINT)
		to_chat(user, SPAN_WARNING("Please close the maintenance hatch first."))
		return
	if(!Adjacent(target))
		to_chat(user, SPAN_WARNING("Please stay close to \the [src]."))
		return
	//when there is a breather:
	if(breather && target != breather)
		to_chat(user, SPAN_WARNING("The pump is already in use."))
		return
	//Checking if breather is still valid
	mask = target.get_equipped_item(slot_wear_mask_str)
	if(target == breather && (!mask || mask != contained))
		to_chat(user, SPAN_WARNING("\The [target] is not using the supplied mask."))
		return
	return 1

/obj/machinery/oxygen_pump/attackby(obj/item/used_item, mob/user)
	if(IS_SCREWDRIVER(used_item))
		stat ^= MAINT
		user.visible_message(SPAN_NOTICE("\The [user] [stat & MAINT ? "opens" : "closes"] \the [src]."), SPAN_NOTICE("You [stat & MAINT ? "open" : "close"] \the [src]."))
		if(stat & MAINT)
			icon_state = icon_state_open
		if(!stat)
			icon_state = icon_state_closed
		return TRUE
	if(istype(used_item, /obj/item/tank) && (stat & MAINT))
		if(tank)
			to_chat(user, SPAN_WARNING("\The [src] already has a tank installed!"))
			return TRUE
		if(!user.try_unequip(used_item, src))
			return TRUE
		tank = used_item
		user.visible_message(SPAN_NOTICE("\The [user] installs \the [tank] into \the [src]."), SPAN_NOTICE("You install \the [tank] into \the [src]."))
		src.add_fingerprint(user)
		return TRUE
	if(istype(used_item, /obj/item/tank) && !stat)
		to_chat(user, SPAN_WARNING("Please open the maintenance hatch first."))
		return TRUE
	return FALSE // TODO: should this be a parent call? do we want this to be (de)constructable?

/obj/machinery/oxygen_pump/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(tank)
		. += "The meter shows [round(tank.air_contents.return_pressure())]."
	else
		. += SPAN_WARNING("It is missing a tank!")

/obj/machinery/oxygen_pump/Process()
	if(istype(breather))
		if(!can_apply_to_target(breather))
			detach_mask()
		else if(!breather.get_internals() && tank)
			set_internals()

//Create rightclick to view tank settings
/obj/machinery/oxygen_pump/verb/settings()
	set src in oview(1)
	set category = "Object"
	set name = "Show Tank Settings"
	ui_interact(usr)

//GUI Tank Setup
/obj/machinery/oxygen_pump/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	if(!tank)
		to_chat(user, SPAN_WARNING("It is missing a tank!"))
		data["tankPressure"] = 0
		data["releasePressure"] = 0
		data["defaultReleasePressure"] = 0
		data["maxReleasePressure"] = 0
		data["maskConnected"] = 0
		data["tankInstalled"] = 0
	// this is the data which will be sent to the ui
	if(tank)
		data["tankPressure"] = round(tank.air_contents.return_pressure() ? tank.air_contents.return_pressure() : 0)
		data["releasePressure"] = round(tank.distribute_pressure ? tank.distribute_pressure : 0)
		data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
		data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
		data["maskConnected"] = 0
		data["tankInstalled"] = 1

	if(!breather)
		data["maskConnected"] = 0
	if(breather)
		data["maskConnected"] = 1


	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "Oxygen_pump.tmpl", "Tank", 500, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/oxygen_pump/OnTopic(mob/user, href_list, datum/topic_state/state)
	if((. = ..()))
		return

	if (href_list["dist_p"])
		if (href_list["dist_p"] == "reset")
			tank.distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
		else if (href_list["dist_p"] == "max")
			tank.distribute_pressure = TANK_MAX_RELEASE_PRESSURE
		else
			var/cp = text2num(href_list["dist_p"])
			tank.distribute_pressure += cp
		tank.distribute_pressure = min(max(round(tank.distribute_pressure), 0), TANK_MAX_RELEASE_PRESSURE)
		. = TOPIC_REFRESH // Refreshing is handled in machinery/Topic

/obj/machinery/oxygen_pump/mobile
	name = "portable oxygen pump"
	icon = 'icons/obj/machines/medpump.dmi'
	desc = "A portable oxygen pump with a retractable mask that you can pull over your face in case of emergencies."
	icon_state = "medpump"
	icon_state_open = "medpump_open"
	icon_state_closed = "medpump"
	icon_state_active = "medpump_active"
	anchored = FALSE
	density = TRUE

/obj/machinery/oxygen_pump/mobile/stabilizer
	name = "portable patient stabilizer"
	desc = "A portable oxygen pump with a retractable mask used for stabilizing patients in the field."
	icon_state = "patient_stabilizer"
	icon_state_closed = "patient_stabilizer"
	icon_state_open = "patient_stabilizer_open"
	icon_state_active = "patient_stabilizer_active"

/obj/machinery/oxygen_pump/mobile/stabilizer/Process()
	. = ..()
	if(!breather)	// Safety.
		return
	if(breather.isSynthetic())
		return

/* TODO: port modifiers or something similar
	breather.add_modifier(breather.stat == DEAD ? /datum/modifier/bloodpump/corpse : /datum/modifier/bloodpump, 6 SECONDS)
*/

	var/obj/item/organ/internal/lungs/lungs = breather.get_organ(BP_LUNGS, /obj/item/organ/internal/lungs)
	if(!lungs)
		return
	if(lungs.status & ORGAN_DEAD)
		breather.adjustOxyLoss(-(rand(1,8)))
	else
		breather.adjustOxyLoss(-(rand(10,15)))
		if(lungs.is_bruised() && prob(30))
			lungs.heal_damage(1)
		else
			breather.suffocation_counter = max(breather.suffocation_counter - rand(1,5), 0)

/obj/machinery/oxygen_pump/anesthetic
	name = "anesthetic pump"
	desc = "A wall-mounted anesthetic pump with a retractable mask that someone can pull over your face to knock you out."
	spawn_type = /obj/item/tank/anesthetic
	icon_state = "anesthetic_tank"
	icon_state_closed = "anesthetic_tank"
	icon_state_open = "anesthetic_tank_open"
	mask_type = /obj/item/clothing/mask/breath/medical

/obj/machinery/oxygen_pump/mobile/anesthetic
	name = "portable anesthetic pump"
	desc = "A portable anesthetic pump with a retractable mask that someone can pull over your face to knock you out."
	spawn_type = /obj/item/tank/anesthetic
	icon_state = "medpump_n2o"
	icon_state_closed = "medpump_n2o"
	icon_state_open = "medpump_n2o_open"
	icon_state_active = "medpump_n2o_active"
	mask_type = /obj/item/clothing/mask/breath // /obj/item/clothing/mask/breath/anesthetic // TODO implement
