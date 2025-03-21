var/global/const/CHARACTER_PREFERENCE_INPUT_TITLE = "Character Preference"

/datum/category_group/player_setup_category
	abstract_type = /datum/category_group/player_setup_category

/datum/category_group/player_setup_category/background_preferences
	name = "Background"
	sort_order = 1 // must go first because species
	category_item_type = /datum/category_item/player_setup_item/background

/datum/category_group/player_setup_category/physical_preferences
	name = "Physical"
	sort_order = 2
	category_item_type = /datum/category_item/player_setup_item/physical

/datum/category_group/player_setup_category/trait_preferences
	name = "Traits"
	sort_order = 3
	category_item_type = /datum/category_item/player_setup_item/traits

/datum/category_group/player_setup_category/background_preferences/content(var/mob/user)
	. = ""
	for(var/datum/category_item/player_setup_item/PI in items)
		. += "[PI.content(user)]<br>"

/datum/category_group/player_setup_category/occupation_preferences
	name = "Occupation"
	sort_order = 4
	category_item_type = /datum/category_item/player_setup_item/occupation

/datum/category_group/player_setup_category/record_preferences
	name = "Records"
	sort_order = 5
	category_item_type = /datum/category_item/player_setup_item/records

/datum/category_group/player_setup_category/appearance_preferences
	name = "Roles"
	sort_order = 6
	category_item_type = /datum/category_item/player_setup_item/antagonism

/datum/category_group/player_setup_category/loadout_preferences
	name = "Equipment"
	sort_order = 7
	category_item_type = /datum/category_item/player_setup_item/loadout

/datum/category_group/player_setup_category/controls
	name = "Controls"
	sort_order = 8
	category_item_type = /datum/category_item/player_setup_item/controls

/datum/category_group/player_setup_category/global_preferences
	name = "Global"
	sort_order = 9
	category_item_type = /datum/category_item/player_setup_item/player_global


/****************************
* Category Collection Setup *
****************************/
/datum/category_collection/player_setup_collection
	category_group_type = /datum/category_group/player_setup_category
	var/datum/preferences/preferences
	var/datum/category_group/player_setup_category/selected_category = null

/datum/category_collection/player_setup_collection/New(var/datum/preferences/preferences)
	src.preferences = preferences
	..()
	selected_category = categories[1]

/datum/category_collection/player_setup_collection/Destroy()
	preferences = null
	selected_category = null
	return ..()

/datum/category_collection/player_setup_collection/proc/sanitize_setup()
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.sanitize_setup()

/datum/category_collection/player_setup_collection/proc/load_character(datum/pref_record_reader/R)
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.preload_character(R)
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.load_character(R)

/datum/category_collection/player_setup_collection/proc/save_character(datum/pref_record_writer/writer)
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.save_character(writer)

/datum/category_collection/player_setup_collection/proc/load_preferences(datum/pref_record_reader/R)
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.load_preferences(R)

/datum/category_collection/player_setup_collection/proc/save_preferences(datum/pref_record_writer/writer)
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.save_preferences(writer)

/datum/category_collection/player_setup_collection/proc/header()
	var/dat = ""
	for(var/datum/category_group/player_setup_category/PS in categories)
		if(PS == selected_category)
			dat += "[PS.name] "	// TODO: Check how to properly mark a href/button selected in a classic browser window
		else
			dat += "<a href='byond://?src=\ref[src];category=\ref[PS]'>[PS.name]</a> "
	return dat

/datum/category_collection/player_setup_collection/proc/content(var/mob/user)
	if(selected_category)
		return selected_category.content(user)

/datum/category_collection/player_setup_collection/Topic(var/href,var/list/href_list)
	if(..())
		return 1
	var/mob/user = usr
	if(!user.client)
		return 1

	if(href_list["category"])
		var/category = locate(href_list["category"])
		if(category && (category in categories))
			selected_category = category
		. = 1

	if(.)
		user.client.prefs.update_setup_window(user)

/**************************
* Category Category Setup *
**************************/
/datum/category_group/player_setup_category/proc/sanitize_setup()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.sanitize_preferences()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.sanitize_character()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.finalize_character()

/datum/category_group/player_setup_category/proc/preload_character(datum/pref_record_reader/R)
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.preload_character(R)

/datum/category_group/player_setup_category/proc/load_character(datum/pref_record_reader/R)
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.load_character(R)
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.sanitize_character()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.finalize_character()

