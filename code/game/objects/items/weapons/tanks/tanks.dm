#define TANK_IDEAL_PRESSURE 1015 //Arbitrary.

var/global/tank_bomb_severity = 1
#define TANK_BOMB_DVSTN_FACTOR (0.15 * global.tank_bomb_severity)
#define TANK_BOMB_HEAVY_FACTOR (0.35 * global.tank_bomb_severity)
#define TANK_BOMB_LIGHT_FACTOR (0.80 * global.tank_bomb_severity)
#define TANK_BOMB_FLASH_FACTOR (1.25 * global.tank_bomb_severity)
#define MAX_TANK_BOMB_SEVERITY 20

/client/proc/verb_adjust_tank_bomb_severity()
	set name = "Adjust Tank Bomb Severity"
	set category = "Debug"

	if(check_rights(R_DEBUG))
		var/next_input = input("Enter a new bomb severity between 1 and [MAX_TANK_BOMB_SEVERITY].", "Tank Bomb Severity", global.tank_bomb_severity) as num|null
		if(isnum(next_input))
			global.tank_bomb_severity = clamp(next_input, 0, MAX_TANK_BOMB_SEVERITY)
			log_and_message_admins("[key_name_admin(mob)] has set the tank bomb severity value to [global.tank_bomb_severity].", mob)

var/global/list/global/tank_gauge_cache = list()

/obj/item/tank
	name = "tank"
	icon = 'icons/obj/items/tanks/tank_blue.dmi'
	icon_state = ICON_STATE_WORLD
	material = /decl/material/solid/metal/steel
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BACK
	w_class = ITEM_SIZE_LARGE
	attack_cooldown = 2*DEFAULT_WEAPON_COOLDOWN
	melee_accuracy_bonus = -30
	throw_speed = 1
	throw_range = 4
	_base_attack_force = 15

	var/gauge_icon = "indicator_tank"
	var/gauge_cap = 6

	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 20
	var/maxintegrity = 20
	var/valve_welded = 0
	var/obj/item/tankassemblyproxy/proxyassembly
	var/volume = 70
	//Used by _onclick/hud/screen_objects.dm internals to determine if someone has messed with our tank or not.
	//If they have and we haven't scanned it with the PDA or gas analyzer then we might just breath whatever they put in it.
	var/manipulated_by = null
	var/failure_temp = 173 //173 deg C Borate seal (yes it should be 153 F, but that's annoying)
	var/leaking = 0
	var/wired = 0
	var/list/starting_pressure //list in format 'xgm gas id' = 'desired pressure at start'

/obj/item/tank/Initialize()
	. = ..()
	proxyassembly = new /obj/item/tankassemblyproxy(src)
	proxyassembly.tank = src

	air_contents = new /datum/gas_mixture(volume, T20C)
	for(var/gas in starting_pressure)
		air_contents.adjust_gas(gas, starting_pressure[gas]*volume/(R_IDEAL_GAS_EQUATION*T20C), 0)
	air_contents.update_values()

	START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/tank/Destroy()
	QDEL_NULL(air_contents)

	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(proxyassembly)

	if(istype(loc, /obj/item/transfer_valve))
		var/obj/item/transfer_valve/TTV = loc
		TTV.remove_tank(src)
		if(!QDELETED(TTV)) // It will delete tanks inside it on qdel.
			qdel(TTV)

	. = ..()

/obj/item/tank/get_single_monetary_worth()
	. = ..()
	for(var/gas in air_contents?.gas)
		var/decl/material/gas_data = GET_DECL(gas)
		. += gas_data.get_value() * air_contents.gas[gas] * GAS_WORTH_MULTIPLIER
	. = max(1, round(.))

