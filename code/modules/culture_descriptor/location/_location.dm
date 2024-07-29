/decl/cultural_info/homeculture
	abstract_type = /decl/cultural_info/homeculture
	desc_type = "Culture"
	category = TAG_HOMECULTURE
	var/ruling_body = "Other Faction"
	var/capital

/decl/cultural_info/homeculture/get_text_details()
	. = list()
	if(!isnull(capital))
		. += "<b>Capital:</b> [capital]."
	if(!isnull(ruling_body))
		. += "<b>Territory:</b> [ruling_body]."
	. += ..()
