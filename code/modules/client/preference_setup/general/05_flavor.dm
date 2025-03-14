/datum/preferences
	var/list/flavor_texts        = list()
	var/list/flavour_texts_robot = list()

/datum/category_item/player_setup_item/physical/flavor
	name = "Flavor"
	sort_order = 5

/datum/category_item/player_setup_item/physical/flavor/load_character(datum/pref_record_reader/R)
	pref.flavor_texts["general"] = R.read("flavor_texts_general")
	pref.flavor_texts["head"] =    R.read("flavor_texts_head")
	pref.flavor_texts["face"] =    R.read("flavor_texts_face")
	pref.flavor_texts["eyes"] =    R.read("flavor_texts_eyes")
	pref.flavor_texts["torso"] =   R.read("flavor_texts_torso")
	pref.flavor_texts["arms"] =    R.read("flavor_texts_arms")
	pref.flavor_texts["hands"] =   R.read("flavor_texts_hands")
	pref.flavor_texts["legs"] =    R.read("flavor_texts_legs")
	pref.flavor_texts["feet"] =    R.read("flavor_texts_feet")

	//Flavour text for robots.
	pref.flavour_texts_robot["Default"] = R.read("flavour_texts_robot_Default")
	for(var/module in SSrobots.all_module_names)
		pref.flavour_texts_robot[module] = R.read("flavour_texts_robot_[module]")

/datum/category_item/player_setup_item/physical/flavor/save_character(datum/pref_record_writer/writer)
	writer.write("flavor_texts_general", pref.flavor_texts["general"])
	writer.write("flavor_texts_head",    pref.flavor_texts["head"])
	writer.write("flavor_texts_face",    pref.flavor_texts["face"])
	writer.write("flavor_texts_eyes",    pref.flavor_texts["eyes"])
	writer.write("flavor_texts_torso",   pref.flavor_texts["torso"])
	writer.write("flavor_texts_arms",    pref.flavor_texts["arms"])
	writer.write("flavor_texts_hands",   pref.flavor_texts["hands"])
	writer.write("flavor_texts_legs",    pref.flavor_texts["legs"])
	writer.write("flavor_texts_feet",    pref.flavor_texts["feet"])

	writer.write("flavour_texts_robot_Default", pref.flavour_texts_robot["Default"])
	for(var/module in SSrobots.all_module_names)
		writer.write("flavour_texts_robot_[module]", pref.flavour_texts_robot[module])

/datum/category_item/player_setup_item/physical/flavor/sanitize_character()
	if(!istype(pref.flavor_texts))        pref.flavor_texts = list()
	if(!istype(pref.flavour_texts_robot)) pref.flavour_texts_robot = list()

/datum/category_item/player_setup_item/physical/flavor/content(var/mob/user)

	. += "<b>Flavor:</b><br>"
	. += "<a href='byond://?src=\ref[src];flavor_text=open'>Set Flavor Text</a><br/>"
	. += "<a href='byond://?src=\ref[src];flavour_text_robot=open'>Set Robot Flavor Text</a><br/>"

/datum/category_item/player_setup_item/physical/flavor/OnTopic(var/href,var/list/href_list, var/mob/user)

	if(href_list["flavor_text"])
		switch(href_list["flavor_text"])
			if("open")
				pass()
			if("general")
				var/msg = sanitize(input(user,"Give a general description of your character. This will be shown regardless of clothing. Do not include OOC information here.","Flavor Text",html_decode(pref.flavor_texts[href_list["flavor_text"]])) as message, extra = 0)
				if(CanUseTopic(user))
					pref.flavor_texts[href_list["flavor_text"]] = msg
			else
				var/msg = sanitize(input(user,"Set the flavor text for your [href_list["flavor_text"]].","Flavor Text",html_decode(pref.flavor_texts[href_list["flavor_text"]])) as message, extra = 0)
				if(CanUseTopic(user))
					pref.flavor_texts[href_list["flavor_text"]] = msg
		SetFlavorText(user)
		return TOPIC_HANDLED

	else if(href_list["flavour_text_robot"])
		switch(href_list["flavour_text_robot"])
			if("open")
				pass()
			if("Default")
				var/msg = sanitize(input(user,"Set the default flavour text for your robot. It will be used for any module without individual setting.","Flavour Text",html_decode(pref.flavour_texts_robot["Default"])) as message, extra = 0)
				if(CanUseTopic(user))
					pref.flavour_texts_robot[href_list["flavour_text_robot"]] = msg
			else
				var/msg = sanitize(input(user,"Set the flavour text for your robot with [href_list["flavour_text_robot"]] module. If you leave this empty, default flavour text will be used for this module.","Flavour Text",html_decode(pref.flavour_texts_robot[href_list["flavour_text_robot"]])) as message, extra = 0)
				if(CanUseTopic(user))
					pref.flavour_texts_robot[href_list["flavour_text_robot"]] = msg
		SetFlavourTextRobot(user)
		return TOPIC_HANDLED

	return ..()

/datum/category_item/player_setup_item/physical/flavor/proc/SetFlavorText(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[src];flavor_text=general'>General:</a> "
	HTML += TextPreview(pref.flavor_texts["general"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_text=head'>Head:</a> "
	HTML += TextPreview(pref.flavor_texts["head"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_text=face'>Face:</a> "
	HTML += TextPreview(pref.flavor_texts["face"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_text=eyes'>Eyes:</a> "
	HTML += TextPreview(pref.flavor_texts["eyes"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_text=torso'>Body:</a> "
	HTML += TextPreview(pref.flavor_texts["torso"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_text=arms'>Arms:</a> "
	HTML += TextPreview(pref.flavor_texts["arms"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_text=hands'>Hands:</a> "
	HTML += TextPreview(pref.flavor_texts["hands"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_text=legs'>Legs:</a> "
	HTML += TextPreview(pref.flavor_texts["legs"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_text=feet'>Feet:</a> "
	HTML += TextPreview(pref.flavor_texts["feet"])
	HTML += "<br>"
	HTML += "<hr />"
	HTML += "<tt>"
	show_browser(user, HTML, "window=flavor_text;size=430x300")
	return

/datum/category_item/player_setup_item/physical/flavor/proc/SetFlavourTextRobot(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Robot Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[src];flavour_text_robot=Default'>Default:</a> "
	HTML += TextPreview(pref.flavour_texts_robot["Default"])
	HTML += "<hr />"
	for(var/module in SSrobots.all_module_names)
		HTML += "<a href='byond://?src=\ref[src];flavour_text_robot=[module]'>[module]:</a> "
		HTML += TextPreview(pref.flavour_texts_robot[module])
		HTML += "<br>"
	HTML += "<hr />"
	HTML += "<tt>"
	show_browser(user, HTML, "window=flavour_text_robot;size=430x300")
	return
