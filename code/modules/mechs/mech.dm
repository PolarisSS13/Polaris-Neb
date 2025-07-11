

// Big stompy robots.
/mob/living/exosuit
	name = "exosuit"
	desc = "A powerful machine piloted from a cockpit, but worn like a suit of armour."
	density =  TRUE
	opacity =  TRUE
	anchored = TRUE
	default_pixel_x = -8
	default_pixel_y = 0
	status_flags = PASSEMOTES
	mob_size =     MOB_SIZE_LARGE
	atom_flags = ATOM_FLAG_SHIELD_CONTENTS | ATOM_FLAG_BLOCK_DIAGONAL_FACING
	butchery_data = null

	var/emp_damage = 0

	var/obj/item/radio/exosuit/radio

	var/wreckage_path = /obj/structure/mech_wreckage
	var/mech_turn_sound = 'sound/mecha/mechturn.ogg'
	var/mech_step_sound = 'sound/mecha/mechstep.ogg'

	// Access updating/container.
	var/obj/item/card/id/access_card
	var/list/saved_access = list()
	var/sync_access = 1

	// Mob currently piloting the exosuit.
	var/list/pilots
	var/list/pilot_overlays

	// Visible external components. Not strictly accurately named for non-humanoid machines (submarines) but w/e
	var/obj/item/mech_component/manipulators/arms
	var/obj/item/mech_component/propulsion/legs
	var/obj/item/mech_component/sensors/head
	var/obj/item/mech_component/chassis/body

	// Invisible components.
	var/datum/effect/effect/system/spark_spread/sparks

	// Equipment tracking vars.
	var/obj/item/mech_equipment/selected_system
	var/selected_hardpoint
	var/list/hardpoints = list()
	var/hardpoints_locked
	var/maintenance_protocols

	// Material
	var/decl/material/material

	// Cockpit access vars.
	var/hatch_closed = FALSE
	var/hatch_locked = FALSE

	//Air!
	var/use_air      = FALSE

	// Interface stuff.
	var/list/hud_elements = list()
	var/list/hardpoint_hud_elements = list()
	var/obj/screen/exosuit/health/hud_health
	var/obj/screen/exosuit/toggle/hatch_open/hud_open
	var/obj/screen/exosuit/power/hud_power
	var/obj/screen/exosuit/heat/hud_heat
	var/obj/screen/exosuit/toggle/power_control/hud_power_control
	var/obj/screen/exosuit/toggle/camera/hud_camera
	//POWER
	var/power = MECH_POWER_OFF

	var/mob/living/current_user = null


//Pixel projectiles need a client, so we need a way to pass who the last user was for view calcs
/mob/living/proc/get_effective_gunner()
	return src

/mob/living/exosuit/get_effective_gunner()
	return current_user

/mob/living/exosuit/can_be_buckled(mob/user)
	return FALSE

/mob/living/exosuit/is_flooded(lying_mob, absolute)
	. = (body && body.pilot_coverage >= 100 && hatch_closed) ? FALSE : ..()

/mob/living/exosuit/Initialize(mapload, var/obj/structure/heavy_vehicle_frame/source_frame)
	. = ..()

	if(!access_card) access_card = new (src)

	reset_offsets(0)
	sparks = new(src)

	// Grab all the supplied components.
	if(source_frame)
		if(source_frame.set_name)
			name = source_frame.set_name
		if(source_frame.arms)
			source_frame.arms.forceMove(src)
			arms = source_frame.arms
		if(source_frame.legs)
			source_frame.legs.forceMove(src)
			legs = source_frame.legs
		if(source_frame.head)
			source_frame.head.forceMove(src)
			head = source_frame.head
		if(source_frame.body)
			source_frame.body.forceMove(src)
			body = source_frame.body
		if(source_frame.material)
			material = source_frame.material

	// Generate hardpoint list.
	var/list/component_descriptions
	for(var/obj/item/mech_component/comp in list(arms, legs, head, body))
		if(comp.exosuit_desc_string)
			LAZYADD(component_descriptions, comp.exosuit_desc_string)
		if(LAZYLEN(comp.has_hardpoints))
			for(var/hardpoint in comp.has_hardpoints)
				hardpoints[hardpoint] = null

	if(head && head.radio)
		radio = new(src)

	if(LAZYLEN(component_descriptions))
		desc = "[desc] It has been built with [english_list(component_descriptions)]."

	// Create HUD.
	initialize_hud()

	// Build icon.
	queue_icon_update()

