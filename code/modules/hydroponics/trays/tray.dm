/obj/machinery/portable_atmospherics/hydroponics
	name = "hydroponics tray"
	desc = "A mechanical basin designed to nurture plants and other aquatic life. It has various useful sensors."
	icon = 'icons/obj/hydroponics/hydroponics_machines.dmi'
	icon_state = "hydrotray3"
	density = TRUE
	anchored = TRUE
	volume = 100
	construct_state = /decl/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0
	atom_flags = ATOM_FLAG_OPEN_CONTAINER | ATOM_FLAG_CLIMBABLE | ATOM_FLAG_NO_CHEM_CHANGE

	var/mechanical = 1         // Set to 0 to stop it from drawing the alert lights.
	var/base_name = "tray"

	// Plant maintenance vars.
	var/waterlevel = 100       // Water (max 100)
	var/nutrilevel = 10        // Nutrient (max 10)
	var/pestlevel = 0          // Pests (max 10)
	var/weedlevel = 0          // Weeds (max 10)

	// Tray state vars.
	var/dead = 0               // Is it dead?
	var/harvest = 0            // Is it ready to harvest?
	var/age = 0                // Current plant age
	var/sampled = 0            // Have we taken a sample?

	// Harvest/mutation mods.
	var/yield_mod = 0          // Modifier to yield
	var/mutation_mod = 0       // Modifier to mutation chance
	var/toxins = 0             // Toxicity in the tray?
	var/mutation_level = 0     // When it hits 100, the plant mutates.
	var/tray_light = 5         // Supplied lighting.

	// Mechanical concerns.
	var/plant_health = 0       // Plant health.
	var/lastproduce = 0        // Last time tray was harvested
	var/closed_system          // If set, the tray will attempt to take atmos from a pipe.
	var/force_update           // Set this to bypass the cycle time check.
	var/obj/temp_chem_holder   // Something to hold reagents during process_reagents()

	// Counter used by bees.
	var/pollen = 0

	// Seed details/line data.
	var/datum/seed/seed = null // The currently planted seed

	// Reagent information for process(), consider moving this to a controller along
	// with cycle information under 'mechanical concerns' at some point.
	var/static/list/toxic_reagents = list(
		/decl/material/liquid/antitoxins =         -2,
		/decl/material/liquid/fuel/hydrazine =      2.5,
		/decl/material/liquid/acetone =	            1,
		/decl/material/liquid/acid =                1.5,
		/decl/material/liquid/acid/hydrochloric =   1.5,
		/decl/material/liquid/acid/polyacid =       3,
		/decl/material/liquid/weedkiller =          3,
		/decl/material/solid/metal/radium =         2
	)
	var/static/list/nutrient_reagents = list(
		/decl/material/liquid/drink/milk =          0.1,
		/decl/material/liquid/alcohol/beer =        0.25,
		/decl/material/solid/phosphorus =           0.1,
		/decl/material/liquid/nutriment/sugar =     0.1,
		/decl/material/liquid/drink/sodawater =     0.1,
		/decl/material/gas/ammonia =                1,
		/decl/material/liquid/nutriment =           1,
		/decl/material/liquid/adminordrazine =      1,
		/decl/material/liquid/fertilizer =          1,
		/decl/material/liquid/fertilizer/compost =  1
	)
	var/static/list/weedkiller_reagents = list(
		/decl/material/liquid/fuel/hydrazine =     -4,
		/decl/material/solid/phosphorus =          -2,
		/decl/material/liquid/nutriment/sugar =     2,
		/decl/material/liquid/acid =               -2,
		/decl/material/liquid/acid/hydrochloric =  -2,
		/decl/material/liquid/acid/polyacid =      -4,
		/decl/material/liquid/weedkiller =         -8,
		/decl/material/liquid/adminordrazine =     -5
	)
	var/static/list/pestkiller_reagents = list(
		/decl/material/liquid/nutriment/sugar =     2,
		/decl/material/liquid/bromide =            -2,
		/decl/material/gas/methyl_bromide =        -4,
		/decl/material/liquid/adminordrazine =     -5
	)
	var/static/list/water_reagents = list(
		/decl/material/liquid/water =               1,
		/decl/material/liquid/adminordrazine =      1,
		/decl/material/liquid/drink/milk =          0.9,
		/decl/material/liquid/alcohol/beer =        0.7,
		/decl/material/liquid/fuel/hydrazine =     -2,
		/decl/material/solid/phosphorus =          -0.5,
		/decl/material/liquid/water =               1,
		/decl/material/liquid/drink/sodawater =     1
	)

	// Beneficial reagents also have values for modifying yield_mod and mut_mod (in that order).
	var/static/list/beneficial_reagents = list(
		/decl/material/liquid/alcohol/beer =       list( -0.05, 0,   0  ),
		/decl/material/liquid/fuel/hydrazine =     list( -2,    0,   0  ),
		/decl/material/solid/phosphorus =          list( -0.75, 0,   0  ),
		/decl/material/liquid/drink/sodawater =    list(  0.1,  0,   0  ),
		/decl/material/liquid/acid =               list( -1,    0,   0  ),
		/decl/material/liquid/acid/hydrochloric =  list( -1,    0,   0  ),
		/decl/material/liquid/acid/polyacid =      list( -2,    0,   0  ),
		/decl/material/liquid/weedkiller =         list( -2,    0,   0.2),
		/decl/material/gas/ammonia =               list(  0.5,  0.2, 0.2),
		/decl/material/liquid/nutriment =          list(  0.5,  0.1, 0  ),
		/decl/material/solid/metal/radium =        list( -1.5,  0,   0.2),
		/decl/material/liquid/adminordrazine =     list(  1,    1,   1  ),
		/decl/material/liquid/fertilizer =         list(  0,    0.2, 0.2),
		/decl/material/liquid/fertilizer/compost = list(  0,    0.2, 0.2)
	)

	// Mutagen list specifies minimum value for the mutation to take place, rather
	// than a bound as the lists above specify.
	var/static/list/mutagenic_reagents = list(
		/decl/material/solid/metal/radium =  8,
		/decl/material/liquid/mutagenics =  15
	)

