/decl/modpack/vatborn
	name = "Vatborn"

/decl/modpack/vatborn/pre_initialize()
	..()
	SSmodpacks.default_submap_whitelisted_species |= SPECIES_VATBORN

/mob/living/human/vatborn/Initialize(mapload, species_name, datum/mob_snapshot/supplied_appearance)
	species_name = SPECIES_VATBORN
	. = ..()
