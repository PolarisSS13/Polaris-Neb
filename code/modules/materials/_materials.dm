var/global/list/_descriptive_temperature_strings
/proc/get_descriptive_temperature_strings(temperature as num)
	if(!_descriptive_temperature_strings)
		_descriptive_temperature_strings = list()

		for(var/decl/material/material as anything in decls_repository.get_decls_of_subtype_unassociated(/decl/material))

			if(material.type != material.temperature_burn_milestone_material)
				continue

			if(!isnull(material.bakes_into_at_temperature) && material.bakes_into_material)
				var/decl/material/cook = GET_DECL(material.bakes_into_material)
				global._descriptive_temperature_strings["bake [material.name] into [cook.name]"] = material.bakes_into_at_temperature
				continue

			switch(material.phase_at_temperature())
				if(MAT_PHASE_SOLID)
					if(!isnull(material.ignition_point))
						global._descriptive_temperature_strings["ignite [material.name]"] = material.ignition_point
					else if(!isnull(material.melting_point))
						global._descriptive_temperature_strings["melt [material.name]"] = material.melting_point
				if(MAT_PHASE_LIQUID)
					if(!isnull(material.boiling_point))
						global._descriptive_temperature_strings["boil [material.name]"] = material.boiling_point

	for(var/burn_string in global._descriptive_temperature_strings)
		if(temperature >= global._descriptive_temperature_strings[burn_string])
			LAZYADD(., burn_string)

var/global/list/materials_by_gas_symbol = list()

/obj/effect/gas_overlay
	name = "gas"
	desc = "You shouldn't be clicking this."
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "generic"
	layer = FIRE_LAYER
	appearance_flags = RESET_COLOR
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	var/decl/material/material

INITIALIZE_IMMEDIATE(/obj/effect/gas_overlay)

/obj/effect/gas_overlay/proc/update_alpha_animation(var/new_alpha as num)
	animate(src, alpha = new_alpha)
	alpha = new_alpha
	animate(src, alpha = 0.8 * new_alpha, time = 10, easing = SINE_EASING | EASE_OUT, loop = -1)
	animate(alpha = new_alpha, time = 10, easing = SINE_EASING | EASE_IN, loop = -1)

/obj/effect/gas_overlay/Initialize(mapload, gas)
	. = ..()
	material = GET_DECL(gas)
	if(!istype(material))
		return INITIALIZE_HINT_QDEL
	if(material.gas_tile_overlay)
		icon_state = material.gas_tile_overlay
	color = material.color

/*
	MATERIAL DATUMS
	This data is used by various parts of the game for basic physical properties and behaviors
	of the metals/materials used for constructing many objects. Each var is commented and should be pretty
	self-explanatory but the various object types may have their own documentation.

	PATHS THAT USE DATUMS
		turf/wall
		obj/item
		obj/structure/barricade
		obj/structure/table

	VALID ICONS
		WALLS
			stone
			metal
			solid
			cult
		DOORS
			stone
			metal
			plastic
			wood
*/

