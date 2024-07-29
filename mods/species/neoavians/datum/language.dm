
/decl/language/neoavian
	name = "Schechi"
	desc = "A trilling language spoken by the diminutive Teshari."
	speech_verb = "chirps"
	ask_verb = "chirrups"
	exclaim_verb = "trills"
	colour = "alien"
	key = "v"
	flags = LANG_FLAG_WHITELISTED
	space_chance = 50
	partial_understanding = list(/decl/language/human/common = 5, /decl/language/skrell = 15)
	syllables = list(
			"ca", "ra", "ma", "sa", "na", "ta", "la", "sha", "scha", "a", "a",
			"ce", "re", "me", "se", "ne", "te", "le", "she", "sche", "e", "e",
			"ci", "ri", "mi", "si", "ni", "ti", "li", "shi", "schi", "i", "i"
		)

/decl/language/neoavian/get_random_name(gender)
	return ..(gender, 2, 4, 1.5)

/decl/cultural_info/citizenship/teshari
	name = "Pack Teshari"
	description = "Most Teshari follow the unique cultural traditions of their specific pack, which vary as widely as any other species' \
	idea of nations. Pack Teshari tend to be highly social, curious, and open people, with little concept of privacy and a high tendency \
	towards sharing and mutual aid. Many packs remain mostly on Sirisai, with those venturing into human space doing so via Skrellian \
	sponsorship programmes, though others exist wholly outside of the homeworld."
	language = /decl/language/neoavian
	secondary_langs = list(
		/decl/language/neoavian,
		/decl/language/sign
	)
