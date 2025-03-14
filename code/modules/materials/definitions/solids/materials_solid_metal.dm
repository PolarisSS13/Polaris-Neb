/decl/material/solid/metal
	name = null
	construction_difficulty = MAT_VALUE_HARD_DIY
	reflectiveness = MAT_VALUE_SHINY
	removed_by_welder = TRUE
	wall_name = "bulkhead"
	weight = MAT_VALUE_HEAVY
	hardness = MAT_VALUE_RIGID
	wall_support_value = MAT_VALUE_HEAVY
	wall_flags = PAINT_PAINTABLE
	wall_blend_icons = list(
		'icons/turf/walls/wood.dmi' = TRUE,
		'icons/turf/walls/stone.dmi' = TRUE
	)
	default_solid_form = /obj/item/stack/material/ingot
	table_icon_base = "metal"
	door_icon_base = "metal"
	abstract_type = /decl/material/solid/metal
	icon_base = 'icons/turf/walls/metal.dmi'
	icon_reinf = 'icons/turf/walls/reinforced_metal.dmi'
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE
	tensile_strength = 0.8 // metal wire is probably better than plastic?
	forgable = TRUE
	glows_with_heat = TRUE

/decl/material/solid/metal/uranium
	name = "uranium"
	codex_name = "elemental uranium"
	uid = "solid_uranium"
	lore_text = "A silvery-white metallic chemical element in the actinide series, weakly radioactive. Commonly used as fuel in fission reactors."
	mechanics_text = "Uranium can be used as fuel in fission reactors."
	taste_description = "the inside of a reactor"
	melting_point = 1407
	boiling_point = 4074
	flags = MAT_FLAG_FISSIBLE
	radioactivity = 12
	icon_base = 'icons/turf/walls/stone.dmi'
	wall_flags = 0
	table_icon_base = "stone"
	icon_reinf = 'icons/turf/walls/reinforced_stone.dmi'
	color = "#007a00"
	weight = MAT_VALUE_VERY_HEAVY
	stack_origin_tech = @'{"materials":5}'
	reflectiveness = MAT_VALUE_MATTE
	value = 1.5
	default_solid_form = /obj/item/stack/material/puck
	exoplanet_rarity_plant = MAT_RARITY_UNCOMMON
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE

	neutron_cross_section = 10
	neutron_interactions = list(
		INTERACTION_FISSION = 1500,
		INTERACTION_ABSORPTION = 4000,
		INTERACTION_SCATTER = 5000
	)
	fission_products = list(
		/decl/material/solid/metal/depleted_uranium = 0.6,
		/decl/material/solid/metal/fission_byproduct = 0.4
	)
	absorption_products = list(
		/decl/material/solid/metal/neptunium = 1
	)
	neutron_production = 10
	neutron_absorption = 6
	moderation_target = 3000
	fission_heat = 35000
	fission_energy = 4000

/decl/material/solid/metal/radium
	name = "radium"
	uid = "solid_radium"
	lore_text = "Radium is an alkaline earth metal. It is extremely radioactive."
	mechanics_text = "Radium can be used as a neutron source in fission reactors."
	taste_description = "the color blue, and regret"
	melting_point = 1234
	boiling_point = 1414
	color = "#c7c7c7"
	value = 0.5
	radioactivity = 18

/decl/material/solid/metal/gold
	name = "gold"
	adjective_name = "golden"
	codex_name = "elemental gold"
	uid = "solid_gold"
	lore_text = "A heavy, soft, ductile metal. Once considered valuable enough to back entire currencies, now predominantly used in corrosion-resistant electronics."
	melting_point = 1337
	boiling_point = 2974
	color = COLOR_GOLD
	hardness = MAT_VALUE_FLEXIBLE + 5
	integrity = 100
	stack_origin_tech = @'{"materials":4}'
	ore_result_amount = 1
	ore_name = "native gold"
	ore_spread_chance = 10
	ore_scan_icon = "mineral_uncommon"
	ore_icon_overlay = "nugget"
	value = 1.6
	sparse_material_weight = 8
	rich_material_weight = 10
	ore_type_value = ORE_PRECIOUS
	ore_data_value = 2

