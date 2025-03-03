#define SPECIES_UNATHI "Unathi"
#define LANGUAGE_UNATHI "Sinta'unathi"

/decl/modpack/unathi
	name = "Unathi Species"
	tabloid_headlines = list(
		"SHOCKING FIGURES REVEAL MORE TEENS DIE TO UNATHI HONOUR DUELS THAN GUN VIOLENCE",
		"LOCAL UNATHI SYMPATHIZER: 'I really think you should stop with these spacebaiting articles.'",
		"DO UNATHI SYMPATHIZERS HATE THE HUMAN RACE?"
	)

/decl/modpack/unathi/pre_initialize()
	..()
	SSmodpacks.default_submap_whitelisted_species |= SPECIES_UNATHI

/mob/living/human/unathi/Initialize(mapload, species_name, datum/mob_snapshot/supplied_appearance)
	species_name = SPECIES_UNATHI
	. = ..()
