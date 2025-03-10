/datum/event/ailments/start()
	var/list/candidates = list()
	for(var/mob/living/human/H in global.living_mob_list_)
		if(H.client && !H.has_mob_modifier(/decl/mob_modifier/stasis))
			candidates += H
	if(!length(candidates))
		return
	candidates = shuffle(candidates)
	var/create_ailments = min(length(candidates), rand(1,3))
	for(var/i = 1 to length(candidates))
		var/mob/living/human/H = candidates[i]
		var/list/organs = shuffle(H.get_organs())
		for(var/ii = 1 to length(organs))
			var/obj/item/organ/O = organs[ii]
			var/list/possible_ailments = O.get_possible_ailments()
			if(!length(possible_ailments))
				continue
			possible_ailments = shuffle(possible_ailments)
			var/gave_ailment = FALSE
			for(var/iii = 1 to length(possible_ailments))
				var/datum/ailment/ailment = possible_ailments[iii]
				if(O.add_ailment(ailment))
					log_debug("Random event gave [ailment] to [key_name(H)].")
					create_ailments--
					if(!create_ailments)
						return
					gave_ailment = TRUE
					break
			if(gave_ailment)
				break
