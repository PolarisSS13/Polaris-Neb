/obj/item/mech_component/manipulators
	name = "arms"
	pixel_y = -12
	icon_state = "loader_arms"
	has_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	material = /decl/material/solid/metal/steel
	power_use = 10

	var/melee_damage = 15
	var/action_delay = 15
	var/obj/item/robot_parts/robot_component/actuator/motivator

/obj/item/mech_component/manipulators/Destroy()
	QDEL_NULL(motivator)
	. = ..()

/obj/item/mech_component/manipulators/show_missing_parts(var/mob/user)
	if(!motivator)
		return list(SPAN_WARNING("It is missing an actuator."))

/obj/item/mech_component/manipulators/ready_to_install()
	return motivator

/obj/item/mech_component/manipulators/prebuild()
	motivator = new(src)

/obj/item/mech_component/manipulators/attackby(var/obj/item/used_item, var/mob/user)
	if(istype(used_item,/obj/item/robot_parts/robot_component/actuator))
		if(motivator)
			to_chat(user, SPAN_WARNING("\The [src] already has an actuator installed."))
			return TRUE
		if(install_component(used_item, user))
			motivator = used_item
			return TRUE
		return FALSE
	else
		return ..()

/obj/item/mech_component/manipulators/update_components()
	motivator = locate() in src

/obj/item/mech_component/manipulators/get_damage_string()
	if(!motivator || !motivator.is_functional())
		return SPAN_DANGER("disabled")
	return ..()

/obj/item/mech_component/manipulators/return_diagnostics(mob/user)
	..()
	if(motivator)
		to_chat(user, SPAN_NOTICE(" Actuator Integrity: <b>[round(motivator.get_percent_health())]%</b>"))
	else
		to_chat(user, SPAN_WARNING(" Actuator Missing or Non-functional."))
