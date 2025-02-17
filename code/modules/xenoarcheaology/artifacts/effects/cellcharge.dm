//todo
/datum/artifact_effect/cellcharge
	name = "cell charge"
	origin_type = XA_EFFECT_ELECTRO
	var/last_message

/datum/artifact_effect/cellcharge/DoEffectTouch(var/mob/user)
	if(user)
		if(isrobot(user))
			var/mob/living/silicon/robot/robot = user
			var/obj/item/cell/C = robot.get_cell()
			if(C)
				C.give(100)
				to_chat(robot, SPAN_NOTICE("SYSTEM ALERT: Energy boost detected!"))
				return 1

/datum/artifact_effect/cellcharge/DoEffectAura()
	if(holder)
		charge_cells_in_range(25)
		return 1

/datum/artifact_effect/cellcharge/DoEffectPulse()
	if(holder)
		charge_cells_in_range(100)
		return 1

/datum/artifact_effect/cellcharge/proc/charge_cells_in_range(amount)
	var/turf/T = get_turf(holder)
	for (var/obj/machinery/power/apc/A in range(effect_range, T))
		var/obj/item/cell/C = A.get_cell()
		if(C)
			C.give(amount)
	for (var/obj/machinery/power/smes/S in range(effect_range, T))
		S.add_charge(amount / CELLRATE)
	for (var/mob/living/silicon/robot/M in range(effect_range, T))
		var/obj/item/cell/C = M.get_cell()
		if(C)
			C.give(amount)
			if(world.time - last_message > 200)
				to_chat(M, SPAN_NOTICE("SYSTEM ALERT: Energy boost detected!"))
				last_message = world.time