// Material definition and procs follow.
/decl/material

	abstract_type = /decl/material
	decl_flags = DECL_FLAG_MANDATORY_UID

	var/name               // Prettier name for display.
	var/codex_name         // Override for the codex article name.
	var/adjective_name
	var/solid_name
	var/gas_name
	var/liquid_name
	var/solution_name      // Name for the material in solution.
	var/use_name
	var/wall_name = "wall" // Name given to walls of this material
	var/flags = 0          // Various status modifiers.
	var/hidden_from_codex
	var/lore_text
	var/mechanics_text
	var/antag_text
	var/default_solid_form = /obj/item/stack/material/sheet

	var/soup_hot_desc = "simmering"

	var/affect_blood_on_ingest = 0.5
	var/affect_blood_on_inhale = 0.75

	var/narcosis = 0 // Not a great word for it. Constant for causing mild confusion when ingested.
	var/toxicity = 0 // Organ damage from ingestion.
	var/toxicity_targets_organ // Bypass liver/kidneys when ingested, harm this organ directly (using BP_FOO defines).

	var/can_backfill_floor_type

	// Shards/tables/structures
	var/shard_type = /obj/item/shard
	var/shard_name = SHARD_SHRAPNEL as text // Path of debris object.
	var/shard_icon                        // Related to above.
	var/shard_can_repair = 1              // Can shards be turned into sheets with a welder?
	var/destruction_desc = "breaks apart" // Fancy string for barricades/tables/objects exploding.
	var/destruction_sound = "fracture"     // As above, but the sound that plays.

	// Icons
	var/icon_base = 'icons/turf/walls/solid.dmi'
	var/icon_base_natural = 'icons/turf/walls/natural.dmi'
	/// Either the icon used for reinforcement, or a list of icons to pick from.
	var/icon_reinf = 'icons/turf/walls/reinforced_metal.dmi'
	var/wall_flags = 0
	var/list/wall_blend_icons = list() // Which wall icon types walls of this material type will consider blending with. Assoc list (icon path = TRUE/FALSE)
	var/use_reinf_state = "full"

	var/door_icon_base = "metal"                         // Door base icon tag. See header.
	var/table_icon_base = "metal"
	var/table_icon_reinforced = "reinf_metal"

	// TODO: Refactor these to just apply a generic material overlay (e.g. wood grain) instead of entirely-separate icon files?
	// Alternatively, find some other way for icon variation based on material.
	// You can't do it by having separate states in the base icons,
	// because then modpacked materials can't add new states,
	// and what if we really really want a special nullglass pew sprite or something?
	var/bench_icon = 'icons/obj/structures/furniture/bench.dmi'
	var/pew_icon = 'icons/obj/structures/furniture/pew.dmi'
	var/slatted_seat_icon = 'icons/obj/structures/furniture/chair_slatted.dmi'
	var/backed_chair_icon = 'icons/obj/structures/furniture/chair_backed.dmi'

	var/list/stack_origin_tech = @'{"materials":1}' // Research level for stacks.

	// Attributes
	/// Does this material float to the top of liquids, allowing it to be skimmed off? Specific to cream at time of writing.
	var/skimmable = FALSE
	/// How rare is this material in exoplanet xenoflora?
	var/exoplanet_rarity_plant = MAT_RARITY_MUNDANE
	/// How rare is this material in exoplanet atmospheres?
	var/exoplanet_rarity_gas = MAT_RARITY_MUNDANE
	/// Delay in ticks when cutting through this wall.
	var/cut_delay = 0
	/// Radiation var. Used in wall and object processing to irradiate surroundings.
	var/radioactivity
	/// K, point at which the material catches on fire.
	var/ignition_point
	/// K, walls will take damage if they're next to a fire hotter than this
	var/melting_point = 1800
	/// K, point that material will become a gas.
	var/boiling_point = 3000
	/// Set automatically if null based on ignition, boiling and melting point
	var/temperature_damage_threshold
	/// kJ/kg, enthalpy of vaporization
	var/latent_heat = 7000
	/// kg/mol
	var/molar_mass = 0.06
	/// g/ml
	var/liquid_density = 0.997
	/// g/ml
	var/solid_density = 0.9168
	/// Brute damage to a wall is divided by this value if the wall is reinforced by this material.
	var/brute_armor = 2
	/// Same as above, but for Burn damage type. If blank brute_armor's value is used.
	var/burn_armor
	/// General-use HP value for products.
	var/integrity = 150
	/// Is the material transparent? 0.5< makes transparent walls/doors.
	var/opacity = 1.0
	/// Only used by walls currently.
	var/explosion_resistance = 5
	/// Objects with this var add CONDUCTS to flags on spawn.
	var/conductive = 1
	/// Does this material glow?
	var/luminescence
	/// Used for checking if a material can function as a wall support.
	var/wall_support_value = 30
	/// Ore generation constant for rare materials.
	var/sparse_material_weight
	/// Ore generation constant for common materials.
	var/rich_material_weight
	/// How transparent can fluids be?
	var/min_fluid_opacity = FLUID_MIN_ALPHA
	/// How opaque can fluids be?
	var/max_fluid_opacity = FLUID_MAX_ALPHA
	/// Point at which the fluid will proc turf interaction logic. Workaround for mops being ruined forever by 1u of anything else being added.
	var/turf_touch_threshold = FLUID_QDEL_POINT
	/// Whether or not billets of this material will glow with heat.
	var/glows_with_heat = FALSE

	// Damage values.
	var/hardness = MAT_VALUE_HARD       // Used for edge damage in weapons.
	var/weight = MAT_VALUE_NORMAL       // Determines blunt damage/throw force for weapons.
	var/reflectiveness = MAT_VALUE_DULL // How effective is this at reflecting light?
	var/ferrous = FALSE                 // Can be used as a striker for firemaking.

	// Noise when someone is faceplanted onto a table made of this material.
	var/tableslam_noise = 'sound/weapons/tablehit1.ogg'
	// Noise made when a simple door made of this material opens or closes.
	var/dooropen_noise = 'sound/effects/stonedoor_openclose.ogg'
	// Noise made when you hit structure made of this material.
	var/hitsound = 'sound/weapons/genhit.ogg'
	// Wallrot crumble message.
	var/rotting_touch_message = "crumbles under your touch"
	/// When a stack recipe doesn't specify a skill to use, use this skill.
	var/crafting_skill = SKILL_CONSTRUCTION
	// Modifies skill checks when constructing with this material.
	var/construction_difficulty = MAT_VALUE_EASY_DIY
	// Determines what is used to remove or dismantle this material.
	var/removed_by_welder

	// Mining behavior.
	var/ore_name
	var/ore_desc
	var/ore_compresses_to
	var/ore_result_amount
	var/ore_spread_chance
	var/ore_scan_icon
	var/ore_icon_overlay
	var/ore_type_value
	var/ore_data_value
	var/ore_type = /obj/item/stack/material/ore

	var/value = 1

	// Xenoarch behavior.
	var/xarch_source_mineral = /decl/material/solid/metal/iron

	// Gas behavior.
	var/gas_overlay_limit
	var/gas_specific_heat = 20    // J/(mol*K)
	var/gas_symbol_html
	var/gas_symbol
	var/gas_flags = 0
	var/gas_tile_overlay = "generic"
	var/gas_condensation_point = null
	var/gas_metabolically_inert = FALSE // If false, material will move into the bloodstream when breathed.
	// Armor values generated from properties
	var/list/basic_armor
	var/armor_degradation_speed

	// Allergen values, used by /mob/living and /datum/reagents
	/// What allergens are present on this material?
	var/allergen_flags  = ALLERGEN_NONE
	var/allergen_factor = 2

	// Copied reagent values. Todo: integrate.
	var/taste_description
	var/taste_mult = 1 //how this taste compares to others. Higher values means it is more noticable
	var/metabolism = REM // This would be 0.2 normally
	var/ingest_met = 0
	var/touch_met = 0
	var/inhale_met = 0
	var/overdose = 0
	var/scannable = 0 // Shows up on health analyzers.
	var/color = COLOR_BEIGE
	// How much variance in color do objects of this material have, in fraction of maximum brightness/hue.
	var/color_variance = 0.04
	var/color_weight = 1
	var/cocktail_ingredient
	var/defoliant
	var/fruit_descriptor // String added to fruit desc if this chemical is present.
	/// Does this reagent have an antibiotic effect (helping with infections)?
	var/antibiotic_strength = 0

	var/dirtiness = DIRTINESS_NEUTRAL // How dirty turfs are after being exposed to this material. Negative values cause a cleaning/sterilizing effect.
	var/decontamination_dose = 0      // Amount required for a decontamination effect, if any.
	var/solvent_power = MAT_SOLVENT_NONE
	var/solvent_melt_dose = 0
	var/solvent_max_damage  = 0
	var/slipperiness = 0
	var/slippery_amount = 1
	var/euphoriant // If set, ingesting/injecting this material will cause the rainbow high overlay/behavior.

	var/glass_icon = DRINK_ICON_DEFAULT
	var/glass_name = "something"
	var/glass_desc = "It's a glass of... what, exactly?"
	var/list/glass_special = null // null equivalent to list()

	// Matter state data.
	var/dissolve_message = "dissolves in"
	var/dissolve_sound = 'sound/effects/bubbles.ogg'
	var/dissolves_in = MAT_SOLVENT_STRONG
	var/list/dissolves_into	// Used with the grinder and a solvent to extract other materials.

	var/chilling_point
	var/chilling_message = "crackles and freezes!"
	var/chilling_sound = 'sound/effects/bubbles.ogg'
	var/list/chilling_products

	var/heating_point
	var/heating_message = "begins to boil!"
	var/heating_sound = 'sound/effects/bubbles.ogg'
	var/list/heating_products
	var/accelerant_value = FUEL_VALUE_NONE
	var/burn_temperature = 100 CELSIUS
	var/burn_product
	var/list/vapor_products // If splashed, releases these gasses in these proportions. // TODO add to unit test after solvent PR is merged

	var/scent //refer to _scent.dm
	var/scent_intensity = /decl/scent_intensity/normal
	var/scent_descriptor = "smell"
	var/scent_range = 1

	var/list/neutron_interactions // Associative List of potential neutron interactions for the material to undergo, corresponding to the ideal
								  // neutron energy for that reaction to occur.

	var/neutron_cross_section	  // How broad the neutron interaction curve is, independent of temperature. Materials that are harder to react with will have lower values.
	var/absorption_products		  // Transmutes into these reagents following neutron absorption and/or subsequent beta decay. Generally forms heavier reagents.
	var/fission_products		  // Transmutes into these reagents following fission. Forms lighter reagents, and a lot of heat.
	var/neutron_production		  // How many neutrons are created per unit per fission event.
	var/neutron_absorption		  // How many neutrons are absorbed per unit per absorption event.
	var/fission_heat			  // How much thermal energy per unit per fission event this material releases.
	var/fission_energy			  // Energy of neutrons released by fission.
	var/moderation_target		  // The 'target' neutron energy value that the fission environment shifts towards after a moderation event.
								  // Neutron moderators can only slow down neutrons.

	var/sound_manipulate          //Default sound something like a material stack made of this material does when picked up
	var/sound_dropped             //Default sound something like a material stack made of this material does when hitting the ground or placed down

	var/holographic // Set to true if this material is fake/visual only.

	/// Does high temperature baking change this material into something else?
	var/bakes_into_material
	var/bakes_into_at_temperature

	/// If set to a material type, stacks of this material will be able to be tanned on a drying rack after being wetted to convert them to tans_to.
	var/tans_to
	/// A multiplier for this material when used in fishing bait.
	var/fishing_bait_value = 0
	/// A relative value used only by fishing line at time of commit.
	var/tensile_strength = 0

	/// What form does this take if dug out of the ground, if any?
	var/dug_drop_type

	/// Can objects containing this material be used for textile spinning?
	var/has_textile_fibers = FALSE

	/// Whether or not turfs made of this material can support plants.
	var/tillable = FALSE

	var/compost_value = 0

	/// Nutrition values!
	var/nutriment_factor     = 0 // Per removed amount each tick
	var/hydration_factor     = 0 // Per removed amount each tick
	var/injectable_nutrition = FALSE
	var/reagent_overlay
	var/reagent_overlay_base = "reagent_base"

	/// Set to a type to indicate that a type with a matching milestone type should be used as a reference point for burn temperatures.
	var/temperature_burn_milestone_material

	/// Semi-temporary fix to issues with soup/tea boil-off - only set to TRUE on water and ethanol at time of commit.
	var/can_boil_to_gas = FALSE
	/// How much of this boils away per evaporation run?
	var/boil_evaporation_per_run = 1

	/// What verb is used when describing a colored piece of this material? e.g. 'dyed' or 'painted'
	/// If an item has a null paint_verb, it automatically sets it based on material.
	var/paint_verb = "painted"

	/// What word is used to describe an item covered in/stained by this by default?
	/// Can be overridden by get_coated_adjective().
	var/coated_adjective = "stained"

	/// Chance of a natural wall made of this material dropping a gemstone, if the gemstone_types list is populated.
	var/gemstone_chance = 5
	/// Assoc weighted list of gemstone material types to weighting.
	var/list/gemstone_types

	var/forgable = FALSE // Can this material be forged in bar/billet form?

