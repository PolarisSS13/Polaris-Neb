#define SPECIES_TAJARA  "Tajara"
#define LANGUAGE_TAJARA "Siik"
#define LANGUAGE_AKHANI "Akhani"
#define BODYTYPE_TAJARA "felinoid body"

/decl/modpack/tajaran
	name = "Tajaran Species"
	tabloid_headlines = list(
		"TAJARAS: CUTE AND CUDDLY, OR INFILTRATING THE GOVERNMENT? FIND OUT MORE INSIDE"
	)

/decl/modpack/tajaran/pre_initialize()
	..()
	SSmodpacks.default_submap_whitelisted_species |= SPECIES_TAJARA

/mob/living/human/tajaran/Initialize(mapload, species_name, datum/mob_snapshot/supplied_appearance)
	. = ..(species_name = SPECIES_TAJARA)

/obj/item
	var/_tajaran_onmob_icon

/obj/item/setup_sprite_sheets()
	. = ..()
	if(_tajaran_onmob_icon)
		LAZYSET(sprite_sheets, BODYTYPE_TAJARA, _tajaran_onmob_icon)
