#define isslime(X) istype(X, /mob/living/slime)
#define SPECIES_GOLEM "Golem"

/decl/modpack/xenobiology
	name = "Xenobiology"

/decl/modpack/xenobiology/initialize()
	. = ..()
	SSmodpacks.default_submap_blacklisted_species += SPECIES_GOLEM