// Placeholders for light tiles and rglass.
/decl/material/proc/reinforce(var/mob/user, var/obj/item/stack/material/used_stack, var/obj/item/stack/material/target_stack, var/use_sheets = 1)
	if(!used_stack.can_use(use_sheets))
		to_chat(user, SPAN_WARNING("You need at least one [used_stack.singular_name] to reinforce [target_stack]."))
		return

	var/decl/material/reinf_mat = used_stack.get_material()
	if(reinf_mat.integrity <= integrity || reinf_mat.is_brittle())
		to_chat(user, SPAN_WARNING("The [reinf_mat.solid_name] is too structurally weak to reinforce \the [src]."))
		return

	if(!target_stack.can_use(use_sheets))
		to_chat(user, SPAN_WARNING("You need at least [use_sheets] [use_sheets == 1 ? target_stack.singular_name : target_stack.plural_name] for reinforcement with \the [used_stack]."))
		return

	to_chat(user, SPAN_NOTICE("You reinforce the [target_stack] with [reinf_mat.solid_name]."))
	used_stack.use(use_sheets)
	var/obj/item/stack/material/S = target_stack.split(1)
	S.reinf_material = reinf_mat
	S.update_strings()
	S.update_icon()
	if(!QDELETED(target_stack))
		S.dropInto(get_turf(target_stack))
	else if(user)
		S.dropInto(get_turf(user))
	else
		S.dropInto(get_turf(used_stack))
	S.add_to_stacks(user, TRUE)

// Make sure we have a use name and shard icon even if they aren't explicitly set.
/decl/material/Initialize()
	. = ..()
	if(!name)
		CRASH("Unnamed material /decl tried to initialize.")
	// Default use_name to name if unset.
	use_name       ||= name
	// Default the other state names to use_name, so that if it's overridden, we use that instead of base name.
	liquid_name    ||= use_name
	solid_name     ||= use_name
	gas_name       ||= use_name
	// Use solid_name for adjective_name so that we get "ice bracelet" instead of "water bracelet" for things made of water below 0C.
	adjective_name ||= solid_name
	adjective_name ||= use_name

	// Null/clear a bunch of physical vars as this material is fake.
	if(holographic)
		temperature_burn_milestone_material = null
		can_boil_to_gas              = FALSE
		shard_name                   = SHARD_NONE
		shard_type                   = null
		conductive                   = 0
		hidden_from_codex            = TRUE
		value                        = 0
		exoplanet_rarity_plant       = MAT_RARITY_NOWHERE
		exoplanet_rarity_gas         = MAT_RARITY_NOWHERE
		dissolves_into               = null
		dissolves_in                 = MAT_SOLVENT_IMMUNE
		solvent_power                = MAT_SOLVENT_NONE
		heating_products             = null
		chilling_products            = null
		heating_point                = null
		chilling_point               = null
		solvent_melt_dose            = 0
		solvent_max_damage           = 0
		slipperiness                 = 0
		bakes_into_at_temperature    = null
		ignition_point               = null
		melting_point                = null
		boiling_point                = null
		temperature_damage_threshold = INFINITY
		accelerant_value             = FUEL_VALUE_NONE
		burn_product                 = null
		vapor_products               = null
		compost_value                = 0
		forgable                     = FALSE
	else if(isnull(temperature_damage_threshold))
		var/new_temperature_damage_threshold = max(melting_point, boiling_point, heating_point)
		// Don't let the threshold be lower than the ignition point.
		if(isnull(new_temperature_damage_threshold) && !isnull(ignition_point))
			temperature_damage_threshold = ignition_point
		else if(isnull(ignition_point) || (new_temperature_damage_threshold > ignition_point))
			temperature_damage_threshold = new_temperature_damage_threshold

	if(!shard_icon)
		shard_icon = shard_name
	if(!burn_armor)
		burn_armor = brute_armor
	if(!gas_symbol)
		gas_symbol = "[name]_[sequential_id(abstract_type)]"
	if(!gas_symbol_html)
		gas_symbol_html = gas_symbol
	global.materials_by_gas_symbol[gas_symbol] = type
	generate_armor_values()

	if(!holographic)
		var/list/cocktails = decls_repository.get_decls_of_subtype(/decl/cocktail)
		for(var/ctype in cocktails)
			var/decl/cocktail/cocktail = cocktails[ctype]
			if(type in cocktail.ratios)
				cocktail_ingredient = TRUE
				break