/obj/machinery/portable_atmospherics/hydroponics/proc/set_seed(new_seed, reset_values)

	if(seed == new_seed)
		return

	seed = new_seed

	if(seed?.scannable_result)
		set_extension(src, /datum/extension/scannable, seed.scannable_result)
	else if(has_extension(src, /datum/extension/scannable))
		remove_extension(src, /datum/extension/scannable)

	dead = 0
	age = 0
	sampled = 0
	harvest = 0
	plant_health = seed ? seed.get_trait(TRAIT_ENDURANCE) : 0

	if(reset_values)
		yield_mod = 0
		mutation_mod = 0
		lastproduce = 0
		weedlevel = 0

	check_plant_health()
	update_icon()

/obj/machinery/portable_atmospherics/hydroponics/attack_ghost(var/mob/observer/ghost/user)
	if(!(harvest && seed && ispath(seed.product_type, /mob)))
		return

	if(!user.can_admin_interact())
		return

	var/response = alert(user, "Are you sure you want to harvest this [seed.display_name]?", "Living plant request", "Yes", "No")
	if(response == "Yes")
		harvest()

/obj/machinery/portable_atmospherics/hydroponics/Initialize()
	if(!mechanical)
		construct_state = /decl/machine_construction/noninteractive
	. = ..()
	temp_chem_holder = new()
	temp_chem_holder.create_reagents(10)
	temp_chem_holder.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
	create_reagents(200)
	if(mechanical)
		connect()
	update_icon()
	STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_ALL)
	START_PROCESSING(SSplants, src)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/portable_atmospherics/hydroponics/Destroy()
	STOP_PROCESSING(SSplants, src)
	. = ..()

