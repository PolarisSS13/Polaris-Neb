//Security
/obj/item/clothing/suit/armor/pcarrier/light/cynosure
	name = "security armor"
	starting_accessories = list(
		/obj/item/clothing/armor_attachment/plate,
		/obj/item/clothing/webbing/drop_pouches,
		/obj/item/clothing/armor_attachment/tag/corp
	)

/obj/item/clothing/suit/jacket/winter/medical/sar
	name = "search and rescue winter coat"
	desc = "A heavy winter jacket. A white star of life is emblazoned on the back, with the words search and rescue written underneath."
	icon = 'mods/content/polaris/icons/clothing/suits/sar_jacket.dmi'
	armor = list(melee = 15, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 5)
	valid_accessory_slots = list(ACCESSORY_SLOT_INSIGNIA)
	allowed = list (
		/obj/item/gun,
		/obj/item/pen,
		/obj/item/paper,
		/obj/item/flashlight,
		/obj/item/tank/emergency/oxygen,
		/obj/item/box/fancy/cigarettes,
		/obj/item/box/matches,
		/obj/item/chems/drinks/flask,
		/obj/item/suit_cooling_unit,
		/obj/item/scanner/gas,
		/obj/item/stack/medical,
		/obj/item/chems/dropper,
		/obj/item/chems/syringe,
		/obj/item/chems/hypospray,
		/obj/item/scanner/health,
		/obj/item/chems/glass/bottle,
		/obj/item/chems/glass/beaker,
		/obj/item/chems/pill,
		/obj/item/pill_bottle
	)