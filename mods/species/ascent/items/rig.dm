// Rigs and gear themselves.
/obj/item/rig/mantid
	name = "alate support exosuit"
	desc = "A powerful support exosuit with integrated power supply, weapon and atmosphere. It's closer to a mech than a rig."
	icon = 'mods/species/ascent/icons/rig/rig.dmi'
	suit_type = "support exosuit"
	armor = list(
		ARMOR_MELEE = ARMOR_MELEE_MAJOR,
		ARMOR_BULLET = 1.1 * ARMOR_BALLISTIC_RESISTANT,
		ARMOR_LASER = 1.1 * ARMOR_LASER_RIFLES,
		ARMOR_ENERGY = ARMOR_ENERGY_RESISTANT,
		ARMOR_BOMB = ARMOR_BOMB_RESISTANT,
		ARMOR_BIO = ARMOR_BIO_SHIELDED,
		ARMOR_RAD = ARMOR_RAD_SHIELDED
	)
	armor_type = /datum/extension/armor/ablative
	armor_degradation_speed = 0.05
	online_slowdown = 0
	offline_slowdown = 1
	equipment_overlay_icon = null

	air_supply = /obj/item/tank/mantid/reactor
	cell =       /obj/item/cell/mantid
	chest =      /obj/item/clothing/suit/space/rig/mantid
	helmet =     /obj/item/clothing/head/helmet/space/rig/mantid
	boots =      /obj/item/clothing/shoes/magboots/rig/mantid
	gloves =     /obj/item/clothing/gloves/rig/mantid

	update_visible_name = TRUE
	_gyne_onmob_icon = 'mods/species/ascent/icons/rig/rig_gyne.dmi'
	initial_modules = list(
		/obj/item/rig_module/vision/thermal,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/chem_dispenser/mantid,
		/obj/item/rig_module/device/multitool,
		/obj/item/rig_module/device/cable_coil,
		/obj/item/rig_module/device/welder,
		/obj/item/rig_module/device/clustertool,
		/obj/item/rig_module/mounted/plasmacutter,
		/obj/item/rig_module/maneuvering_jets
		)
	req_access = list(access_ascent)
	var/mantid_caste = /decl/species/mantid::uid

// Renamed blade.
/obj/item/rig_module/mounted/energy_blade/mantid
	name = "nanoblade projector"
	desc = "A fusion-powered blade nanofabricator of Ascent design."
	interface_name = "nanoblade"
	interface_desc = "A fusion-powered blade nanofabricator of Ascent design."
	icon = 'mods/species/ascent/icons/ascent.dmi'
	icon_state = "blade"
	usable = FALSE
	gun = null

/obj/item/rig_module/mounted/flechette_rifle
	name = "flechette rifle"
	desc = "A flechette nanofabricator and launch system of Ascent design."
	interface_name = "flechette rifle"
	interface_desc = "A flechette nanofabricator and launch system of Ascent design."
	icon = 'mods/species/ascent/icons/ascent.dmi'
	icon_state = "rifle"
	gun = /obj/item/gun/magnetic/railgun/flechette/ascent

/obj/item/rig_module/mounted/particle_rifle
	name = "particle rifle"
	desc = "A mounted particle rifle of Ascent design."
	interface_name = "particle rifle"
	interface_desc = "A mounted particle rifle of Ascent design."
	icon = 'mods/species/ascent/icons/ascent.dmi'
	icon_state = "rifle"
	gun = /obj/item/gun/energy/particle

/obj/item/rig_module/device/multitool
	name = "mantid integrated multitool"
	desc = "A limited-sentience integrated multitool capable of interfacing with any number of systems."
	interface_name = "multitool"
	interface_desc = "A limited-sentience integrated multitool capable of interfacing with any number of systems."
	device = /obj/item/multitool/mantid
	icon = 'mods/species/ascent/icons/ascent.dmi'
	icon_state = "multitool"
	usable = FALSE
	selectable = TRUE

/obj/item/rig_module/device/multitool/get_tool_quality(archetype)
	return device?.get_tool_quality(archetype)

/obj/item/rig_module/device/multitool/get_tool_speed(archetype)
	return device?.get_tool_speed(archetype)