/decl/material/solid/metal/bronze
	name = "bronze"
	codex_name = "bronze alloy"
	uid = "solid_bronze"
	lore_text = "An alloy of copper and tin. Once used in weapons and laboring tools."
	melting_point = 1184
	boiling_point = 2574
	color = "#ccbc63"
	brute_armor = 3
	hardness = MAT_VALUE_RIGID + 10
	icon_base = 'icons/turf/walls/solid.dmi'
	icon_reinf = 'icons/turf/walls/reinforced.dmi'
	wall_flags = PAINT_PAINTABLE|PAINT_STRIPABLE|WALL_HAS_EDGES
	use_reinf_state = null
	value = 1.2
	default_solid_form = /obj/item/stack/material/sheet

/decl/material/solid/metal/blackbronze
	name = "black bronze"
	uid = "solid_black_bronze"
	lore_text = "An alloy of copper and silver. Used in ancient ceremonial gear."
	color = "#3f352a"
	brute_armor = 4
	hardness = MAT_VALUE_HARD
	reflectiveness = MAT_VALUE_MATTE
	icon_base = 'icons/turf/walls/solid.dmi'
	icon_reinf = 'icons/turf/walls/reinforced.dmi'
	wall_flags = PAINT_PAINTABLE|PAINT_STRIPABLE|WALL_HAS_EDGES
	use_reinf_state = null
	value = 1.4
	exoplanet_rarity_plant = MAT_RARITY_UNCOMMON
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE

/decl/material/solid/metal/redgold
	name = "red gold"
	uid = "solid_red_gold"
	lore_text = "An alloy of copper and gold. A soft metal used for its ornamental properties."
	color = "#ff7a59"
	reflectiveness = MAT_VALUE_SHINY
	value = 1.4
	exoplanet_rarity_plant = MAT_RARITY_UNCOMMON
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE

/decl/material/solid/metal/brass
	name = "brass"
	uid = "solid_brass"
	lore_text = "An alloy of copper and zinc. Renowned for its golden color."
	melting_point = 1174
	boiling_point = 1374
	color = "#dab900"
	reflectiveness = MAT_VALUE_VERY_SHINY
	value = 1.2
	default_solid_form = /obj/item/stack/material/sheet
	exoplanet_rarity_plant = MAT_RARITY_UNCOMMON
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE

/decl/material/solid/metal/copper
	name = "copper"
	uid = "solid_copper"
	lore_text = "A metal used in some components and many alloys. Known for its color-shifting properties when oxidized."
	melting_point = 1357
	boiling_point = 2774
	color = COLOR_COPPER
	weight = MAT_VALUE_NORMAL
	hardness = MAT_VALUE_FLEXIBLE + 10
	stack_origin_tech = @'{"materials":2}'
	temperature_burn_milestone_material = /decl/material/solid/metal/copper

/decl/material/solid/metal/silver
	name = "silver"
	uid = "solid_silver"
	lore_text = "A soft, white, lustrous transition metal. Has many and varied industrial uses in electronics, solar panels and mirrors."
	melting_point = 1234
	boiling_point = 2444
	color = "#d1e6e3"
	hardness = MAT_VALUE_FLEXIBLE + 10
	stack_origin_tech = @'{"materials":3}'
	ore_result_amount = 1
	ore_spread_chance = 10
	ore_name = "native silver"
	ore_scan_icon = "mineral_uncommon"
	ore_icon_overlay = "shiny"
	value = 1.2
	sparse_material_weight = 8
	rich_material_weight = 10
	ore_type_value = ORE_PRECIOUS
	ore_data_value = 2