/mob/living/exosuit/Destroy()

	selected_system = null

	for(var/thing in pilots)
		var/mob/pilot = thing
		if(pilot && pilot.client)
			pilot.client.screen -= hud_elements
			pilot.client.images -= hud_elements
		pilot.forceMove(get_turf(src))
	pilots = null

	hud_health = null
	hud_open = null
	hud_power = null
	hud_heat = null
	hud_power_control = null
	hud_camera = null

	for(var/thing in hud_elements)
		qdel(thing)
	hud_elements.Cut()

	for(var/hardpoint in hardpoints)
		var/obj/item/mech_equipment/equipment = hardpoints[hardpoint]
		if(istype(equipment))
			equipment.uninstalled()
		QDEL_NULL(equipment)
	hardpoints.Cut()

	QDEL_NULL(access_card)
	QDEL_NULL(radio)
	QDEL_NULL(arms)
	QDEL_NULL(legs)
	QDEL_NULL(head)
	QDEL_NULL(body)

	for(var/hardpoint in hardpoint_hud_elements)
		var/obj/screen/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
		H.owner_ref = null
		H.holding = null
		qdel(H)
	hardpoint_hud_elements.Cut()

	. = ..()

/mob/living/exosuit/get_other_examine_strings(mob/user, distance, infix, suffix, hideflags, decl/pronouns/pronouns)
	. = ..()
	if(LAZYLEN(pilots) && (!hatch_closed || body.pilot_coverage < 100 || body.transparent_cabin))
		. += "It is being piloted by [english_list(pilots, nothing_text = "nobody")]."
	if(body && LAZYLEN(body.pilot_positions))
		. += "It can seat [body.pilot_positions.len] pilot\s total."
	if(hardpoints.len)
		. += "It has the following hardpoints:"
		for(var/hardpoint in hardpoints)
			var/obj/item/I = hardpoints[hardpoint]
			. += "- [hardpoint]: [istype(I) ? "[I]" : "nothing"]."
	else
		. += "It has no visible hardpoints."
	for(var/obj/item/mech_component/thing in list(arms, legs, head, body))
		if(!thing)
			continue
		. += "Its [thing.name] [thing.gender == PLURAL ? "are" : "is"] [thing.get_damage_string()]."
	. += "It menaces with reinforcements of [material]."

/mob/living/exosuit/return_air()
	return (body && body.pilot_coverage >= 100 && hatch_closed && body.cockpit) ? body.cockpit : loc?.return_air()

/mob/living/exosuit/GetIdCards(list/exceptions)
	. = ..()
	if(istype(access_card) && !is_type_in_list(access_card, exceptions))
		LAZYDISTINCTADD(., access_card)

/mob/living/exosuit/set_dir()
	. = ..()
	if(.)
		update_pilots()

/mob/living/exosuit/increaseBodyTemp(value)
	bodytemperature += value
	return bodytemperature

/mob/living/exosuit/proc/toggle_power(var/mob/user)
	if(power == MECH_POWER_TRANSITION)
		to_chat(user, SPAN_NOTICE("Power transition in progress. Please wait."))
	else if(power == MECH_POWER_ON) //Turning it off is instant
		playsound(src, 'sound/mecha/mech-shutdown.ogg', 100, 0)
		power = MECH_POWER_OFF
	else if(get_cell(TRUE))
		//Start power up sequence
		power = MECH_POWER_TRANSITION
		playsound(src, 'sound/mecha/powerup.ogg', 50, 0)
		if(user.do_skilled(1.5 SECONDS, SKILL_MECH, src, 0.5) && power == MECH_POWER_TRANSITION)
			playsound(src, 'sound/mecha/nominal.ogg', 50, 0)
			power = MECH_POWER_ON
		else
			to_chat(user, SPAN_WARNING("You abort the powerup sequence."))
			power = MECH_POWER_OFF
		hud_power_control?.queue_icon_update()
	else
		to_chat(user, SPAN_WARNING("Error: No power cell was detected."))

// Dump exhaled air into the environment to avoid the tank filling
// up with CO2 and the cockpit filling up with N2. This isn't an
// ideal fix; regulators or something would be a better solution.
/mob/living/exosuit/merge_exhaled_volume(datum/gas_mixture/exhaled)
	return loc?.merge_exhaled_volume(exhaled)

// Override this to avoid triggering the ancient vore code.
/mob/living/exosuit/relaymove(mob/living/user, direction)
	return

/mob/living/exosuit/get_available_postures()
	var/static/list/available_postures = list(
		/decl/posture/standing
	)
	return available_postures

/mob/living/exosuit/try_awaken(mob/user)
	return FALSE

/mob/living/exosuit/handle_stance()
	stance_damage = 0
	return

/mob/living/exosuit/is_valid_merchant_pad_target()
	if(current_user)
		return FALSE
	return ..()

