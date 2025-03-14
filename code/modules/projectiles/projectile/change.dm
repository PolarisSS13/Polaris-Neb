/obj/item/projectile/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	atom_damage_type = BURN
	damage_flags = 0
	nodamage = 1

/obj/item/projectile/change/on_hit(var/atom/change)
	wabbajack(change)

/obj/item/projectile/change/proc/get_random_transformation_options(var/mob/M)
	. = list()
	if(!isrobot(M))
		. += "robot"
	for(var/decl/species/species as anything in decls_repository.get_decls_of_subtype_unassociated(/decl/species))
		. += species.uid
	if(ishuman(M))
		var/mob/living/human/H = M
		. -= H.species.uid

/obj/item/projectile/change/proc/apply_transformation(var/mob/M, var/choice)

	if(choice == "robot")
		var/mob/living/silicon/robot/robot = new(get_turf(M))
		robot.set_gender(M.get_gender())
		robot.job = ASSIGNMENT_ROBOT
		robot.central_processor = new /obj/item/organ/internal/brain_interface(robot)
		transfer_key_from_mob_to_mob(M, robot)
		return robot

	if(decls_repository.get_decl_by_id(choice))
		var/mob/living/human/H = M
		if(!istype(H))
			H = new(get_turf(M))
			H.set_gender(M.get_gender())
		H.name = "unknown" // This will cause set_species() to randomize the mob name.
		H.real_name = H.name
		H.change_species(choice)
		H.universal_speak = TRUE
		var/datum/preferences/A = new()
		A.randomize_appearance_and_body_for(H)
		return H

/obj/item/projectile/change/proc/wabbajack(var/mob/M)

	if(!isliving(M) || M.stat == DEAD)
		return

	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(M))
		return

	M.handle_pre_transformation()
	var/choice = pick(get_random_transformation_options(M))
	var/mob/living/new_mob = apply_transformation(M, choice)
	if(new_mob)
		new_mob.set_intent(I_FLAG_HARM)
		new_mob.copy_abilities_from(M)
		transfer_key_from_mob_to_mob(M, new_mob)
		to_chat(new_mob, "<span class='warning'>Your form morphs into that of \a [choice].</span>")
	else
		new_mob = M
	if(new_mob)
		to_chat(new_mob, SPAN_WARNING("Your form morphs into that of \a [choice]."))

	if(new_mob != M && !QDELETED(M))
		qdel(M)
