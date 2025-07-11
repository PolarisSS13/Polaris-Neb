#define FARMBOT_COLLECT 1
#define FARMBOT_WATER 2
#define FARMBOT_UPROOT 3
#define FARMBOT_NUTRIMENT 4

/mob/living/bot/farmbot
	name = "Farmbot"
	desc = "The botanist's best friend."
	icon = 'icons/mob/bot/farmbot.dmi'
	icon_state = "farmbot0"
	max_health = 50
	req_access = list(list(access_hydroponics, access_robotics))

	var/action = "" // Used to update icon
	var/waters_trays = 1
	var/refills_water = 1
	var/uproots_weeds = 1
	var/replaces_nutriment = 0
	var/collects_produce = 0
	var/removes_dead = 0

	var/obj/structure/reagent_dispensers/watertank/tank

/mob/living/bot/farmbot/Initialize(mapload, var/newTank)
	. = ..(mapload)
	if(!newTank)
		newTank = new /obj/structure/reagent_dispensers/watertank(src)
	tank = newTank
	tank.forceMove(src)

/mob/living/bot/farmbot/premade
	name = "Old Ben"
	on = 0

/mob/living/bot/farmbot/GetInteractTitle()
	. = "<head><title>Farmbot controls</title></head>"
	. += "<b>Automatic Hyrdoponic Assisting Unit v1.0</b>"

/mob/living/bot/farmbot/GetInteractStatus()
	. = ..()
	. += "<br>Water tank: "
	if(tank)
		. += "[tank.reagents.total_volume]/[tank.reagents.maximum_volume]"
	else
		. += "error: not found"

/mob/living/bot/farmbot/GetInteractPanel()
	. = "Water plants : <a href='byond://?src=\ref[src];command=water'>[waters_trays ? "Yes" : "No"]</a>"
	. += "<br>Refill watertank : <a href='byond://?src=\ref[src];command=refill'>[refills_water ? "Yes" : "No"]</a>"
	. += "<br>Weed plants: <a href='byond://?src=\ref[src];command=weed'>[uproots_weeds ? "Yes" : "No"]</a>"
	. += "<br>Replace fertilizer: <a href='byond://?src=\ref[src];command=replacenutri'>[replaces_nutriment ? "Yes" : "No"]</a>"
	. += "<br>Collect produce: <a href='byond://?src=\ref[src];command=collect'>[collects_produce ? "Yes" : "No"]</a>"
	. += "<br>Remove dead plants: <a href='byond://?src=\ref[src];command=removedead'>[removes_dead ? "Yes" : "No"]</a>"

/mob/living/bot/farmbot/GetInteractMaintenance()
	. = "Plant identifier status: "
	switch(emagged)
		if(0)
			. += "<a href='byond://?src=\ref[src];command=emag'>Normal</a>"
		if(1)
			. += "<a href='byond://?src=\ref[src];command=emag'>Scrambled (DANGER)</a>"
		if(2)
			. += "ERROROROROROR-----"

/mob/living/bot/farmbot/ProcessCommand(var/mob/user, var/command, var/href_list)
	..()
	if(CanAccessPanel(user))
		switch(command)
			if("water")
				waters_trays = !waters_trays
			if("refill")
				refills_water = !refills_water
			if("weed")
				uproots_weeds = !uproots_weeds
			if("replacenutri")
				replaces_nutriment = !replaces_nutriment
			if("collect")
				collects_produce = !collects_produce
			if("removedead")
				removes_dead = !removes_dead

	if(CanAccessMaintenance(user))
		switch(command)
			if("emag")
				if(emagged < 2)
					emagged = !emagged

/mob/living/bot/farmbot/emag_act(var/remaining_charges, var/mob/user)
	. = ..()
	if(!emagged)
		if(user)
			to_chat(user, "<span class='notice'>You short out [src]'s plant identifier circuits.</span>")
			ignore_list |= user
		emagged = 2
		return 1

/mob/living/bot/farmbot/on_update_icon()
	..()
	if(on && action)
		icon_state = "farmbot_[action]"
	else
		icon_state = "farmbot[on]"

/mob/living/bot/farmbot/handleRegular()
	if(emagged && prob(1))
		flick("farmbot_broke", src)

/mob/living/bot/farmbot/handleAdjacentTarget()
	UnarmedAttack(target, TRUE)

/mob/living/bot/farmbot/lookForTargets()
	if(emagged)
		for(var/mob/living/human/H in view(7, src))
			target = H
			return
	else
		for(var/obj/machinery/portable_atmospherics/hydroponics/tray in view(7, src))
			if(confirmTarget(tray))
				target = tray
				return
		if(!target && refills_water && tank && tank.reagents.total_volume < tank.reagents.maximum_volume)
			for(var/obj/structure/hygiene/sink/source in view(7, src))
				target = source
				return