/datum/category_group/player_setup_category/proc/save_character(datum/pref_record_writer/writer)
	// Sanitize all data, then save it
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.sanitize_character()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.finalize_character()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.save_character(writer)

/datum/category_group/player_setup_category/proc/load_preferences(datum/pref_record_reader/R)
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.load_preferences(R)

/datum/category_group/player_setup_category/proc/save_preferences(datum/pref_record_writer/writer)
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.sanitize_preferences()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.save_preferences(writer)

/datum/category_group/player_setup_category/proc/content(var/mob/user)
	. = "<table style='width:100%'><tr style='vertical-align:top'><td style='width:50%'>"
	var/current = 0
	var/halfway = items.len / 2
	for(var/datum/category_item/player_setup_item/PI in items)
		if(halfway && current++ >= halfway)
			halfway = 0
			. += "</td><td></td><td style='width:50%'>"
		. += "[PI.content(user)]<br>"
	. += "</td></tr></table>"

/datum/category_group/player_setup_category/occupation_preferences/content(var/mob/user)
	for(var/datum/category_item/player_setup_item/PI in items)
		. += "[PI.content(user)]<br>"

/**********************
* Category Item Setup *
**********************/
/datum/category_item/player_setup_item
	abstract_type = /datum/category_item/player_setup_item
	var/sort_order = 0
	var/datum/preferences/pref

/datum/category_item/player_setup_item/New()
	..()
	var/datum/category_collection/player_setup_collection/psc = category.collection
	pref = psc.preferences

/datum/category_item/player_setup_item/Destroy()
	pref = null
	return ..()

/datum/category_item/player_setup_item/dd_SortValue()
	return sort_order

/*
* Called when the item is asked to load per character settings, prior to load_character()
*/
/datum/category_item/player_setup_item/proc/preload_character(datum/pref_record_reader/R)
	return

/*
* Called when the item is asked to load per character settings
*/
/datum/category_item/player_setup_item/proc/load_character(datum/pref_record_reader/R)
	return

/*
* Called when the item is asked to save per character settings
*/
/datum/category_item/player_setup_item/proc/save_character(datum/pref_record_writer/writer)
	return

/*
* Called when the item is asked to load user/global settings
*/
/datum/category_item/player_setup_item/proc/load_preferences(datum/pref_record_reader/R)
	return

/*
* Called when the item is asked to save user/global settings
*/
/datum/category_item/player_setup_item/proc/save_preferences(datum/pref_record_writer/writer)
	return

/datum/category_item/player_setup_item/proc/content()
	return

/datum/category_item/player_setup_item/proc/sanitize_character()
	return

/datum/category_item/player_setup_item/proc/finalize_character()
	return

/datum/category_item/player_setup_item/proc/sanitize_preferences()
	return

/datum/category_item/player_setup_item/Topic(var/href,var/list/href_list)
	if(..())
		return 1
	var/mob/pref_mob = preference_mob()
	if(!pref_mob || !pref_mob.client)
		return 1
	// If the usr isn't trying to alter their own mob then they must instead be an admin
	if(usr != pref_mob && !check_rights(R_ADMIN, 0, usr))
		return 1

	. = OnTopic(href, href_list, usr)

	// The user might have joined the game or otherwise had a change of mob while tweaking their preferences.
	pref_mob = preference_mob()
	if(!pref_mob || !pref_mob.client)
		return 1
	if(. & TOPIC_UPDATE_PREVIEW)
		pref_mob.client.prefs.update_preview_icon()

	// And again: above operation is slow/may sleep, clients disappear whenever.
	pref_mob = preference_mob()
	if(!pref_mob || !pref_mob.client)
		return 1
	if(. & TOPIC_HARD_REFRESH)
		pref_mob.client.prefs.open_setup_window(usr)

	// And again again: above operation is slow/may sleep, clients disappear whenever.
	pref_mob = preference_mob()
	if(!pref_mob || !pref_mob.client)
		return 1
	if(. & TOPIC_REFRESH)
		pref_mob.client.prefs.update_setup_window(usr)

/datum/category_item/player_setup_item/CanUseTopic(var/mob/user)
	return 1

/datum/category_item/player_setup_item/proc/OnTopic(var/href,var/list/href_list, var/mob/user)
	return TOPIC_NOACTION

/datum/category_item/player_setup_item/proc/preference_mob()
	if(!pref.client)
		for(var/client/C)
			if(C.ckey == pref.client_ckey)
				pref.client = C
				break

	if(pref.client)
		return pref.client.mob
