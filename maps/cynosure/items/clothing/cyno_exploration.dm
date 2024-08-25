/obj/item/clothing/jumpsuit/explorer
	name = "explorer's jumpsuit"
	desc = "A green uniform for operating in hazardous environments."
	icon = 'maps/cynosure/icons/obj/clothing/jumpsuits/explorer.dmi'

/obj/item/clothing/mask/gas/explorer
	name = "explorer gas mask"
	desc = "A military-grade gas mask that can be connected to an air supply."
	icon = 'maps/cynosure/icons/obj/clothing/masks/gas_explorer.dmi'
	siemens_coefficient = 0.9

/obj/item/clothing/suit/toggle/explorer
	name = "explorer suit"
	desc = "An armoured suit for exploring harsh environments."
	icon = 'maps/cynosure/icons/obj/clothing/suits/explorer.dmi'
	item_flags = ITEM_FLAG_THICKMATERIAL
	body_parts_covered = SLOT_UPPER_BODY|SLOT_LOWER_BODY|SLOT_LEGS|SLOT_ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	cold_protection = SLOT_UPPER_BODY|SLOT_LOWER_BODY|SLOT_LEGS|SLOT_ARMS
	hood = /obj/item/clothing/head/explorerhood
	siemens_coefficient = 0.9
	armor = list(ARMOR_MELEE = ARMOR_MELEE_RESISTANT, ARMOR_BULLET = ARMOR_BALLISTIC_SMALL, ARMOR_LASER = ARMOR_LASER_SMALL, ARMOR_ENERGY = ARMOR_ENERGY_SMALL, ARMOR_BOMB = ARMOR_BOMB_PADDED, ARMOR_BIO = ARMOR_BIO_STRONG, ARMOR_RAD = ARMOR_RAD_RESISTANT) // Inferior to sec vests in bullet/laser but better for environmental protection.
	allowed = list(
		/obj/item/flashlight, /obj/item/gun, /obj/item/ammo_magazine,
		/obj/item/knife, /obj/item/tool/machete, /obj/item/tank,
		/obj/item/radio, /obj/item/tool/pickaxe,  /obj/item/tool/shovel, /obj/item/gun/projectile/flare
	)

/obj/item/clothing/head/explorerhood
	name = "explorer hood"
	desc = "An armoured hood for exploring harsh environments."
	icon = 'maps/cynosure/icons/obj/clothing/suits/explorer_hood.dmi'
	item_flags = ITEM_FLAG_THICKMATERIAL
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	armor = list(ARMOR_MELEE = ARMOR_MELEE_RESISTANT, ARMOR_BULLET = ARMOR_BALLISTIC_SMALL, ARMOR_LASER = ARMOR_LASER_SMALL, ARMOR_ENERGY = ARMOR_ENERGY_SMALL, ARMOR_BOMB = ARMOR_BOMB_PADDED, ARMOR_BIO = ARMOR_BIO_STRONG, ARMOR_RAD = ARMOR_RAD_RESISTANT)

/obj/item/clothing/shoes/winterboots/explorer
	name = "explorer winter boots"
	desc = "Steel-toed winter boots for mining or exploration in hazardous environments. Very good at keeping toes warm and uncrushed."
	icon = 'maps/cynosure/icons/obj/clothing/shoes/explorer.dmi'
	armor = list(ARMOR_MELEE = 30, ARMOR_BULLET = 10, ARMOR_LASER = 10, ARMOR_ENERGY = 15, ARMOR_BOMB = 20, ARMOR_BIO = 0, ARMOR_RAD = 0)

// Voidsuits
/obj/item/clothing/head/helmet/space/void/exploration
	name = "exploration voidsuit helmet"
	desc = "A radiation-resistant helmet made especially for exploring unknown planetary environments."
	icon = 'maps/cynosure/icons/obj/clothing/suits/void_explorer_helmet.dmi'
	armor = list(ARMOR_MELEE = 40, ARMOR_BULLET = 15, ARMOR_LASER = 25,ARMOR_ENERGY = 35, ARMOR_BOMB = 30, ARMOR_BIO = 100, ARMOR_RAD = 70)

/obj/item/clothing/suit/space/void/exploration
	name = "exploration voidsuit"
	desc = "A lightweight, radiation-resistant voidsuit, featuring the Explorer emblem on its chest plate. Designed for exploring unknown planetary environments."
	icon = 'maps/cynosure/icons/obj/clothing/suits/void_explorer.dmi'
	armor = list(ARMOR_MELEE = 40, ARMOR_BULLET = 15, ARMOR_LASER = 25,ARMOR_ENERGY = 35, ARMOR_BOMB = 30, ARMOR_BIO = 100, ARMOR_RAD = 70)
	allowed = list(
		/obj/item/flashlight, /obj/item/tank, /obj/item/suit_cooling_unit,
		/obj/item/stack/flag, /obj/item/scanner/health, /obj/item/gps,
		/obj/item/radio/beacon, /obj/item/tool/pickaxe,  /obj/item/tool/shovel, /obj/item/ammo_magazine, /obj/item/gun
	)