/decl/modpack/beekeeping
	name = "Beekeeping Content"

/datum/storage/hopper/industrial/centrifuge/New()
	..()
	can_hold |= /obj/item/honey_frame

// Terrible, will be replaced in beewrite.
/datum/storage/hopper/industrial/centrifuge/should_ingest(mob/user, obj/item/thing)
	if(istype(thing, /obj/item/honey_frame))
		var/obj/item/honey_frame/frame = thing
		if(frame.honey > 0)
			return TRUE
		if(user)
			to_chat(user, SPAN_WARNING("\The [thing] is empty."))
		return FALSE
	return ..()