/obj/item/tank/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	var/descriptive
	if(!air_contents)
		descriptive = "empty"
	else
		var/celsius_temperature = air_contents.temperature - T0C
		switch(celsius_temperature)
			if(300 to INFINITY)
				descriptive = "furiously hot"
			if(100 to 300)
				descriptive = "hot"
			if(80 to 100)
				descriptive = "warm"
			if(40 to 80)
				descriptive = "lukewarm"
			if(20 to 40)
				descriptive = "room temperature"
			if(-20 to 20)
				descriptive = "cold"
			else
				descriptive = "bitterly cold"
	. += SPAN_NOTICE("\The [src] feels [descriptive].")

	if(proxyassembly.assembly || wired)
		. += SPAN_WARNING("It seems to have [wired? "some wires ": ""][wired && proxyassembly.assembly? "and ":""][proxyassembly.assembly ? "some sort of assembly ":""]attached to it.")
	if(valve_welded)
		. += SPAN_WARNING("\The [src] emergency relief valve has been welded shut!")

/obj/item/tank/attackby(var/obj/item/used_item, var/mob/user)
	if (istype(loc, /obj/item/assembly))
		icon = loc

	if (istype(used_item, /obj/item/scanner/gas))
		return FALSE // allow afterattack to proceed

	if (istype(used_item,/obj/item/latexballon))
		var/obj/item/latexballon/LB = used_item
		LB.blow(src)
		add_fingerprint(user)
		return TRUE

	if(IS_COIL(used_item))
		var/obj/item/stack/cable_coil/C = used_item
		if(C.use(1))
			wired = 1
			to_chat(user, "<span class='notice'>You attach the wires to the tank.</span>")
			update_icon()
		return TRUE

	if(IS_WIRECUTTER(used_item))
		if(wired && proxyassembly.assembly)

			to_chat(user, "<span class='notice'>You carefully begin clipping the wires that attach to the tank.</span>")
			if(do_after(user, 100,src))
				wired = 0
				to_chat(user, "<span class='notice'>You cut the wire and remove the device.</span>")

				var/obj/item/assembly_holder/assy = proxyassembly.assembly
				if(assy.a_left && assy.a_right)
					assy.dropInto(user.loc)
					assy.master = null
					proxyassembly.assembly = null
				else
					if(!proxyassembly.assembly.a_left)
						assy.a_right.dropInto(user.loc)
						assy.a_right.holder = null
						assy.a_right = null
						proxyassembly.assembly = null
						qdel(assy)
				update_icon()

			else
				to_chat(user, "<span class='danger'>You slip and bump the igniter!</span>")
				if(prob(85))
					proxyassembly.receive_signal()
			return TRUE

		else if(wired)
			if(do_after(user, 10, src))
				to_chat(user, "<span class='notice'>You quickly clip the wire from the tank.</span>")
				wired = 0
				update_icon()

		else
			to_chat(user, "<span class='notice'>There are no wires to cut!</span>")
		return TRUE

	if(istype(used_item, /obj/item/assembly_holder))
		if(wired)
			to_chat(user, "<span class='notice'>You begin attaching the assembly to \the [src].</span>")
			if(do_after(user, 50, src))
				assemble_bomb(used_item,user)
			else
				to_chat(user, "<span class='notice'>You stop attaching the assembly.</span>")
		else
			to_chat(user, "<span class='notice'>You need to wire the device up first.</span>")
		return TRUE

	if(IS_WELDER(used_item))
		var/obj/item/weldingtool/welder = used_item
		if(welder.weld(1,user))
			if(!valve_welded)
				to_chat(user, "<span class='notice'>You begin welding \the [src] emergency pressure relief valve.</span>")
				if(do_after(user, 40,src))
					to_chat(user, "<span class='notice'>You carefully weld \the [src] emergency pressure relief valve shut.</span><span class='warning'> \The [src] may now rupture under pressure!</span>")
					valve_welded = 1
					leaking = 0
				else
					global.bombers += "[key_name(user)] attempted to weld \a [src]. [air_contents.temperature-T0C]"
					log_and_message_admins("attempted to weld \a [src]. [air_contents.temperature-T0C]", user)
					if(welder.welding)
						to_chat(user, "<span class='danger'>You accidentally rake \the [used_item] across \the [src]!</span>")
						maxintegrity -= rand(2,6)
						integrity = min(integrity,maxintegrity)
						air_contents.add_thermal_energy(rand(2000,50000))
			else
				to_chat(user, "<span class='notice'>The emergency pressure relief valve has already been welded.</span>")
		add_fingerprint(user)
		return TRUE

	if(istype(used_item, /obj/item/flamethrower))
		var/obj/item/flamethrower/F = used_item
		if(!F.secured || F.tank || !user.try_unequip(src, F))
			return TRUE

		master = F
		F.tank = src
		return TRUE
	return ..()

