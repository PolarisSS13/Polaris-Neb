/obj/item/organ/internal/heart
	name = "heart"
	organ_tag = "heart"
	parent_organ = BP_CHEST
	icon_state = "heart-on"
	dead_icon = "heart-off"
	prosthetic_icon = "heart-prosthetic"
	damage_reduction = 0.7
	relative_size = 5
	max_damage = 45
	var/pulse = PULSE_NORM
	var/heartbeat = 0
	var/beat_sound = 'sound/effects/singlebeat.ogg'
	var/tmp/next_blood_squirt = 0
	var/open
	var/list/external_pump

/obj/item/organ/internal/heart/on_holder_death(var/gibbed)
	pulse = PULSE_NONE
	update_icon()

/obj/item/organ/internal/heart/open
	open = 1

/obj/item/organ/internal/heart/Process()
	if(owner)
		handle_pulse()
		if(pulse)
			handle_heartbeat()
			if(pulse == PULSE_2FAST && prob(1))
				take_damage(0.5)
			if(pulse == PULSE_THREADY && prob(5))
				take_damage(0.5)
		handle_blood()
	..()

/obj/item/organ/internal/heart/proc/handle_pulse()
	if(BP_IS_PROSTHETIC(src) || !owner || owner.vital_organ_missing_time)
		pulse = PULSE_NONE	//that's it, you're dead (or your metal heart is), nothing can influence your pulse
		return

	// pulse mod starts out as just the chemical effect amount
	var/pulse_mod = GET_CHEMICAL_EFFECT(owner, CE_PULSE)
	var/is_stable = GET_CHEMICAL_EFFECT(owner, CE_STABLE)

	// If you have enough heart chemicals to be over 2, you're likely to take extra damage.
	if(pulse_mod > 2 && !is_stable)
		var/damage_chance = (pulse_mod - 2) ** 2
		if(prob(damage_chance))
			take_damage(0.5)

	// Now pulse mod is impacted by shock stage and other things too
	if(owner.shock_stage > 30)
		pulse_mod++
	if(owner.shock_stage > 80)
		pulse_mod++

	var/oxy = owner.get_blood_oxygenation()
	if(oxy < BLOOD_VOLUME_OKAY) //brain wants us to get MOAR OXY
		pulse_mod++
	if(oxy < BLOOD_VOLUME_BAD) //MOAR
		pulse_mod++

	if(owner.status_flags & FAKEDEATH || GET_CHEMICAL_EFFECT(owner, CE_NOPULSE))
		pulse = clamp(PULSE_NONE + pulse_mod, PULSE_NONE, PULSE_2FAST) //pretend that we're dead. unlike actual death, can be inflienced by meds
		return

	//If heart is stopped, it isn't going to restart itself randomly.
	if(pulse == PULSE_NONE)
		return

	//and if it's beating, let's see if it should
	var/should_stop = prob(80) && oxy < BLOOD_VOLUME_SURVIVE //cardiovascular shock, not enough liquid to pump
	should_stop = should_stop || prob(max(0, owner.get_damage(BRAIN) - owner.get_max_health() * 0.75)) //brain failing to work heart properly
	should_stop = should_stop || (prob(5) && pulse == PULSE_THREADY) //erratic heart patterns, usually caused by oxyloss
	if(should_stop) // The heart has stopped due to going into traumatic or cardiovascular shock.
		to_chat(owner, SPAN_DANGER("Your heart has stopped!"))
		pulse = PULSE_NONE
		return

	// Pulse normally shouldn't go above PULSE_2FAST
	pulse = clamp(PULSE_NORM + pulse_mod, PULSE_SLOW, PULSE_2FAST)

	// If fibrillation, then it can be PULSE_THREADY
	var/fibrillation = oxy <= BLOOD_VOLUME_SURVIVE || (prob(30) && owner.shock_stage > 120)
	if(pulse && fibrillation)	//I SAID MOAR OXYGEN
		pulse = PULSE_THREADY

	// Stablising chemicals pull the heartbeat towards the center
	if(pulse != PULSE_NORM && is_stable)
		if(pulse > PULSE_NORM)
			pulse--
		else
			pulse++

/obj/item/organ/internal/heart/proc/handle_heartbeat()
	if(pulse >= PULSE_2FAST || owner.shock_stage >= 10 || is_below_sound_pressure(get_turf(owner)))
		//PULSE_THREADY - maximum value for pulse, currently it 5.
		//High pulse value corresponds to a fast rate of heartbeat.
		//Divided by 2, otherwise it is too slow.
		var/rate = (PULSE_THREADY - pulse)/2
		if(owner.has_chemical_effect(CE_PULSE, 2))
			heartbeat++

		if(heartbeat >= rate)
			heartbeat = 0
			sound_to(owner, sound(beat_sound,0,0,0,50))
		else
			heartbeat++

