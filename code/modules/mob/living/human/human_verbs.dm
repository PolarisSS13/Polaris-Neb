/mob/living/human/proc/remotesay()
	set name = "Project mind"
	set category = "Superpower"

	if(stat!=CONSCIOUS)
		reset_view(0)
		remoteview_target = null
		return

	if(!has_genetic_condition(GENE_COND_REMOTE_TALK))
		src.verbs -= /mob/living/human/proc/remotesay
		return
	var/list/creatures = list()
	for(var/mob/living/h in global.player_list)
		creatures += h
	var/mob/target = input(usr, "Who do you want to project your mind to?") as null|anything in creatures
	if (isnull(target))
		return

	var/say = sanitize(input("What do you wish to say"))
	if(target.has_genetic_condition(GENE_COND_REMOTE_TALK))
		target.show_message("<span class='notice'>You hear [src.real_name]'s voice: [say]</span>")
	else
		target.show_message("<span class='notice'>You hear a voice that seems to echo around the room: [say]</span>")
	usr.show_message("<span class='notice'>You project your mind into [target.real_name]: [say]</span>")
	log_say("[key_name(usr)] sent a telepathic message to [key_name(target)]: [say]")
	for(var/mob/observer/ghost/ghost in global.player_list)
		ghost.show_message("<i>Telepathic message from <b>[src]</b> to <b>[target]</b>: [say]</i>")

/mob/living/human/proc/remoteobserve()
	set name = "Remote View"
	set category = "Superpower"

	if(stat!=CONSCIOUS)
		remoteview_target = null
		reset_view(0)
		return

	if(!has_genetic_condition(GENE_COND_REMOTE_VIEW))
		remoteview_target = null
		reset_view(0)
		src.verbs -= /mob/living/human/proc/remoteobserve
		return

	if(client.eye != client.mob)
		remoteview_target = null
		reset_view(0)
		return

	var/list/mob/creatures = list()

	for(var/mob/living/h in global.living_mob_list_)
		var/turf/temp_turf = get_turf(h)
		if((temp_turf.z != 1 && temp_turf.z != 5) || h.stat!=CONSCIOUS) //Not on mining or the station. Or dead
			continue
		creatures += h

	var/mob/target = input(usr, "Who do you want to project your mind to?") as mob in creatures

	if (target)
		remoteview_target = target
		reset_view(target)
	else
		remoteview_target = null
		reset_view(0)

/mob/living/human/proc/remove_splints()
	set category = "Object"
	set name = "Remove Splints"
	set desc = "Carefully remove splints from someone's limbs."
	set src in view(1)
	var/mob/living/user = usr
	var/removed_splint = 0

	if(usr.stat || usr.restrained() || !isliving(usr)) return

	for(var/obj/item/organ/external/o in get_external_organs())
		if (o && o.splinted)
			var/obj/item/S = o.splinted
			if(!istype(S) || S.loc != o) //can only remove splints that are actually worn on the organ (deals with hardsuit splints)
				to_chat(user, SPAN_WARNING("You cannot remove any splints on [src]'s [o.name] - [o.splinted] is supporting some of the breaks."))
			else
				S.add_fingerprint(user)
				if(o.remove_splint())
					user.put_in_active_hand(S)
					removed_splint = 1
	if(removed_splint)
		user.visible_message(SPAN_DANGER("\The [user] removes \the [src]'s splints!"))
	else
		to_chat(user, SPAN_WARNING("\The [src] has no splints that can be removed."))
	verbs -= /mob/living/human/proc/remove_splints

/mob/living/human/verb/check_pulse()
	set category = "Object"
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)

	if(usr.incapacitated() || usr.restrained() || !isliving(usr))
		return

	var/self = (usr == src)
	var/decl/pronouns/pronouns = usr.get_pronouns()
	if(!self)
		var/decl/pronouns/target_gender = src.get_pronouns()
		usr.visible_message( \
			SPAN_NOTICE("\The [usr] kneels down, puts [pronouns.his] hand on \the [src]'s wrist, and begins counting [target_gender.his] pulse."), \
			SPAN_NOTICE("You begin counting \the [src]'s pulse."))
	else
		usr.visible_message(
			SPAN_NOTICE("\The [usr] begins counting [pronouns.his] pulse."), \
			SPAN_NOTICE("You begin counting your pulse."))

	if(get_pulse())
		to_chat(usr, "<span class='notice'>[self ? "You have a" : "[src] has a"] pulse! Counting...</span>")
	else
		to_chat(usr, "<span class='danger'>[src] has no pulse!</span>")//it is REALLY UNLIKELY that a dead person would check his own pulse
		return

	to_chat(usr, "You must[self ? "" : " both"] remain still until counting is finished.")
	if(do_mob(usr, src, 60))
		var/message = "<span class='notice'>[self ? "Your" : "[src]'s"] pulse is [src.get_pulse_as_string(GETPULSE_HAND)].</span>"
		to_chat(usr, message)
	else
		to_chat(usr, "<span class='warning'>You failed to check the pulse. Try again.</span>")