/obj/item/tank/attack_self(mob/user)
	add_fingerprint(user)
	if (!air_contents)
		return
	ui_interact(user)

// There's GOT to be a better way to do this
	if (proxyassembly.assembly)
		proxyassembly.assembly.attack_self(user)

/obj/item/tank/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/mob/living/location = get_recursive_loc_of_type(/mob/living)

	var/using_internal
	if(istype(location))
		if(location.get_internals() == src)
			using_internal = 1

	// this is the data which will be sent to the ui
	var/data[0]
	data["tankPressure"] = round(air_contents && air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(initial(distribute_pressure))
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
	data["valveOpen"] = using_internal ? 1 : 0
	data["maskConnected"] = 0

	if(istype(location))
		var/mask_check = 0

		if(location.get_internals() == src)	// if tank is current internal
			mask_check = 1
		else if(src in location)		// or if tank is in the mobs possession
			if(!location.get_internals())		// and they do not have any active internals
				mask_check = 1
		else if(istype(loc, /obj/item/rig) && (loc in location))	// or the rig is in the mobs possession
			if(!location.get_internals())		// and they do not have any active internals
				mask_check = 1

		if(mask_check)
			var/obj/item/mask = location.get_equipped_item(slot_wear_mask_str)
			if(mask && (mask.item_flags & ITEM_FLAG_AIRTIGHT))
				data["maskConnected"] = 1
			else if(ishuman(location))
				var/mob/living/human/H = location
				var/obj/item/head = H.get_equipped_item(slot_head_str)
				if(head && (head.item_flags & ITEM_FLAG_AIRTIGHT))
					data["maskConnected"] = 1

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "tanks.tmpl", "Tank", 500, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/item/tank/DefaultTopicState()
	return global.inventory_topic_state

/obj/item/tank/OnTopic(user, href_list)
	if (href_list["dist_p"])
		if (href_list["dist_p"] == "reset")
			distribute_pressure = initial(distribute_pressure)
		else if (href_list["dist_p"] == "max")
			distribute_pressure = TANK_MAX_RELEASE_PRESSURE
		else
			var/cp = text2num(href_list["dist_p"])
			distribute_pressure += cp
		distribute_pressure = min(max(round(distribute_pressure), 0), TANK_MAX_RELEASE_PRESSURE)
		return TOPIC_REFRESH

	if (href_list["stat"])
		toggle_valve(user)
		return TOPIC_REFRESH

/obj/item/tank/proc/toggle_valve(var/mob/user)

	var/mob/living/location
	if(isliving(loc))
		location = loc
	else if(istype(loc,/obj/item/rig))
		var/obj/item/rig/rig = loc
		if(rig.wearer)
			location = rig.wearer
	else
		return

	if(location.get_internals() == src)
		to_chat(user, "<span class='notice'>You close the tank release valve.</span>")
		location.set_internals(null)
	else
		var/can_open_valve
		var/obj/item/mask = location.get_equipped_item(slot_wear_mask_str)
		if(mask && (mask.item_flags & ITEM_FLAG_AIRTIGHT))
			can_open_valve = 1
		else if(ishuman(location))
			var/mob/living/human/H = location
			var/obj/item/head = H.get_equipped_item(slot_head_str)
			if(head && (head.item_flags & ITEM_FLAG_AIRTIGHT))
				can_open_valve = 1

		if(can_open_valve)
			to_chat(user, "<span class='notice'>You open \the [src] valve.</span>")
			location.set_internals(src)
		else
			to_chat(user, "<span class='warning'>You need something to connect to \the [src].</span>")

/obj/item/tank/remove_air(amount)
	. = air_contents.remove(amount)
	if(.)
		queue_icon_update()

/obj/item/tank/proc/remove_air_ratio(ratio, out_group_multiplier = 1)
	. = air_contents.remove_ratio(ratio, out_group_multiplier)
	if(.)
		queue_icon_update()

/obj/item/tank/proc/remove_air_by_flag(flag, amount)
	. = air_contents.remove_by_flag(flag, amount)
	queue_icon_update()

/obj/item/tank/proc/air_adjust_gas(gasid, moles, update = 1)
	. = air_contents.adjust_gas(gasid, moles, update)
	if(.)
		queue_icon_update()

/obj/item/tank/return_air()
	return air_contents

/obj/item/tank/assume_air(datum/gas_mixture/giver)
	. = air_contents.merge(giver)
	check_status()
	queue_icon_update()

/obj/item/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < distribute_pressure)
		distribute_pressure = tank_pressure

	var/datum/gas_mixture/removed = remove_air(distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature))
	if(removed)
		removed.volume = volume_to_return
	return removed

