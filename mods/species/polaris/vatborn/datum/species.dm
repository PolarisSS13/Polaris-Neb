/datum/species/human/vatborn
	name = SPECIES_HUMAN_VATBORN
	name_plural = "Vatborn"
	description = "With cloning on the forefront of human scientific advancement, cheap mass production \
	of bodies is a very real and rather ethically grey industry. Vat-grown or Vatborn humans tend to be \
	paler than baseline, with no appendix and fewer inherited genetic disabilities, but a more aggressive metabolism. \
	Most vatborn are engineered to experience rapid maturation, reaching approximately sixteen years of growth in only five \
	before slowing to normal growth rates."

	min_age = 6  /// Accounting for rapid growth.
	max_age = 90

	toxins_mod =   1.1
	metabolic_rate = 1.15
	has_organ = list(
		O_HEART =    /obj/item/organ/internal/heart,
		O_LUNGS =    /obj/item/organ/internal/lungs,
		O_VOICE =    /obj/item/organ/internal/voicebox,
		O_LIVER =    /obj/item/organ/internal/liver,
		O_KIDNEYS =  /obj/item/organ/internal/kidneys,
		O_SPLEEN =   /obj/item/organ/internal/spleen/minor,
		O_BRAIN =    /obj/item/organ/internal/brain,
		O_EYES =     /obj/item/organ/internal/eyes,
		O_STOMACH =	 /obj/item/organ/internal/stomach,
		O_INTESTINE =/obj/item/organ/internal/intestine
		)

	available_bodytypes = list(
		/decl/bodytype/human/vatborn
		)

/datum/appearance_descriptor/age/vatborn
	name = "age"
	standalone_value_descriptors = list(
		"an infant" =      1,
		"a toddler" =      2,
		"a child" =       4,
		"a teenager" =    8,
		"a young adult" = 28,
		"an adult" =      45,
		"middle-aged" =   65,
		"aging" =         90,
		"elderly" =      110
	)

/decl/bodytype/human/vatborn
	name                  = "feminine"
	bodytype_category     = BODYTYPE_HUMANOID
	icon_base             = 'mods/species/polaris/vatborn/icons/body_female.dmi'
	icon_deformed         = 'mods/species/polaris/vatborn/icons/body_female_deformed.dmi'
	limb_icon_intensity   = 0.7
	associated_gender     = FEMALE
	onmob_state_modifiers = list(slot_w_uniform_str = "f")
	appearance_flags      = HAS_SKIN_TONE_NORMAL | HAS_UNDERWEAR | HAS_EYE_COLOR
	nail_noun             = "nails"
	uid                   = "bodytype_vatborn_fem"
	age_descriptor = /datum/appearance_descriptor/age/vatborn

/decl/bodytype/human/vatborn/masculine
	name                  = "masculine"
	icon_base             = 'mods/species/polaris/vatborn/icons/body_male.dmi'
	icon_deformed         = 'mods/species/polaris/vatborn/icons/body_male_deformed.dmi'
	associated_gender     = MALE
	uid                   = "bodytype_vatborn_masc"
	override_emote_sounds = list(
		"cough" = list(
			'sound/voice/emotes/m_cougha.ogg',
			'sound/voice/emotes/m_coughb.ogg',
			'sound/voice/emotes/m_coughc.ogg'
		),
		"sneeze" = list(
			'sound/voice/emotes/m_sneeze.ogg'
		)
	)