/decl/material/validate()
	. = ..()

	if(!crafting_skill)
		. += "no construction skill set"
	else if(!isnull(construction_difficulty))
		var/decl/skill/used_skill = GET_DECL(crafting_skill)
		if(!istype(used_skill))
			. += "invalid skill decl [used_skill]"
		else if(length(used_skill.levels) < construction_difficulty)
			. += "required skill [used_skill] is missing skill level [json_encode(construction_difficulty)]"

	if(isnull(construction_difficulty))
		. += "no construction difficulty set"

	if(!isnull(bakes_into_at_temperature))
		// all of these variables should be above our baking temperature, because we assume only solids not currently on fire can bake
		// modify this if a material ever needs to bake while liquid or gaseous
		var/list/temperatures = list("melting point" = melting_point, "boiling point" = boiling_point, "heating point" = heating_point, "ignition point" = ignition_point)
		for(var/temperature in temperatures)
			if(isnull(temperatures[temperature]))
				continue
			if(temperatures[temperature] <= bakes_into_at_temperature)
				. += "baking point is set but [temperature] is lower or equal to it"

	// this is a little overengineered for only two values...
	// but requiring heating_point > boiling_point caused a bunch of issues
	// at least it's easy to add more if we want to enforce order more
	var/list/transition_temperatures_ascending = list("melting point" = melting_point, "boiling point" = boiling_point)
	var/max_key // if not null, this is a key from the above list
	for(var/temperature_key in transition_temperatures_ascending)
		var/temperature = transition_temperatures_ascending[temperature_key]
		if(isnull(temperature))
			continue
		if(!isnull(max_key) && temperature <= transition_temperatures_ascending[max_key])
			var/expected_temp = transition_temperatures_ascending[max_key]
			. += "transition temperature [temperature_key] ([temperature]K, [temperature - T0C]C) is colder than [max_key], expected >[expected_temp]K ([expected_temp - T0C]C)!"
		else
			max_key = temperature_key

	if(accelerant_value > FUEL_VALUE_NONE && isnull(ignition_point))
		. += "accelerant value larger than zero but null ignition point"
	if(!isnull(ignition_point) && accelerant_value <= FUEL_VALUE_NONE)
		. += "accelerant value below zero but non-null ignition point"
	if(length(dissolves_into) && isnull(dissolves_in))
		. += "dissolves_into set but dissolves_in is undefined"
	if(length(heating_products) && isnull(heating_point))
		. += "heating_products set but heating_point is undefined"
	if(length(chilling_products) && isnull(chilling_point))
		. += "chilling_products set but chilling_point is undefined"

	var/list/checking = list(
		"dissolves" = dissolves_into,
		"heats" = heating_products,
		"chills" = chilling_products
	)
	for(var/field in checking)
		var/list/checking_list = checking[field]
		if(length(checking_list))
			var/total = 0
			for(var/chem in checking_list)
				total += checking_list[chem]
			if(total != 1)
				. += "[field] adds up to [total] (should be 1)"

	if(dissolves_in == MAT_SOLVENT_IMMUNE && LAZYLEN(dissolves_into))
		. += "material is immune to solvents, but has dissolves_into products."

	if(!paint_verb)
		. += "material does not have a paint_verb set"
	else if(!istext(paint_verb))
		. += "material has a non-text paint_verb value"

	for(var/i = 0 to 7)
		if(icon_base)
			if(!check_state_in_icon("[i]", icon_base))
				. += "'[icon_base]' - missing directional base icon state '[i]'"
			if(!check_state_in_icon("other[i]", icon_base))
				. += "'[icon_base]' - missing connective base icon state 'other[i]'"

		if(wall_flags & PAINT_PAINTABLE)
			if(!check_state_in_icon("paint[i]", icon_base))
				. += "'[icon_base]' - missing directional paint icon state '[i]'"
		if(wall_flags & PAINT_STRIPABLE)
			if(!check_state_in_icon("stripe[i]", icon_base))
				. += "'[icon_base]' - missing directional stripe icon state '[i]'"
		if(wall_flags & WALL_HAS_EDGES)
			if(!check_state_in_icon("other[i]", icon_base))
				. += "'[icon_base]' - missing directional edge icon state '[i]'"

		if(icon_base_natural)
			if(!check_state_in_icon("[i]", icon_base_natural))
				. += "'[icon_base_natural]' - missing directional natural icon state '[i]'"
			if(!check_state_in_icon("shine[i]", icon_base_natural))
				. += "'[icon_base_natural]' - missing natural shine icon state 'shine[i]'"

	if(icon_reinf)
		var/list/all_reinf_icons = islist(icon_reinf) ? icon_reinf : list(icon_reinf)
		for(var/sub_icon in all_reinf_icons)
			if(use_reinf_state)
				if(!check_state_in_icon(use_reinf_state, sub_icon))
					. += "'[sub_icon]' - missing reinf icon state '[use_reinf_state]'"
			else
				for(var/i = 0 to 7)
					if(!check_state_in_icon(num2text(i), sub_icon))
						. += "'[sub_icon]' - missing directional reinf icon state '[i]'"

	if(length(color) != 7)
		. += "invalid color (not #RRGGBB)"

// Return the matter comprising this material.
/decl/material/proc/get_matter()
	var/list/temp_matter = list()
	temp_matter[type] = SHEET_MATERIAL_AMOUNT
	return temp_matter

/decl/material/proc/get_attack_cooldown()
	if(weight <= MAT_VALUE_LIGHT)
		return FAST_WEAPON_COOLDOWN
	if(weight >= MAT_VALUE_HEAVY)
		return SLOW_WEAPON_COOLDOWN
	return DEFAULT_WEAPON_COOLDOWN

// Currently used for weapons and objects made of uranium to irradiate things.
/decl/material/proc/products_need_process()
	return (radioactivity>0) //todo

//Clausius–Clapeyron relation
/decl/material/proc/get_boiling_temp(var/pressure = ONE_ATMOSPHERE)
	var/pressure_ratio = (pressure > 0)? log(pressure / ONE_ATMOSPHERE) : 0
	return (1 / (1/max(boiling_point, TCMB)) - ((R_IDEAL_GAS_EQUATION * pressure_ratio) / (latent_heat * molar_mass)))

/// Returns the phase of the matterial at the given temperature and pressure
/// Defaults to standard temperature and pressure (20c at one atmosphere)
/decl/material/proc/phase_at_temperature(var/temperature = T20C, var/pressure = ONE_ATMOSPHERE)
	//#TODO: implement plasma temperature and do pressure checks
	if(!isnull(boiling_point) && temperature >= get_boiling_temp(pressure))
		return MAT_PHASE_GAS
	else if(!isnull(heating_point) && temperature >= heating_point || \
			!isnull(melting_point) && temperature >= melting_point)
		return MAT_PHASE_LIQUID
	return MAT_PHASE_SOLID

