/decl/cultural_info/citizenship
	abstract_type = /decl/cultural_info/citizenship
	desc_type = "Citizenship"
	category = TAG_CITIZENSHIP

	var/capital
	var/size_heading = "Systems"
	var/size_value
	var/founded



/decl/cultural_info/citizenship/get_text_details()
	. = list()
	if(!isnull(capital))
		. += "<b>Capital:</b> [capital]."
	if(!isnull(size_value) && !isnull(size_heading))
		. += "<b>Extent:</b> [size_value] [size_heading]."
	if(!isnull(founded))
		. += "<b>Founded:</b> [founded]"
	. += ..()