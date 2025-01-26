/obj/screen/up_hint
	name       = "up hint"
	icon_state = "uphint0"
	screen_loc = ui_up_hint

/obj/screen/up_hint/handle_click(mob/user, params)
	if(isliving(user))
		var/mob/living/L = user
		L.lookup()

/obj/screen/up_hint/on_update_icon()
	var/mob/owner = owner_ref?.resolve()
	var/turf/above = istype(owner) ? GetAbove(get_turf(owner)) : null
	icon_state = "uphint[!!(istype(above) && TURF_IS_MIMICKING(above))]"
	..()
