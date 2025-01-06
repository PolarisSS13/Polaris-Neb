/mob/proc/has_organ(organ_tag)
	return !!get_organ(organ_tag, /obj/item/organ)

/mob/proc/get_organ(var/organ_tag, var/expected_type)
	RETURN_TYPE(/obj/item/organ)
	return

/mob/proc/get_injured_organs()
	return

/mob/proc/get_external_organs()
	return

/mob/proc/get_internal_organs()
	return

/mob/proc/get_organs()
	for(var/organ in get_external_organs())
		LAZYADD(., organ)
	for(var/organ in get_internal_organs())
		LAZYADD(., organ)
