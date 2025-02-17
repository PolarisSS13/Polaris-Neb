/mob/living/silicon/robot
	hud_used = /datum/hud/robot

/datum/hud/robot/get_ui_style_data()
	return GET_DECL(/decl/ui_style/robot)

/datum/hud/robot/get_ui_color()
	return COLOR_WHITE

/datum/hud/robot/get_ui_alpha()
	return 255

// TODO: Convert robots to use inventory slots.
/datum/hud/robot/finalize_instantiation(mob/_owner)
	var/mob/living/silicon/robot/robit = _owner
	if(!istype(robit))
		return ..()
	robit.inv1 = new(null, _owner)
	robit.inv2 = new(null, _owner)
	robit.inv3 = new(null, _owner)
	LAZYINITLIST(hud_elements_auxilliary)
	hud_elements_auxilliary += robit.inv1
	hud_elements_auxilliary += robit.inv2
	hud_elements_auxilliary += robit.inv3
	..()

/datum/hud/proc/toggle_show_robot_modules()
	var/mob/living/silicon/robot/robit = owner?.resolve()
	if(istype(robit))
		robit.shown_robot_modules = !robit.shown_robot_modules
		update_robot_modules_display()
/datum/hud/proc/update_robot_modules_display()
	var/mob/living/silicon/robot/robit = owner?.resolve()
	if(!istype(robit) || !robit.client)
		return

	if(robit.shown_robot_modules)
		if(robit.active_storage)
			robit.active_storage.close(robit) //Closes the inventory ui.

		if(!robit.module)
			to_chat(robit, SPAN_WARNING("No module selected."))
			return

		if(!robit.module.equipment)
			to_chat(robit, SPAN_WARNING("Selected module has no equipment available."))
			return

		if(!robit.robot_modules_background)
			return

		var/display_rows = ceil(robit.module.equipment.len / 8)
		robit.robot_modules_background.screen_loc = "CENTER-4:16,BOTTOM+1:7 to CENTER+3:16,BOTTOM+[display_rows]:7"
		robit.client.screen += robit.robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		//Unfortunately adding the emag module to the list of modules has to be here. This is because a borg can
		//be emagged before they actually select a module. - or some situation can cause them to get a new module
		// - or some situation might cause them to get de-emagged or something.
		if(robit.emagged)
			if(!(robit.module.emag in robit.module.equipment))
				robit.module.equipment.Add(robit.module.emag)
		else
			if(robit.module.emag in robit.module.equipment)
				robit.module.equipment.Remove(robit.module.emag)

		for(var/atom/movable/A in robit.module.equipment)
			if( (A != robit.module_state_1) && (A != robit.module_state_2) && (A != robit.module_state_3) )
				//Module is not currently active
				robit.client.screen += A
				if(x < 0)
					A.screen_loc = "CENTER[x]:[WORLD_ICON_SIZE/2],BOTTOM+[y]:7"
				else
					A.screen_loc = "CENTER+[x]:[WORLD_ICON_SIZE/2],BOTTOM+[y]:7"
				A.hud_layerise()

				x++
				if(x == 4)
					x = -4
					y++

	else
		//Modules display is hidden
		for(var/atom/A in robit.module.equipment)
			if( (A != robit.module_state_1) && (A != robit.module_state_2) && (A != robit.module_state_3) )
				//Module is not currently active
				robit.client.screen -= A
		robit.shown_robot_modules = 0
		robit.client.screen -= robit.robot_modules_background
