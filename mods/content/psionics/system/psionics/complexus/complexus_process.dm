/datum/ability_handler/psionics/proc/update(var/force)

	set waitfor = FALSE

	var/last_rating = rating
	var/highest_faculty
	var/highest_rank = 0
	var/combined_rank = 0
	for(var/faculty in ranks)
		var/check_rank = get_rank(faculty)
		if(check_rank == 1)
			LAZYADD(latencies, faculty)
		else
			if(check_rank <= 0)
				ranks -= faculty
			LAZYREMOVE(latencies, faculty)
		combined_rank += check_rank
		if(!highest_faculty || highest_rank < check_rank)
			highest_faculty = faculty
			highest_rank = check_rank

	UNSETEMPTY(latencies)
	var/rank_count = max(1, LAZYLEN(ranks))
	if(force || last_rating != ceil(combined_rank/rank_count))
		if(highest_rank <= 1)
			if(highest_rank == 0)
				qdel(src)
			return
		else
			rebuild_power_cache = TRUE
			sound_to(owner, 'sound/effects/psi/power_unlock.ogg')
			rating = ceil(combined_rank/rank_count)
			cost_modifier = 1
			if(rating > 1)
				cost_modifier -= min(1, max(0.1, (rating-1) / 10))
			if(!ui)
				ui = new(null, owner)
				if(owner.client)
					owner.client.screen += ui.components
					owner.client.screen += ui
			else
				if(owner.client)
					owner.client.screen |= ui.components
					owner.client.screen |= ui
			if(!suppressed && owner.client)
				for(var/thing in SSpsi.all_aura_images)
					owner.client.images |= thing

			var/image/aura_image = get_aura_image()
			if(rating >= PSI_RANK_PARAMOUNT) // spooky boosters
				aura_color = "#aaffaa"
				aura_image.blend_mode = BLEND_SUBTRACT
			else
				aura_image.blend_mode = BLEND_ADD
				if(highest_faculty == PSI_COERCION)
					aura_color = "#cc3333"
				else if(highest_faculty == PSI_PSYCHOKINESIS)
					aura_color = "#3333cc"
				else if(highest_faculty == PSI_REDACTION)
					aura_color = "#33cc33"
				else if(highest_faculty == PSI_ENERGISTICS)
					aura_color = "#cccc33"
			aura_image.pixel_x = -64 - owner.default_pixel_x
			aura_image.pixel_y = -64 - owner.default_pixel_y

	if(!announced && owner && owner.client && !QDELETED(src))
		announced = TRUE
		to_chat(owner, "<hr>")
		to_chat(owner, SPAN_NOTICE("<font size = 3>You are <b>psionic</b>, touched by powers beyond understanding.</font>"))
		to_chat(owner, SPAN_NOTICE("<b>Shift-left-click your Psi icon</b> on the bottom right to <b>view a summary of how to use them</b>, or <b>left click</b> it to <b>suppress or unsuppress</b> your psionics. Beware: overusing your gifts can have <b>deadly consequences</b>."))
		to_chat(owner, "<hr>")

/datum/ability_handler/psionics/Process()

	var/update_hud
	if(armor_cost)
		var/value = max(1, ceil(armor_cost * cost_modifier))
		if(value <= stamina)
			stamina -= value
		else
			backblast(abs(stamina - value))
			stamina = 0
		update_hud = TRUE
		armor_cost = 0

	if(stun)
		stun--
		if(stun)
			if(!suppressed)
				suppressed = TRUE
				update_hud = TRUE
		else
			to_chat(owner, SPAN_NOTICE("You have recovered your mental composure."))
			update_hud = TRUE
	else
		var/psi_leech = owner.do_psionics_check()
		if(psi_leech)
			if(stamina > 10)
				stamina = max(0, stamina - rand(15,20))
				to_chat(owner, SPAN_DANGER("You feel your psi-power leeched away by \the [psi_leech]..."))
			else
				stamina++
		else if(stamina < max_stamina)
			if(owner.stat == CONSCIOUS)
				stamina = min(max_stamina, stamina + rand(1,3))
			else if(owner.stat == UNCONSCIOUS)
				stamina = min(max_stamina, stamina + rand(3,5))

		if(!owner.nervous_system_failure() && owner.stat != DEAD && stamina && !suppressed && get_rank(PSI_REDACTION) >= PSI_RANK_OPERANT)
			attempt_regeneration()

	var/next_aura_size = max(0.1,((stamina/max_stamina)*min(3,rating))/5)
	var/next_aura_alpha = round(((suppressed ? max(0,rating - 2) : rating)/5)*255)

	if(next_aura_alpha != last_aura_alpha || next_aura_size != last_aura_size || aura_color != last_aura_color)
		last_aura_size =  next_aura_size
		last_aura_alpha = next_aura_alpha
		last_aura_color = aura_color
		var/matrix/M = matrix()
		if(next_aura_size != 1)
			M.Scale(next_aura_size)
		animate(get_aura_image(), alpha = next_aura_alpha, transform = M, color = aura_color, time = 3)

	if(update_hud)
		ui.update_icon()

