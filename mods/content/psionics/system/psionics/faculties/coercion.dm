/decl/psionic_faculty/coercion
	id = PSI_COERCION
	name = "Coercion"
	associated_intent_flag = I_FLAG_DISARM
	armour_types = list(PSIONIC)

/decl/psionic_power/coercion
	faculty = PSI_COERCION
	abstract_type = /decl/psionic_power/coercion

/decl/psionic_power/coercion/invoke(var/mob/living/user, var/mob/living/target)
	if (!istype(target))
		to_chat(user, SPAN_WARNING("You cannot mentally attack \the [target]."))
		return FALSE

	. = ..()
	if(. && target.deflect_psionic_attack(user))
		return FALSE

/decl/psionic_power/coercion/blindstrike
	name =           "Blindstrike"
	cost =           8
	cooldown =       120
	use_ranged =     TRUE
	use_melee =      TRUE
	min_rank =       PSI_RANK_GRANDMASTER
	use_description = "Target the eyes or mouth on disarm intent and click anywhere to use a radial attack that blinds, deafens and disorients everyone near you."

/decl/psionic_power/coercion/blindstrike/invoke(var/mob/living/user, var/mob/living/target)
	var/user_target_zone = user.get_target_zone()
	if(user_target_zone != BP_MOUTH && user_target_zone != BP_EYES)
		return FALSE
	. = ..()
	if(.)
		var/datum/ability_handler/psionics/psi = user?.get_ability_handler(/datum/ability_handler/psionics)
		user.visible_message(SPAN_DANGER("\The [user] suddenly throws back their head, as though screaming silently!"))
		to_chat(user, SPAN_DANGER("You strike at all around you with a deafening psionic scream!"))
		for(var/mob/living/M in orange(user, psi?.get_rank(PSI_COERCION)))
			if(M == user)
				continue
			var/blocked = 100 * M.get_blocked_ratio(null, PSIONIC)
			if(prob(blocked))
				to_chat(M, SPAN_DANGER("A psionic onslaught strikes your mind, but you withstand it!"))
				continue
			if(prob(60) && M.can_feel_pain())
				to_chat(M, SPAN_DANGER("Your senses are blasted into oblivion by a psionic scream!"))
				M.emote(/decl/emote/audible/scream)
			M.flash_eyes()
			SET_STATUS_MAX(M, STAT_BLIND,   3)
			SET_STATUS_MAX(M, STAT_DEAF,    6)
			SET_STATUS_MAX(M, STAT_CONFUSE, rand(3,8))
		return TRUE

/decl/psionic_power/coercion/mindread
	name =            "Read Mind"
	cost =            6
	cooldown =        80
	use_melee =       TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Target the head on disarm intent at melee range to attempt to read a victim's surface thoughts."

/decl/psionic_power/coercion/mindread/invoke(var/mob/living/user, var/mob/living/target)
	if(!isliving(target) || !istype(target) || user.get_target_zone() != BP_HEAD)
		return FALSE
	. = ..()
	if(!.)
		return

	if(target.stat == DEAD || (target.status_flags & FAKEDEATH) || !target.client)
		to_chat(user, SPAN_WARNING("\The [target] is in no state for a mind-ream."))
		return TRUE

	user.visible_message(SPAN_WARNING("\The [user] touches \the [target]'s temple..."))
	var/question =  input(user, "Say something?", "Read Mind", "Penny for your thoughts?") as null|text
	if(!question || user.incapacitated() || !do_after(user, 20))
		return TRUE

	var/started_mindread = world.time
	to_chat(user, SPAN_NOTICE("<b>You dip your mentality into the surface layer of \the [target]'s mind, seeking an answer: <i>[question]</i></b>"))
	to_chat(target, SPAN_NOTICE("<b>Your mind is compelled to answer: <i>[question]</i></b>"))

	var/answer = sanitize((input(target, question, "Read Mind") as null|message), MAX_MESSAGE_LEN)
	if(!answer || world.time > started_mindread + 60 SECONDS || user.stat != CONSCIOUS || target.stat == DEAD)
		to_chat(user, SPAN_NOTICE("<b>You receive nothing useful from \the [target].</b>"))
	else
		to_chat(user, SPAN_NOTICE("<b>You skim thoughts from the surface of \the [target]'s mind: <i>[answer]</i></b>"))
	msg_admin_attack("[key_name(user)] read mind of [key_name(target)] with question \"[question]\" and [answer?"got answer \"[answer]\".":"got no answer."]")
	return TRUE