/decl/material/solid/metal/steel
	name = "steel"
	codex_name = "carbon steel"
	uid = "solid_steel"
	lore_text = "A strong, flexible alloy of iron and carbon. Probably the single most fundamentally useful and ubiquitous substance in human space."
	melting_point = 1734
	boiling_point = 2774
	weight = MAT_VALUE_NORMAL
	wall_support_value = MAT_VALUE_VERY_HEAVY // Ideal construction material.
	hardness = MAT_VALUE_HARD + 5
	integrity = 150
	brute_armor = 5
	icon_base = 'icons/turf/walls/solid.dmi'
	icon_reinf = 'icons/turf/walls/reinforced.dmi'
	wall_flags = PAINT_PAINTABLE|PAINT_STRIPABLE|WALL_HAS_EDGES
	use_reinf_state = null
	color = COLOR_STEEL
	hitsound = 'sound/weapons/smash.ogg'
	construction_difficulty = MAT_VALUE_NORMAL_DIY
	value = 1.1
	dissolves_in = MAT_SOLVENT_STRONGEST
	dissolves_into = list(
		/decl/material/solid/metal/iron = 0.98,
		/decl/material/solid/carbon = 0.02
	)
	default_solid_form = /obj/item/stack/material/sheet
	ferrous = TRUE

/decl/material/solid/metal/steel/holographic
	name = "holographic steel"
	uid = "solid_holographic_steel"
	holographic = TRUE

/decl/material/solid/metal/stainlesssteel
	name = "stainless steel"
	uid = "solid_stainless_steel"
	lore_text = "A reflective alloy of steel and chromium. Used for its reflective and sturdy properties."
	melting_point = 1784
	boiling_point = null
	wall_support_value = MAT_VALUE_HEAVY
	hardness = MAT_VALUE_HARD + 5
	integrity = 175
	burn_armor = 10
	color = "#a5a5a5"
	icon_base = 'icons/turf/walls/solid.dmi'
	icon_reinf = 'icons/turf/walls/reinforced.dmi'
	wall_flags = PAINT_PAINTABLE|PAINT_STRIPABLE|WALL_HAS_EDGES
	use_reinf_state = null
	hitsound = 'sound/weapons/smash.ogg'
	construction_difficulty = MAT_VALUE_VERY_HARD_DIY
	reflectiveness = MAT_VALUE_MIRRORED
	value = 1.3
	exoplanet_rarity_plant = MAT_RARITY_UNCOMMON
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE
	dissolves_in = MAT_SOLVENT_IMMUNE
	dissolves_into = null
	ferrous = TRUE

/decl/material/solid/metal/aluminium
	name = "aluminium"
	uid = "solid_aluminium"
	lore_text = "A low-density ductile metal with a silvery-white sheen."
	melting_point = 932
	boiling_point = 2474
	integrity = 125
	weight = MAT_VALUE_LIGHT
	icon_base = 'icons/turf/walls/solid.dmi'
	icon_reinf = 'icons/turf/walls/reinforced.dmi'
	wall_flags = PAINT_PAINTABLE|PAINT_STRIPABLE|WALL_HAS_EDGES
	use_reinf_state = null
	color = "#cccdcc"
	hitsound = 'sound/weapons/smash.ogg'
	taste_description = "metal"
	default_solid_form = /obj/item/stack/material/sheet/shiny

/decl/material/solid/metal/aluminium/holographic
	name = "holoaluminium"
	uid = "solid_holographic_aluminium"
	holographic = TRUE

/decl/material/solid/metal/plasteel
	name = "plasteel"
	codex_name = "plasteel alloy"
	uid = "solid_plasteel"
	lore_text = "An alloy of steel and platinum. When regular high-tensile steel isn't tough enough to get the job done, the smart consumer turns to frankly absurd alloys of steel and platinum."
	integrity = 400
	melting_point = 6000
	icon_base = 'icons/turf/walls/solid.dmi'
	icon_reinf = 'icons/turf/walls/reinforced.dmi'
	wall_flags = PAINT_PAINTABLE|PAINT_STRIPABLE|WALL_HAS_EDGES
	use_reinf_state = null
	color = "#a8a9b2"
	explosion_resistance = 25
	brute_armor = 8
	burn_armor = 10
	hardness = MAT_VALUE_VERY_HARD
	stack_origin_tech = @'{"materials":2}'
	hitsound = 'sound/weapons/smash.ogg'
	value = 1.4
	reflectiveness = MAT_VALUE_MATTE
	default_solid_form = /obj/item/stack/material/sheet/reinforced
	exoplanet_rarity_plant = MAT_RARITY_UNCOMMON
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE
	dissolves_in = MAT_SOLVENT_IMMUNE
	dissolves_into = null
	ferrous = TRUE

