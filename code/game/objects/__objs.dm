/obj
	layer = OBJ_LAYER
	animate_movement = 2
	is_spawnable_type = TRUE
	abstract_type = /obj

	///The maximum health that the object can have. If set to ITEM_HEALTH_NO_DAMAGE, the object won't take any damage.
	max_health = ITEM_HEALTH_NO_DAMAGE
	///The current health of the obj. Leave to null, unless you want the object to start at a different health than max_health.
	current_health = null

	var/obj_flags
	var/datum/talking_atom/talking_atom
	var/list/req_access
	var/list/matter //Used to store information about the contents of the object.
	var/w_class // Size of the object.

	var/in_use = FALSE // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
	var/armor_penetration = 0
	var/anchor_fall = FALSE
	/// if the obj is a holographic object spawned by the holodeck
	var/holographic = FALSE
	///JSON list of directions to x,y offsets to be applied to the object depending on its direction EX: @'{"NORTH":{"x":12,"y":5}, "EAST":{"x":10,"y":50}}'
	var/directional_offset

/obj/Initialize(mapload)
	//Health should be set to max_health only if it's null.
	. = ..()
	create_matter()
	//Only apply directional offsets if the mappers haven't set any offsets already
	if(!pixel_x && !pixel_y && !pixel_w && !pixel_z)
		update_directional_offset()
	if(isnull(current_health))
		current_health = get_max_health()

/obj/object_shaken()
	shake_animation()
	return ..()

/obj/hitby(atom/movable/AM, var/datum/thrownthing/TT)
	. = ..()
	if(. && !anchored)
		step(src, AM.last_move)

/obj/proc/create_matter()
	if(length(matter))
		for(var/mat in matter)
			matter[mat] = round(matter[mat] * get_matter_amount_modifier())
	UNSETEMPTY(matter)

/obj/Destroy()
	QDEL_NULL(talking_atom)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/proc/get_matter_amount_modifier()
	. = w_class * BASE_OBJECT_MATTER_MULTPLIER

/obj/assume_air(datum/gas_mixture/giver)
	return loc?.assume_air(giver)

/obj/remove_air(amount)
	return loc?.remove_air(amount)

/obj/return_air()
	return loc?.return_air()

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src) | usr
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				if(CanUseTopic(M, DefaultTopicState()) > STATUS_CLOSE)
					is_in_use = 1
					interact(M)
				else
					M.unset_machine()
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				if(CanUseTopic(M, DefaultTopicState()) > STATUS_CLOSE)
					is_in_use = 1
					interact(M)
				else
					M.unset_machine()
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/attack_ghost(mob/user)
	ui_interact(user)
	..()

/obj/proc/interact(mob/user)
	return FALSE

/obj/proc/hide(var/hide)
	set_invisibility(hide ? INVISIBILITY_MAXIMUM : initial(invisibility))

/obj/proc/hides_under_flooring()
	return level == LEVEL_BELOW_PLATING

/obj/proc/hear_talk(mob/M, text, verb, decl/language/speaking)
	if(talking_atom)
		talking_atom.catchMessage(text, M)
/*
	var/mob/mo = locate(/mob) in src
	if(mo)
		var/rendered = "<span class='game say'><span class='name'>[M.name]: </span> <span class='message'>[text]</span></span>"
		mo.show_message(rendered, 2)
		*/
	return

/obj/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	return

/obj/proc/damage_flags()
	. = 0
	if(is_sharp())
		. |= DAM_SHARP|DAM_EDGE
		if(atom_damage_type == BURN)
			. |= DAM_LASER
	else if(has_edge())
		. |= DAM_EDGE

/obj/attackby(obj/item/used_item, mob/user)
	// We need to call parent even if we lack dexterity, so that storage can work.
	if((obj_flags & OBJ_FLAG_ANCHORABLE) && (IS_WRENCH(used_item) || IS_HAMMER(used_item)))
		if(used_item.user_can_attack_with(user))
			wrench_floor_bolts(user, null, used_item)
			update_icon()
			return TRUE
	var/datum/extension/padding/padding_extension = get_extension(src, __IMPLIED_TYPE__)
	if(padding_extension && padding_extension.handle_use_item(used_item, user))
		return TRUE
	return ..()