/obj/item/organ/internal/heart/proc/handle_blood()

	if(!owner)
		return

	//Dead or cryosleep people do not pump the blood.
	if(!owner || owner.has_mob_modifier(/decl/mob_modifier/stasis) || owner.stat == DEAD || owner.bodytemperature < 170)
		return

	if(pulse != PULSE_NONE || BP_IS_PROSTHETIC(src))
		//Bleeding out
		var/blood_max = 0
		var/list/do_spray = list()
		for(var/obj/item/organ/external/temp in owner.get_external_organs())

			if(BP_IS_PROSTHETIC(temp))
				continue

			var/open_wound
			if(temp.status & ORGAN_BLEEDING)

				for(var/datum/wound/wound in temp.wounds)

					if(!open_wound && (wound.damage_type == CUT || wound.damage_type == PIERCE) && wound.damage && !wound.is_treated())
						open_wound = TRUE

					if(wound.bleeding())
						if(temp.applied_pressure)
							if(ishuman(temp.applied_pressure))
								var/mob/living/human/H = temp.applied_pressure
								H.bloody_hands(src, 0)
							//somehow you can apply pressure to every wound on the organ at the same time
							//you're basically forced to do nothing at all, so let's make it pretty effective
							var/min_eff_damage = max(0, wound.damage - 10) / 6 //still want a little bit to drip out, for effect
							blood_max += max(min_eff_damage, wound.damage - 30) / 40
						else
							blood_max += wound.damage / 40

			if(temp.status & ORGAN_ARTERY_CUT)
				var/bleed_amount = floor((owner.vessel.total_volume / (temp.applied_pressure || !open_wound ? 400 : 250))*temp.arterial_bleed_severity)
				if(bleed_amount)
					if(open_wound)
						blood_max += bleed_amount
						do_spray += "[temp.name]"
					else
						owner.vessel.remove_any(bleed_amount)

		switch(pulse)
			if(PULSE_SLOW)
				blood_max *= 0.8
			if(PULSE_FAST)
				blood_max *= 1.25
			if(PULSE_2FAST, PULSE_THREADY)
				blood_max *= 1.5

		if(GET_CHEMICAL_EFFECT(owner, CE_STABLE))
			blood_max *= 0.8

		if(world.time >= next_blood_squirt && isturf(owner.loc) && do_spray.len)
			var/spray_organ = pick(do_spray)
			owner.visible_message(
				SPAN_DANGER("Blood sprays out from \the [owner]'s [spray_organ]!"),
				FONT_HUGE(SPAN_DANGER("Blood sprays out from your [spray_organ]!"))
			)
			SET_STATUS_MAX(owner, STAT_STUN, 1)
			owner.set_status_condition(STAT_BLURRY, 2)

			//AB occurs every heartbeat, this only throttles the visible effect
			next_blood_squirt = world.time + 80
			var/turf/sprayloc = get_turf(owner)
			blood_max -= owner.drip(ceil(blood_max/3), sprayloc)
			if(blood_max > 0)
				blood_max -= owner.blood_squirt(blood_max, sprayloc)
				if(blood_max > 0)
					owner.drip(blood_max, get_turf(owner))
		else
			owner.drip(blood_max)

/obj/item/organ/internal/heart/proc/is_working()
	return is_usable() && (pulse > PULSE_NONE || BP_IS_PROSTHETIC(src) || (owner.status_flags & FAKEDEATH))

/obj/item/organ/internal/heart/listen()

	if(!owner || (status & (ORGAN_DEAD|ORGAN_CUT_AWAY)))
		return "no pulse"

	if(BP_IS_PROSTHETIC(src) && is_working())
		if(is_bruised())
			return "sputtering pump"
		else
			return "steady whirr of the pump"

	if(!pulse || (owner.status_flags & FAKEDEATH))
		return "no pulse"

	var/pulsesound = "normal"
	if(is_bruised())
		pulsesound = "irregular"

	switch(pulse)
		if(PULSE_SLOW)
			pulsesound = "slow"
		if(PULSE_FAST)
			pulsesound = "fast"
		if(PULSE_2FAST)
			pulsesound = "very fast"
		if(PULSE_THREADY)
			pulsesound = "extremely fast and faint"

	. = "[pulsesound] pulse"

/obj/item/organ/internal/heart/rejuvenate(ignore_organ_traits)
	. = ..()
	if(!BP_IS_PROSTHETIC(src))
		pulse = PULSE_NORM
	else
		pulse = PULSE_NONE