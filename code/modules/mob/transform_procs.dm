/mob/living/human/proc/monkeyize()
	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/thing in get_contained_external_atoms())
		drop_from_inventory(thing)
	try_refresh_visible_overlays()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	set_status_condition(STAT_STUN, 1)
	icon = null
	set_invisibility(INVISIBILITY_ABSTRACT)
	for(var/t in get_external_organs())
		qdel(t)
	var/atom/movable/overlay/animation = new /atom/movable/overlay(src)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	flick("h2monkey", animation)
	sleep(48)
	//animation = null

	DEL_TRANSFORMATION_MOVEMENT_HANDLER(src)
	set_status_condition(STAT_STUN, 0)
	update_posture()
	set_invisibility(initial(invisibility))

	if(!species.primitive_form) //If the creature in question has no primitive set, this is going to be messy.
		gib()
		return

	for(var/obj/item/thing in src)
		drop_from_inventory(thing)
	change_species(species.primitive_form)

	to_chat(src, "<B>You are now [species.name]. </B>")
	qdel(animation)

	return src

/mob/new_player/AIize(move = TRUE)
	spawning = 1
	return ..()

/mob/living/human/AIize(move = TRUE)
	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	QDEL_NULL_LIST(worn_underwear)
	return ..()

/mob/living/silicon/ai/AIize(move = TRUE)
	return src

/mob/living/AIize(move = TRUE)
	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/t in get_external_organs())
		qdel(t)
	for(var/obj/item/thing in src)
		drop_from_inventory(thing)
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(INVISIBILITY_ABSTRACT)
	return ..()

/mob/proc/AIize(move = TRUE)
	if(client)
		sound_to(src, sound(null, repeat = 0, wait = 0, volume = 85, channel = sound_channels.lobby_channel))// stop the jams for AIs


	var/mob/living/silicon/ai/O = new (loc, global.using_map.default_law_type,,1)//No brain but safety is in effect.
	O.set_invisibility(INVISIBILITY_NONE)
	O.aiRestorePowerRoutine = 0
	if(mind)
		mind.transfer_to(O)
	else
		O.key = key

	if(move)
		var/obj/loc_landmark
		for(var/obj/abstract/landmark/start/sloc in global.all_landmarks)
			if (sloc.name != "AI")
				continue
			if (locate(/mob/living) in sloc.loc)
				continue
			loc_landmark = sloc
		if (!loc_landmark)
			for(var/obj/abstract/landmark/tripai in global.all_landmarks)
				if (tripai.name == "tripai")
					if((locate(/mob/living) in tripai.loc) || (locate(/obj/structure/aicore) in tripai.loc))
						continue
					loc_landmark = tripai
		if (!loc_landmark)
			to_chat(O, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
			for(var/obj/abstract/landmark/start/sloc in global.all_landmarks)
				if (sloc.name == "AI")
					loc_landmark = sloc
		O.forceMove(loc_landmark ? loc_landmark.loc : get_turf(src))
		O.on_mob_init()

	O.add_ai_verbs()

	O.rename_self("ai",1)
	qdel(src)
	return O

//human -> robot
/mob/living/human/proc/Robotize(var/supplied_robot_type = /mob/living/silicon/robot)
	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	QDEL_NULL_LIST(worn_underwear)
	for(var/obj/item/thing in src)
		drop_from_inventory(thing)
	try_refresh_visible_overlays()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(INVISIBILITY_ABSTRACT)
	for(var/t in get_external_organs())
		qdel(t)

	var/mob/living/silicon/robot/O = new supplied_robot_type( loc )

	O.set_gender(gender)
	O.set_invisibility(INVISIBILITY_NONE)

	if(!mind)
		mind_initialize()
		mind.assigned_role = ASSIGNMENT_ROBOT
	mind.active = TRUE
	mind.transfer_to(O)
	if(O.mind && O.mind.assigned_role == ASSIGNMENT_ROBOT)
		var/mmi_type = SSrobots.get_brain_type_by_title(O.mind.role_alt_title ? O.mind.role_alt_title : O.mind.assigned_role)
		if(mmi_type)
			O.central_processor = new mmi_type(O)

	O.dropInto(loc)
	O.job = ASSIGNMENT_ROBOT
	RAISE_EVENT(/decl/observ/cyborg_created, O)
	O.Namepick()

	qdel(src)
	return O

/mob/living/human/proc/corgize()
	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/thing in src)
		drop_from_inventory(thing)
	try_refresh_visible_overlays()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(INVISIBILITY_ABSTRACT)
	for(var/t in get_external_organs())	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi (loc)
	new_corgi.set_intent(get_intent())
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	qdel(src)
	return

/mob/living/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	for(var/obj/item/thing in src)
		drop_from_inventory(thing)

	try_refresh_visible_overlays()
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(src)
	icon = null
	set_invisibility(INVISIBILITY_ABSTRACT)

	for(var/t in get_external_organs())
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.set_intent(get_intent())


	to_chat(new_mob, "You suddenly feel more... animalistic.")
	qdel(src)
	return

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.set_intent(get_intent())
	to_chat(new_mob, "You feel more... animalistic.")

	qdel(src)

/* Certain mob types have problems and should not be allowed to be controlled by players.
 *
 * This proc is here to force coders to manually place their mob in this list, hopefully tested.
 * This also gives a place to explain -why- players shouldnt be turn into certain mobs and hopefully someone can fix them.
 */
/mob/proc/safe_animal(var/MP)

//Bad mobs! - Remember to add a comment explaining what's wrong with the mob
	if(!MP)
		return 0	//Sanity, this should never happen.

//Good mobs!
	if(ispath(MP, /mob/living/simple_animal/passive/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/corgi))
		return 1
	if(ispath(MP, /mob/living/simple_animal/crab))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/carp))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mushroom))
		return 1
	if(ispath(MP, /mob/living/simple_animal/tomato))
		return 1
	if(ispath(MP, /mob/living/simple_animal/passive/mouse))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/bear))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/parrot))
		return 1

	//Not in here? Must be untested!
	return 0


/mob/living/human/proc/zombify()
	add_genetic_condition(GENE_COND_HUSK)
	add_genetic_condition(GENE_COND_CLUMSY)
	src.visible_message("<span class='danger'>\The [src]'s skin decays before your very eyes!</span>", "<span class='danger'>Your entire body is ripe with pain as it is consumed down to flesh and bones. You ... hunger. Not only for flesh, but to spread this gift.</span>")
	if (src.mind)
		if (src.mind.assigned_special_role == "Zombie")
			return
		src.mind.assigned_special_role = "Zombie"
	log_admin("[key_name(src)] has transformed into a zombie!")
	SET_STATUS_MAX(src, STAT_WEAK, 5)
	if (should_have_organ(BP_HEART))
		adjust_blood(species.blood_volume - vessel.total_volume)
	for (var/o in get_external_organs())
		var/obj/item/organ/organ = o
		if (!BP_IS_PROSTHETIC(organ))
			organ.rejuvenate(1)
			organ.max_damage *= 3
			organ.min_broken_damage = floor(organ.max_damage * 0.75)
	verbs += /mob/living/proc/breath_death
	verbs += /mob/living/proc/consume
	playsound(get_turf(src), 'sound/hallucinations/wail.ogg', 20, 1)