/decl/psionic_power/coercion/agony
	name =          "Agony"
	cost =          8
	cooldown =      50
	use_melee =     TRUE
	min_rank =      PSI_RANK_MASTER
	use_description = "Target the chest or groin on disarm intent to use a melee attack equivalent to a strike from a stun baton."

/decl/psionic_power/coercion/agony/invoke(var/mob/living/user, var/mob/living/target)
	if(!istype(target))
		return FALSE
	var/user_zone_sel = user.get_target_zone()
	if(user_zone_sel != BP_CHEST && user_zone_sel != BP_GROIN)
		return FALSE
	. = ..()
	if(.)
		user.visible_message("<span class='danger'>\The [target] has been struck by \the [user]!</span>")
		playsound(user.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		target.stun_effect_act(0, 60, user_zone_sel)
		return TRUE

/decl/psionic_power/coercion/spasm
	name =           "Spasm"
	cost =           15
	cooldown =       100
	use_melee =      TRUE
	use_ranged =     TRUE
	min_rank =       PSI_RANK_MASTER
	use_description = "Target the arms or hands on disarm intent to use a ranged attack that may rip the weapons away from the target."

/decl/psionic_power/coercion/spasm/invoke(var/mob/living/user, var/mob/living/human/target)
	if(!istype(target))
		return FALSE

	if(!(user.get_target_zone() in list(BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND)))
		return FALSE

	. = ..()

	if(.)
		to_chat(user, "<span class='danger'>You lash out, stabbing into \the [target] with a lance of psi-power.</span>")
		to_chat(target, "<span class='danger'>The muscles in your arms cramp horrendously!</span>")
		if(prob(75))
			target.emote(/decl/emote/audible/scream)
		for(var/hand_slot in target.get_held_item_slots())
			var/obj/item/thing = target.get_equipped_item(hand_slot)
			if(thing?.simulated && prob(75) && target.try_unequip(thing))
				var/obj/item/organ/external/E = GET_EXTERNAL_ORGAN(target, hand_slot)
				target.visible_message(SPAN_DANGER("\The [target] drops what they were holding as their [E ? E.name : "hand"] spasms!"))
		return TRUE

/decl/psionic_power/coercion/beguile
	name =          "Beguile"
	cost =          28
	cooldown =      200
	use_grab =      TRUE
	min_rank =      PSI_RANK_PARAMOUNT
	use_description = "Grab a victim, target the eyes, then use the grab on them while on disarm intent, in order to beguile them into serving your cause."

/decl/psionic_power/coercion/beguile/invoke(var/mob/living/user, var/mob/living/target)
	if(!istype(target) || user.get_target_zone() != BP_EYES)
		return FALSE
	. = ..()
	if(.)
		if(target.stat == DEAD || (target.status_flags & FAKEDEATH))
			to_chat(user, SPAN_WARNING("\The [target] is dead!"))
			return TRUE
		if(!target.mind || !target.key)
			to_chat(user, SPAN_WARNING("\The [target] is mindless!"))
			return TRUE
		var/decl/special_role/beguiled/beguiled = GET_DECL(/decl/special_role/beguiled)
		if(beguiled.is_antagonist(target.mind))
			to_chat(user, SPAN_WARNING("\The [target] is already under a glamour!"))
			return TRUE

		user.visible_message("<b>\The [user] seizes the head of \the [target] in both hands...</b>")
		to_chat(user,   SPAN_NOTICE("You insinuate your mentality into that of \the [target]..."))
		to_chat(target, SPAN_DANGER("Your mind is being beguiled by the presence of \the [user]! They are trying to pull you under their glamour!"))

		var/accepted_glamour = alert(target, "Will you become \the [user]'s beguiled servant? Refusal will have harsh consequences.", "Beguilement", "No", "Yes")

		// Redo all our validity checks post-blocking call.
		if(QDELETED(user) || QDELETED(target) || !user.Adjacent(target) || user.incapacitated())
			return TRUE
		if(target.stat == DEAD || (target.status_flags & FAKEDEATH))
			return TRUE
		if(!target.mind || !target.key)
			return TRUE
		if(!target.mind || beguiled.is_antagonist(target.mind))
			return TRUE

		if(accepted_glamour == "Yes")
			to_chat(user,   SPAN_DANGER("You layer a glamour across \the [target]'s senses, beguiling them to unwittingly follow your commands."))
			to_chat(target, SPAN_DANGER("You have been ensnared by \the [user]'s glamour!"))
			beguiled.add_antagonist(target.mind, new_controller = user)
		else
			to_chat(user,   SPAN_WARNING("\The [target] resists your glamour, writhing in your grip. You hurriedly release them before too much damage is done, but the psyche is left tattered. They should have no memory of this encounter, at least."))
			to_chat(target, SPAN_DANGER("You resist \the [user], struggling free of their influence at the cost of your own mind!"))
			to_chat(target, SPAN_DANGER("You fall into darkness, losing all memory of the encounter..."))
			target.take_damage(rand(25,40), BRAIN)
			SET_STATUS_MAX(target, STAT_PARA, 10 SECONDS)

		return TRUE

/decl/psionic_power/coercion/assay
	name =            "Assay"
	cost =            15
	cooldown =        100
	use_grab =        TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Grab a patient, target the head, then use the grab on them while on disarm intent, in order to perform a deep coercive-redactive probe of their psionic potential."

/decl/psionic_power/coercion/assay/invoke(var/mob/living/user, var/mob/living/target)
	if(user.get_target_zone() != BP_HEAD)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(SPAN_WARNING("\The [user] holds the head of \the [target] in both hands..."))
		to_chat(user, SPAN_NOTICE("You insinuate your mentality into that of \the [target]..."))
		to_chat(target, SPAN_WARNING("Your persona is being probed by the psychic lens of \the [user]."))
		if(!do_after(user, (target.stat == CONSCIOUS ? 50 : 25), target, 0, 1))
			var/datum/ability_handler/psionics/psi = user?.get_ability_handler(/datum/ability_handler/psionics)
			psi?.backblast(rand(5,10))
			return TRUE
		to_chat(user, SPAN_NOTICE("You retreat from \the [target], holding your new knowledge close."))
		to_chat(target, SPAN_DANGER("Your mental complexus is laid bare to judgement of \the [user]."))
		target.show_psi_assay(user)
		return TRUE

/decl/psionic_power/coercion/focus
	name =          "Focus"
	cost =          10
	cooldown =      80
	use_grab =     TRUE
	min_rank =      PSI_RANK_OPERANT
	use_description = "Grab a patient, target the mouth, then use the grab on them while on disarm intent, in order to cure ailments of the mind."

/decl/psionic_power/coercion/focus/invoke(var/mob/living/user, var/mob/living/target)
	if(user.get_target_zone() != BP_MOUTH)
		return FALSE
	. = ..()
	if(.)
		var/datum/ability_handler/psionics/psi = user?.get_ability_handler(/datum/ability_handler/psionics)
		user.visible_message(SPAN_WARNING("\The [user] holds the head of \the [target] in both hands..."))
		to_chat(user, SPAN_NOTICE("You probe \the [target]'s mind for various ailments..."))
		to_chat(target, SPAN_WARNING("Your mind is being cleansed of ailments by \the [user]."))
		if(!do_after(user, (target.stat == CONSCIOUS ? 50 : 25), target, 0, 1))
			psi?.backblast(rand(5,10))
			return TRUE
		to_chat(user, SPAN_WARNING("You clear \the [target]'s mind of ailments."))
		to_chat(target, SPAN_WARNING("Your mind is cleared of ailments."))

		var/coercion_rank = psi?.get_rank(PSI_COERCION)
		if(coercion_rank >= PSI_RANK_GRANDMASTER)
			ADJ_STATUS(target, STAT_PARA, -1)
		target.set_status_condition(STAT_DROWSY, 0)
		if(isliving(target))
			var/mob/living/M = target
			M.adjust_hallucination(-30)
		return TRUE