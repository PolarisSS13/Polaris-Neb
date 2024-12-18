/obj/item/clothing/gloves/ring/aura_ring
	icon                = 'icons/clothing/accessories/jewelry/rings/ring_band_thick.dmi'
	can_inscribe        = FALSE
	material            = /decl/material/solid/metal/silver
	abstract_type       = /obj/item/clothing/gloves/ring/aura_ring
	material_alteration = MAT_FLAG_ALTERATION_COLOR
	var/obj/aura/granted_aura

/obj/item/clothing/gloves/ring/aura_ring/update_name()
	return

/obj/item/clothing/gloves/ring/aura_ring/Initialize()
	if(ispath(granted_aura))
		granted_aura = new granted_aura
	. = ..()

/obj/item/clothing/gloves/ring/aura_ring/Destroy()
	QDEL_NULL(granted_aura)
	. = ..()

/obj/item/clothing/gloves/ring/aura_ring/equipped(var/mob/living/L, var/slot)
	..()
	if(istype(granted_aura) && slot == slot_gloves_str)
		L.add_aura(granted_aura)

/obj/item/clothing/gloves/ring/aura_ring/dropped(var/mob/living/L)
	..()
	if(istype(granted_aura))
		L.remove_aura(granted_aura)
