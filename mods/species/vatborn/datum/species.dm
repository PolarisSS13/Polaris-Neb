/datum/appearance_descriptor/age/vatborn
	name = "age"
	chargen_max_index = 9

	standalone_value_descriptors = list( //vatborns grow quickly and die young
		"an infant" =      1,
		"a toddler" =      2,
		"a child" =        3,
		"a teenager" =    4,
		"a young adult" = 6,
		"an adult" =      20,
		"middle-aged" =   35,
		"aging" =         50,
		"elderly" =       70,
		"ancient" =      91
	)


/decl/species/human/vatborn
	name = SPECIES_VATBORN
	name_plural = SPECIES_VATBORN

	available_bodytypes = list(
		/decl/bodytype/human/vatborn,
		/decl/bodytype/human/vatborn/masculine,
		/decl/bodytype/prosthetic/basic_human
		)


	description = "A genetically modified type of human, Vatborn humans are cloned from a template and grown in special tubes. They look like pale \
	but otherwise normal humans, but their bodies have a few internal changes. For one, they lack an appendix. On top of that, they are frequently \
	hungry, as their metabolisms are faster than standard."

	preview_outfit = /decl/outfit/job/generic/assistant


	toxins_mod = 1.1
	metabolism_mod = 1.15



/decl/species/vatborn/Initialize()
	. = ..()
	LAZYINITLIST(available_background_info)

/decl/species/vatborn/check_background()
	return TRUE
