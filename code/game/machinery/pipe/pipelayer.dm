// Note: this machine is not compatible with the current pipe construction code. Needs a refactor of the lay pipe and pipe selection procs before using.

/obj/machinery/pipelayer

	name = "automatic pipe layer"
	icon = 'icons/obj/machines/pipe_dispenser.dmi'
	icon_state = "pipe_d"
	density = TRUE
	var/turf/old_turf
	var/old_dir
	var/on = 0
	var/a_dis = 0
	var/P_type = 0
	var/P_type_t = ""
	var/max_metal = 50
	var/metal = 10
	var/obj/item/wrench/wrench
	var/list/Pipes = list("regular pipes"=0,"scrubbers pipes"=31,"supply pipes"=29,"heat exchange pipes"=2, "fuel pipes"=45)

/obj/machinery/pipelayer/Initialize()
	. = ..()
	wrench = new(src)

/obj/machinery/pipelayer/Move(new_turf,M_Dir)
	. = ..()

	if(on && a_dis)
		dismantle_floor(old_turf)
	layPipe(old_turf,M_Dir,old_dir)

	old_turf = new_turf
	old_dir = turn(M_Dir,180)

/obj/machinery/pipelayer/interface_interact(mob/user)
	if(!metal&&!on)
		to_chat(user, "<span class='warning'>\The [src] doesn't work without metal.</span>")
		return TRUE
	on=!on
	user.visible_message("<span class='notice'>[user] has [!on?"de":""]activated \the [src].</span>", "<span class='notice'>You [!on?"de":""]activate \the [src].</span>")
	return TRUE

/obj/machinery/pipelayer/attackby(var/obj/item/used_item, var/mob/user)

	if(IS_WRENCH(used_item))
		P_type_t = input("Choose pipe type", "Pipe type") as null|anything in Pipes
		P_type = Pipes[P_type_t]
		user.visible_message("<span class='notice'>[user] has set \the [src] to manufacture [P_type_t].</span>", "<span class='notice'>You set \the [src] to manufacture [P_type_t].</span>")
		return TRUE

	if(IS_CROWBAR(used_item))
		a_dis=!a_dis
		user.visible_message("<span class='notice'>[user] has [!a_dis?"de":""]activated auto-dismantling.</span>", "<span class='notice'>You [!a_dis?"de":""]activate auto-dismantling.</span>")
		return TRUE

	if(istype(used_item, /obj/item/stack/material) && used_item.get_material_type() == /decl/material/solid/metal/steel)

		var/result = load_metal(used_item)
		if(isnull(result))
			to_chat(user, "<span class='warning'>Unable to load [used_item] - no metal found.</span>")
		else if(!result)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
		else
			user.visible_message("<span class='notice'>[user] has loaded metal into \the [src].</span>", "<span class='notice'>You load metal into \the [src]</span>")

		return TRUE

	if(IS_SCREWDRIVER(used_item))
		if(metal)
			var/m = round(input(usr,"Please specify the amount of metal to remove","Remove metal",min(round(metal),50)) as num, 1)
			m = min(m, 50)
			m = min(m, round(metal))
			m = round(m)
			if(m)
				use_metal(m)
				SSmaterials.create_object(/decl/material/solid/metal/steel, get_turf(src), m)
				user.visible_message(SPAN_NOTICE("[user] removes [m] sheet\s of metal from \the [src]."), SPAN_NOTICE("You remove [m] sheet\s of metal from \the [src]"))
		else
			to_chat(user, "\The [src] is empty.")
		return TRUE
	return ..()

/obj/machinery/pipelayer/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	. += "\The [src] has [metal] sheet\s, is set to produce [P_type_t], and auto-dismantling is [!a_dis?"de":""]activated."

/obj/machinery/pipelayer/proc/reset()
	on=0
	return

/obj/machinery/pipelayer/proc/load_metal(var/obj/item/stack/MM)
	if(istype(MM) && MM.get_amount())
		var/cur_amount = metal
		var/to_load = max(max_metal - round(cur_amount),0)
		if(to_load)
			to_load = min(MM.get_amount(), to_load)
			metal += to_load
			MM.use(to_load)
			return to_load
		else
			return 0
	return

/obj/machinery/pipelayer/proc/use_metal(amount)
	if(!metal || metal<amount)
		visible_message("\The [src] deactivates as its metal source depletes.")
		return
	metal-=amount
	return 1

/obj/machinery/pipelayer/proc/dismantle_floor(var/turf/new_turf)
	if(istype(new_turf, /turf/floor))
		var/turf/floor/T = new_turf
		if(!T.is_plating())
			T.clear_flooring(place_product = !T.is_floor_damaged())
	return new_turf.is_plating()

/obj/machinery/pipelayer/proc/layPipe(var/turf/w_turf,var/M_Dir,var/old_dir)
	if(!on || !(M_Dir in list(1, 2, 4, 8)) || M_Dir==old_dir)
		return reset()
	if(!use_metal(0.25))
		return reset()
	var/fdirn = turn(M_Dir,180)
	var/p_dir

	if (fdirn!=old_dir)
		p_dir=old_dir+M_Dir
	else
		p_dir=M_Dir

	var/obj/item/pipe/P = new(w_turf)
	P.set_dir(p_dir)
	P.attackby(wrench , src)

	return 1