/obj/item/tank/Process()
	air_contents.react()
	check_status()

// TODO: Check if this works without the override argument. Everything in tank code seems to call it, so...
/obj/item/tank/on_update_icon()
	. = ..()
	if(proxyassembly?.assembly || wired)
		add_overlay(overlay_image('icons/obj/items/tanks/tank_components.dmi', "bomb_assembly"))
		if(proxyassembly.assembly)
			var/mutable_appearance/bombthing = new(proxyassembly.assembly)
			bombthing.appearance_flags = RESET_COLOR
			bombthing.pixel_y = -1
			bombthing.pixel_x = -3
			add_overlay(bombthing)

	if(gauge_icon)
		var/gauge_pressure = 0
		if(air_contents)
			gauge_pressure = air_contents.return_pressure()
			if(gauge_pressure > TANK_IDEAL_PRESSURE)
				gauge_pressure = -1
			else
				gauge_pressure = round((gauge_pressure/TANK_IDEAL_PRESSURE)*gauge_cap)
		var/indicator = "[gauge_icon][(gauge_pressure == -1) ? "overload" : gauge_pressure]"
		if(!tank_gauge_cache[indicator])
			tank_gauge_cache[indicator] = image('icons/obj/items/tanks/tank_indicators.dmi', indicator)
		add_overlay(tank_gauge_cache[indicator])