/obj/machinery/portable_atmospherics/hydroponics/LateInitialize()
	. = ..()
	if(locate(/obj/item/seeds) in get_turf(src))
		plant()

/obj/machinery/portable_atmospherics/hydroponics/bullet_act(var/obj/item/projectile/Proj)

	if(seed && seed.get_trait(TRAIT_IMMUTABLE) > 0)
		return

	//Override for somatoray projectiles.
	if(istype(Proj ,/obj/item/projectile/energy/floramut)&& prob(20))
		if(istype(Proj, /obj/item/projectile/energy/floramut/gene))
			var/obj/item/projectile/energy/floramut/gene/G = Proj
			if(seed)
				set_seed(seed.diverge_mutate_gene(G.gene, src), reset_values = FALSE)
		else
			mutate(1)
			return
	else if(istype(Proj ,/obj/item/projectile/energy/florayield) && prob(20))
		yield_mod = min(10,yield_mod+rand(1,2))
		return

	..()

/obj/machinery/portable_atmospherics/hydroponics/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASS_FLAG_TABLE))
		return 1
	else
		return !density

/obj/machinery/portable_atmospherics/hydroponics/proc/check_plant_health(var/icon_update = 1)
	if(seed && !dead && plant_health <= 0)
		die()
	check_level_sanity()
	if(icon_update)
		update_icon()

/obj/machinery/portable_atmospherics/hydroponics/proc/die()
	dead = 1
	mutation_level = 0
	harvest = 0
	weedlevel += 1
	pestlevel = 0

//Process reagents being input into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()

	if(!reagents) return

	if(reagents.total_volume <= 0)
		return

	reagents.trans_to_obj(temp_chem_holder, min(reagents.total_volume,rand(1,3)))

	for(var/decl/material/reagent as anything in temp_chem_holder.reagents.reagent_volumes)

		var/reagent_total = REAGENT_VOLUME(temp_chem_holder.reagents, reagent)

		if(seed && !dead)
			//Handle some general level adjustments.
			if(toxic_reagents[reagent.type])
				toxins += toxic_reagents[reagent.type]         * reagent_total
			if(weedkiller_reagents[reagent.type])
				weedlevel += weedkiller_reagents[reagent.type] * reagent_total
			if(pestkiller_reagents[reagent.type])
				pestlevel += pestkiller_reagents[reagent.type] * reagent_total

			// Beneficial reagents have a few impacts along with health buffs.
			if(beneficial_reagents[reagent.type])
				plant_health += beneficial_reagents[reagent.type][1] * reagent_total
				yield_mod += beneficial_reagents[reagent.type][2]    * reagent_total
				mutation_mod += beneficial_reagents[reagent.type][3] * reagent_total

			// Mutagen is distinct from the previous types and mostly has a chance of proccing a mutation.
			if(mutagenic_reagents[reagent.type])
				mutation_level += reagent_total*mutagenic_reagents[reagent.type]+mutation_mod

		// Handle nutrient refilling.
		if(nutrient_reagents[reagent.type])
			nutrilevel += nutrient_reagents[reagent.type]  * reagent_total

		// Handle water and water refilling.
		var/water_added = 0
		if(water_reagents[reagent.type])
			var/water_input = water_reagents[reagent.type] * reagent_total
			water_added += water_input
			waterlevel += water_input

		// Water dilutes toxin level.
		if(water_added > 0)
			toxins -= round(water_added/4)

	temp_chem_holder.reagents.clear_reagents()
	check_plant_health()

//Harvests the product of a plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/harvest(mob/user)

	//Harvest the product of the plant,
	if(!seed || !harvest)
		return

	if(closed_system)
		if(user) to_chat(user, "You can't harvest from the plant while the lid is shut.")
		return

	if(user)
		. = seed.harvest(user,yield_mod)
	else
		. = seed.harvest(get_turf(src),yield_mod)

	// Reset values.
	harvest = 0
	lastproduce = age

	if(!seed.get_trait(TRAIT_HARVEST_REPEAT))
		yield_mod = 0
		set_seed(null)

	check_plant_health()

