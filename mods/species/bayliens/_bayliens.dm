#define SPECIES_SKRELL    "Skrell"
#define SPECIES_TAJARA    "Tajara"
#define SPECIES_LIZARD    "Unathi"
#define SPECIES_ADHERENT  "Adherent"

#define BODYTYPE_FELINE   "feline body"
#define BODYTYPE_ADHERENT "adherent body"

#define BODY_EQUIP_FLAG_FELINE BITFLAG(7)

/decl/modpack/bayliens
	name = "Baystation 12 Aliens"

/decl/modpack/bayliens/pre_initialize()
	..()
	SSmodpacks.default_submap_whitelisted_species |= SPECIES_TAJARA
	SSmodpacks.default_submap_whitelisted_species |= SPECIES_LIZARD
	SSmodpacks.default_submap_whitelisted_species |= SPECIES_SKRELL
	SSmodpacks.default_submap_whitelisted_species |= SPECIES_ADHERENT

/mob/living/human/Process_Spacemove(allow_movement)
	. = ..()
	if(.)
		return
	// This is horrible but short of spawning a jetpack inside the organ than locating
	// it, I don't really see another viable approach short of a total jetpack refactor.
	for(var/obj/item/organ/internal/powered/jets/jet in get_internal_organs())
		if(!jet.is_broken() && jet.active)
			// Unlike Bay, we don't check or unset inertia_dir here
			// because the spacedrift subsystem checks the return value of this proc
			// and unsets inertia_dir if it returns nonzero.
			return 1
