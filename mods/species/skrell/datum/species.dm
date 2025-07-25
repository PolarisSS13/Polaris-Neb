/decl/butchery_data/humanoid/skrell
	meat_name = "calamari"
	meat_type = /obj/item/food/butchery/meat/fish/octopus/skrell
	bone_material = /decl/material/solid/organic/bone/cartilage

/decl/species/skrell
	uid = "species_skrell"
	name = "Skrell"
	name_plural = "Skrell"

	available_bodytypes = list(
		/decl/bodytype/skrell
		)

	traits = list(/decl/trait/malus/intolerance/protein = TRAIT_LEVEL_MINOR)

	primitive_form = "Neaera"

	description = "The skrell are a highly advanced species of amphibians hailing from \
	the system known as Qerr'Vallis, which translates to 'Star of the royals' or 'Light of the Crown'. \
	Their society is regimented into five castes which the Qerr'Katish, or High-caste, rules over. \
	Skrell are strict herbivores who are unable to eat large quantities of animal protein \
	without feeling sick or even suffering from food poisoning. <br/><br/> \
	While skrell place high value on cooperation, diplomacy and scientific pursuit, \
	they tend to be very leery of outside interference in their customs and values, \
	and are highly secretive regarding internal matters of state."


	butchery_data = /decl/butchery_data/humanoid/skrell

	available_pronouns = list(
		/decl/pronouns/skrell
	)
	hidden_from_codex = FALSE

	preview_outfit = /decl/outfit/job/generic/scientist

	burn_mod = 0.9
	oxy_mod = 1.3
	toxins_mod = 0.8
	shock_vulnerability = 1.3
	warning_low_pressure = WARNING_LOW_PRESSURE * 1.4
	hazard_low_pressure = HAZARD_LOW_PRESSURE * 2
	warning_high_pressure = WARNING_HIGH_PRESSURE / 0.8125
	hazard_high_pressure = HAZARD_HIGH_PRESSURE / 0.84615
	water_soothe_amount = 5

	body_temperature = null // cold-blooded, implemented the same way nabbers do it

	spawn_flags = SPECIES_CAN_JOIN

	flesh_color = "#8cd7a3"
	organs_icon = 'mods/species/skrell/icons/body/organs.dmi'

	blood_types = list(
		/decl/blood_type/skrell/yplus,
		/decl/blood_type/skrell/yminus,
		/decl/blood_type/skrell/zplus,
		/decl/blood_type/skrell/zminus,
		/decl/blood_type/skrell/yzplus,
		/decl/blood_type/skrell/yzminus,
		/decl/blood_type/skrell/noplus,
		/decl/blood_type/skrell/nominus
	)

	available_background_info = list(
		/decl/background_category/citizenship = list(
			/decl/background_detail/citizenship/other
		),
		/decl/background_category/heritage = list(
			/decl/background_detail/heritage/skrell,
			/decl/background_detail/heritage/skrell/caste_malish,
			/decl/background_detail/heritage/skrell/caste_kanin,
			/decl/background_detail/heritage/skrell/caste_talum,
			/decl/background_detail/heritage/skrell/caste_raskinta,
			/decl/background_detail/heritage/skrell/caste_ue
		),
		/decl/background_category/homeworld = list(
			/decl/background_detail/location/free,
			/decl/background_detail/location/skrellspace,
			/decl/background_detail/location/other
		),
		/decl/background_category/faction = list(
			/decl/background_detail/faction/skrell,
			/decl/background_detail/faction/other
		),
		/decl/background_category/religion = list(
			/decl/background_detail/religion/skrell,
			/decl/background_detail/religion/other
		)
	)

	exertion_effect_chance = 10
	exertion_hydration_scale = 1
	exertion_charge_scale = 1
	exertion_reagent_scale = 5
	exertion_reagent_path = /decl/material/liquid/lactate
	exertion_emotes_biological = list(
		/decl/emote/exertion/biological/breath
	)
	exertion_emotes_synthetic = list(
		/decl/emote/exertion/synthetic,
		/decl/emote/exertion/synthetic/creak
	)

/decl/species/skrell/fluid_act(var/mob/living/human/H, var/datum/reagents/fluids)
	. = ..()
	var/water = REAGENT_VOLUME(fluids, /decl/material/liquid/water)
	if(water >= 40 && H.hydration < 400) //skrell passively absorb water.
		H.hydration += 1

/decl/species/skrell/handle_trail(mob/living/human/H, turf/T, old_loc)
	var/obj/item/shoes = H.get_equipped_item(slot_shoes_str)
	if(!shoes)
		var/list/bloodDNA
		var/list/blood_data = REAGENT_DATA(H.vessel, blood_reagent)
		if(blood_data)
			bloodDNA = list(blood_data[DATA_BLOOD_DNA] = blood_data[DATA_BLOOD_TYPE])
		else
			bloodDNA = list()
		T.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints/skrellprints, bloodDNA, H.dir, 0, H.get_skin_colour() + "25") // Coming (25 is the alpha value)
		if(isturf(old_loc))
			var/turf/old_turf = old_loc
			old_turf.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints/skrellprints, bloodDNA, 0, H.dir, H.get_skin_colour() + "25") // Going (25 is the alpha value)

/decl/species/skrell/check_background()
	return TRUE

/decl/material/liquid/mucus/skrell
	name = "slime"
	uid = "chem_mucus_skrell"
	lore_text = "A gooey semi-liquid secreted by skrellian skin."

// Copied from blood.
// TODO: There's not currently a way to check this, which might be a little annoying for forensics.
// But this is just a stopgap to stop Skrell from literally leaking blood everywhere they go.
/decl/material/liquid/mucus/skrell/get_reagent_color(datum/reagents/holder)
	var/list/goo_data = REAGENT_DATA(holder, src)
	return goo_data?[DATA_BLOOD_COLOR] || ..()

/obj/effect/decal/cleanable/blood/tracks/footprints/skrellprints
	name = "wet footprints"
	desc = "They look like still wet tracks left by skrellian feet."
	chemical = /decl/material/liquid/mucus/skrell

/obj/item/organ/internal/eyes/skrell
	name = "amphibian eyes"
	desc = "Large black orbs, belonging to some sort of giant frog by looks of it."
	icon = 'mods/species/skrell/icons/body/organs.dmi'

/decl/species/skrell/Initialize()
	. = ..()
	LAZYINITLIST(available_background_info)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/citizenship], /decl/background_detail/citizenship/skrell)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/heritage], /decl/background_detail/heritage/skrell/caste_malish)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/heritage], /decl/background_detail/heritage/skrell/caste_kanin)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/heritage], /decl/background_detail/heritage/skrell/caste_talum)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/heritage], /decl/background_detail/heritage/skrell/caste_raskinta)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/heritage], /decl/background_detail/heritage/skrell/caste_ue)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/faction], /decl/background_detail/faction/skrell)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/faction], /decl/background_detail/faction/skrell_pirate)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/faction], /decl/background_detail/faction/skrell_qerrglia)
	LAZYDISTINCTADD(available_background_info[/decl/background_category/religion], /decl/background_detail/religion/skrell)
	LAZYSET(default_background_info, /decl/background_category/citizenship, /decl/background_detail/citizenship/skrell)
	LAZYSET(default_background_info, /decl/background_category/heritage, /decl/background_detail/heritage/skrell/caste_malish)
	LAZYSET(default_background_info, /decl/background_category/religion, /decl/background_detail/religion/skrell)