/obj/proc/wrench_floor_bolts(mob/user, delay = 2 SECONDS, obj/item/tool)
	if(!istype(tool) || IS_WRENCH(tool))
		playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
	else if(IS_HAMMER(tool))
		playsound(loc, 'sound/weapons/Genhit.ogg', 100, 1)

	if(anchored)
		user.visible_message("\The [user] begins unsecuring \the [src] from the floor.", "You start unsecuring \the [src] from the floor.")
	else
		user.visible_message("\The [user] begins securing \the [src] to the floor.", "You start securing \the [src] to the floor.")
	if(do_after(user, delay, src))
		if(!src) return
		to_chat(user, SPAN_NOTICE("You [anchored? "un" : ""]secured \the [src]!"))
		anchored = !anchored
	return 1

/obj/attack_hand(mob/user)
	if(Adjacent(user))
		add_fingerprint(user)
	return ..()

/obj/try_fluid_push(volume, strength)
	return ..() && w_class <= round(strength/20)

/obj/proc/can_embed()
	return FALSE

/obj/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if((obj_flags & OBJ_FLAG_ROTATABLE))
		. += SPAN_SUBTLE("\The [src] can be rotated with alt-click.")
	if((obj_flags & OBJ_FLAG_ANCHORABLE))
		. += SPAN_SUBTLE("\The [src] can be anchored or unanchored with a wrench.")

/obj/proc/rotate(mob/user)
	if(!CanPhysicallyInteract(user))
		to_chat(user, SPAN_NOTICE("You can't interact with \the [src] right now!"))
		return

	if(anchored)
		to_chat(user, SPAN_NOTICE("\The [src] is secured to the floor!"))
		return

	set_dir(turn(dir, 90))
	update_icon()

//For things to apply special effects after damaging an organ, called by organ's take_damage
/obj/proc/after_wounding(obj/item/organ/external/organ, datum/wound)
	return

/obj/get_mass()
	return min(2**(w_class-1), 100)

/obj/get_object_size()
	return w_class

/obj/get_mob()
	return buckled_mob

/obj/set_dir(ndir)
	. = ..()
	if(directional_offset)
		update_directional_offset()

/obj/Move()
	. = ..()
	if(directional_offset)
		update_directional_offset()

/obj/forceMove(atom/dest)
	. = ..()
	if(directional_offset)
		update_directional_offset()

/**
 * Applies the offset stored in the directional_offset json list depending on the current direction.
 * force will force the default offset to be 0 if there are no directional_offset string.
 */
/obj/proc/update_directional_offset(var/force = FALSE)
	if(!force && !length(directional_offset))
		return

	default_pixel_x = 0
	default_pixel_y = 0
	default_pixel_w = 0
	default_pixel_z = 0

	var/list/diroff = cached_json_decode(directional_offset)
	var/list/curoff = diroff["[uppertext(dir2text(dir))]"]
	if(length(curoff))
		default_pixel_x = curoff["x"] || 0
		default_pixel_y = curoff["y"] || 0
		default_pixel_w = curoff["w"] || 0
		default_pixel_z = curoff["z"] || 0
	reset_offsets(0)

/**
 * Returns whether the object should be considered as hanging off a wall.
 * This is userful because wall-mounted things are actually on the adjacent floor tile offset towards the wall.
 * Which means we have to deal with directional offsets differently. Such as with buttons mounted on a table, or on a wall.
 */
/obj/proc/is_wall_mounted()
	//If this flag is on, and we have an offset, we're most likely wall mounted
	if(obj_flags & OBJ_FLAG_MOVES_UNSUPPORTED || anchor_fall)
		var/turf/forward = get_step(get_turf(src), dir)
		var/turf/reverse = get_step(get_turf(src), global.reverse_dir[dir])
		//If we're wall mounted and don't have a wall either facing us, or in the opposite direction, don't apply the offset.
		// This is mainly for things that can be both wall mounted and floor mounted. Like buttons, which mappers seem to really like putting on tables.
		// It's sort of a hack for now. But objects don't handle being on a wall or not. (They don't change their flags, layer, etc when on a wall or anything)
		if(!forward?.is_wall() && !reverse?.is_wall())
			return
	return TRUE

/**
 * Init starting reagents and/or reagent var. Not called at the /obj level.
 * populate: If set to true, we expect map load/admin spawned reagents to be set.
 */