/obj/item/rig_module/device/cable_coil
	name = "mantid cable extruder"
	desc = "A cable nanofabricator of Ascent design."
	interface_name = "cable fabricator"
	interface_desc = "A cable nanofabricator of Ascent design."
	device = /obj/item/stack/cable_coil/fabricator
	icon = 'mods/species/ascent/icons/ascent.dmi'
	icon_state = "cablecoil"
	usable = FALSE
	selectable = TRUE

/obj/item/rig_module/device/welder
	name = "mantid welding arm"
	desc = "An electrical cutting torch of Ascent design."
	interface_name = "welding arm"
	interface_desc = "An electrical cutting torch of Ascent design."
	icon = 'mods/species/ascent/icons/ascent.dmi'
	icon_state = "welder1"
	engage_string = "Toggle Welder"
	device = /obj/item/weldingtool/electric/mantid
	usable = TRUE
	selectable = TRUE

/obj/item/rig_module/device/clustertool
	name = "mantid clustertool"
	desc = "A complex assembly of self-guiding, modular heads capable of performing most manual tasks."
	interface_name = "modular clustertool"
	interface_desc = "A complex assembly of self-guiding, modular heads capable of performing most manual tasks."
	icon = 'mods/species/ascent/icons/ascent.dmi'
	icon_state = "clustertool"
	engage_string = "Select Mode"
	device = /obj/item/clustertool
	usable = TRUE
	selectable = TRUE

/obj/item/rig_module/device/clustertool/get_tool_quality(archetype)
	return device?.get_tool_quality(archetype)

/obj/item/rig_module/device/clustertool/get_tool_speed(archetype)
	return device?.get_tool_speed(archetype)

// Atmosphere/jetpack filler.
/obj/item/tank/mantid
	name = "mantid gas tank"
	icon = 'mods/species/ascent/icons/tank.dmi'
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 180

/obj/item/tank/mantid/methyl_bromide
	starting_pressure = list(/decl/material/gas/methyl_bromide = 6 ATM)

/obj/item/tank/mantid/oxygen
	name = "mantid oxygen tank"
	starting_pressure = list(OXYGEN = 6 ATM)

// Boilerplate due to hard typechecks in jetpack code. Todo: make it an extension.
/obj/item/tank/jetpack/ascent
	name = "catalytic maneuvering pack"
	desc = "An integrated Ascent gas processing plant and maneuvering pack that continuously synthesises 'breathable' atmosphere and propellant."
	icon = 'mods/species/ascent/icons/clothing/jetpack.dmi'
	var/refill_gas_type = /decl/material/gas/methyl_bromide
	var/gas_regen_amount = 0.03
	var/gas_regen_cap = 30

/obj/item/tank/jetpack/ascent/Initialize()
	starting_pressure = list()
	starting_pressure[refill_gas_type] = 6 ATM
	. = ..()

/obj/item/tank/jetpack/ascent/Process()
	..()
	if(air_contents.total_moles < gas_regen_cap)
		air_contents.adjust_gas(refill_gas_type, gas_regen_amount)

/obj/item/tank/mantid/reactor
	name = "mantid gas reactor"
	desc = "A mantid gas processing plant that continuously synthesises 'breathable' atmosphere."
	var/charge_cost = 12
	var/refill_gas_type = /decl/material/gas/methyl_bromide
	var/gas_regen_amount = 0.05
	var/gas_regen_cap = 50

/obj/item/tank/mantid/reactor/Initialize()
	starting_pressure = list()
	starting_pressure[refill_gas_type] = 6 ATM
	. = ..()

/obj/item/tank/mantid/reactor/Process()
	..()
	var/obj/item/rig/holder = loc
	if(air_contents.total_moles < gas_regen_cap && istype(holder) && holder.cell && holder.cell.use(charge_cost))
		air_contents.adjust_gas(refill_gas_type, gas_regen_amount)

// Chem dispenser.
/obj/item/rig_module/chem_dispenser/mantid
	name = "mantid chemical injector"
	desc = "A compact chemical dispenser of mantid design."
	interface_name = "mantid chemical injector"
	interface_desc = "A compact chemical dispenser of mantid design."
	icon = 'mods/species/ascent/icons/ascent.dmi'
	icon_state = "injector"
	charges = list(
		list("bromide",             "bromide",             /decl/material/liquid/bromide,            80),
		list("crystallizing agent", "crystallizing agent", /decl/material/liquid/crystal_agent,      80),
		list("antibiotics",         "antibiotics",         /decl/material/liquid/antibiotics,        80),
		list("painkillers",         "painkillers",         /decl/material/liquid/painkillers/strong, 80)
	)

