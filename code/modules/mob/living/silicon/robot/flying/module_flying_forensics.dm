/obj/item/robot_module/flying/forensics
	name = "forensic drone module"
	display_name = "Forensics"
	channels = list("Security" = TRUE)
	camera_channels = list(CAMERA_CHANNEL_SECURITY)
	software = list(
		/datum/computer_file/program/suit_sensors,
		/datum/computer_file/program/digitalwarrant
	)
	module_sprites = list(
		"Drone" = 'icons/mob/robots/flying/flying_security.dmi',
		"Eyebot" = 'icons/mob/robots/flying/eyebot_security.dmi'
	)
	equipment = list(
		/obj/item/forensics/sample_kit/swabs,
		/obj/item/evidence,
		/obj/item/forensics/sample_kit,
		/obj/item/forensics/sample_kit/powder,
		/obj/item/gripper/clerical,
		/obj/item/flash,
		/obj/item/borg/sight/hud/sec,
		/obj/item/stack/tape_roll/barricade_tape/police,
		/obj/item/scalpel/laser,
		/obj/item/scanner/autopsy,
		/obj/item/chems/spray/luminol,
		/obj/item/uv_light,
		/obj/item/crowbar
	)
	emag = /obj/item/gun/energy/laser/mounted
	skills = list(
		SKILL_LITERACY            = SKILL_ADEPT,
		SKILL_COMPUTER            = SKILL_EXPERT,
		SKILL_FORENSICS           = SKILL_PROF,
		SKILL_WEAPONS             = SKILL_EXPERT,
		SKILL_CONSTRUCTION        = SKILL_ADEPT,
		SKILL_ANATOMY             = SKILL_ADEPT
	)

/obj/item/robot_module/flying/forensics/respawn_consumable(var/mob/living/silicon/robot/robot, var/amount)
	var/obj/item/chems/spray/luminol/luminol = locate() in equipment
	if(!luminol)
		luminol = new(src)
		equipment += luminol
	if(luminol.reagents.total_volume < luminol.volume)
		var/adding = min(luminol.volume-luminol.reagents.total_volume, 2*amount)
		if(adding > 0)
			luminol.add_to_reagents(/decl/material/liquid/luminol, adding)
	..()
