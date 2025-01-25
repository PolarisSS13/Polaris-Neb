/decl/game_mode/possible_ert_disabled_reasons()
	var/static/sm_injected = FALSE
	if(sm_injected)
		return ..()
	sm_injected = TRUE
	. = ..()
	. += "supermatter dust"

/obj/item/disk/secret_project/get_secret_project_nouns()
	var/static/sm_injected = FALSE
	if(sm_injected)
		return ..()
	sm_injected = TRUE
	. = ..()
	. += "a supermatter engine"
	return .

/decl/material/solid/exotic_matter
	lore_text = "Hypercrystalline supermatter is a subset of non-baryonic 'exotic' matter. It is found mostly in the heart of large stars, and features heavily in all kinds of fringe physics-defying technology."