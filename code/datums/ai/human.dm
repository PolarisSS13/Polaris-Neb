/datum/mob_controller/human
	expected_type = /mob/living/human
	do_wander = FALSE

/datum/mob_controller/human/do_process(var/time_elapsed)

	var/mob/living/human/H = body
	if(H.stat != CONSCIOUS)
		return

	if(!(. = ..()))
		return

	if(H.get_shock() && H.shock_stage < 40 && prob(1.5))
		H.emote(pick(/decl/emote/audible/moan, /decl/emote/audible/groan))

	if(H.shock_stage > 10 && prob(1.5))
		H.emote(pick(/decl/emote/audible/cry, /decl/emote/audible/whimper))

	if(H.shock_stage >= 40 && prob(1.5))
		H.emote(/decl/emote/audible/scream)

	if(!H.restrained() && H.current_posture.prone && H.shock_stage >= 60 && prob(1.5))
		H.custom_emote("thrashes in agony")

	if(!H.restrained() && H.shock_stage < 40 && prob(3))
		var/maxdam = 0
		var/obj/item/organ/external/damaged_organ = null
		for(var/obj/item/organ/external/E in H.get_external_organs())
			if(!E.can_feel_pain()) continue
			var/dam = E.get_damage()
			// make the choice of the organ depend on damage,
			// but also sometimes use one of the less damaged ones
			if(dam > maxdam && (maxdam == 0 || prob(50)) )
				damaged_organ = E
				maxdam = dam
		var/decl/pronouns/pronouns = H.get_pronouns()
		if(damaged_organ)
			if(damaged_organ.status & ORGAN_BLEEDING)
				H.custom_emote("clutches [pronouns.his] [damaged_organ.name], trying to stop the blood.")
			else if(damaged_organ.status & ORGAN_BROKEN)
				H.custom_emote("holds [pronouns.his] [damaged_organ.name] carefully.")
			else if(damaged_organ.burn_dam > damaged_organ.brute_dam && damaged_organ.organ_tag != BP_HEAD)
				H.custom_emote("blows on [pronouns.his] [damaged_organ.name] carefully.")
			else
				H.custom_emote("rubs [pronouns.his] [damaged_organ.name] carefully.")

		for(var/obj/item/organ/internal/organ in H.get_internal_organs())
			if((organ.status & ORGAN_DEAD) || BP_IS_PROSTHETIC(organ))
				continue
			if(organ.get_organ_damage() > 2 && prob(1))
				var/obj/item/organ/external/parent = GET_EXTERNAL_ORGAN(H, organ.parent_organ)
				H.custom_emote("clutches [pronouns.his] [parent.name]!")