/decl/material/solid/metal/titanium
	name = "titanium"
	uid = "solid_titanium"
	lore_text = "A light, strong, corrosion-resistant metal. Perfect for cladding high-velocity ballistic supply pods."
	brute_armor = 10
	burn_armor = 8
	integrity = 200
	melting_point = 1944
	boiling_point = 3474
	weight = MAT_VALUE_LIGHT
	icon_base = 'icons/turf/walls/metal.dmi'
	wall_flags = PAINT_PAINTABLE
	door_icon_base = "metal"
	color = "#d1e6e3"
	icon_reinf = 'icons/turf/walls/reinforced_metal.dmi'
	construction_difficulty = MAT_VALUE_VERY_HARD_DIY
	value = 1.5
	explosion_resistance = 25
	hardness = MAT_VALUE_VERY_HARD
	stack_origin_tech = @'{"materials":2}'
	hitsound = 'sound/weapons/smash.ogg'
	reflectiveness = MAT_VALUE_MATTE
	default_solid_form = /obj/item/stack/material/sheet/reinforced
	dissolves_in = MAT_SOLVENT_IMMUNE
	dissolves_into = null

/decl/material/solid/metal/plasteel/ocp
	name = "osmium-carbide plasteel"
	codex_name = null
	uid = "solid_osmium_carbide_plasteel"
	integrity = 200
	melting_point = 12000
	icon_base = 'icons/turf/walls/solid.dmi'
	icon_reinf = 'icons/turf/walls/reinforced.dmi'
	wall_flags = PAINT_PAINTABLE|PAINT_STRIPABLE|WALL_HAS_EDGES
	use_reinf_state = null
	color = "#9bc6f2"
	brute_armor = 4
	burn_armor = 20
	stack_origin_tech = @'{"materials":3}'
	construction_difficulty = MAT_VALUE_VERY_HARD_DIY
	value = 1.8
	exoplanet_rarity_plant = MAT_RARITY_UNCOMMON
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE

/decl/material/solid/metal/osmium
	name = "osmium"
	uid = "solid_osmium"
	lore_text = "An extremely hard form of platinum."
	melting_point = 3307
	boiling_point = 5285
	color = "#9999ff"
	stack_origin_tech = @'{"materials":5}'
	construction_difficulty = MAT_VALUE_VERY_HARD_DIY
	value = 1.3

/decl/material/solid/metal/platinum
	name = "platinum"
	uid = "solid_platinum"
	lore_text = "A very dense, unreactive, precious metal. Has many industrial uses, particularly as a catalyst."
	melting_point = 2041
	boiling_point = 4098
	color = "#deddff"
	weight = MAT_VALUE_VERY_HEAVY
	wall_support_value = MAT_VALUE_VERY_HEAVY
	hardness = MAT_VALUE_VERY_HARD
	stack_origin_tech = @'{"materials":2}'
	ore_compresses_to = /decl/material/solid/metal/osmium
	ore_result_amount = 1
	ore_spread_chance = 10
	ore_name = "raw platinum"
	ore_scan_icon = "mineral_rare"
	ore_icon_overlay = "shiny"
	value = 1.5
	sparse_material_weight = 8
	rich_material_weight = 10
	ore_type_value = ORE_EXOTIC
	ore_data_value = 4

/decl/material/solid/metal/iron
	name = "iron"
	uid = "solid_iron"
	lore_text = "A ubiquitous, very common metal. The epitaph of stars and the primary ingredient in Earth's core."
	melting_point = 1811
	boiling_point = 3134
	color = "#5c5454"
	hitsound = 'sound/weapons/smash.ogg'
	hardness = MAT_VALUE_HARD
	construction_difficulty = MAT_VALUE_NORMAL_DIY
	reflectiveness = MAT_VALUE_MATTE
	taste_description = "metal"
	ferrous = TRUE
	temperature_burn_milestone_material = /decl/material/solid/metal/iron

