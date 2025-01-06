/decl/loadout_option/suit/bomber // Override version of bomber jacket selection incorporating map-specific jacket.
	name = "jacket, bomber selection"
	description = "A selection of jackets styled after early aviation gear."
	path = /obj/item/clothing/suit/jacket/bomber
	cost = 2

/decl/loadout_option/suit/bomber/New()
	..()
	var/bombertype = list()
	bombertype["bomber jacket"] = /obj/item/clothing/suit/jacket/bomber
	bombertype["bomber jacket, alternate"] = /obj/item/clothing/suit/jacket/bomber/alt
	bombertype["bomber jacket, retro"] = /obj/item/clothing/suit/jacket/bomber/retro
	bombertype["bomber jacket, pilot blue"] = /obj/item/clothing/suit/jacket/bomber/pilot
	gear_tweaks += new/datum/gear_tweak/path(bombertype)
