#define LANGUAGE_ADHERENT "Protocol"
#define BP_FLOAT        "floatation disc"
#define BP_JETS         "maneuvering jets"
#define BP_COOLING_FINS "cooling fins"

#define SPECIES_ADHERENT  "Adherent"
#define BODYTYPE_ADHERENT "adherent body"

/decl/modpack/adherent
	name = "Adherent Species"

/decl/modpack/adherent/pre_initialize()
	..()
	SSmodpacks.default_submap_whitelisted_species |= SPECIES_ADHERENT

/mob/living/human/adherent/Initialize(mapload, species_name, datum/mob_snapshot/supplied_appearance)
	species_name = SPECIES_ADHERENT
	. = ..()