/decl/material/solid/metal/iron/affect_ingest(var/mob/living/M, var/removed, var/datum/reagents/holder)
	. = ..()
	if(M.has_trait(/decl/trait/metabolically_inert))
		return
	M.add_chemical_effect(CE_BLOODRESTORE, 8 * removed)

/decl/material/solid/metal/tin
	name = "tin"
	uid = "solid_tin"
	lore_text = "A soft metal that can be cut without much force. Used in many alloys."
	melting_point = 505
	boiling_point = 2875
	color = "#c5c5a8"
	hardness = MAT_VALUE_FLEXIBLE
	construction_difficulty = MAT_VALUE_EASY_DIY
	reflectiveness = MAT_VALUE_MATTE

/decl/material/solid/metal/lead
	name = "lead"
	uid = "solid_lead"
	lore_text = "A very soft, heavy and poisonous metal. You probably shouldn't lick it."
	melting_point = 600
	boiling_point = 2022
	color = "#3f3f4d"
	hardness = MAT_VALUE_FLEXIBLE
	construction_difficulty = MAT_VALUE_NORMAL_DIY
	reflectiveness = MAT_VALUE_MATTE
	taste_description = "metallic sugar"
	toxicity = 1
	temperature_burn_milestone_material = /decl/material/solid/metal/lead

/decl/material/solid/metal/zinc
	name = "zinc"
	uid = "solid_zinc"
	lore_text = "A dull-looking metal with some use in alloying."
	melting_point = 692
	boiling_point = 1180
	color = "#92aae4"
	construction_difficulty = MAT_VALUE_NORMAL_DIY
	reflectiveness = MAT_VALUE_MATTE

/decl/material/solid/metal/chromium
	name = "chromium"
	uid = "solid_chromium"
	lore_text = "A heavy metal with near perfect reflectiveness. Used in stainless alloys."
	color = "#dadada"
	integrity = 200
	burn_armor = 15 // Strong against laser weaponry, but not as good as OCP.
	melting_point = 2180
	boiling_point = 2944
	icon_base = 'icons/turf/walls/solid.dmi'
	icon_reinf = 'icons/turf/walls/reinforced.dmi'
	wall_flags = PAINT_PAINTABLE|PAINT_STRIPABLE|WALL_HAS_EDGES
	use_reinf_state = null
	value = 1.5
	weight = MAT_VALUE_VERY_HEAVY
	hardness = MAT_VALUE_HARD + 10
	construction_difficulty = MAT_VALUE_VERY_HARD_DIY
	reflectiveness = MAT_VALUE_MIRRORED

// Adminspawn only, do not let anyone get this.
/decl/material/solid/metal/alienalloy
	name = "dense alloy"
	uid = "solid_alienalloy"
	color = "#6c7364"
	integrity = 1200
	melting_point = 6000       // Hull plating.
	explosion_resistance = 200 // Hull plating.
	hardness = 500
	weight = MAT_VALUE_VERY_HEAVY
	wall_support_value = MAT_VALUE_VERY_HEAVY
	hidden_from_codex = TRUE
	value = 3
	default_solid_form = /obj/item/stack/material/cubes
	exoplanet_rarity_plant = MAT_RARITY_NOWHERE
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE
	icon_base = 'icons/turf/walls/solid.dmi'
	icon_reinf = 'icons/turf/walls/reinforced.dmi'
	use_reinf_state = null
	wall_flags = PAINT_PAINTABLE|PAINT_STRIPABLE|WALL_HAS_EDGES

// Likewise.
/decl/material/solid/metal/alienalloy/elevatorium
	name = "elevator panelling"
	uid = "solid_elevator"
	color = "#666666"
	hidden_from_codex = TRUE
	default_solid_form = /obj/item/stack/material/sheet
	exoplanet_rarity_plant = MAT_RARITY_NOWHERE
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE

/decl/material/solid/metal/tungsten
	name = "tungsten"
	uid = "solid_tungsten"
	lore_text = "A chemical element, and a strong oxidising agent."
	weight = MAT_VALUE_VERY_HEAVY
	taste_mult = 0 //no taste
	color = "#dcdcdc"
	value = 0.5
	melting_point = 3422 CELSIUS