/datum/ability_handler/psionics/proc/attempt_regeneration()

	var/heal_general =  FALSE
	var/heal_poison =   FALSE
	var/heal_internal = FALSE
	var/heal_bleeding = FALSE
	var/heal_rate =     0
	var/mend_prob =     0

	var/use_rank = get_rank(PSI_REDACTION)
	if(use_rank >= PSI_RANK_PARAMOUNT)
		heal_general = TRUE
		heal_poison = TRUE
		heal_internal = TRUE
		heal_bleeding = TRUE
		mend_prob = 50
		heal_rate = 7
	else if(use_rank == PSI_RANK_GRANDMASTER)
		heal_poison = TRUE
		heal_internal = TRUE
		heal_bleeding = TRUE
		mend_prob = 20
		heal_rate = 5
	else if(use_rank == PSI_RANK_MASTER)
		heal_internal = TRUE
		heal_bleeding = TRUE
		mend_prob = 10
		heal_rate = 3
	else if(use_rank == PSI_RANK_OPERANT)
		heal_bleeding = TRUE
		mend_prob = 5
		heal_rate = 1
	else
		return

	if(owner.stat != CONSCIOUS)
		mend_prob = round(mend_prob * 0.65)
		heal_rate = round(heal_rate * 0.65)

	if(!heal_rate || stamina < heal_rate)
		return // Don't backblast from trying to heal ourselves thanks.

	if(ishuman(owner))

		var/mob/living/human/H = owner

		// Fix some pain.
		if(heal_rate > 0)
			H.shock_stage = max(0, H.shock_stage - max(1, round(heal_rate/2)))

		// Mend internal damage.
		if(prob(mend_prob))

			// Fix our heart if we're paramount.
			if(heal_general && H.is_asystole() && H.should_have_organ(BP_HEART) && spend_power(heal_rate))
				H.resuscitate()

			// Heal organ damage.
			if(heal_internal)
				for(var/obj/item/organ/internal/organ in H.get_internal_organs())

					if(BP_IS_PROSTHETIC(organ) || BP_IS_CRYSTAL(organ))
						continue

					// Autoredaction doesn't heal brain damage directly.
					if(organ.organ_tag == BP_BRAIN)
						continue

					var/organ_damage = organ.get_organ_damage()
					if(organ_damage > 0 && spend_power(heal_rate))
						organ.adjust_organ_damage(-(heal_rate))
						if(prob(25))
							to_chat(H, SPAN_NOTICE("Your innards itch as your autoredactive faculty mends your [organ.name]."))
						return

			// Heal broken bones.
			for(var/obj/item/organ/external/E in H.bad_external_organs)

				if(BP_IS_PROSTHETIC(E))
					continue

				if(heal_bleeding)

					if((E.status & ORGAN_ARTERY_CUT) && spend_power(heal_rate))
						to_chat(H, SPAN_NOTICE("Your autoredactive faculty mends the torn artery in your [E.name], stemming the worst of the bleeding."))
						E.status &= ~ORGAN_ARTERY_CUT
						return

					if(E.status & ORGAN_TENDON_CUT)
						to_chat(H, SPAN_NOTICE("Your autoredactive faculty repairs the severed tendon in your [E.name]."))
						E.status &= ~ORGAN_TENDON_CUT
						return TRUE

					for(var/datum/wound/wound in E.wounds)
						if(wound.bleeding() && spend_power(heal_rate))
							to_chat(H, SPAN_NOTICE("Your autoredactive faculty knits together severed veins, stemming the bleeding from \a [wound.desc] on your [E.name]."))
							wound.bleed_timer = 0
							wound.clamped = TRUE
							E.status &= ~ORGAN_BLEEDING
							return

	// Heal radiation, cloneloss and poisoning.
	if(heal_poison)

		if(owner.radiation && spend_power(heal_rate))
			if(prob(25))
				to_chat(owner, SPAN_NOTICE("Your autoredactive faculty repairs some of the radiation damage to your body."))
			owner.radiation = max(0, owner.radiation - heal_rate)
			return

		if(owner.get_damage(CLONE) && spend_power(heal_rate))
			if(prob(25))
				to_chat(owner, SPAN_NOTICE("Your autoredactive faculty stitches together some of your mangled DNA."))
			owner.heal_damage(CLONE, heal_rate)
			return

	// Heal everything left.
	if(heal_general && prob(mend_prob) && (owner.get_damage(BRUTE) || owner.get_damage(BURN) || owner.get_damage(OXY)) && spend_power(heal_rate))
		owner.heal_damage(BRUTE, heal_rate, do_update_health = FALSE)
		owner.heal_damage(BURN, heal_rate, do_update_health = FALSE)
		owner.heal_damage(OXY, heal_rate)
		if(prob(25))
			to_chat(owner, SPAN_NOTICE("Your skin crawls as your autoredactive faculty heals your body."))
