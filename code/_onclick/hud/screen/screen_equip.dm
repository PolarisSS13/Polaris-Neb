/obj/screen/equip
	name       = "equip"
	icon_state = "act_equip"

/obj/screen/equip/handle_click(mob/user, params)
	if(ishuman(user))
		var/mob/living/human/H = user
		H.quick_equip()