/mob/living/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if (src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	var/bloody_hands = 0
	for(var/obj/item/organ/external/grabber in get_hands_organs())
		if(grabber.coating)
			bloody_hands += REAGENT_VOLUME(grabber.coating, /decl/material/liquid/blood)
	if (!bloody_hands)
		verbs -= /mob/living/human/proc/bloody_doodle

	var/obj/item/gloves = get_equipped_item(slot_gloves_str)
	if (gloves)
		to_chat(src, SPAN_WARNING("Your [gloves] are getting in the way."))
		return

	var/turf/T = src.loc
	if (!istype(T) || !T.simulated) //to prevent doodling out of mechs and lockers
		to_chat(src, "<span class='warning'>You cannot reach the floor.</span>")
		return

	var/direction = input(src,"Which way?","Tile selection") as null|anything in list("Here","North","South","East","West")
	if(!direction)
		return
	if(direction != "Here")
		T = get_step(T,text2dir(direction))
	if (!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/writing in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = sanitize(input("Write a message. It cannot be longer than [max_length] characters.","Blood writing", ""))

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")
		var/obj/effect/decal/cleanable/blood/writing/writing = new(T)
		writing.basecolor = (hand_blood_color) ? hand_blood_color : COLOR_BLOOD_HUMAN
		writing.update_icon()
		writing.message = message
		writing.add_fingerprint(src)

/mob/living/human/proc/undislocate()
	set category = "Object"
	set name = "Undislocate Joint"
	set desc = "Pop a joint back into place. Extremely painful."
	set src in view(1)

	if(!isliving(usr) || !usr.canClick())
		return

	usr.setClickCooldown(20)

	if(usr.stat > 0)
		to_chat(usr, "You are unconscious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/self = null
	if(S == U)
		self = 1 // Removing object from yourself.

	var/list/limbs = list()
	for(var/obj/item/organ/external/current_limb in get_external_organs())
		if(current_limb && current_limb.is_dislocated() && !current_limb.is_parent_dislocated()) //if the parent is also dislocated you will have to relocate that first
			limbs |= current_limb
	var/obj/item/organ/external/current_limb = input(usr,"Which joint do you wish to relocate?") as null|anything in limbs

	if(!current_limb)
		return

	if(self)
		to_chat(src, "<span class='warning'>You brace yourself to relocate your [current_limb.joint]...</span>")
	else
		to_chat(U, "<span class='warning'>You begin to relocate [S]'s [current_limb.joint]...</span>")
	if(!do_after(U, 30, src))
		return
	if(!current_limb || !S || !U)
		return

	var/fail_prob = U.skill_fail_chance(SKILL_MEDICAL, 60, SKILL_ADEPT, 3)
	if(self)
		fail_prob += U.skill_fail_chance(SKILL_MEDICAL, 20, SKILL_EXPERT, 1)
	var/decl/pronouns/pronouns = get_pronouns()
	if(prob(fail_prob))
		visible_message( \
		"<span class='danger'>[U] pops [self ? "[pronouns.his]" : "[S]'s"] [current_limb.joint] in the WRONG place!</span>", \
		"<span class='danger'>[self ? "You pop" : "[U] pops"] your [current_limb.joint] in the WRONG place!</span>" \
		)
		current_limb.add_pain(30)
		current_limb.take_damage(5)
		shock_stage += 20
	else
		visible_message( \
		"<span class='danger'>[U] pops [self ? "[pronouns.his]" : "[S]'s"] [current_limb.joint] back in!</span>", \
		"<span class='danger'>[self ? "You pop" : "[U] pops"] your [current_limb.joint] back in!</span>" \
		)
		current_limb.undislocate()