/obj/proc/initialize_reagents(var/populate = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(reagents?.total_volume > 0)
		log_warning("\The [src] possibly is initializing its reagents more than once!")
	if(populate)
		populate_reagents()

/**
 * Actually populates the reagents.
 * Can be easily nulled out or fully overriden without having to rewrite the complete reagent init logic.
 * An alternative to using a list for defining our starting reagents since apparently overriding the value of a list creates an (init) proc each time.
 */
/obj/proc/populate_reagents()
	return

//#TODO: Implement me for all other objects!
/obj/PopulateClone(obj/clone)
	clone = ..()
	clone.req_access  = deepCopyList(req_access)
	clone.matter      = matter?.Copy()
	clone.anchor_fall = anchor_fall

	//#TODO: once item damage in, check health!
	return clone

/**
 * Returns a list with the contents that may be spawned in this object.
 * This shouldn't include things that are necessary for the object to operate, like machine components.
 * It's mainly for populating storage and the like.
 */
/obj/proc/WillContain()
	return

/obj/get_contained_matter(include_reagents = TRUE)
	. = ..()
	if(length(matter))
		. = MERGE_ASSOCS_WITH_NUM_VALUES(., matter.Copy())

/obj/proc/clear_matter()
	matter = null
	reagents?.clear_reagents()

////////////////////////////////////////////////////////////////
// Interactions
////////////////////////////////////////////////////////////////
/**Returns a text string to describe the current damage level of the item, or null if non-applicable. */
/obj/proc/get_examined_damage_string()
	if(!can_take_damage())
		return
	var/health_percent = get_percent_health()
	if(health_percent >= 100)
		return SPAN_NOTICE("It looks fully intact.")
	else if(health_percent > 75)
		return SPAN_NOTICE("It has a few cracks.")
	else if(health_percent > 50)
		return SPAN_WARNING("It looks slightly damaged.")
	else if(health_percent > 25)
		return SPAN_WARNING("It looks moderately damaged.")
	else
		return SPAN_DANGER("It looks heavily damaged.")

/obj/fluid_act(var/datum/reagents/fluids)
	..()
	if(!QDELETED(src) && fluids?.total_volume)
		fluids.touch_obj(src)

// TODO: maybe iterate the entire matter list or do some partial damage handling
/obj/proc/solvent_can_melt(var/solvent_power = MAT_SOLVENT_STRONG)
	if(!simulated)
		return FALSE
	var/decl/material/mat = get_material()
	return !mat || mat.dissolves_in <= solvent_power

/obj/handle_melting(list/meltable_materials)
	. = ..()
	if(QDELETED(src))
		return
	if(reagents?.total_volume)
		reagents.trans_to(loc, reagents.total_volume)
	dump_contents()
	return place_melted_product(meltable_materials)

/obj/proc/place_melted_product(list/meltable_materials)
	if(length(matter))
		var/datum/gas_mixture/environment = loc?.return_air()
		for(var/mat in matter)
			var/decl/material/M = GET_DECL(mat)
			M.add_burn_product(environment, MOLES_PER_MATERIAL_UNIT(matter[mat]))
		matter = null
	. = new /obj/effect/decal/cleanable/molten_item(src)
	qdel(src)

/obj/can_be_injected_by(var/atom/injector)
	return ATOM_IS_OPEN_CONTAINER(src)

/obj/ProcessAtomTemperature()
	. = ..()
	if(QDELETED(src))
		return
	// Bake any matter into the cooked form.
	if(LAZYLEN(matter))
		var/new_matter
		var/remove_matter
		for(var/matter_type in matter)
			var/decl/material/mat = GET_DECL(matter_type)
			if(mat.bakes_into_material && !isnull(mat.bakes_into_at_temperature) && temperature >= mat.bakes_into_at_temperature)
				LAZYINITLIST(new_matter)
				new_matter[mat.bakes_into_material] += matter[matter_type]
				LAZYDISTINCTADD(remove_matter, remove_matter)
		if(LAZYLEN(new_matter))
			for(var/mat in new_matter)
				matter[mat] = new_matter[mat]
		if(LAZYLEN(remove_matter))
			for(var/mat in remove_matter)
				matter -= mat
		UNSETEMPTY(matter)

/obj/proc/get_blend_objects()
	return

/obj/proc/is_compostable()
	for(var/mat in matter)
		var/decl/material/composting_mat = GET_DECL(mat)
		if(composting_mat.compost_value)
			return TRUE
	return FALSE

// Used to determine if something can be used as the basis of a mold.
/obj/proc/get_mould_difficulty()
	return SKILL_IMPOSSIBLE // length(matter) <= 1

// Used to determine what a mold made from this item produces.
/obj/proc/get_mould_product_type()
	return type

// Used to pass an associative list of data to the mold to pass to the product.
/obj/proc/get_mould_metadata()
	return

// Called when passing the metadata back to the item.
/obj/proc/take_mould_metadata(list/metadata)
	return

/obj/try_burn_wearer(var/mob/living/holder, var/held_slot, var/delay = 0)
	if(obj_flags & OBJ_FLAG_INSULATED_HANDLE)
		return
	return ..()

// Stub, used by /item and /structure
/obj/proc/refresh_color()
	return

// Slightly convoluted reagent logic to avoid fluid_act() putting reagents straight back into the destroyed /obj.
/obj/physically_destroyed(skip_qdel)
	var/dumped_reagents = FALSE
	var/atom/last_loc = loc
	if(last_loc && reagents?.total_volume)
		reagents.trans_to(loc, reagents.total_volume, defer_update = TRUE)
		dumped_reagents = TRUE
		reagents.clear_reagents() // We are qdeling, don't bother with a more nuanced update.
	. = ..()
	if(dumped_reagents && last_loc && !QDELETED(last_loc) && last_loc.reagents?.total_volume)
		last_loc.reagents.handle_update()
		HANDLE_REACTIONS(last_loc.reagents)

// Used by HE pipes and forging bars/billets. Defaults are for HE pipes.
/obj/proc/animate_heat_glow(icon_temperature, scale_sub = 500, scale_div = 1500, scale_max = 2000, skip_filter = FALSE, anim_time = 2 SECONDS)

	var/scale = max((icon_temperature - scale_sub) / scale_div, 0)
	var/h_r = heat2color_r(icon_temperature)
	var/h_g = heat2color_g(icon_temperature)
	var/h_b = heat2color_b(icon_temperature)

	var/base_color = get_color()
	var/b_r = HEX_RED(base_color)
	var/b_g = HEX_GREEN(base_color)
	var/b_b = HEX_BLUE(base_color)

	if(icon_temperature < scale_max)
		h_r = b_r + (h_r - b_r)*scale
		h_g = b_g + (h_g - b_g)*scale
		h_b = b_b + (h_b - b_b)*scale

	var/scale_color = rgb(h_r, h_g, h_b)
	var/list/animate_targets = get_above_oo() + src
	for (var/thing in animate_targets)
		var/atom/movable/AM = thing
		if(anim_time > 0)
			animate(AM, color = scale_color, time = anim_time, easing = SINE_EASING)
		else
			color = scale_color
	if(!skip_filter)
		animate_filter("glow", list(color = scale_color, time = anim_time, easing = LINEAR_EASING))

	set_light(min(3, scale*2.5), min(3, scale*2.5), scale_color)

/obj/proc/update_heat_glow(anim_time)

	// We have no real way to find temperature bounds without a material that has a melting point.
	var/decl/material/my_material = get_material()
	if(!istype(my_material) || !my_material.glows_with_heat || isnull(my_material.melting_point) || QDELETED(src))
		set_light(0, 0)
		if(isatom(loc))
			loc.update_icon()
		return

	var/temperature_percentage
	if(temperature >= my_material.melting_point) // We should have melted...
		temperature_percentage = 1
	else if(temperature <= T20C) // Arbitrary point for the sake of not trying to find a proportional temperature delta with ice
		temperature_percentage = 0
	else
		temperature_percentage = (my_material.melting_point - T20C) / (temperature - T20C)
	if(temperature_percentage < 0.25)
		set_light(0, 0)
	else
		animate_heat_glow(temperature, scale_sub = round((my_material.melting_point - T20C) * 0.25) + T20C, scale_div = round(my_material.melting_point * 0.75), scale_max = my_material.melting_point, skip_filter = TRUE, anim_time = anim_time)
	if(isatom(loc))
		loc.update_icon()

/obj/is_valid_merchant_pad_target()
	if(anchored)
		return FALSE
	return ..()