// Rig definitions.
/obj/item/rig/mantid/gyne
	name = "gyne support exosuit"
	armor = list(
		ARMOR_MELEE = ARMOR_MELEE_VERY_HIGH,
		ARMOR_BULLET = ARMOR_BALLISTIC_RIFLE,
		ARMOR_LASER = ARMOR_LASER_RIFLES,
		ARMOR_ENERGY = ARMOR_ENERGY_RESISTANT,
		ARMOR_BOMB = ARMOR_BOMB_RESISTANT,
		ARMOR_BIO = ARMOR_BIO_SHIELDED,
		ARMOR_RAD = ARMOR_RAD_SHIELDED
	)
	mantid_caste = /decl/species/mantid/gyne::uid
	initial_modules = list(
		/obj/item/rig_module/vision/thermal,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/chem_dispenser/mantid,
		/obj/item/rig_module/mounted/energy_blade/mantid,
		/obj/item/rig_module/mounted/flechette_rifle,
		/obj/item/rig_module/mounted/particle_rifle,
		/obj/item/rig_module/device/multitool,
		/obj/item/rig_module/device/cable_coil,
		/obj/item/rig_module/device/welder,
		/obj/item/rig_module/device/clustertool,
		/obj/item/rig_module/mounted/plasmacutter,
		/obj/item/rig_module/maneuvering_jets
	)

/obj/item/rig/mantid/mob_can_equip(mob/user, slot, disable_warning = FALSE, force = FALSE, ignore_equipped = FALSE)
	. = ..()
	if(!. || slot != slot_back_str || !mantid_caste)
		return
	var/decl/species/my_species = user?.get_species()
	if(my_species?.uid != mantid_caste)
		to_chat(user, SPAN_WARNING("Your species cannot wear \the [src]."))
		return FALSE

/obj/item/clothing/head/helmet/space/rig/mantid
	light_color = "#00ffff"
	desc = "More like a torpedo casing than a helmet."
	bodytype_equip_flags = BODY_EQUIP_FLAG_GYNE | BODY_EQUIP_FLAG_ALATE
	icon = 'mods/species/ascent/icons/rig/rig_helmet.dmi'
	_gyne_onmob_icon = 'mods/species/ascent/icons/rig/rig_helmet_gyne.dmi'

/obj/item/clothing/suit/space/rig/mantid
	desc = "It's closer to a mech than a suit."
	bodytype_equip_flags = BODY_EQUIP_FLAG_GYNE | BODY_EQUIP_FLAG_ALATE
	icon = 'mods/species/ascent/icons/rig/rig_chest.dmi'
	allowed = list(
		/obj/item/clustertool,
		/obj/item/gun/energy/particle/small,
		/obj/item/weldingtool/electric/mantid,
		/obj/item/multitool/mantid,
		/obj/item/stack/medical/resin,
		/obj/item/chems/drinks/cans/waterbottle/ascent
	)
	_gyne_onmob_icon = 'mods/species/ascent/icons/rig/rig_chest_gyne.dmi'

/obj/item/clothing/shoes/magboots/rig/mantid
	icon = 'mods/species/ascent/icons/rig/rig_boots.dmi'
	desc = "It's like a highly advanced forklift."
	bodytype_equip_flags = BODY_EQUIP_FLAG_GYNE | BODY_EQUIP_FLAG_ALATE
	_gyne_onmob_icon = 'mods/species/ascent/icons/rig/rig_boots_gyne.dmi'

/obj/item/clothing/gloves/rig/mantid
	icon = 'mods/species/ascent/icons/rig/rig_gloves.dmi'
	desc = "They look like a cross between a can opener and a Swiss army knife the size of a shoebox."
	bodytype_equip_flags = BODY_EQUIP_FLAG_GYNE | BODY_EQUIP_FLAG_ALATE
	_gyne_onmob_icon = 'mods/species/ascent/icons/rig/rig_gloves_gyne.dmi'