// Returns the number of mols of material for the amount of solid or liquid units passed.
/decl/material/proc/get_mols_from_units(units, phase)
	var/ml = units*10 // Rough estimation.
	switch(phase)
		if(MAT_PHASE_LIQUID)
			var/kg = (liquid_density*ml)/1000
			return kg/molar_mass
		if(MAT_PHASE_SOLID)
			var/kg = (solid_density*ml)/1000
			return kg/molar_mass
		else
			log_warning("Invalid phase '[phase]' passed to get_mols_from_units!")
			return units

// Used by walls when qdel()ing to avoid neighbor merging.
/decl/material/placeholder
	name = "placeholder"
	uid = "mat_placeholder"
	hidden_from_codex = TRUE
	exoplanet_rarity_plant = MAT_RARITY_NOWHERE
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE
	holographic = TRUE

/// Generic material product (sheets, bricks, etc). Used ALL THE TIME.
/// May return an instance list, a single instance, or nothing if there is no instance produced.
/decl/material/proc/create_object(var/atom/target, var/amount = 1, var/object_type, var/reinf_type)

	if(!object_type)
		object_type = default_solid_form

	if(!ispath(object_type, /atom/movable))
		CRASH("Non-movable path '[object_type || "NULL"]' supplied to [type] create_object()")

	if(ispath(object_type, /obj/item/stack))
		var/obj/item/stack/stack_type = object_type
		var/divisor = initial(stack_type.max_amount)
		while(amount >= divisor)
			LAZYADD(., new object_type(target, divisor, type, reinf_type))
			amount -= divisor
		if(amount >= 1)
			LAZYADD(., new object_type(target, amount, type, reinf_type))
	else
		for(var/i = 1 to amount)
			var/atom/movable/placed = new object_type(target, type, reinf_type)
			if(istype(placed))
				LAZYADD(., placed)

	if(istype(target) && LAZYLEN(.))
		for(var/atom/movable/placed in .)
			placed.dropInto(target)

// Places a girder object when a wall is dismantled, also applies reinforced material.
/decl/material/proc/place_dismantled_girder(var/turf/target, var/decl/material/reinf_material)
	return create_object(target, 1, /obj/structure/girder, ispath(reinf_material) ? reinf_material : reinf_material?.type)

// General wall debris product placement.
// Not particularly necessary aside from snowflakey cult girders.
/decl/material/proc/place_dismantled_product(var/turf/target, var/is_devastated, var/amount = 2, var/drop_type)
	amount = is_devastated ? floor(amount * 0.5) : amount
	if(amount > 0)
		return create_object(target, amount, object_type = drop_type)

// As above.
/decl/material/proc/place_shards(var/turf/target, var/amount = 1)
	if(shard_name)
		return create_object(target, amount, /obj/item/shard)

/**Places downa as many shards as needed for the given amount of matter units. Returns a list of all the cuttings. */
/decl/material/proc/place_cuttings(var/turf/target, var/matter_units)
	if(!shard_type && matter_units <= 0)
		return
	var/list/shard_mat = atom_info_repository.get_matter_for(shard_type, type, 1)
	var/amount_per_shard = LAZYACCESS(shard_mat, type)
	if(amount_per_shard < 1)
		return

	//Make all the shards we can
	var/shard_amount = round(matter_units / amount_per_shard)
	var/matter_left  = round(matter_units % amount_per_shard)
	LAZYADD(., create_object(target, shard_amount, shard_type))

	//If we got more than expected, just make a shard with that amount
	if(matter_left > 0)
		var/list/O = create_object(target, 1, shard_type)
		var/obj/S = O[O.len]
		LAZYSET(S.matter, type, matter_left)
		LAZYADD(., S)

// Used by walls and weapons to determine if they break or not.
/decl/material/proc/is_brittle()
	return !!(flags & MAT_FLAG_BRITTLE)

/decl/material/proc/combustion_effect(var/turf/T, var/temperature)
	return

// Dumb overlay to apply over wall sprite for cheap texture effect
/decl/material/proc/get_wall_texture()
	return

/decl/material/proc/on_leaving_metabolism(datum/reagents/metabolism/holder)
	return

/decl/material/proc/touch_obj(var/obj/O, var/amount, var/datum/reagents/holder) // Acid melting, cleaner cleaning, etc

	if(solvent_power >= MAT_SOLVENT_MODERATE)
		if(istype(O, /obj/item/paper) && amount >= FLUID_MINIMUM_TRANSFER)
			var/obj/item/paper/paperaffected = O
			paperaffected.clearpaper()
			O.visible_message(SPAN_NOTICE("The solution dissolves the ink on the paper."), range = 1)
		else if(istype(O, /obj/item/book) && amount >= FLUID_PUDDLE)
			var/obj/item/book/affectedbook = O
			if(affectedbook.clear_text())
				O.visible_message(SPAN_NOTICE("The solution dissolves the ink on the book."), range = 1)
			else
				O.visible_message(SPAN_WARNING("The solution does nothing. Whatever this is, it isn't normal ink."), range = 1)

	if(solvent_power >= MAT_SOLVENT_STRONG && O.solvent_can_melt(solvent_power) && (istype(O, /obj/item) || istype(O, /obj/effect/vine)) && (amount > solvent_melt_dose))
		O.visible_message(SPAN_DANGER("\The [O] dissolves!"))
		O.handle_melting()
		holder?.remove_reagent(src, solvent_melt_dose)
	else if(defoliant && istype(O, /obj/effect/vine))
		qdel(O)
	else
		if(dirtiness <= DIRTINESS_DECONTAMINATE)
			if(amount >= decontamination_dose && istype(O, /obj/item))
				var/obj/item/thing = O
				if(thing.contaminated)
					thing.decontaminate()
		if(dirtiness <= DIRTINESS_STERILE)
			O.germ_level -= min(amount*20, O.germ_level)
			O.was_bloodied = FALSE
		if(dirtiness <= DIRTINESS_CLEAN)
			O.clean()

#define FLAMMABLE_LIQUID_DIVISOR 7
// This doesn't apply to skin contact - this is for, e.g. extinguishers and sprays. The difference is that reagent is not directly on the mob's skin - it might just be on their clothing.
/decl/material/proc/touch_mob(var/mob/living/M, var/amount, var/datum/reagents/holder)
	if(accelerant_value != FUEL_VALUE_NONE && amount && istype(M))
		M.adjust_fire_intensity(floor((amount * accelerant_value)/FLAMMABLE_LIQUID_DIVISOR))
#undef FLAMMABLE_LIQUID_DIVISOR

