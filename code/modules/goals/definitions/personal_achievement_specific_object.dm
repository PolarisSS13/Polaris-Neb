// Toggle upon receiving a particular type from some trigger in wider code.
/datum/goal/achievement/specific_object
	var/object_path
	var/list/possible_objects
	var/list/blacklisted_objects

/datum/goal/achievement/specific_object/New()
	if(LAZYLEN(blacklisted_objects))
		possible_objects -= blacklisted_objects
	object_path = pick(possible_objects)
	possible_objects = null
	blacklisted_objects = null
	..()

/datum/goal/achievement/specific_object/update_progress(var/progress)
	if(!success)
		if(ispath(progress))
			if(ispath(progress, object_path) || ispath(object_path, progress))
				success = TRUE
		else if(isatom(progress))
			var/atom/A = progress
			if(istype(A, object_path) || ispath(object_path, A.type))
				success = TRUE
		if(success)
			on_completion()

/datum/goal/achievement/specific_object/food
	completion_message = "Ahh, that was just what you needed."

/datum/goal/achievement/specific_object/food/New()
	possible_objects = subtypesof(/obj/item/food)
	blacklisted_objects = blacklisted_objects || list()
	blacklisted_objects |= typesof(/obj/item/food/amanita_pie)
	blacklisted_objects |= typesof(/obj/item/food/amanitajelly)
	blacklisted_objects |= typesof(/obj/item/food/can/caviar/true)
	blacklisted_objects |= typesof(/obj/item/food/old)
	..()

/datum/goal/achievement/specific_object/food/update_strings()
	..()
	var/obj/food = object_path
	description = "You really feel like \a [initial(food.name)]. Make sure to get some."

/datum/goal/achievement/specific_object/drink
	completion_message = "Ahh, that hit the spot!"

/datum/goal/achievement/specific_object/drink/New()
	possible_objects = decls_repository.get_decl_paths_of_subtype(/decl/material/liquid/drink)
	..()

/datum/goal/achievement/specific_object/drink/update_strings()
	..()
	var/decl/material/liquid/drink = object_path
	description = "You could really do with a nice [initial(drink.name)]."

/datum/goal/achievement/specific_object/pet
	completion_message = "You should get a pet of your own..."

/datum/goal/achievement/specific_object/pet
	possible_objects = list(
		/mob/living/simple_animal/corgi,
		/mob/living/simple_animal/passive/cat
	)

/datum/goal/achievement/specific_object/pet/update_strings()
	..()
	var/mob/animal = object_path
	description = "Pet \a [initial(animal.name)]." // probably best not to use the atom info repository for this, lest we get 'Pet a monkey (666).'
