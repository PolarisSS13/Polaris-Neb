//Security

/obj/item/clothing/suit/armor/pcarrier/light/nt/cynosure
	name = "security armor"
	starting_accessories = list(/obj/item/clothing/armor/armorplate, /obj/item/clothing/pouches, /obj/item/clothing/armor/tag/nt)

//Pilot

/obj/item/clothing/suit/toggle/bomber/pilot
	name = "pilot jacket"
	desc = "A thick, blue bomber jacket."
	icon_state = "pilot_bomber"
	item_icons = list(slot_wear_suit_str = 'maps/cynosure/icons/mob/cyno_suit.dmi')
	item_state_slots = list(slot_r_hand_str = "brown_jacket", slot_l_hand_str = "brown_jacket")
	icon = 'maps/cynosure/icons/obj/cyno_suit.dmi'
	sprite_sheets = list(
			"Teshari" = 'maps/cynosure/icons/mob/species/teshari/cyno_suit.dmi'
			)
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

//Misc

/obj/item/clothing/suit/jacket/winter/medical/sar
	name = "search and rescue winter coat"
	desc = "A heavy winter jacket. A white star of life is emblazoned on the back, with the words search and rescue written underneath."
	icon_state = "coatsar"
	item_icons = list(slot_wear_suit_str = 'maps/cynosure/icons/mob/cyno_suit.dmi')
	icon = 'maps/cynosure/icons/obj/cyno_suit.dmi'
	armor = list(melee = 15, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 5)
	valid_accessory_slots = (ACCESSORY_SLOT_INSIGNIA)
	allowed = list (/obj/item/gun,/obj/item/pen, /obj/item/paper, /obj/item/flashlight,/obj/item/tank/emergency/oxygen, /obj/item/box/fancy/cigarettes,
	/obj/item/box/matches, /obj/item/chems/drinks/flask, /obj/item/suit_cooling_unit, /obj/item/scanner/gas,/obj/item/stack/medical,
	/obj/item/dnainjector,/obj/item/chems/dropper,/obj/item/chems/syringe,/obj/item/chems/hypospray,
	/obj/item/scanner/health,/obj/item/chems/glass/bottle,/obj/item/chems/glass/beaker,
	/obj/item/chems/pill,/obj/item/pill_bottle)