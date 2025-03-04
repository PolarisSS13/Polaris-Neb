/obj/screen/stamina
	name              = "stamina"
	icon              = 'icons/effects/progressbar.dmi'
	icon_state        = "prog_bar_100"
	invisibility      = INVISIBILITY_MAXIMUM
	screen_loc        = ui_stamina
	requires_ui_style = FALSE
	layer = HUD_BASE_LAYER + 0.1 // needs to layer over the movement intent element

/obj/screen/stamina/on_update_icon()
	. = ..()
	var/mob/living/owner = owner_ref?.resolve()
	if(!istype(owner))
		set_invisibility(INVISIBILITY_MAXIMUM)
	else
		var/stamina = owner.get_stamina()
		if(stamina < 100)
			set_invisibility(INVISIBILITY_NONE)
			icon_state = "prog_bar_[floor(stamina/5)*5][(stamina >= 5) && (stamina <= 25) ? "_fail" : null]"
		else
			set_invisibility(INVISIBILITY_MAXIMUM)