//Clears out a dead plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/remove_dead(var/mob/user, var/silent)
	if(!dead || !seed)
		return

	if(closed_system)
		if(!silent)
			to_chat(user, SPAN_WARNING("You can't remove the dead [seed.display_name] while the lid is shut."))
		return FALSE

	if(!silent)
		to_chat(user, SPAN_NOTICE("You remove the dead [seed.display_name]."))

	set_seed(null)

	return TRUE

// If a weed growth is sufficient, this proc is called.
/obj/machinery/portable_atmospherics/hydroponics/proc/weed_invasion()

	set_seed(SSplants.seeds[pick(list("reishi", "nettles", "amanita", "mushrooms", "plumphelmet", "towercap", "harebells", "weeds"))], reset_values = FALSE)

	if(!seed)
		return //Weed does not exist, someone fucked up.

	age = 0
	harvest = 0
	weedlevel = 0
	pestlevel = 0
	sampled = 0
	update_icon()
	visible_message("<span class='notice'>[src] has been overtaken by [seed.display_name].</span>")

	return

/obj/machinery/portable_atmospherics/hydroponics/proc/mutate(var/severity)

	// No seed, no mutations.
	if(!seed)
		return

	// Check if we should even bother working on the current seed datum.
	if(seed.mutants && seed.mutants.len && severity > 1)
		mutate_species()
		return

	// We need to make sure we're not modifying one of the global seed datums.
	// If it's not in the global list, then no products of the line have been
	// harvested yet and it's safe to assume it's restricted to this tray.
	if(!isnull(SSplants.seeds[seed.name]))
		set_seed(seed.diverge(), reset_values = FALSE)
	seed.mutate(severity, src)

	return

/obj/machinery/portable_atmospherics/hydroponics/verb/setlight()
	set name = "Set Light"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated())
		return
	if(ishuman(usr) || isrobot(usr))
		var/new_light = input("Specify a light level.") as null|anything in list(0,1,2,3,4,5,6,7,8,9,10)
		if(new_light)
			tray_light = new_light
			to_chat(usr, "You set the tray to a light level of [tray_light] lumens.")
	return

/obj/machinery/portable_atmospherics/hydroponics/proc/check_level_sanity()
	//Make sure various values are sane.
	if(seed)
		plant_health = max(0, min(seed.get_trait(TRAIT_ENDURANCE), plant_health))
	else
		plant_health = 0
		dead = 0

	mutation_level = max(0,min(mutation_level,100))
	nutrilevel =     max(0,min(nutrilevel,10))
	waterlevel =     max(0,min(waterlevel,100))
	pestlevel =      max(0,min(pestlevel,10))
	weedlevel =      max(0,min(weedlevel,10))
	toxins =         max(0,min(toxins,10))

/obj/machinery/portable_atmospherics/hydroponics/proc/mutate_species()

	var/newseed = seed?.get_mutant_variant()
	if(!newseed || !(newseed in SSplants.seeds))
		return

	var/previous_plant = seed.display_name
	set_seed(SSplants.seeds[newseed])
	mutate(1)
	plant_health = seed.get_trait(TRAIT_ENDURANCE) // re-run in case mutation changed our endurance

	update_icon()
	visible_message("<span class='danger'>The </span><span class='notice'>[previous_plant]</span><span class='danger'> has suddenly mutated into </span><span class='notice'>[seed.display_name]!</span>")

	return

