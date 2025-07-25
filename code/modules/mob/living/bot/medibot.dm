#define MEDBOT_PANIC_NONE	0
#define MEDBOT_PANIC_LOW	15
#define MEDBOT_PANIC_MED	35
#define MEDBOT_PANIC_HIGH	55
#define MEDBOT_PANIC_FUCK	70
#define MEDBOT_PANIC_ENDING	90
#define MEDBOT_PANIC_END	100

/mob/living/bot/medbot
	name = "Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'icons/mob/bot/medibot.dmi'
	icon_state = "medibot0"
	req_access = list(list(access_medical, access_robotics))
	botcard_access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology)
	var/skin = null //Set to "tox", "ointment" or "o2" for the other two firstaid kits.

	//AI vars
	var/last_newpatient_speak = 0
	var/vocal = 1

	//Healing vars
	var/obj/item/chems/glass/reagent_glass = null //Can be set to draw from this for reagents.
	var/injection_amount = 15 //How much reagent do we inject at a time?
	var/heal_threshold = 10 //Start healing when they have this much damage in a category
	var/use_beaker = 0 //Use reagents in beaker instead of default treatment agents.
	var/treatment_brute = /decl/material/liquid/regenerator
	var/treatment_oxy =   /decl/material/liquid/regenerator
	var/treatment_fire =  /decl/material/liquid/regenerator
	var/treatment_tox =   /decl/material/liquid/regenerator
	var/treatment_emag =  /decl/material/liquid/venom
	var/declare_treatment = 0 //When attempting to treat a patient, should it notify everyone wearing medhuds?

	// Are we tipped over?
	var/is_tipped = FALSE
	//How panicked we are about being tipped over (why would you do this?)
	var/tipped_status = MEDBOT_PANIC_NONE
	//The name we got when we were tipped
	var/tipper_name
	//The last time we were tipped/righted and said a voice line, to avoid spam
	var/last_tipping_action_voice = 0

/mob/living/bot/medbot/get_other_examine_strings(mob/user, distance, infix, suffix, hideflags, decl/pronouns/pronouns)
	. = ..()
	if(tipped_status == MEDBOT_PANIC_NONE)
		return

	switch(tipped_status)
		if(MEDBOT_PANIC_NONE to MEDBOT_PANIC_LOW)
			. += "It appears to be tipped over, and is quietly waiting for someone to set it right."
		if(MEDBOT_PANIC_LOW to MEDBOT_PANIC_MED)
			. += "It is tipped over and requesting help."
		if(MEDBOT_PANIC_MED to MEDBOT_PANIC_HIGH)
			. += SPAN_WARNING("They are tipped over and appear visibly distressed.") // now we humanize the medbot as a they, not an it
		if(MEDBOT_PANIC_HIGH to MEDBOT_PANIC_FUCK)
			. += SPAN_WARNING("They are tipped over and visibly panicking!")
		if(MEDBOT_PANIC_FUCK to INFINITY)
			. += SPAN_DANGER("They are freaking out from being tipped over!")

/mob/living/bot/medbot/handleIdle()
	if(vocal && prob(1))
		var/static/message_options = list(
			"Radar, put a mask on!" = 'sound/voice/medbot/mradar.ogg',
			"There's always a catch, and it's the best there is." = 'sound/voice/medbot/mcatch.ogg',
			"I knew it, I should've been a plastic surgeon." = 'sound/voice/medbot/msurgeon.ogg',
			"What kind of medbay is this? Everyone's dropping like flies." = 'sound/voice/medbot/mflies.ogg',
			"Delicious!" = 'sound/voice/medbot/mdelicious.ogg'
			)
		var/message = pick(message_options)
		say(message)
		playsound(src, message_options[message], 50, 0)

/mob/living/bot/medbot/handleAdjacentTarget()
	if(is_tipped) // Don't handle targets if we're incapacitated!
		return
	UnarmedAttack(target, TRUE)

/mob/living/bot/medbot/lookForTargets()
	if(is_tipped) // Don't look for targets if we're incapacitated!
		return
	for(var/mob/living/human/patient in view(7, src)) // Time to find a patient!
		if(confirmTarget(patient))
			target = patient
			if(last_newpatient_speak + 300 < world.time && vocal)
				if(vocal)
					var/message_options = list(
						"Hey, [patient.name]! Hold on, I'm coming." = 'sound/voice/medbot/mcoming.ogg',
						"Wait [patient.name]! I want to help!" = 'sound/voice/medbot/mhelp.ogg',
						"[patient.name], you appear to be injured!" = 'sound/voice/medbot/minjured.ogg'
						)
					var/message = pick(message_options)
					say(message)
					playsound(src, message_options[message], 50, 0)
				custom_emote(1, "points at [patient.name].")
				last_newpatient_speak = world.time
			break

