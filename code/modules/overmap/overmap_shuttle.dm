#define waypoint_sector(waypoint) global.overmap_sectors[num2text(waypoint.z)]

/datum/shuttle/autodock/overmap
	warmup_time = 10

	var/range = 0	//how many overmap tiles can shuttle go, for picking destinations and returning.
	var/fuel_consumption = 0 //Amount of moles of gas consumed per trip; If zero, then shuttle is magic and does not need fuel
	var/list/obj/structure/fuel_port/fuel_ports //the fuel ports of the shuttle (but usually just one)

	abstract_type = /datum/shuttle/autodock/overmap
	var/skill_needed = SKILL_BASIC
	var/landing_skill_needed = SKILL_EXPERT
	var/operator_skill = SKILL_MIN

/datum/shuttle/autodock/overmap/New(var/map_hash, var/obj/effect/shuttle_landmark/start_waypoint)
	..()
	refresh_fuel_ports_list()

/datum/shuttle/autodock/overmap/proc/refresh_fuel_ports_list() //loop through all
	fuel_ports = list()
	for(var/area/A in shuttle_area)
		for(var/obj/structure/fuel_port/fuel_port_in_area in A)
			fuel_port_in_area.parent_shuttle = src
			fuel_ports += fuel_port_in_area

/datum/shuttle/autodock/overmap/fuel_check()
	if(!try_consume_fuel()) //insufficient fuel
		for(var/mob/hearer in global.living_mob_list_ + global.ghost_mob_list)
			if(is_type_in_list(get_area(hearer), shuttle_area))
				hearer.show_message(SPAN_WARNING("You hear the shuttle engines sputter... perhaps it doesn't have enough fuel?"), AUDIBLE_MESSAGE,
				SPAN_WARNING("The shuttle shakes but fails to take off."), VISIBLE_MESSAGE)
		return FALSE //failure
	return TRUE //sucess, continue with launch

/datum/shuttle/autodock/overmap/proc/can_go()
	if(!next_location)
		return FALSE
	if(moving_status == SHUTTLE_INTRANSIT)
		return FALSE //already going somewhere, current_location may be an intransit location instead of in a sector

	return get_dist(waypoint_sector(current_location), waypoint_sector(next_location)) <= range

/datum/shuttle/autodock/overmap/can_launch()
	return ..() && can_go()

/datum/shuttle/autodock/overmap/can_force()
	return ..() && can_go()

/datum/shuttle/autodock/overmap/get_travel_time()
	var/distance_mod = get_dist(waypoint_sector(current_location),waypoint_sector(next_location))
	var/skill_mod = 0.2*(skill_needed - operator_skill)
	return move_time * (1 + distance_mod + skill_mod)

/datum/shuttle/autodock/overmap/process_launch()
	if(prob(10*max(0, skill_needed - operator_skill)))
		var/places = get_possible_destinations()
		var/place = pick(places)
		set_destination(places[place])
	..()

/datum/shuttle/autodock/overmap/proc/set_destination(var/obj/effect/shuttle_landmark/A)
	if(A != current_location)
		if(next_location)
			next_location.landmark_deselected(src)
		next_location = A
		next_location.landmark_selected(src)

/datum/shuttle/autodock/overmap/proc/get_possible_destinations()
	var/list/res = list()
	for (var/obj/effect/overmap/visitable/S in range(get_turf(waypoint_sector(current_location)), range))
		var/list/waypoints = S.get_waypoints(type)
		for(var/obj/effect/shuttle_landmark/LZ in waypoints)
			if(LZ.is_valid(src))
				res["[waypoints[LZ]] - [LZ.name]"] = LZ
	return res

/datum/shuttle/autodock/overmap/get_location_name()
	if(moving_status == SHUTTLE_INTRANSIT)
		return "In transit"
	return "\the [waypoint_sector(current_location)] - [current_location]"

/datum/shuttle/autodock/overmap/get_destination_name()
	if(!next_location)
		return "None"
	return "[waypoint_sector(next_location)] - [next_location]"

/datum/shuttle/autodock/overmap/proc/try_consume_fuel() //returns 1 if sucessful, returns 0 if error (like insufficient fuel)
	if(!fuel_consumption)
		return 1 //shuttles with zero fuel consumption are magic and can always launch
	if(!fuel_ports.len)
		return 0 //Nowhere to get fuel from
	var/list/obj/item/tank/fuel_tanks = list()
	for(var/obj/structure/FP in fuel_ports) //loop through fuel ports and assemble list of all fuel tanks
		var/obj/item/tank/FT = locate() in FP
		if(FT)
			fuel_tanks += FT
	if(!fuel_tanks.len)
		return 0 //can't launch if you have no fuel TANKS in the ports
	var/total_flammable_gas_moles = 0
	for(var/obj/item/tank/FT in fuel_tanks)
		total_flammable_gas_moles += FT.air_contents.get_by_flag(XGM_GAS_FUEL)
	if(total_flammable_gas_moles < fuel_consumption) //not enough fuel
		return 0
	// We are going to succeed if we got to here, so start consuming that fuel
	var/fuel_to_consume = fuel_consumption
	for(var/obj/item/tank/FT in fuel_tanks) //loop through tanks, consume their fuel one by one
		var/fuel_available = FT.air_contents.get_by_flag(XGM_GAS_FUEL)
		if(!fuel_available) // Didn't even have fuel.
			continue
		if(fuel_available >= fuel_to_consume)
			FT.remove_air_by_flag(XGM_GAS_FUEL, fuel_to_consume)
			return 1 //ALL REQUIRED FUEL HAS BEEN CONSUMED, GO FOR LAUNCH!
		else //this tank doesn't have enough to launch shuttle by itself, so remove all its fuel, then continue loop
			fuel_to_consume -= fuel_available
			FT.remove_air_by_flag(XGM_GAS_FUEL, fuel_available)

// When we rotate, rotate our overmap landmark's fore_dir too, so meteors come from the right direction.
/datum/shuttle/autodock/overmap/shuttle_moved(obj/effect/shuttle_landmark/destination, list/turf_translation, angle = 0)
	..()
	var/obj/effect/overmap/visitable/ship/landable/our_ship = SSshuttle.ship_by_shuttle(name)
	if(our_ship && angle != 0)
		our_ship.fore_dir = turn(our_ship.fore_dir, angle)