// Gloves

/obj/item/clothing/gloves/mittens
	name = "mittens"
	desc = "A pair of cozy mittens."
	icon = 'mods/content/polaris/icons/clothing/gloves/gloves_mittens.dmi'
	permeability_coefficient = 0.50
	cold_protection = SLOT_HANDS
	heat_protection = SLOT_HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "A pair of gloves that don't actually cover the fingers."
	icon = 'mods/content/polaris/icons/clothing/gloves/gloves_fingerless.dmi'
	permeability_coefficient = 1
	body_parts_covered = 0


/obj/item/clothing/gloves/knuckle_dusters //Not currently functional while worn; have to take them off and hit people with them.
	name = "knuckle dusters"
	desc = "A pair of knuckle dusters. Generally used to enhance the user's punches."
	icon = 'mods/content/polaris/icons/clothing/gloves/gloves_knuckle_dusters.dmi'
	attack_verb = list("punched", "beaten", "struck")
	material = /decl/material/solid/metal/steel
	item_flags = ITEM_FLAG_THICKMATERIAL
	permeability_coefficient = 1
	body_parts_covered = 0
	_base_attack_force = 5