/mob/living/bot/medbot/ResolveUnarmedAttack(var/mob/living/human/target)
	if(!on || !istype(target))
		return FALSE

	if(busy)
		return TRUE

	if(target.stat == DEAD)
		if(vocal)
			var/static/death_messages = list(
				"No! Stay with me!" = 'sound/voice/medbot/mno.ogg',
				"Live, damnit! LIVE!" = 'sound/voice/medbot/mlive.ogg',
				"I... I've never lost a patient before. Not today, I mean." = 'sound/voice/medbot/mlost.ogg'
				)
			var/message = pick(death_messages)
			say(message)
			playsound(src, death_messages[message], 50, 0)

	var/t = confirmTarget(target)
	if(!t)
		if(vocal)
			var/static/possible_messages = list(
				"All patched up!" = 'sound/voice/medbot/mpatchedup.ogg',
				"An apple a day keeps me away." = 'sound/voice/medbot/mapple.ogg',
				"Feel better soon!" = 'sound/voice/medbot/mfeelbetter.ogg'
				)
			var/message = pick(possible_messages)
			say(message)
			playsound(src, possible_messages[message], 50, 0)

	icon_state = "medibots"
	visible_message("<span class='warning'>[src] is trying to inject [target]!</span>")
	if(declare_treatment)
		var/area/location = get_area(src)
		broadcast_medical_hud_message("[src] is treating <b>[target]</b> in <b>[location.proper_name]</b>", src)
	busy = 1
	update_icon()
	if(do_mob(src, target, 30))
		if(t == 1)
			reagent_glass.reagents.trans_to_mob(target, injection_amount, CHEM_INJECT)
		else
			target.add_to_reagents(t, injection_amount)
		visible_message("<span class='warning'>[src] injects [target] with the syringe!</span>")
	busy = 0
	update_icon()
	return TRUE

/mob/living/bot/medbot/on_update_icon()
	..()
	if(skin)
		add_overlay(image('icons/mob/bot/medibot_skins.dmi', "medskin_[skin]"))
	if(busy)
		icon_state = "medibots"
	else
		icon_state = "medibot[on]"

/mob/living/bot/medbot/attackby(var/obj/item/used_item, var/mob/user)
	if(istype(used_item, /obj/item/chems/glass))
		if(locked)
			to_chat(user, "<span class='notice'>You cannot insert a beaker because the panel is locked.</span>")
			return TRUE
		if(!isnull(reagent_glass))
			to_chat(user, "<span class='notice'>There is already a beaker loaded.</span>")
			return TRUE

		if(!user.try_unequip(used_item, src))
			return TRUE
		reagent_glass = used_item
		to_chat(user, "<span class='notice'>You insert [used_item].</span>")
		return TRUE
	else
		return ..()

/mob/living/bot/medbot/default_disarm_interaction(mob/user)
	if(!is_tipped)
		user.visible_message(SPAN_DANGER("\The [user] begins tipping over [src]."), SPAN_WARNING("You begin tipping over [src]..."))

		if(world.time > last_tipping_action_voice + 15 SECONDS && vocal)
			last_tipping_action_voice = world.time // message for tipping happens when we start interacting, message for righting comes after finishing
			var/static/list/messagevoice = list("Hey, wait..." = 'sound/voice/medbot/hey_wait.ogg',"Please don't..." = 'sound/voice/medbot/please_dont.ogg',"I trusted you..." = 'sound/voice/medbot/i_trusted_you.ogg', "Nooo..." = 'sound/voice/medbot/nooo.ogg', "Oh fuck-" = 'sound/voice/medbot/oh_fuck.ogg')
			var/message = pick(messagevoice)
			say(message)
			playsound(src, messagevoice[message], 70, FALSE)
		if(do_after(user, 3 SECONDS, target=src))
			tip_over(user)
		return TRUE
	. = ..()

/mob/living/bot/medbot/default_help_interaction(mob/user)
	if(is_tipped)
		user.visible_message(SPAN_NOTICE("\The [user] begins righting [src]."), SPAN_NOTICE("You begin righting [src]..."))
		if(do_after(user, 3 SECONDS, target=src))
			set_right(user)
		return TRUE
	. = ..()

/mob/living/bot/medbot/GetInteractTitle()
	. = "<head><title>Medibot v1.0 controls</title></head>"
	. += "<b>Automatic Medical Unit v1.0</b>"

