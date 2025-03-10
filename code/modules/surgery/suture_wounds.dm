/decl/surgery_step/suture_wounds
	name = "Suture wound"
	description = "This procedure reduces the size of a wound, allowing it to heal or close."
	allowed_tools = list(TOOL_SUTURES = 100)

	min_duration = 70
	max_duration = 100
	can_infect = 1
	shock_level = 1
	surgery_candidate_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_CRYSTAL

/decl/surgery_step/suture_wounds/pre_surgery_step(mob/living/user, mob/living/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = GET_EXTERNAL_ORGAN(target, target_zone)
	if(affected)
		for(var/datum/wound/wound in affected.wounds)
			if(wound.damage_type == CUT && wound.damage >= wound.autoheal_cutoff)
				return TRUE
		to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] has no wounds that are large enough to need suturing."))
	return FALSE

/decl/surgery_step/suture_wounds/begin_step(mob/user, mob/living/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = GET_EXTERNAL_ORGAN(target, target_zone)
	user.visible_message("[user] is beginning to close a wound on [target]'s [affected.name] with \the [tool]." , \
		"You are beginning to close a wound on [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Your [affected.name] is being stabbed!",1)
	..()

/decl/surgery_step/suture_wounds/end_step(mob/living/user, mob/living/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = GET_EXTERNAL_ORGAN(target, target_zone)
	for(var/datum/wound/wound in affected.wounds)
		if(wound.damage_type == CUT && wound.damage >= wound.autoheal_cutoff)
			// Close it up to a point that it can be bandaged and heal naturally!
			wound.heal_damage(rand(10,20)+10)
			if(wound.damage >= wound.autoheal_cutoff)
				user.visible_message(SPAN_NOTICE("\The [user] partially closes a wound on [target]'s [affected.name] with \the [tool]."), \
				SPAN_NOTICE("You partially close a wound on [target]'s [affected.name] with \the [tool]."))
			else
				user.visible_message(SPAN_NOTICE("\The [user] closes a wound on [target]'s [affected.name] with \the [tool]."), \
				SPAN_NOTICE("You close a wound on [target]'s [affected.name] with \the [tool]."))
				if(!wound.damage)
					affected.wounds -= wound
					qdel(wound)
				else if(wound.damage <= 10)
					wound.clamped = 1
			break
	affected.update_damages()
	..()

/decl/surgery_step/suture_wounds/fail_step(mob/living/user, mob/living/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = GET_EXTERNAL_ORGAN(target, target_zone)
	user.visible_message(SPAN_DANGER("[user]'s hand slips, tearing [target]'s [affected.name] with \the [tool]!"), \
		SPAN_DANGER("Your hand slips, tearing [target]'s [affected.name] with \the [tool]!"))
	target.apply_damage(3, BRUTE, affected)
	..()