//Handle exploding, leaking, and rupturing of the tank
/obj/item/tank/proc/check_status()
	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()

	if(pressure > TANK_FRAGMENT_PRESSURE)
		if(integrity <= 7)
			if(!istype(loc,/obj/item/transfer_valve))
				log_and_message_admins("Explosive tank rupture! last key to touch the tank was [fingerprintslast].")

			//Give the gas a chance to build up more pressure through reacting
			air_contents.react()
			air_contents.react()
			air_contents.react()

			pressure = air_contents.return_pressure()
			var/strength = ((pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE)

			var/mult = ((air_contents.volume/140)**(1/2)) * (air_contents.total_moles**2/3)/((29*0.64) **2/3) //tanks appear to be experiencing a reduction on scale of about 0.64 total moles
			//tanks appear to be experiencing a reduction on scale of about 0.64 total moles

			var/turf/T = get_turf(src)
			if(!T?.simulated)
				return
			T.hotspot_expose(air_contents.temperature, 70, 1)

			T.assume_air(air_contents)
			explosion(
				get_turf(loc),
				round(min(BOMBCAP_DVSTN_RADIUS, ((mult) * strength) * TANK_BOMB_DVSTN_FACTOR)),
				round(min(BOMBCAP_HEAVY_RADIUS, ((mult) * strength) * TANK_BOMB_HEAVY_FACTOR)),
				round(min(BOMBCAP_LIGHT_RADIUS, ((mult) * strength) * TANK_BOMB_LIGHT_FACTOR)),
				round(min(BOMBCAP_FLASH_RADIUS, ((mult) * strength) * TANK_BOMB_FLASH_FACTOR)),
				)

			var/num_fragments = round(rand(8,10) * sqrt(strength * mult))
			fragmentate(T, num_fragments, 7, list(/obj/item/projectile/bullet/pellet/fragment/tank/small = 7,/obj/item/projectile/bullet/pellet/fragment/tank = 2,/obj/item/projectile/bullet/pellet/fragment/strong = 1))

			if(istype(loc, /obj/item/transfer_valve))
				var/obj/item/transfer_valve/TTV = loc
				TTV.remove_tank(src)
				qdel(TTV)

			if(src)
				qdel(src)
		else
			integrity -=7
	else if(pressure > TANK_RUPTURE_PRESSURE)
		#ifdef FIREDBG
		log_debug("<span class='warning'>[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]</span>")
		#endif

		if(integrity <= 0)
			var/turf/T = get_turf(src)
			if(!T?.simulated)
				return
			T.assume_air(air_contents)
			playsound(get_turf(src), 'sound/weapons/gunshot/shotgun.ogg', 20, 1)
			visible_message("[html_icon(src)] <span class='danger'>\The [src] flies apart!</span>", "<span class='warning'>You hear a bang!</span>")
			T.hotspot_expose(air_contents.temperature, 70, 1)

			var/strength = 1+((pressure-TANK_LEAK_PRESSURE)/TANK_FRAGMENT_SCALE)

			var/mult = (air_contents.total_moles**2/3)/((29*0.64) **2/3) //tanks appear to be experiencing a reduction on scale of about 0.64 total moles

			var/num_fragments = round(rand(6,8) * sqrt(strength * mult)) //Less chunks, but bigger
			fragmentate(T, num_fragments, 7, list(/obj/item/projectile/bullet/pellet/fragment/tank/small = 1,/obj/item/projectile/bullet/pellet/fragment/tank = 5,/obj/item/projectile/bullet/pellet/fragment/strong = 4))

			if(istype(loc, /obj/item/transfer_valve))
				var/obj/item/transfer_valve/TTV = loc
				TTV.remove_tank(src)

			qdel(src)
		else
			integrity-= 5
	else if(pressure && (pressure > TANK_LEAK_PRESSURE || air_contents.temperature - T0C > failure_temp))
		if((integrity <= 19 || leaking) && !valve_welded)
			var/turf/T = get_turf(src)
			if(!T?.simulated)
				return
			var/datum/gas_mixture/environment = loc.return_air()
			var/env_pressure = environment.return_pressure()

			var/release_ratio = clamp(0.002, sqrt(max(pressure-env_pressure,0)/pressure),1)
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(release_ratio)
			//dynamic air release based on ambient pressure

			T.assume_air(leaked_gas)
			if(!leaking)
				visible_message("[html_icon(src)] <span class='warning'>\The [src] relief valve flips open with a hiss!</span>", "You hear hissing.")
				playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
				leaking = 1
				#ifdef FIREDBG
				log_debug("<span class='warning'>[x],[y] tank is leaking: [pressure] kPa, integrity [integrity]</span>")
				#endif
		else
			integrity-= 2
	else
		if(integrity < maxintegrity)
			integrity++
			if(leaking)
				integrity++
			if(integrity == maxintegrity)
				leaking = 0

/obj/item/tank/onetankbomb/Initialize()
	. = ..()

	// Set up appearance/strings.
	var/obj/item/tank/tank_copy = pick(typesof(/obj/item/tank/oxygen) + typesof(/obj/item/tank/hydrogen) + typesof(/obj/item/tank/phoron))
	name = initial(tank_copy.name)
	desc = initial(tank_copy.desc)
	icon = initial(tank_copy.icon)
	icon_state = initial(tank_copy.icon_state)
	volume = initial(tank_copy.volume)

	// Set up explosive mix.
	air_contents.gas[DEFAULT_GAS_ACCELERANT] = 4 + rand(4)
	air_contents.gas[DEFAULT_GAS_OXIDIZER] = 6 + rand(8)
	air_contents.update_values()
	air_contents.temperature = FLAMMABLE_GAS_MINIMUM_BURN_TEMPERATURE-1
	valve_welded = TRUE
	wired = TRUE
	proxyassembly.assembly = new /obj/item/assembly_holder(src)
	proxyassembly.assembly.master = proxyassembly
	proxyassembly.assembly.update_icon()
	update_icon()

/////////////////////////////////
///Pulled from rewritten bomb.dm
/////////////////////////////////

/obj/item/tankassemblyproxy
	name = "Tank assembly proxy"
	desc = "Used as a stand in to trigger single tank assemblies... but you shouldn't see this."
	is_spawnable_type = FALSE
	var/obj/item/tank/tank = null
	var/obj/item/assembly_holder/assembly = null

/obj/item/tankassemblyproxy/Destroy()
	tank = null // We aren't responsible for our tank
	QDEL_NULL(assembly) // but we're responsible for the assembly.
	return ..()

/obj/item/tankassemblyproxy/receive_signal()	//This is mainly called by the sensor through sense() to the holder, and from the holder to here.
	tank.cause_explosion()	//boom (or not boom if you made shijwtty mix)

/obj/item/tank/proc/assemble_bomb(used_item,mob/user)	//Bomb assembly proc. This turns assembly+tank into a bomb
	var/obj/item/assembly_holder/S = used_item
	if(isigniter(S.a_left) == isigniter(S.a_right))		//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
		return
	if(!S.secured)										//Check if the assembly is secured
		to_chat(user, SPAN_NOTICE("\The [S] must be secured before attaching it to \the [src]!"))
		return

	if(!user.try_unequip(src))
		return					//Remove the tank from your character,in case you were holding it
	user.put_in_hands(src)			//Equips the bomb if possible, or puts it on the floor.

	proxyassembly.assembly = S	//Tell the bomb about its assembly part
	S.master = proxyassembly	//Tell the assembly about its new owner
	user.remove_from_mob(S, src, FALSE) //Move the assembly and reset HUD layer/plane status

	update_icon()
	to_chat(user, "<span class='notice'>You finish attaching the assembly to \the [src].</span>")
	global.bombers += "[key_name(user)] attached an assembly to a wired [src]. Temp: [air_contents.temperature-T0C]"
	log_and_message_admins("attached an assembly to a wired [src]. Temp: [air_contents.temperature-T0C]", user)

/obj/item/tank/proc/cause_explosion()	//This happens when a bomb is told to explode

	var/obj/item/assembly_holder/assy = proxyassembly.assembly
	var/obj/item/igniter = assy.a_right
	var/obj/item/other   = assy.a_left

	if (isigniter(assy.a_left))
		igniter = assy.a_left
		other   = assy.a_right

	if(other)
		other.dropInto(get_turf(src))
	if(!QDELETED(igniter))
		qdel(igniter)
	assy.master = null
	proxyassembly.assembly = null
	if(!QDELETED(assy))
		qdel(assy)
	update_icon()

	air_contents.add_thermal_energy(15000)

/obj/item/tankassemblyproxy/on_update_icon()
	. = ..()
	tank.update_icon()

/obj/item/tankassemblyproxy/HasProximity(atom/movable/AM)
	. = ..()
	if(. && assembly)
		assembly.HasProximity(AM)

//Fragmentation projectiles

/obj/item/projectile/bullet/pellet/fragment/tank
	name = "metal fragment"
	damage = 9  //Big chunks flying off.
	range_step = 1 //controls damage falloff with distance. projectiles lose a "pellet" each time they travel this distance. Can be a non-integer.

	base_spread = 0 //causes it to be treated as a shrapnel explosion instead of cone
	spread_step = 20

	silenced = 1
	fire_sound = null
	no_attack_log = 1
	muzzle_type = null
	pellets = 1

/obj/item/projectile/bullet/pellet/fragment/tank/small
	name = "small metal fragment"
	damage = 6

/obj/item/projectile/bullet/pellet/fragment/tank/big
	name = "large metal fragment"
	damage = 17

#undef TANK_BOMB_DVSTN_FACTOR
#undef TANK_BOMB_HEAVY_FACTOR
#undef TANK_BOMB_LIGHT_FACTOR
#undef TANK_BOMB_FLASH_FACTOR
#undef MAX_TANK_BOMB_SEVERITY