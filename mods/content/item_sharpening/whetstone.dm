/obj/item/whetstone
	name = "whetstone"
	desc = "A worn-down lozenge used to sharpen blades."
	icon = 'icons/obj/items/striker.dmi' // TODO unique icon?
	w_class = ITEM_SIZE_TINY
	material_alteration = MAT_FLAG_ALTERATION_ALL
	material = /decl/material/solid/quartz

/obj/item/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, /obj/item/whetstone))
		return try_sharpen_with(user, used_item)
	return ..()

/decl/loadout_option/utility/whetstone
	name = "whetstone"
	path = /obj/item/whetstone
	loadout_flags = null
	uid = "gear_utility_whetstone"
