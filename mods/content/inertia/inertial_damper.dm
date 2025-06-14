/obj/machinery/inertial_damper
	name = "inertial damper"
	icon = 'mods/content/inertia/icons/inertial_damper.dmi'
	desc = "An inertial damper, a very large machine that balances against engine thrust to prevent harm to the crew."
	density = TRUE
	icon_state = "damper_on"

	base_type = /obj/machinery/inertial_damper
	construct_state = /decl/machine_construction/default/panel_closed
	wires = /datum/wires/inertial_damper
	uncreated_component_parts = null
	stat_immune = FALSE

	idle_power_usage = 1 KILOWATTS
	use_power = POWER_USE_ACTIVE
	anchored = TRUE

	pixel_x = -32
	pixel_y = -32
	bound_x = -32
	bound_y = -32

	var/datum/ship_inertial_damper/controller

	var/active = TRUE

	var/damping_strength = 1 //units of Gm/h
	var/damping_modifier = 0 //modifier due to events
	var/target_strength = 1
	var/delta = 0.01
	var/max_strength = 5
	var/power_draw
	var/max_power_draw = 200 KILOWATTS
	var/lastwarning = 0
	var/warned = FALSE

	var/was_reset = FALSE //if this inertial damper was fully turned off recently (zero damping strength, no power)

	var/hacked = FALSE
	var/locked = FALSE
	var/ai_control_disabled = FALSE
	var/input_cut = FALSE

	var/current_overlay = null
	var/width = 3
	var/height = 2

	/// The cooldown between announcements that the inertial damping system is off.
	var/const/WARNING_DELAY = 8 SECONDS

/obj/machinery/inertial_damper/Initialize()
	. = ..()
	SetBounds()
	update_nearby_tiles(locs)
	controller = new(src)

	var/obj/effect/overmap/visitable/ship/S = get_owning_overmap_object()
	if(istype(S))
		S.inertial_dampers |= controller

	src.overlays += "activated"

/obj/machinery/inertial_damper/Process()
	..()
	if(active && !(stat & (NOPOWER | BROKEN)) && !input_cut)
		delta = initial(delta)
		power_draw = (damping_strength / max_strength) * max_power_draw
		change_power_consumption(power_draw, POWER_USE_ACTIVE)

		// Provide a warning if our inertial damping level is decreasing past a threshold and we haven't already warned since someone last adjusted the setting
		if(!warned && damping_strength < 0.3*initial(damping_strength) && target_strength < damping_strength && lastwarning - world.timeofday >= WARNING_DELAY)
			warned = TRUE
			lastwarning = world.timeofday
			do_telecomms_announcement(src, "WARNING: Inertial dampening level dangerously low! All crew must be secured before firing thrusters!", "Inertial Damper Monitor")
	else
		delta = initial(delta) * 5 // rate of dampening strength decay is higher if we have no power
		target_strength = 0
		if(!damping_strength)
			damping_modifier = initial(damping_modifier)
			was_reset = TRUE
		change_power_consumption(0, POWER_USE_OFF)

	queue_icon_update()

	if(damping_strength != target_strength)
		damping_strength = damping_strength > target_strength ? max(damping_strength - delta, target_strength) : min(damping_strength + delta, target_strength)

/obj/machinery/inertial_damper/Destroy()
	QDEL_NULL(controller)
	update_nearby_tiles(locs)
	return ..()

/obj/machinery/inertial_damper/proc/toggle()
	active = !active
	update_icon()
	return active

/obj/machinery/inertial_damper/proc/is_on()
	return active

/// Returns either the true damping strength including modifiers (include_modifiers == TRUE),
/// or just the value the damper is set to (include_modifiers == FALSE).
/obj/machinery/inertial_damper/proc/get_damping_strength(var/include_modifiers)
	if(hacked && !include_modifiers)
		return initial(damping_strength)
	return damping_strength + damping_modifier

/obj/machinery/inertial_damper/proc/get_status()
	return active ? "on" : "off"

/obj/machinery/inertial_damper/on_update_icon()
	..()
	icon_state = "damper_[get_status()]"

	var/overlay_state = null
	if(!active && damping_strength == 0)
		overlay_state = null //inactive and powered off
	else if(damping_strength < initial(damping_strength))
		if(target_strength != damping_strength)
			overlay_state = "startup" //lower than default strength and changing
		else
			overlay_state = "weak" //met our target but lower than default strength
	else if(target_strength > damping_strength && damping_strength >= initial(damping_strength))
		overlay_state = "activating" //rising higher than default strength
	else
		overlay_state = "activated" //met our target higher than default strength

	if(overlay_state != current_overlay)
		overlays.Cut()
		if(overlay_state)
			var/image/new_overlay_state = image(icon, overlay_state)
			new_overlay_state.appearance_flags |= RESET_COLOR
			overlays += new_overlay_state
		current_overlay = overlay_state

/obj/machinery/inertial_damper/proc/SetBounds()
	bound_width = width * world.icon_size
	bound_height = height * world.icon_size
	if(bound_height != world.icon_size || bound_width != world.icon_size)
		appearance_flags = /obj/machinery::appearance_flags & ~TILE_BOUND

/obj/machinery/inertial_damper/interface_interact(var/mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/inertial_damper/CanUseTopic(var/mob/user)
	if(issilicon(user) && !Adjacent(user) && ai_control_disabled)
		return STATUS_UPDATE
	return ..()

/obj/machinery/inertial_damper/OnTopic(user, href_list, datum/topic_state/state)
	if(locked)
		to_chat(user, SPAN_WARNING("\The [src]'s controls are not responding."))
		return TOPIC_NOACTION

	if(href_list["toggle"])
		toggle()
		return TOPIC_REFRESH

	if(href_list["set_strength"])
		var/new_strength = input("Enter a new damper strength between 0 and [max_strength] Gm/h", "Modifying damper strength", get_damping_strength(TRUE)) as num
		if(!(new_strength in 0 to max_strength))
			to_chat(user, SPAN_WARNING("That's not a valid damper strength."))
			warned = FALSE
			return TOPIC_NOACTION

		warned = FALSE
		target_strength = clamp(new_strength, 0, max_strength)
		return TOPIC_REFRESH

	return TOPIC_NOACTION

/obj/machinery/inertial_damper/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	data["online"] = is_on()
	data["damping_strength"] = round(get_damping_strength(TRUE), 0.01)
	data["max_strength"] = max_strength
	data["hacked"] = hacked
	data["power_usage"] = round(power_draw/1e3)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "inertial_damper.tmpl", "Inertial Damper", 400, 400)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/inertial_damper/dismantle()
	if((. = ..()))
		update_nearby_tiles(locs)
