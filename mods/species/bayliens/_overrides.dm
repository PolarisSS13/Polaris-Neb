/obj/item
	var/_feline_onmob_icon

/obj/item/setup_sprite_sheets()
	. = ..()
	if(_feline_onmob_icon)
		LAZYSET(sprite_sheets, BODYTYPE_FELINE, _feline_onmob_icon)