/obj/machinery/portable_atmospherics/hydroponics/attackby(var/obj/item/used_item, var/mob/user)

	if(istype(used_item, /obj/item/food/grown))
		var/obj/item/food/grown/bulb = used_item
		if(bulb.seed?.grown_is_seed)
			plant_seed(user, bulb)
			return TRUE

	if(IS_HOE(used_item))

		if(weedlevel > 0)
			if(!used_item.do_tool_interaction(TOOL_HOE, user, src, 2 SECONDS, start_message = "uprooting the weeds in", success_message = "weeding") || weedlevel <= 0 || QDELETED(src))
				return TRUE
			weedlevel = 0
			update_icon()
			if(seed)
				var/needed_skill = seed.mysterious ? SKILL_ADEPT : SKILL_BASIC
				if(!user.skill_check(SKILL_BOTANY, needed_skill))
					plant_health -= rand(40,60)
					check_plant_health()
		else
			to_chat(user, SPAN_WARNING("This plot is completely devoid of weeds. It doesn't need uprooting."))
		return TRUE

	if(IS_SHOVEL(used_item))
		if(seed)
			var/removing_seed = seed
			if(used_item.do_tool_interaction(TOOL_SHOVEL, user, src, 3 SECONDS, start_message = "removing \the [seed.display_name] from", success_message = "removing \the [seed.display_name] from") && seed == removing_seed)
				set_seed(null)
		else
			to_chat(user, SPAN_WARNING("There is no plant in \the [src] to remove."))
		return TRUE

	if(!user.check_intent(I_FLAG_HARM))
		var/decl/interaction_handler/sample_interaction = GET_DECL(/decl/interaction_handler/hydroponics/sample)
		if(sample_interaction.is_possible(src, user, used_item))
			sample_interaction.invoked(src, user, used_item)
			return TRUE

	// Handled in afterattack/
	if (ATOM_IS_OPEN_CONTAINER(used_item))
		return FALSE

	if(istype(used_item, /obj/item/chems/syringe))
		var/obj/item/chems/syringe/S = used_item
		if (S.mode == 1)
			if(seed)
				return ..()
			else
				to_chat(user, SPAN_WARNING("There's no plant to inject."))
		else
			if(seed)
				//Leaving this in in case we want to extract from plants later.
				to_chat(user, SPAN_WARNING("You can't get any extract out of this plant."))
			else
				to_chat(user, SPAN_WARNING("There's nothing to draw something from."))
		return TRUE

	if(istype(used_item, /obj/item/seeds))
		plant_seed(user, used_item)
		return TRUE

	if (istype(used_item, /obj/item/plants))
		physical_attack_hand(user) // Harvests and clears out dead plants.
		if(used_item.storage)
			for (var/obj/item/food/grown/G in get_turf(user))
				if(used_item.storage.can_be_inserted(G, user))
					used_item.storage.handle_item_insertion(user, G, TRUE)
		return TRUE

	if ( istype(used_item, /obj/item/plantspray) )

		var/obj/item/plantspray/spray = used_item
		toxins += spray.toxicity
		pestlevel -= spray.pest_kill_str
		weedlevel -= spray.weed_kill_str
		update_icon()
		to_chat(user, "You spray [src] with [used_item].")
		playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
		qdel(used_item)
		check_plant_health()
		return TRUE

	if(mechanical && IS_WRENCH(used_item))

		//If there's a connector here, the portable_atmospherics setup can handle it.
		if(locate(/obj/machinery/atmospherics/portables_connector/) in loc)
			return ..()

		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		anchored = !anchored
		to_chat(user, "You [anchored ? "wrench" : "unwrench"] \the [src].")
		return TRUE

	if(user.check_intent(I_FLAG_HARM) && seed)
		var/force = used_item.expend_attack_force(user)
		if(force)
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			user.visible_message("<span class='danger'>\The [seed.display_name] has been attacked by [user] with \the [used_item]!</span>")
			playsound(get_turf(src), used_item.hitsound, 100, 1)
			if(!dead)
				plant_health -= force
				check_plant_health()
			return TRUE

	if(mechanical)
		return component_attackby(used_item, user)

	return ..()

