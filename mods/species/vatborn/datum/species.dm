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


	description = "With cloning on the forefront of human scientific advancement, cheap mass production \
	of bodies is a very real and rather ethically grey industry. Vat-grown or Vatborn humans tend to be \
	paler than baseline, with no appendix and fewer inherited genetic disabilities, but a more aggressive metabolism. \
	Most vatborn are engineered to experience rapid maturation, reaching approximately sixteen years of growth in only five \
	before slowing to normal growth rates."

	preview_outfit = /decl/outfit/job/generic/assistant

	toxins_mod = 1.1
	metabolism_mod = 1.15



/decl/species/vatborn/Initialize()
	default_bodytype = /decl/bodytype/human/vatborn //runtime prevention
	. = ..()
	LAZYINITLIST(available_background_info)

/decl/species/vatborn/check_background()
	return TRUE
