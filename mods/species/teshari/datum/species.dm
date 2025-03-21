/datum/appearance_descriptor/age/teshari
	chargen_min_index = 3
	chargen_max_index = 6
	standalone_value_descriptors = list(
		"a hatchling" =     1,
		"an fledgeling" =   6,
		"a young adult" =  12,
		"an adult" =       25,
		"middle-aged" =    35,
		"aging" =          45,
		"elderly" =        50
	)

/decl/butchery_data/humanoid/teshari
	meat_name = "chicken"
	meat_type = /obj/item/food/butchery/meat/chicken

/decl/species/teshari
	name        = "Teshari"
	name_plural = "Teshari"
	description = "A race of feathered raptors who developed alongside the Skrell, \
	inhabiting the polar tundral regions outside of Skrell territory. \
	Extremely fragile, they developed hunting skills that emphasized \
	taking out their prey without themselves getting hit. \
	They are only recently becoming known on human stations \
	after reaching space with Skrell assistance."
	base_external_prosthetics_model = null
	uid = "species_teshari"

	snow_slowdown_mod = -1

	holder_icon = 'mods/species/teshari/icons/holder.dmi'

	butchery_data = /decl/butchery_data/humanoid/teshari

	preview_outfit = /decl/outfit/job/generic/assistant/teshari

	available_bodytypes = list(
		/decl/bodytype/teshari,
		/decl/bodytype/teshari/additive
	)

	total_health = 120
	holder_type = /obj/item/holder
	gluttonous = GLUT_TINY
	blood_volume = 320
	hunger_factor = DEFAULT_HUNGER_FACTOR * 1.6
	thirst_factor = DEFAULT_THIRST_FACTOR * 1.6

	spawn_flags = SPECIES_CAN_JOIN
	bump_flag = MONKEY
	swap_flags = MONKEY|SIMPLE_ANIMAL
	push_flags = MONKEY|SIMPLE_ANIMAL

	blood_types = list(
		/decl/blood_type/teshari/taplus,
		/decl/blood_type/teshari/taminus,
		/decl/blood_type/teshari/tbplus,
		/decl/blood_type/teshari/tbminus,
		/decl/blood_type/teshari/tatbplus,
		/decl/blood_type/teshari/tatbminus,
		/decl/blood_type/teshari/oplus,
		/decl/blood_type/teshari/ominus,
	)

/decl/species/teshari/Initialize()
	. = ..()
	LAZYINITLIST(available_background_info)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/heritage], /decl/background_detail/heritage/teshari)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/heritage], /decl/background_detail/heritage/teshari/kamerr)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/heritage], /decl/background_detail/heritage/teshari/autonomist)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/heritage], /decl/background_detail/heritage/teshari/sif)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/heritage], /decl/background_detail/heritage/teshari/spacer)
	LAZYSET(default_background_info, /decl/background_category/heritage, /decl/background_detail/heritage/teshari)

/decl/species/teshari/equip_default_fallback_uniform(var/mob/living/human/H)
	if(istype(H))
		H.equip_to_slot_or_del(new /obj/item/clothing/dress/teshari_smock/worker, slot_w_uniform_str)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/teshari, slot_shoes_str)

/decl/species/teshari/get_holder_color(var/mob/living/human/H)
	return H.get_skin_colour()

/decl/outfit/job/generic/assistant/teshari
	name = "Job - Teshari Assistant"
	uniform = /obj/item/clothing/dress/teshari_smock/worker
	shoes = /obj/item/clothing/shoes/teshari/footwraps