// S can also be an instance of /obj/item/food/grown
/obj/machinery/portable_atmospherics/hydroponics/proc/plant_seed(var/mob/user, var/obj/item/seeds/S)

	if(seed)
		to_chat(user, SPAN_WARNING("\The [src] already has something growing in it!"))
		return

	var/plant_noun
	var/datum/seed/planting_seed = S.seed
	if(istype(S))
		planting_seed = S.seed
		plant_noun = "[planting_seed?.product_name] [planting_seed.seed_noun]"
	else if(istype(S, /obj/item/food/grown))
		var/obj/item/food/grown/fruit = S
		planting_seed = fruit.seed
		plant_noun = "[planting_seed?.product_name]"
	else if(istype(S, /obj/item/food/processed_grown))
		var/obj/item/food/processed_grown/fruit = S
		planting_seed = fruit.seed
		plant_noun = "[planting_seed?.product_name]"
	else
		CRASH("Invalid or null value passed to plant_seed(): [S || "NULL"]")

	if(!istype(planting_seed))
		if(istype(S))
			to_chat(user, SPAN_WARNING("\The [S] seems to be empty. You throw it away."))
		else
			to_chat(user, SPAN_WARNING("\The [S] seems to be rotten. You throw it away."))
		qdel(S)
		return

	if(planting_seed.hydrotray_only && !mechanical)
		to_chat(user, SPAN_WARNING("\The [plant_noun] can only be planted in a hydroponics tray."))
		return

	to_chat(user, SPAN_NOTICE("You plant the [plant_noun]."))
	lastproduce = 0
	set_seed(planting_seed) //Grab the seed datum.
	age = 1

	//Snowflakey, maybe move this to the seed datum
	// re-running to adjust based on planting method
	plant_health = (istype(S, /obj/item/seeds/extracted/cutting) ? round(seed.get_trait(TRAIT_ENDURANCE)/rand(2,5)) : seed.get_trait(TRAIT_ENDURANCE))

	var/needed_skill = seed.mysterious ? SKILL_ADEPT : SKILL_BASIC
	if(prob(user.skill_fail_chance(SKILL_BOTANY, 40, needed_skill)))
		dead = 1
		plant_health = 0

	qdel(S)
	check_plant_health()

/obj/machinery/portable_atmospherics/hydroponics/attack_robot(mob/user)
	return FALSE // no hands

/obj/machinery/portable_atmospherics/hydroponics/physical_attack_hand(mob/user)
	if(harvest)
		harvest(user)
		return TRUE
	if(dead)
		remove_dead(user)
		return TRUE
	return FALSE

/obj/machinery/portable_atmospherics/hydroponics/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(!seed)
		. += "\The [src] is empty."
		return

	. += SPAN_NOTICE("\A [seed.display_name] is growing here.")

	if(user.skill_check(SKILL_BOTANY, SKILL_BASIC))
		if(weedlevel >= 5)
			. += "\The [src] is <span class='danger'>infested with weeds</span>!"
		if(pestlevel >= 5)
			. += "\The [src] is <span class='danger'>infested with tiny worms</span>!"

		if(dead)
			. += "<span class='danger'>The [seed.display_name] is dead.</span>"
		else if(plant_health <= (seed.get_trait(TRAIT_ENDURANCE)/ 2))
			. += "The [seed.display_name] looks <span class='danger'>unhealthy</span>."

	if(!Adjacent(user))
		return

	if(mechanical)
		var/turf/T = loc
		var/datum/gas_mixture/environment

		if(closed_system && (get_port() || holding))
			environment = air_contents

		if(!environment)
			if(istype(T))
				environment = T.return_air()

		if(!environment) //We're in a crate or nullspace, bail out.
			return

		var/light_string
		if(closed_system)
			light_string = "that the internal lights are set to [tray_light] lumens"
		else
			var/light_available = T.get_lumcount() * 5
			light_string = "a light level of [light_available] lumens"

		. += "Water: [round(waterlevel,0.1)]/100"
		. += "Nutrient: [round(nutrilevel,0.1)]/10"
		. += "The tray's sensor suite is reporting [light_string] and a temperature of [environment.temperature]K."
	else
		if(waterlevel < 20)
			. += SPAN_WARNING("The [seed.display_name] is dry.")
		if(nutrilevel < 2)
			. += SPAN_WARNING("The [seed.display_name]'s growth is stunted due to a lack of nutrients.")

