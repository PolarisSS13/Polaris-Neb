#define LANGUAGE_TAJARA "Siik'maas"

/obj/item/clothing/setup_equip_flags()
	. = ..()
	if(bodytype_equip_flags & BODY_EQUIP_FLAG_EXCLUDE)
		bodytype_equip_flags |= BODY_EQUIP_FLAG_FELINE

/mob/living/human/tajaran/Initialize(mapload, species_name, datum/mob_snapshot/supplied_appearance)
	. = ..(species_name = SPECIES_TAJARA)
