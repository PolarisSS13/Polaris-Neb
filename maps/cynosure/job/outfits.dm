//Job Outfits
/*
SOUTHERN CROSS OUTFITS
Keep outfits simple. Spawn with basic uniforms and minimal gear. Gear instead goes in lockers. Keep this in mind if editing.
*/


/decl/outfit/job/explorer2
	name     = "Cynosure - Explorer"
	shoes    = /obj/item/clothing/shoes/winterboots/explorer
	uniform  = /obj/item/clothing/under/explorer
	l_ear    = /obj/item/radio/headset/headset_exp
	id_slot  = slot_wear_id_str
	pda_slot = slot_l_store_str
	pda_type = /obj/item/pda/cargo // Brown looks more rugged
	id_type  = /obj/item/card/id/civilian
	flags    = OUTFIT_HAS_BACKPACK|OUTFIT_COMPREHENSIVE_SURVIVAL
	id_pda_assignment = "Explorer"
	backpack_contents = list(/obj/item/clothing/permit/gun/planetside = 1)


/decl/outfit/job/explorer2/post_equip(mob/living/human/H)
	..()
	for(var/obj/item/clothing/permit/gun/planetside/permit in H.back.contents)
		permit.set_owner(H.real_name) // no letting someone else use it!

/decl/outfit/job/explorer2/technician
	name = "Cynosure - Explorer Technician"
	belt = /obj/item/belt/utility/full
	pda_slot = slot_l_store
	id_pda_assignment = "Explorer Technician"

/decl/outfit/job/explorer2/medic
	name = "Cynosure - Explorer Medic"
	l_hand = /obj/item/firstaid/regular
	pda_slot = slot_l_store
	id_pda_assignment = "Explorer Medic"

/decl/outfit/job/pilot
	name = "Cynosure - Pilot"
	shoes = /obj/item/clothing/shoes/color/black
	uniform = /obj/item/clothing/under/rank/pilot1
	suit = /obj/item/clothing/suit/toggle/bomber/pilot
	gloves = /obj/item/clothing/gloves/fingerless
	glasses = /obj/item/clothing/glasses/fakesunglasses/aviator
	l_ear = /obj/item/radio/headset/headset_exp/bowman
	id_slot = slot_wear_id
	pda_slot = slot_belt
	pda_type = /obj/item/pda/cargo // Brown looks more rugged
	id_type = /obj/item/card/id/civilian
	id_pda_assignment = "Pilot"
	flags = OUTFIT_HAS_BACKPACK|OUTFIT_COMPREHENSIVE_SURVIVAL

/decl/outfit/job/medical/sar
	name = "Cynosure - Search and Rescue"
	uniform = /obj/item/clothing/under/utility/blue
	suit = /obj/item/clothing/suit/jacket/winter/medical/sar
	shoes = /obj/item/clothing/shoes/winterboots/explorer
	l_ear = /obj/item/radio/headset/headset_sar
	l_hand = /obj/item/firstaid/regular
	belt = /obj/item/belt/medical/emt
	pda_slot = slot_l_store
	id_type = /obj/item/card/id/medical
	id_pda_assignment = "Search and Rescue"
	flags = OUTFIT_HAS_BACKPACK|OUTFIT_EXTENDED_SURVIVAL|OUTFIT_COMPREHENSIVE_SURVIVAL

/decl/outfit/job/survivalist
	name = "Cynosure - Survivalist"
	l_ear =    null
	r_ear =    null
	pda_slot = null
	pda_type = null
	id_slot =  null
	id_type =  null
	mask =     /obj/item/clothing/mask/gas
	r_pocket = /obj/item/tank/emergency/oxygen/double
	l_pocket = /obj/item/radio
	uniform =  /obj/item/clothing/jumpsuit/grey
	shoes =    /obj/item/clothing/shoes/winterboots
	suit =     /obj/item/clothing/suit/jacket/winter
	belt =     /obj/item/gun/energy/phasegun/pistol // better make that cell count

/decl/outfit/job/survivalist/equip_outfit(mob/living/human/H, assignment, equip_adjustments, datum/job/job, datum/mil_rank/rank)
	. = ..()
	var/obj/item/clothing/shoes/shoes = H?.get_equipped_item(slot_shoes_str)
	if(istype(shoes) && !shoes.holding && shoes.can_hold_knife)
		shoes.holding = new /obj/item/bladed/knife/survival(H)
		shoes.update_icon()

/decl/outfit/job/survivalist/crash_survivor
	name = "Cynosure - Crash Survivor"
	uniform = /obj/item/clothing/jumpsuit/lightblue
	shoes = /obj/item/clothing/shoes/color/black
	head = /obj/item/clothing/head/helmet/space/emergency
	suit = /obj/item/clothing/suit/space/emergency
	suit_store = /obj/item/tank/oxygen
	mask = null

// This is basically a joke for the service drake spawn alt title.
/decl/outfit/siffet
	name = "Cynosure - Siffet"
	suit = /obj/item/clothing/suit/hooded/costume/siffet
	head = /obj/item/clothing/head/hood/siffet_hood