/mob/living/bot/medbot/GetInteractStatus()
	. = ..()
	. += "<br>Beaker: "
	if(reagent_glass)
		. += "<A href='byond://?src=\ref[src];command=eject'>Loaded \[[reagent_glass.reagents.total_volume]/[reagent_glass.reagents.maximum_volume]\]</a>"
	else
		. += "None loaded"

/mob/living/bot/medbot/GetInteractPanel()
	. = "Healing threshold: "
	. += "<a href='byond://?src=\ref[src];command=adj_threshold;amount=-10'>--</a> "
	. += "<a href='byond://?src=\ref[src];command=adj_threshold;amount=-5'>-</a> "
	. += "[heal_threshold] "
	. += "<a href='byond://?src=\ref[src];command=adj_threshold;amount=5'>+</a> "
	. += "<a href='byond://?src=\ref[src];command=adj_threshold;amount=10'>++</a>"

	. += "<br>Injection level: "
	. += "<a href='byond://?src=\ref[src];command=adj_inject;amount=-5'>-</a> "
	. += "[injection_amount] "
	. += "<a href='byond://?src=\ref[src];command=adj_inject;amount=5'>+</a> "

	. += "<br>Reagent source: <a href='byond://?src=\ref[src];command=use_beaker'>[use_beaker ? "Loaded Beaker (When available)" : "Internal Synthesizer"]</a>"
	. += "<br>Treatment report is [declare_treatment ? "on" : "off"]. <a href='byond://?src=\ref[src];command=declaretreatment'>Toggle</a>"
	. += "<br>The speaker switch is [vocal ? "on" : "off"]. <a href='byond://?src=\ref[src];command=togglevoice'>Toggle</a>"

/mob/living/bot/medbot/GetInteractMaintenance()
	. = "Injection mode: "
	switch(emagged)
		if(0)
			. += "<a href='byond://?src=\ref[src];command=emag'>Treatment</a>"
		if(1)
			. += "<a href='byond://?src=\ref[src];command=emag'>Random (DANGER)</a>"
		if(2)
			. += "ERROROROROROR-----"

/mob/living/bot/medbot/ProcessCommand(var/mob/user, var/command, var/href_list)
	..()
	if(CanAccessPanel(user))
		switch(command)
			if("adj_threshold")
				if(!locked || issilicon(user))
					var/adjust_num = text2num(href_list["amount"])
					heal_threshold = clamp(heal_threshold + adjust_num, 5, 75)
			if("adj_inject")
				if(!locked || issilicon(user))
					var/adjust_num = text2num(href_list["amount"])
					injection_amount = clamp(injection_amount + adjust_num, 5, 15)
			if("use_beaker")
				if(!locked || issilicon(user))
					use_beaker = !use_beaker
			if("eject")
				if(reagent_glass)
					if(!locked)
						reagent_glass.dropInto(src.loc)
						reagent_glass = null
					else
						to_chat(user, "<span class='notice'>You cannot eject the beaker because the panel is locked.</span>")
			if("togglevoice")
				if(!locked || issilicon(user))
					vocal = !vocal
			if("declaretreatment")
				if(!locked || issilicon(user))
					declare_treatment = !declare_treatment

	if(CanAccessMaintenance(user))
		switch(command)
			if("emag")
				if(emagged < 2)
					emagged = !emagged

/mob/living/bot/medbot/emag_act(var/remaining_uses, var/mob/user)
	. = ..()
	if(!emagged)
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s reagent synthesis circuits.</span>")
			ignore_list |= user
		visible_message("<span class='warning'>[src] buzzes oddly!</span>")
		flick("medibot_spark", src)
		target = null
		busy = 0
		emagged = 1
		on = 1
		update_icon()
		. = 1

/mob/living/bot/medbot/gib(do_gibs = TRUE)
	var/turf/my_turf = get_turf(src)
	. = ..()
	if(. && my_turf)
		new /obj/item/firstaid(my_turf)
		new /obj/item/assembly/prox_sensor(my_turf)
		new /obj/item/scanner/health(my_turf)
		if (prob(50))
			new /obj/item/robot_parts/l_arm(my_turf)
		if(reagent_glass)
			reagent_glass.forceMove(my_turf)
			reagent_glass = null