/obj/machinery/portable_atmospherics/hydroponics/verb/close_lid_verb()
	set name = "Toggle Tray Lid"
	set category = "Object"
	set src in view(1)
	if(usr.incapacitated())
		return

	if(ishuman(usr) || isrobot(usr))
		close_lid(usr)
	return

/obj/machinery/portable_atmospherics/hydroponics/proc/close_lid(var/mob/living/user)
	closed_system = !closed_system
	to_chat(user, "You [closed_system ? "close" : "open"] the tray's lid.")
	update_icon()

//proc for trays to spawn pre-planted
/obj/machinery/portable_atmospherics/hydroponics/proc/plant()
	var/obj/item/seeds/S = locate() in get_turf(src)
	if(S.seed)
		set_seed(S.seed)
		age = 1
		// re-running to adjust for planting method
		plant_health = (istype(S, /obj/item/seeds/extracted/cutting) ? round(seed.get_trait(TRAIT_ENDURANCE)/rand(2,5)) : seed.get_trait(TRAIT_ENDURANCE))
		check_plant_health()
	qdel(S)

/obj/machinery/portable_atmospherics/hydroponics/do_simple_ranged_interaction(var/mob/user)
	if(dead)
		remove_dead()
	else if(harvest)
		harvest()
	return TRUE

/obj/machinery/portable_atmospherics/hydroponics/get_alt_interactions(var/mob/user)
	. = ..()
	LAZYADD(., /decl/interaction_handler/hydroponics/close_lid)
	LAZYADD(., /decl/interaction_handler/hydroponics/sample)

/decl/interaction_handler/hydroponics
	abstract_type = /decl/interaction_handler/hydroponics
	expected_target_type = /obj/machinery/portable_atmospherics/hydroponics

/decl/interaction_handler/hydroponics/close_lid
	name = "Open/Close Lid"
	examine_desc = "open or close the lid"

/decl/interaction_handler/hydroponics/close_lid/is_possible(atom/target, mob/user, obj/item/prop)
	var/obj/machinery/portable_atmospherics/hydroponics/tray = target
	return ..() && tray.mechanical

/decl/interaction_handler/hydroponics/close_lid/invoked(atom/target, mob/user, obj/item/prop)
	var/obj/machinery/portable_atmospherics/hydroponics/tray = target
	tray.close_lid(user)

/decl/interaction_handler/hydroponics/sample
	name = "Sample Plant"
	examine_desc = "take a sample"

/decl/interaction_handler/hydroponics/sample/is_possible(atom/target, mob/user, obj/item/prop)
	return ..() && istype(prop) && prop.has_edge() && prop.w_class < ITEM_SIZE_NORMAL

/decl/interaction_handler/hydroponics/sample/invoked(atom/target, mob/user, obj/item/prop)
	var/obj/machinery/portable_atmospherics/hydroponics/tray = target
	if(!tray.seed)
		to_chat(user, SPAN_WARNING("There is nothing to take a sample from in \the [src]."))
		return
	if(tray.sampled)
		to_chat(user, SPAN_WARNING("There's no bits that can be used for a sampling left."))
		return
	if(tray.dead)
		to_chat(user, SPAN_WARNING("The plant is dead."))
		return
	var/needed_skill = tray.seed.mysterious ? SKILL_ADEPT : SKILL_BASIC
	if(prob(user.skill_fail_chance(SKILL_BOTANY, 90, needed_skill)))
		to_chat(user, SPAN_WARNING("You failed to get a usable sample."))
	else
		// Create a sample.
		tray.seed.harvest(user, tray.yield_mod, 1)
	tray.plant_health -= (rand(3,5)*10)

	if(prob(30))
		tray.sampled = 1

	// Bookkeeping.
	tray.check_plant_health()
	tray.force_update = 1
	tray.Process()
