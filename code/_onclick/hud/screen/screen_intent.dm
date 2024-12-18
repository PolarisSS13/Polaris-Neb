/obj/screen/intent
	name              = "intent"
	icon              = 'icons/mob/screen/styles/intents.dmi'
	icon_state        = "intents"
	screen_loc        = ui_acti
	requires_ui_style = FALSE

/obj/screen/intent/Initialize(mapload, mob/_owner, decl/ui_style/ui_style, ui_color, ui_alpha, ui_cat)
	. = ..()
	update_icon()

/obj/screen/intent/handle_click(mob/user, params)
	var/mob/owner = owner_ref?.resolve()
	if(!istype(owner) || QDELETED(owner) || user != owner || !params)
		return
	params = params2list(params)
	if(owner.set_intent(get_intent_by_position(owner.get_available_intents(), text2num(params["icon-x"]), text2num(params["icon-y"]))))
		update_icon()

/obj/screen/intent/proc/get_intent_by_position(list/intents, icon_x, icon_y)
	if(icon_y <= 16)
		if(icon_x <= 16)
			return intents[1]
		return intents[2]
	else if(icon_x <= 16)
		return intents[3]
	return intents[4]

/obj/screen/intent/proc/apply_intent_overlay_offset(image/overlay, index)
	switch(index)
		if(2)
			overlay.pixel_x = 16
		if(3)
			overlay.pixel_y = 16
		if(4)
			overlay.pixel_x = 16
			overlay.pixel_y = 16

/obj/screen/intent/on_update_icon()
	cut_overlays()
	var/mob/owner = owner_ref?.resolve()
	if(!istype(owner) || QDELETED(owner))
		return
	var/decl/intent/owner_intent = owner.get_intent()
	var/i = 0
	var/image/I
	for(var/decl/intent/intent as anything in owner.get_available_intents())
		if(intent == owner_intent)
			I = image(intent.icon, intent.icon_state)
		else
			I = image(intent.icon, "[intent.icon_state]_off")
		i++
		apply_intent_overlay_offset(I, i)
		add_overlay(I)
	compile_overlays()

/obj/screen/intent/binary
	icon = 'icons/mob/screen/styles/intents_wide.dmi'

/obj/screen/intent/binary/get_intent_by_position(list/intents, icon_x, icon_y)
	if(icon_y <= 16)
		return intents[1]
	return intents[2]

/obj/screen/intent/binary/apply_intent_overlay_offset(image/overlay, index)
	if(index == 2)
		overlay.pixel_y = 16
