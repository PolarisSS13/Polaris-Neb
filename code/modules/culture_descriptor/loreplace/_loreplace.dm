/decl/cultural_info/loreplace
	abstract_type = /decl/cultural_info/loreplace
	desc_type = "Place"
	category = TAG_LOREPLACE
	var/distance_heading = "Distance from Sol"
	var/distance = 0
	var/ruling_body = "Other Faction"
	var/capital

	// Used by the random news generator. Populate with subtypes of /decl/loreplace_event.
	var/list/viable_random_events = list()
	var/list/viable_mundane_events = list()

/decl/cultural_info/loreplace/get_text_details()
	. = list()
	if(!isnull(capital))
		. += "<b>Capital:</b> [capital]."
	if(!isnull(ruling_body))
		. += "<b>Territory:</b> [ruling_body]."
	if(!isnull(distance) && !isnull(distance_heading))
		. += "<b>[distance_heading]:</b> [distance]."
	. += ..()