/decl/material/proc/touch_turf(var/turf/touching_turf, var/amount, var/datum/reagents/holder) // Cleaner cleaning, lube lubbing, etc, all go here

	if(REAGENT_VOLUME(holder, src) < turf_touch_threshold)
		return

	if(istype(touching_turf) && touching_turf.simulated)
		if(defoliant)
			for(var/obj/effect/overlay/wallrot/rot in touching_turf)
				touching_turf.visible_message(SPAN_NOTICE("\The [rot] is completely dissolved by the solution!"))
				qdel(rot)
		if(slipperiness != 0 && !touching_turf.check_fluid_depth()) // Don't make floors slippery if they have an active fluid on top of them please.
			if(slipperiness < 0)
				touching_turf.unwet_floor(TRUE)
			else if (REAGENT_VOLUME(holder, src) >= slippery_amount)
				touching_turf.wet_floor(slipperiness)

	if(length(vapor_products))
		var/volume = REAGENT_VOLUME(holder, src)
		var/temperature = holder?.my_atom?.temperature || T20C
		for(var/vapor in vapor_products)
			touching_turf.assume_gas(vapor, (volume * vapor_products[vapor]), temperature)
		holder.remove_reagent(src, volume)

/decl/material/proc/on_mob_life(var/mob/living/M, var/metabolism_class, var/datum/reagents/holder, var/list/life_dose_tracker)

	if(QDELETED(src))
		return // Something else removed us.
	if(!istype(M))
		return
	if(!(flags & AFFECTS_DEAD) && M.stat == DEAD && (world.time - M.timeofdeath > 150))
		return

	// Keep track of dosage of chems across holders for overdosing purposes
	if(overdose && metabolism_class != CHEM_TOUCH && islist(life_dose_tracker))
		life_dose_tracker[src] += REAGENT_VOLUME(holder, src)

	//determine the metabolism rate
	var/removed
	switch(metabolism_class)
		if(CHEM_INGEST)
			removed = ingest_met
		if(CHEM_TOUCH)
			removed = touch_met
		if(CHEM_INHALE)
			removed = inhale_met
	if(!removed)
		removed = metabolism
	if(!removed)
		removed = metabolism
	removed = M.get_adjusted_metabolism(removed)

	//adjust effective amounts - removed, dose, and max_dose - for mob size
	var/effective = removed
	if(!(flags & IGNORE_MOB_SIZE))
		effective *= (MOB_SIZE_MEDIUM/M.mob_size)
	if(metabolism_class != CHEM_TOUCH)
		var/dose = CHEM_DOSE(M, src) + effective
		LAZYSET(M._chem_doses, src, dose)

	var/remove_dose = TRUE
	if(effective >= (metabolism * 0.1) || effective >= 0.1) // If there's too little chemical, don't affect the mob, just remove it
		switch(metabolism_class)
			if(CHEM_INJECT)
				affect_blood(M, effective, holder)
			if(CHEM_INGEST)
				affect_ingest(M, effective, holder)
			if(CHEM_TOUCH)
				remove_dose = affect_touch(M, effective, holder)
			if(CHEM_INHALE)
				affect_inhale(M, effective, holder)
	if(remove_dose)
		holder.remove_reagent(src, removed)

/decl/material/proc/affect_blood(var/mob/living/M, var/removed, var/datum/reagents/holder)

	SHOULD_CALL_PARENT(TRUE)

	if(M.status_flags & GODMODE)
		return

	if(antibiotic_strength)
		M.adjust_immunity(-0.1 * antibiotic_strength)
		M.add_chemical_effect(CE_ANTIBIOTIC, antibiotic_strength)
		if(REAGENT_VOLUME(holder, src) > 10)
			M.adjust_immunity(-0.3 * antibiotic_strength)
		if(CHEM_DOSE(M, src) > 15)
			M.adjust_immunity(-0.25 * antibiotic_strength)

	if(nutriment_factor || hydration_factor)
		if(injectable_nutrition)
			adjust_mob_nutrition(M, removed, holder, CHEM_INJECT)
		else
			apply_intolerances(M, removed, holder, CHEM_INJECT)
			M.take_damage(0.2 * removed, TOX)
	else if(!injectable_nutrition)
		apply_intolerances(M, removed, holder, CHEM_INJECT)

	if(radioactivity)
		M.apply_damage(radioactivity * removed, IRRADIATE, armor_pen = 100)

	if(toxicity)
		M.add_chemical_effect(CE_TOXIN, toxicity)
		var/dam = (toxicity * removed)
		if(toxicity_targets_organ && ishuman(M))
			var/organ_damage = dam * M.get_toxin_resistance()
			if(organ_damage > 0)
				var/mob/living/human/H = M
				var/obj/item/organ/internal/organ = GET_INTERNAL_ORGAN(H, toxicity_targets_organ)
				if(organ)
					var/can_damage = organ.max_damage - organ.get_organ_damage()
					if(can_damage > 0)
						if(organ_damage > can_damage)
							organ.take_damage(can_damage, silent=TRUE)
							dam -= can_damage
						else
							organ.take_damage(organ_damage, silent=TRUE)
							dam = 0
		if(dam > 0)
			M.take_damage(toxicity_targets_organ ? (dam * 0.75) : dam, TOX)

	if(solvent_power >= MAT_SOLVENT_STRONG)
		M.take_organ_damage(0, removed * solvent_power, override_droplimb = DISMEMBER_METHOD_ACID)

	if(narcosis)
		if(prob(10))
			M.SelfMove(pick(global.cardinal))
		if(prob(narcosis))
			M.emote(pick(/decl/emote/visible/twitch, /decl/emote/visible/drool, /decl/emote/audible/moan))

	if(euphoriant)
		SET_STATUS_MAX(M, STAT_DRUGGY, euphoriant)

/decl/material/proc/affect_ingest(var/mob/living/M, var/removed, var/datum/reagents/holder)

	SHOULD_CALL_PARENT(TRUE)

	adjust_mob_nutrition(M, removed, holder, CHEM_INGEST)
	if(affect_blood_on_ingest)
		affect_blood(M, removed * affect_blood_on_ingest, holder)

/decl/material/proc/affect_inhale(var/mob/living/M, var/removed, var/datum/reagents/holder)

	SHOULD_CALL_PARENT(TRUE)

	apply_intolerances(M, removed, holder, CHEM_INHALE)
	if(affect_blood_on_inhale)
		affect_blood(M, removed * affect_blood_on_inhale, holder)

// Major allergy - handled by handle_allergens() on /mob/living by default.
/decl/material/proc/apply_allergy_effects(mob/living/subject, removed, severity, ingestion_method)
	if(allergen_factor > 0)
		subject.add_chemical_effect(CE_ALLERGEN, removed * severity * allergen_factor)
	else if(allergen_factor < 0)
		subject.remove_chemical_effect(CE_ALLERGEN, removed * severity * allergen_factor)

// Intolerance - TODO: more messages
/decl/material/proc/apply_intolerance_effects(mob/living/subject, removed, severity, ingestion_method)
	if(ingestion_method != CHEM_INGEST)
		return
	if(ishuman(subject) && prob(removed))
		var/mob/living/human/puker = subject
		puker.vomit()
	else if(prob(1))
		var/static/list/intolerance_messages = list(
			"Your innards churn and cramp unhappily."
		)
		subject.custom_pain(pick(intolerance_messages), 1)