/mob/living/bot/medbot/confirmTarget(atom/target)
	if(!(. = ..()))
		return

	var/mob/living/human/patient = target
	if(!istype(patient) || patient.stat == DEAD) // He's dead, Jim
		return FALSE

	if(emagged)
		return treatment_emag

	// If they're injured, we're using a beaker, and they don't have on of the chems in the beaker
	if(reagent_glass && use_beaker && ((patient.get_damage(BRUTE) >= heal_threshold) || (patient.get_damage(TOX) >= heal_threshold) || (patient.get_damage(TOX) >= heal_threshold) || (patient.get_damage(OXY) >= (heal_threshold + 15))))
		for(var/decl/material/reagent as anything in reagent_glass.reagents.reagent_volumes)
			if(!patient.reagents.has_reagent(reagent))
				return 1
			continue

	if((patient.get_damage(BRUTE) >= heal_threshold) && (!patient.reagents.has_reagent(treatment_brute)))
		return treatment_brute //If they're already medicated don't bother!

	if((patient.get_damage(OXY) >= (15 + heal_threshold)) && (!patient.reagents.has_reagent(treatment_oxy)))
		return treatment_oxy

	if((patient.get_damage(BURN) >= heal_threshold) && (!patient.reagents.has_reagent(treatment_fire)))
		return treatment_fire

	if((patient.get_damage(TOX) >= heal_threshold) && (!patient.reagents.has_reagent(treatment_tox)))
		return treatment_tox

/mob/living/bot/medbot/proc/tip_over(mob/user)
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50)
	user.visible_message(SPAN_DANGER("[user] tips over [src]!"), SPAN_DANGER("You tip [src] over!"))
	is_tipped = TRUE
	tipper_name = user.name
	var/matrix/mat = transform
	transform = mat.Turn(180)

/mob/living/bot/medbot/proc/set_right(mob/user)
	var/list/messagevoice
	if(user)
		user.visible_message(SPAN_NOTICE("[user] sets [src] right-side up!"), SPAN_NOTICE("You set [src] right-side up!"))
		if(user.name == tipper_name)
			messagevoice = list("I forgive you." = 'sound/voice/medbot/forgive.ogg')
		else
			messagevoice = list("Thank you!" = 'sound/voice/medbot/thank_you.ogg', "You are a good person." = 'sound/voice/medbot/youre_good.ogg')
	else
		visible_message(SPAN_NOTICE("[src] manages to [pick("writhe", "wriggle", "wiggle")] enough to right itself."))
		messagevoice = list("Fuck you." = 'sound/voice/medbot/fuck_you.ogg', "Your behavior has been reported, have a nice day." = 'sound/voice/medbot/reported.ogg')

	tipper_name = null
	if(world.time > last_tipping_action_voice + 15 SECONDS && vocal)
		last_tipping_action_voice = world.time
		var/message = pick(messagevoice)
		say(message)
		playsound(src, messagevoice[message], 70)
	tipped_status = MEDBOT_PANIC_NONE
	is_tipped = FALSE
	transform = matrix()


/mob/living/bot/medbot/handleRegular()
	. = ..()

	if(is_tipped)
		handle_panic()
		return

/mob/living/bot/medbot/proc/handle_panic()
	tipped_status++
	var/list/messagevoice
	switch(tipped_status)
		if(MEDBOT_PANIC_LOW)
			messagevoice = list("I require assistance." = 'sound/voice/medbot/i_require_asst.ogg')
		if(MEDBOT_PANIC_MED)
			messagevoice = list("Please put me back." = 'sound/voice/medbot/please_put_me_back.ogg')
		if(MEDBOT_PANIC_HIGH)
			messagevoice = list("Please, I am scared!" = 'sound/voice/medbot/please_im_scared.ogg')
		if(MEDBOT_PANIC_FUCK)
			messagevoice = list("I don't like this, I need help!" = 'sound/voice/medbot/dont_like.ogg', "This hurts, my pain is real!" = 'sound/voice/medbot/pain_is_real.ogg')
		if(MEDBOT_PANIC_ENDING)
			messagevoice = list("Is this the end?" = 'sound/voice/medbot/is_this_the_end.ogg', "Nooo!" = 'sound/voice/medbot/nooo.ogg')
		if(MEDBOT_PANIC_END)
			broadcast_medical_hud_message("PSYCH ALERT: Crewmember [tipper_name] recorded displaying antisocial tendencies torturing bots in [get_area_name(src)]. Please schedule psych evaluation.", src)
			set_right() // strong independent medbot

	if(messagevoice && vocal)
		var/message = pick(messagevoice)
		say(message)
		playsound(src, messagevoice[message], 70)
	else if(prob(tipped_status * 0.2) && vocal)
		playsound(src, 'sound/machines/warning-buzzer.ogg', 30)

#undef MEDBOT_PANIC_NONE
#undef MEDBOT_PANIC_LOW
#undef MEDBOT_PANIC_MED
#undef MEDBOT_PANIC_HIGH
#undef MEDBOT_PANIC_FUCK
#undef MEDBOT_PANIC_ENDING
#undef MEDBOT_PANIC_END
