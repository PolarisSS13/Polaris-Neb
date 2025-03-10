/datum/job/standard/computer
	title = "Computer"
	event_categories = list(ASSIGNMENT_COMPUTER)
	total_positions = 0 // Not used for AI, see is_position_available below and modules/mob/living/silicon/ai/latejoin.dm
	spawn_positions = 1
	selection_color = "#3f823f"
	supervisors = "your laws"
	req_admin_notify = 1
	minimal_player_age = 14
	account_allowed = 0
	economic_power = 0
	outfit_type = /decl/outfit/job/silicon/ai
	loadout_allowed = FALSE
	hud_icon_state = "hudblank"
	hud_icon = null
	skill_points = 0
	no_skill_buffs = TRUE
	guestbanned = 1
	not_random_selectable = 1
	skip_loadout_preview = TRUE
	department_types = list(/decl/department/miscellaneous)

/datum/job/standard/computer/equip_job(var/mob/living/human/H)
	return !!H

/datum/job/standard/computer/is_position_available()
	return (empty_playable_ai_cores.len != 0)

/datum/job/standard/computer/handle_variant_join(var/mob/living/human/H, var/alt_title)
	return H

/datum/job/standard/computer/do_spawn_special(var/mob/living/character, var/mob/new_player/new_player_mob, var/latejoin)
	character = character.AIize() // AIize the character, but don't move them yet

	// is_available for AI checks that there is an empty core available in this list
	var/obj/structure/aicore/deactivated/C = empty_playable_ai_cores[1]
	empty_playable_ai_cores -= C

	character.forceMove(C.loc)
	var/mob/living/silicon/ai/A = character
	A.on_mob_init()

	if(latejoin)
		new_player_mob.AnnounceCyborg(character, title, "has been downloaded to the empty core in \the [get_area_name(src)]")
	SSticker.mode.handle_latejoin(character)

	qdel(C)
	return TRUE

/datum/job/standard/robot
	title = "Robot"
	event_categories = list(ASSIGNMENT_ROBOT)
	total_positions = 2
	spawn_positions = 2
	supervisors = "your laws and the AI"
	selection_color = "#254c25"
	minimal_player_age = 7
	account_allowed = 0
	economic_power = 0
	loadout_allowed = FALSE
	outfit_type = /decl/outfit/job/silicon/cyborg
	hud_icon_state = "hudblank"
	hud_icon = null
	skill_points = 0
	no_skill_buffs = TRUE
	guestbanned = 1
	not_random_selectable = 1
	skip_loadout_preview = TRUE
	department_types = list(/decl/department/miscellaneous)

/datum/job/standard/robot/handle_variant_join(var/mob/living/human/H, var/alt_title)
	if(H)
		return H.Robotize(SSrobots.get_mob_type_by_title(alt_title || title))

/datum/job/standard/robot/equip_job(var/mob/living/human/H)
	return !!H

/datum/job/standard/robot/New()
	..()
	alt_titles = SSrobots.robot_alt_titles.Copy()
	alt_titles -= title // So the unit test doesn't flip out if a mob or brain type is declared for our main title.