/decl/material/proc/apply_intolerances(mob/living/subject, removed, datum/reagents/holder, ingestion_method)

	var/list/data = REAGENT_DATA(holder, src)
	var/check_flags = LAZYACCESS(data, DATA_INGREDIENT_FLAGS) | allergen_flags
	if(!check_flags)
		return 1

	var/list/intolerances = get_intolerances_by_flag(check_flags, ingestion_method)
	if(!length(intolerances))
		return 1

	var/malus_level = 0
	for(var/decl/trait/intolerance as anything in intolerances)
		malus_level = max(malus_level, subject.get_trait_level(intolerance.type))
	if(!malus_level)
		return 1

	if(malus_level >= TRAIT_LEVEL_MAJOR)
		apply_allergy_effects(subject, removed, malus_level, ingestion_method)
	else if(malus_level >= TRAIT_LEVEL_MINOR)
		apply_intolerance_effects(subject, removed, malus_level, ingestion_method)
	return max(0, (1 - (malus_level * 0.25)))

// Defined as a proc so it can be overridden.
/decl/material/proc/adjust_mob_nutrition(mob/living/subject, removed, datum/reagents/holder, ingestion_method)
	var/metabolic_penalty = apply_intolerances(subject, removed, holder, ingestion_method)
	if(nutriment_factor)
		var/effective_power = nutriment_factor * metabolic_penalty * removed
		if(effective_power)
			subject.adjust_nutrition(effective_power)
	if(hydration_factor)
		var/effective_power = hydration_factor * metabolic_penalty * removed
		if(effective_power)
			subject.adjust_hydration(effective_power)

// Slightly different to other reagent processing - return TRUE to consume the removed amount, FALSE not to consume.
/decl/material/proc/affect_touch(var/mob/living/victim, var/removed, var/datum/reagents/holder)

	SHOULD_CALL_PARENT(TRUE)
	. = FALSE
	if(!istype(victim))
		return FALSE

	if(radioactivity)
		victim.apply_damage((radioactivity / 2) * removed, IRRADIATE)
		. = TRUE

	if(dirtiness <= DIRTINESS_STERILE)
		if(victim.germ_level < INFECTION_LEVEL_TWO) // rest and antibiotics is required to cure serious infections
			victim.germ_level -= min(removed*20, victim.germ_level)
		for(var/obj/item/organ in victim.contents)
			organ.was_bloodied = FALSE
		victim.was_bloodied = FALSE
		. = TRUE

	// TODO: clean should add the gross reagents washed off to a holder to dump on the loc.
	if(dirtiness <= DIRTINESS_CLEAN)
		for(var/obj/item/thing in victim.get_held_items())
			thing.clean()
		var/obj/item/mask = victim.get_equipped_item(slot_wear_mask_str)
		if(mask)
			mask.clean()
		if(ishuman(victim))
			var/mob/living/human/human_victim = victim
			var/obj/item/head = human_victim.get_equipped_item(slot_head_str)
			if(head)
				head.clean()
			var/obj/item/suit = human_victim.get_equipped_item(slot_wear_suit_str)
			if(suit)
				suit.clean()
			else
				var/obj/item/uniform = human_victim.get_equipped_item(slot_w_uniform_str)
				if(uniform)
					uniform.clean()

			var/obj/item/shoes = human_victim.get_equipped_item(slot_shoes_str)
			if(shoes)
				shoes.clean()
			else
				human_victim.clean()
		else
			victim.clean()

	if(solvent_power > MAT_SOLVENT_NONE && removed >= solvent_melt_dose && victim.solvent_act(min(removed * solvent_power * ((removed < solvent_melt_dose) ? 0.1 : 0.2), solvent_max_damage), solvent_melt_dose, solvent_power))
		holder.remove_reagent(src, REAGENT_VOLUME(holder, src))
		. = TRUE

/decl/material/proc/affect_overdose(mob/living/victim, total_dose) // Overdose effect. Doesn't happen instantly.
	victim.add_chemical_effect(CE_TOXIN, 1)
	victim.take_damage(REM, TOX)

/decl/material/proc/initialize_data(list/newdata) // Called when the reagent is first added to a reagents datum.
	. = newdata
	if(allergen_flags)
		LAZYINITLIST(.)
		.[DATA_INGREDIENT_FLAGS] |= allergen_flags

/decl/material/proc/mix_data(var/datum/reagents/reagents, var/list/newdata, var/amount)
	reagents.cached_color = null // colour masking may change
	. = REAGENT_DATA(reagents, src)
	if(!length(newdata) || !islist(newdata))
		return

	// Blend in any allergen flags.
	var/new_allergens = newdata[DATA_INGREDIENT_FLAGS]
	if(new_allergens)
		LAZYINITLIST(.)
		.[DATA_INGREDIENT_FLAGS] |= new_allergens

	// Sum our existing taste data with the incoming taste data.
	var/total_taste = 0
	var/new_fraction = amount / REAGENT_VOLUME(reagents, src) // the fraction of the total reagent volume that the new data is associated with
	var/list/tastes = list()
	var/list/newtastes = LAZYACCESS(newdata, DATA_TASTE)
	for(var/taste in newtastes)
		var/newtaste   = newtastes[taste] * new_fraction
		tastes[taste] += newtaste
		total_taste   += newtaste

	// If we have an old taste list, keep it, but if we don't, generate
	// one to hold our base taste information. This is so pouring nutriment
	// with a taste list into honey for example won't completely mask the
	// taste of honey.
	var/list/oldtastes = LAZYACCESS(., DATA_TASTE)
	var/old_fraction = 1 - new_fraction
	if(length(oldtastes))
		for(var/taste in oldtastes)
			var/oldtaste   = oldtastes[taste] * old_fraction
			tastes[taste] += oldtaste
			total_taste   += oldtaste
	else if(length(tastes) && taste_description) // only add it to the list if we already have other tastes
		tastes[taste_description] += taste_mult * old_fraction
		total_taste               += taste_mult * old_fraction

	// Cull all tastes below 10% of total
	if(length(tastes))
		if(total_taste)
			for(var/taste in tastes)
				if((tastes[taste] / total_taste) < 0.1)
					tastes -= taste
		if(length(tastes))
			LAZYSET(., DATA_TASTE, tastes)

	// Blend our extra_colour...
	var/new_extra_color = newdata?[DATA_EXTRA_COLOR]
	if(new_extra_color)
		.[DATA_EXTRA_COLOR] = BlendHSV(new_extra_color, .[DATA_EXTRA_COLOR], new_fraction)

/decl/material/proc/explosion_act(obj/item/chems/holder, severity)
	SHOULD_CALL_PARENT(TRUE)
	. = TRUE

/decl/material/proc/get_value()
	. = value

