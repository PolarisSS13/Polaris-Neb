/turf/floor
	var/gemstone_dropped = FALSE

/turf/floor/proc/is_fundament()
	var/decl/flooring/flooring = get_topmost_flooring()
	return flooring ? !flooring.constructed : TRUE

/turf/floor/can_be_dug(tool_hardness = MAT_VALUE_MALLEABLE, using_tool = TOOL_SHOVEL)
	// This should be removed before digging trenches.
	if(!is_fundament())
		return FALSE
	var/decl/flooring/flooring = get_base_flooring()
	if(istype(flooring) && flooring.constructed)
		return FALSE
	var/decl/material/my_material = get_material()
	if(density || is_open() || !istype(my_material))
		return FALSE
	if(my_material.hardness > tool_hardness)
		return FALSE
	if(using_tool == TOOL_SHOVEL && my_material.hardness > MAT_VALUE_FLEXIBLE)
		return FALSE
	if(using_tool == TOOL_PICK && my_material.hardness <= MAT_VALUE_FLEXIBLE)
		return FALSE
	return TRUE

/turf/floor/can_dig_trench(tool_hardness = MAT_VALUE_MALLEABLE, using_tool = TOOL_SHOVEL)
	return can_be_dug(tool_hardness, using_tool) && get_physical_height() > -(FLUID_DEEP)

/turf/floor/dig_trench(mob/user, tool_hardness = MAT_VALUE_MALLEABLE, using_tool = TOOL_SHOVEL)
	if(is_fundament())
		handle_trench_digging(user)

/turf/floor/proc/handle_trench_digging(mob/user)
	var/decl/flooring/flooring = get_topmost_flooring()
	if(!flooring.handle_turf_digging(src))
		return
	// Only drop mats if we actually changed the turf height sufficiently.
	var/old_height  = get_physical_height()
	var/new_height  = max(old_height-TRENCH_DEPTH_PER_ACTION, -(FLUID_DEEP))
	var/height_diff = abs(old_height-new_height)
	if(height_diff >= TRENCH_DEPTH_PER_ACTION)
		drop_diggable_resources(user)
	set_physical_height(new_height)

/turf/floor/dig_pit(mob/user, tool_hardness = MAT_VALUE_MALLEABLE, using_tool = TOOL_SHOVEL)
	return has_flooring() ? null : ..()

/turf/floor/get_diggable_resources()
	var/decl/material/my_material = get_material()
	if(is_fundament() && istype(my_material) && my_material.dug_drop_type && (get_physical_height() > -(FLUID_DEEP)))
		. = list()
		.[my_material.dug_drop_type] = list("amount" = 3, "variance" = 2, "material" = my_material.type)
		if(!gemstone_dropped && prob(my_material.gemstone_chance) && LAZYLEN(my_material.gemstone_types))
			gemstone_dropped = TRUE
			var/gem_mat = pick(my_material.gemstone_types)
			.[/obj/item/gemstone] = list("amount" = 1, "material" = gem_mat)
