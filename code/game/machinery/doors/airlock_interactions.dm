/*
	Moved the non-airlock procs in airlock.dm to here.
*/

//*** Blocking Airlocks

/atom/movable/proc/blocks_airlock()
	return density

/obj/machinery/door/blocks_airlock()
	return 0

/obj/structure/window/blocks_airlock()
	return 0

/obj/effect/energy_field/blocks_airlock()
	return 0

/obj/machinery/shield/blocks_airlock()
	return 0

/mob/living/blocks_airlock()
	return 1

/obj/structure/closet/body_bag/blocks_airlock()
	if (locate(/mob) in src)
		return 1
	else
		return 0				//Prevents Airlocks from closing on Bodybags and Cryobags with people inside


//*** Airlock Crushing

#define AIRLOCK_CRUSH_INCREMENT 10 // Damage caused by airlock crushing a mob is split into multiple smaller hits. Makes door crushing behave more like a "slow" crushing effect rather than high-speed impacts.
#define CYBORG_AIRLOCKCRUSH_RESISTANCE 2 // Damage caused to silicon mobs (usually cyborgs) from being crushed by airlocks is divided by this number. Unlike organics cyborgs don't have passive regeneration.

/atom/movable/proc/airlock_crush(var/crush_damage)
	return

/obj/structure/window/airlock_crush(var/crush_damage)
	explosion_act(2)//Smashin windows

/obj/machinery/portable_atmospherics/canister/airlock_crush(var/crush_damage)
	. = ..()
	take_damage(crush_damage)

/obj/effect/energy_field/airlock_crush(var/crush_damage)
	Stress(crush_damage)

/obj/structure/closet/airlock_crush(var/crush_damage)
	..()
	take_damage(crush_damage)
	for(var/atom/movable/AM in src)
		AM.airlock_crush()

/mob/living/airlock_crush(var/crush_damage)
	. = ..()

	for(var/i in 1 to round(crush_damage/AIRLOCK_CRUSH_INCREMENT, 1))
		apply_damage(AIRLOCK_CRUSH_INCREMENT, BRUTE)

	set_status_condition(STAT_STUN, round(crush_damage / 8, 1))
	set_status_condition(STAT_WEAK, round(crush_damage / 8, 1))

	var/turf/T = loc
	if(!istype(T))
		return

	var/list/valid_turfs = list()
	for(var/dir_to_test in global.cardinal)
		var/turf/new_turf = get_step(T, dir_to_test)
		if(!new_turf.contains_dense_objects())
			valid_turfs |= new_turf

	while(valid_turfs.len)
		T = pick(valid_turfs)
		valid_turfs -= T
		// Try to move us to the turf. If all turfs fail for some reason we will stay on this tile.
		if(src.Move(T))
			return

/mob/living/human/airlock_crush(var/crush_damage)
	. = ..()
	if (can_feel_pain())
		emote(/decl/emote/audible/scream)

/mob/living/silicon/robot/airlock_crush(var/crush_damage)
	return ..(round(crush_damage / CYBORG_AIRLOCKCRUSH_RESISTANCE)) //TODO implement robot melee armour and remove this.