/decl/material/proc/get_presentation_name(var/obj/item/prop)
	if(islist(prop?.reagents?.reagent_data))
		. = LAZYACCESS(prop.reagents.reagent_data[src], DATA_MASK_NAME)
	. ||= glass_name || liquid_name
	if(prop?.reagents?.total_volume)
		. = build_presentation_name_from_reagents(prop, .)

/decl/material/proc/build_presentation_name_from_reagents(var/obj/item/prop, var/supplied)
	. = supplied
	if(cocktail_ingredient)
		for(var/decl/cocktail/cocktail in SSmaterials.get_cocktails_by_primary_ingredient(type))
			if(cocktail.matches(prop))
				return cocktail.get_presentation_name(prop)
	if(prop.reagents.has_reagent(/decl/material/solid/ice))
		. = "iced [.]"

/decl/material/proc/get_presentation_desc(var/obj/item/prop)
	. = glass_desc
	if(prop?.reagents?.total_volume)
		. = build_presentation_desc_from_reagents(prop, .)

/decl/material/proc/build_presentation_desc_from_reagents(var/obj/item/prop, var/supplied)
	. = supplied

	if(cocktail_ingredient)
		for(var/decl/cocktail/cocktail in SSmaterials.get_cocktails_by_primary_ingredient(type))
			if(cocktail.matches(prop))
				return cocktail.get_presentation_desc(prop)

/decl/material/proc/neutron_interact(var/neutron_energy, var/total_interacted_units, var/total_units)
	. = list() // Returns associative list of interaction -> interacted units
	if(!length(neutron_interactions))
		return
	for(var/interaction in neutron_interactions)
		var/ideal_energy = neutron_interactions[interaction]
		var/interacted_units_ratio = (clamp(-((((neutron_energy-ideal_energy)**2)/(neutron_cross_section*1000)) - 100), 0, 100))/100
		var/interacted_units = round(interacted_units_ratio*total_interacted_units, 0.001)

		if(interacted_units > 0)
			.[interaction] = interacted_units
			total_interacted_units -= interacted_units
		if(total_interacted_units <= 0)
			return

/decl/material/proc/add_burn_product(var/datum/gas_mixture/environment, var/amount)
	if(!environment || amount <= 0 || !burn_product)
		return
	environment.adjust_gas(burn_product, amount)

// Returns null for no burn, empty list for burn with no products, assoc
// matter to value list for waste products.
// We assume a normalized mole amount for 'amount'.
/decl/material/proc/get_burn_products(var/amount, var/burn_temperature)

	// No chance of burning.
	if(isnull(ignition_point) && isnull(boiling_point) && !length(vapor_products))
		return

	// Burning a reagent of any kind.
	if(ignition_point && burn_temperature >= ignition_point)
		. = list() // We need to return a non-null value to indicate we consumed the material.
		if(burn_product)
			.[burn_product] = amount
		return

	// If it has a vapor product, turn it into that.
	if(length(vapor_products))
		. = list()
		for(var/vapor in vapor_products)
			.[vapor] = (amount * vapor_products[vapor])
		return

	// If it's not ignitable but can be boiled, consider vaporizing it.
	if(!isnull(boiling_point) && burn_temperature >= boiling_point)
		LAZYSET(., src, amount)

/decl/material/proc/get_reagent_name(datum/reagents/holder, phase = MAT_PHASE_LIQUID)

	if(istype(holder) && holder.reagent_data)
		var/list/rdata = holder.reagent_data[src]
		if(rdata)
			var/data_name = rdata[DATA_MASK_NAME]
			if(data_name)
				return data_name

	if(phase == MAT_PHASE_SOLID)
		return solid_name

	// Check if the material is in solution. This is a much simpler check than normal solubility.
	if(phase == MAT_PHASE_LIQUID)
		if(!istype(holder))
			return liquid_name
		var/atom/location = holder.get_reaction_loc()
		var/temperature = location?.temperature || T20C

		if(melting_point > temperature)
			return solution_name
		else
			return liquid_name

	return "something"

/decl/material/proc/get_reagent_color(datum/reagents/holder)
	if(istype(holder) && holder.reagent_data)
		var/list/rdata = holder.reagent_data[src]
		if(rdata)
			var/data_color = rdata[DATA_MASK_COLOR]
			if(data_color)
				return data_color
	return color

/decl/material/proc/get_reagent_overlay_color(datum/reagents/holder)
	var/list/rdata = REAGENT_DATA(holder, src)
	return LAZYACCESS(rdata, DATA_EXTRA_COLOR) || get_reagent_color(holder) + num2hex(opacity * 255)

/decl/material/proc/can_hold_sharpness()
	return hardness > MAT_VALUE_FLEXIBLE

/decl/material/proc/can_hold_edge()
	return hardness > MAT_VALUE_FLEXIBLE

// TODO: expand this to more than just Actual Poison.
/decl/material/proc/is_unsafe_to_drink(mob/user)
	return toxicity > 0

/// Used for material-dependent effects on stain dry.
/// Return TRUE to skip default drying handling.
/decl/material/proc/handle_stain_dry(obj/effect/decal/cleanable/blood/stain)
	return FALSE

/// Returns (in deciseconds) how long until dry() will be called on this stain,
/// or null to use the stain's default.
/// If 0 is returned, it dries instantly.
/// If any value below 0 is returned, it doesn't start processing.
/decl/material/proc/get_time_to_dry_stain(obj/effect/decal/cleanable/blood/stain)
	return initial(stain.time_to_dry)

// TODO: Maybe make this use a strengths system like taste?
/// Returns a string to describe an item coated with this reagent (and others).
/// Receives the coating reagent holder as an argument, so coating.my_atom is accessible
/// and it can also conditionally use a different string for primary/non-primary materials, or
/// if another liquid is present, e.g. 'wet bloody muddy shoes'.
/decl/material/proc/get_coated_adjective(datum/reagents/coating)
	var/used_color = get_reagent_color(coating)
	if(get_config_value(/decl/config/enum/colored_coating_names) == CONFIG_COATING_COLOR_COMPONENTS)
		return FONT_COLORED(used_color, coated_adjective)
	return coated_adjective

/// Gets the name used to describe a coating with this material as its primary reagent.
/// This is mostly for handling special cases like mud.
/decl/material/proc/get_primary_coating_name(datum/reagents/coating)
	// this should probably respect current phase/solution/etc better, but coating sure doesn't
	return get_reagent_name(coating, phase_at_temperature())

/// Builds a string to describe a coating made up of this reagent (and others).
/// This reagent will never be the primary reagent, however; that's handled in get_primary_coating_name.
/// Receives the coating as an argument like get_coated_adjective, but also receives the accumulator list
/// for more complex behaviors like adding to the start. It can't reliably handle things like removing
/// another entry because ordering is not guaranteed, so beware if you need something like that.
/decl/material/proc/build_coated_name(datum/reagents/coating, list/accumulator)
	accumulator |= get_coated_adjective(coating)