/mob/living/bot/farmbot/ResolveUnarmedAttack(var/atom/A, var/proximity)
	if(busy)
		return TRUE

	if(istype(A, /obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/T = A
		var/t = confirmTarget(T)
		switch(t)
			if(0)
				return TRUE
			if(FARMBOT_COLLECT)
				action = "water" // Needs a better one
				update_icon()
				visible_message("<span class='notice'>[src] starts [T.dead? "removing the plant from" : "harvesting"] \the [A].</span>")
				busy = 1
				if(do_after(src, 30, A))
					visible_message("<span class='notice'>[src] [T.dead? "removes the plant from" : "harvests"] \the [A].</span>")
					T.physical_attack_hand(src)
			if(FARMBOT_WATER)
				action = "water"
				update_icon()
				visible_message("<span class='notice'>[src] starts watering \the [A].</span>")
				busy = 1
				if(do_after(src, 30, A))
					playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
					visible_message("<span class='notice'>[src] waters \the [A].</span>")
					tank.reagents.trans_to(T, 100 - T.waterlevel)
			if(FARMBOT_UPROOT)
				action = "hoe"
				update_icon()
				visible_message("<span class='notice'>[src] starts uprooting the weeds in \the [A].</span>")
				busy = 1
				if(do_after(src, 30, A))
					visible_message("<span class='notice'>[src] uproots the weeds in \the [A].</span>")
					T.weedlevel = 0
			if(FARMBOT_NUTRIMENT)
				action = "fertile"
				update_icon()
				visible_message("<span class='notice'>[src] starts fertilizing \the [A].</span>")
				busy = 1
				if(do_after(src, 30, A))
					visible_message("<span class='notice'>[src] fertilizes \the [A].</span>")
					T.add_to_reagents(/decl/material/gas/ammonia, 10)
		busy = 0
		action = ""
		update_icon()
		T.update_icon()
	else if(istype(A, /obj/structure/hygiene/sink))
		if(!tank || tank.reagents.total_volume >= tank.reagents.maximum_volume)
			return TRUE
		action = "water"
		update_icon()
		visible_message("<span class='notice'>[src] starts refilling its tank from \the [A].</span>")
		busy = 1
		while(do_after(src, 10) && tank.reagents.total_volume < tank.reagents.maximum_volume)
			tank.add_to_reagents(/decl/material/liquid/water, 100)
			if(prob(5))
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		busy = 0
		action = ""
		update_icon()
		visible_message("<span class='notice'>[src] finishes refilling its tank.</span>")
	else if(emagged && ishuman(A))
		var/action = pick("weed", "water")
		busy = 1
		spawn(50) // Some delay
			busy = 0
		switch(action)
			if("weed")
				flick("farmbot_hoe", src)
				do_attack_animation(A)
				if(prob(50))
					visible_message("<span class='danger'>[src] swings wildly at [A] with a minihoe, missing completely!</span>")
					return TRUE
				var/t = pick("slashed", "sliced", "cut", "clawed")
				A.attack_generic(src, 5, t)
			if("water")
				flick("farmbot_water", src)
				visible_message("<span class='danger'>[src] splashes [A] with water!</span>")
				tank.reagents.splash(A, 100)
	return TRUE

/mob/living/bot/farmbot/gib(do_gibs = TRUE)
	var/turf/my_turf = get_turf(src)
	. = ..()
	if(. && my_turf)
		new /obj/item/tool/hoe/mini(my_turf)
		new /obj/item/chems/glass/bucket(my_turf)
		new /obj/item/assembly/prox_sensor(my_turf)
		new /obj/item/scanner/plant(my_turf)
		if(tank)
			tank.forceMove(my_turf)
		if(prob(50))
			new /obj/item/robot_parts/l_arm(my_turf)

/mob/living/bot/farmbot/confirmTarget(atom/target)
	if(!..())
		return 0

	if(emagged && ishuman(target))
		if(target in view(world.view, src))
			return 1
		return 0

	if(istype(target, /obj/structure/hygiene/sink))
		if(!tank || tank.reagents.total_volume >= tank.reagents.maximum_volume)
			return 0
		return 1

	var/obj/machinery/portable_atmospherics/hydroponics/tray = target
	if(!istype(tray))
		return 0

	if(tray.closed_system || !tray.seed)
		return 0

	if(tray.dead && removes_dead || tray.harvest && collects_produce)
		return FARMBOT_COLLECT

	else if(refills_water && tray.waterlevel < 40 && !tray.reagents.has_reagent(/decl/material/liquid/water) && (tank?.reagents.total_volume > 0))
		return FARMBOT_WATER

	else if(uproots_weeds && tray.weedlevel > 3)
		return FARMBOT_UPROOT

	else if(replaces_nutriment && tray.nutrilevel < 1 && tray.reagents.total_volume < 1)
		return FARMBOT_NUTRIMENT

	return 0
