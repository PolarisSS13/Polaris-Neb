/atom
	/// (DEFINE) Determines where this atom sits in terms of turf plating. See misc.dm
	var/level = LEVEL_ABOVE_PLATING
	/// (BITFLAG) See flags.dm
	var/atom_flags = 0
	/// (FLOAT) The world.time that this atom last bumped another. Used mostly by mobs.
	var/last_bumped = 0
	/// (BITFLAG) See flags.dm
	var/pass_flags = 0
	/// (BOOL) If a thrown object can continue past this atom. Sometimes used for clicking as well? TODO: Rework this
	var/throwpass = 0
	/// (INTEGER) The number of germs on this atom.
	var/germ_level = GERM_LEVEL_AMBIENT
	/// (BOOL) If an atom should be interacted with by a number of systems (Atmos, Liquids, Turbolifts, Etc.)
	var/simulated = TRUE
	/// The chemical contents of this atom
	var/datum/reagents/reagents
	/// (INTEGER) The amount an explosion's power is decreased when encountering this atom
	var/explosion_resistance = 0
	/// (BOOL) If it can be spawned normally
	var/is_spawnable_type = FALSE


	/// (DICTIONARY) A lazy map. The `key` is a MD5 player name and the `value` is the blood type.
	var/list/blood_DNA
	/// (BOOL) If this atom was bloodied before.
	var/was_bloodied = FALSE
	/// (COLOR) The color of the blood shown on blood overlays.
	var/blood_color
	/// (FALSE|DEFINES) How this atom is interacting with UV light. See misc.dm
	var/fluorescent = FALSE


	/// (LIST) A list of all mobs that are climbing or currently on this atom
	var/list/climbers
	/// (FLOAT) The climbing speed multiplier for this atom
	var/climb_speed_mult = 1


	/// (FLOAT) The horizontal scaling that should be applied.
	var/icon_scale_x = 1
	/// (FLOAT) The vertical scaling that should be applied.
	var/icon_scale_y = 1
	/// (FLOAT) The angle in degrees clockwise that should be applied.
	var/icon_rotation = 0
	/// (FLOAT) If greater than zero, transform-based adjustments (scaling, rotating) will visually occur over this time.
	var/transform_animate_time = 0

	var/tmp/currently_exploding = FALSE
	var/tmp/default_pixel_x
	var/tmp/default_pixel_y
	var/tmp/default_pixel_z
	var/tmp/default_pixel_w

	/// (FLOAT) Current remaining health value.
	var/current_health
	/// (FLOAT) Theoretical maximum health value.
	var/max_health

	/// (BOOL) Does this atom respond to changes in local temperature via the `temperature` var?
	var/temperature_sensitive = FALSE
	/// (DATUM) /datum/storage instance to use for this obj. Set to a type for instantiation on init.
	var/datum/storage/storage
	/// (FLOAT) world.time of last on_reagent_update call, used to prevent recursion due to reagents updating reagents
	VAR_PRIVATE/_reagent_update_started = 0

/atom/proc/get_max_health()
	return max_health

/atom/proc/get_health_ratio()
	return current_health/get_max_health()

/atom/proc/get_health_percent(var/sigfig = 1)
	return round(get_health_ratio()*100, sigfig)

/**
	Adjust variables prior to Initialize() based on the map

	Called by the maploader to perform static modifications to vars set on the map.
	Intended use case: Adjust tag vars on duplicate templates (such as airlock tags).

	- `map_hash`: A unique string for a map (usually using sequential_id)
*/
/atom/proc/modify_mapped_vars(map_hash)
	SHOULD_CALL_PARENT(TRUE)

/**
	Attempt to merge a gas_mixture `giver` into this atom's gas_mixture

	- Return: `TRUE` if successful, otherwise `FALSE`
*/
/atom/proc/assume_air(datum/gas_mixture/giver)
	return FALSE

/**
	Attempt to remove `amount` moles from this atom's gas_mixture

	- Return: A `/datum/gas_mixture` containing the gas removed if successful, otherwise `null`
*/
/atom/proc/remove_air(amount)
	RETURN_TYPE(/datum/gas_mixture)
	return null

/**
	Merge an exhaled air volume into air contents.
*/
/atom/proc/merge_exhaled_volume(datum/gas_mixture/exhaled)
	var/datum/gas_mixture/environment = return_air()
	environment?.merge(exhaled)

/**
	Get the air of this atom or its location's air

	- Return: The `/datum/gas_mixture` of this atom
*/
/atom/proc/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	return loc?.return_air()

/**
	Get the flags that should be added to the `users` sight var.

	- Return: Sight flags, or `-1` if the view should be reset
	- TODO: Also sometimes handles resetting of view itself, probably should be more consistent.
*/
/atom/proc/check_eye(user)
	if (isAI(user)) // WHY
		return 0
	return -1

/**
	Get sight flags that this atom should provide to a user
	- See: /mob/var/sight
*/
/atom/proc/additional_sight_flags()
	SHOULD_BE_PURE(TRUE)
	return 0

/// Get the level of invisible sight this atom should provide to a user
/atom/proc/additional_see_invisible()
	SHOULD_BE_PURE(TRUE)
	return 0

/// Handle reagents being modified
/atom/proc/try_on_reagent_change()
	SHOULD_NOT_OVERRIDE(TRUE)
	set waitfor = FALSE
	if(QDELETED(src) || _reagent_update_started >= world.time)
		return FALSE
	_reagent_update_started = world.time
	sleep(0) // Defer to end of tick so we don't drop subsequent reagent updates.
	if(QDELETED(src))
		return
	return on_reagent_change()

/atom/proc/on_reagent_change()
	SHOULD_CALL_PARENT(TRUE)
	if(storage && reagents?.total_volume)
		for(var/obj/item/thing in get_stored_inventory())
			thing.fluid_act(reagents)
	return TRUE

/**
	Handle an atom bumping this atom

	Called by `AMs` Bump()

	- `AM`: The atom that bumped us
*/
/atom/proc/Bumped(var/atom/movable/AM)
	return

/**
	Check if an atom can exit this atom's turf.

	- `mover`: The atom trying to move
	- `target`: The turf the atom is trying to move to
	- Return: `TRUE` if it can exit, otherwise `FALSE`
*/
/atom/proc/CheckExit(atom/movable/mover, turf/target)
	SHOULD_BE_PURE(TRUE)
	return TRUE

/**
	Handle an atom entering this atom's proximity

	Called when an atom enters this atom's proximity. Both this and the other atom
	need to have the MOVABLE_FLAG_PROXMOVE flag (as it helps reduce lag).

	- `AM`: The atom entering proximity
	- Return: `TRUE` if proximity should continue to be handled, otherwise `FALSE`
	- TODO: Rename this to `handle_proximity`
*/
/atom/proc/HasProximity(atom/movable/AM)
	SHOULD_CALL_PARENT(TRUE)
	set waitfor = FALSE
	if(!istype(AM))
		PRINT_STACK_TRACE("DEBUG: HasProximity called with [AM] on [src] ([usr]).")
		return FALSE
	return TRUE

/**
	Handle an EMP affecting this atom

	- `severity`: Strength of the explosion ranging from 1 to 3. Higher is weaker
*/
/atom/proc/emp_act(severity)
	return

/**
	Set the density of this atom to `new_density`

	- Events: `density_set` (only if density actually changed)
*/
/atom/proc/set_density(new_density)
	SHOULD_CALL_PARENT(TRUE)
	if(density != new_density)
		density = !!new_density
		if(event_listeners?[/decl/observ/density_set])
			raise_event_non_global(/decl/observ/density_set, !density, density)

/**
	Handle a projectile `P` hitting this atom

	- `P`: The `/obj/item/projectile` hitting this atom
	- `def_zone`: The zone `P` is hitting
	- Return: `0 to 100+`, representing the % damage blocked. Can also be special PROJECTILE values (misc.dm)
*/
/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	P.on_hit(src, 0, def_zone)
	return 0

/**
	Check if this atom is in the path or atom `container`

	- `container`: The path or atom to check
	- Return: `TRUE` if `container` contains this atom, otherwise `FALSE`
*/
/atom/proc/in_contents_of(container)
	if(ispath(container))
		if(istype(src.loc, container))
			return TRUE
	else if(src in container)
		return TRUE
	return FALSE

/**
	Recursively search this atom's contents for an atom of type `path`

	- `path`: The path of the atom to search for
	- `filter_path?`: A list of atom paths that only should be searched, or `null` to search all
	- Return: A list of atoms of type `path` found inside this atom
*/
/atom/proc/search_contents_for(path, list/filter_path=null)
	RETURN_TYPE(/list)
	var/list/found = list()
	for(var/atom/A in src)
		if(istype(A, path))
			found += A
		if(filter_path)
			var/pass = 0
			for(var/type in filter_path)
				pass |= istype(A, type)
			if(!pass)
				continue
		if(A.contents.len)
			found += A.search_contents_for(path,filter_path)
	return found

/**
	Display a description of this atom to a mob.

	Overrides should either return the result of ..() or `TRUE` if not calling it.
	Calls to ..() should generally not supply any arguments and instead rely on
	BYOND's automatic argument passing. There is no need to check the return
	value of ..(), this is only done by the calling `/examine_verb()` proc to validate
	the call chain.

	- `user`: The mob examining this atom
	- `distance`: The distance this atom is from the `user`
	- `infix`: An optional string appended directly to the 'That's an X' string, between the name the end of the sentence.
	- `suffix`: An optional string appended in a separate sentence after the initial introduction line.
	- Return: `TRUE` when the call chain is valid, otherwise `FALSE`
	- Events: `atom_examined`
*/
/atom/proc/examined_by(mob/user, distance, infix, suffix)
	var/list/examine_lines
	// to_chat(user, "<blockquote>") // these don't work in BYOND's native output panel. If we switch to browser output instead, you can readd this
	for(var/add_lines in list(get_examine_header(user, distance, infix, suffix), get_examine_strings(user, distance, infix, suffix), get_examine_hints(user, distance, infix, suffix)))
		if(islist(add_lines) && LAZYLEN(add_lines))
			LAZYADD(examine_lines, add_lines)
	if(LAZYLEN(examine_lines))
		to_chat(user, jointext(examine_lines, "<br/>"))
	// to_chat(user, "</blockquote>") // see above
	RAISE_EVENT(/decl/observ/atom_examined, src, user, distance)
	return TRUE

// Name, displayed at the top.
/atom/proc/get_examine_header(mob/user, distance, infix, suffix)
	SHOULD_CALL_PARENT(TRUE)
	var/article_name = name
	if(is_improper(name)) // no 'that's bloody oily slimy Bob', that's just Bob
		//This reformats names to get a/an properly working on item descriptions when they are bloody or coated in reagents.
		var/examine_prefix = get_examine_prefix()
		if(examine_prefix)
			examine_prefix += " " // add a space to the end to be polite
		article_name = ADD_ARTICLE_GENDER("[examine_prefix][name]", gender)
	return list("[html_icon(src)] That's [article_name][infix][get_examine_punctuation()] [suffix]")

// Main body of examine, displayed after the header and before hints.
/atom/proc/get_examine_strings(mob/user, distance, infix, suffix)
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	if(desc)
		. += desc

// Addendum to examine, displayed at the bottom
/atom/proc/get_examine_hints(mob/user, distance, infix, suffix)

	SHOULD_CALL_PARENT(TRUE)

	var/list/alt_interactions = get_alt_interactions(user)
	if(LAZYLEN(alt_interactions))
		var/list/interaction_strings = list()
		for(var/interaction_type as anything in alt_interactions)
			var/decl/interaction_handler/interaction = GET_DECL(interaction_type)
			if(interaction.examine_desc && (interaction.always_show_on_examine || interaction.is_possible(src, user, user?.get_active_held_item())))
				interaction_strings += emote_replace_target_tokens(interaction.examine_desc, src)
		if(length(interaction_strings))
			LAZYADD(., SPAN_INFO("Alt-click on \the [src] to [english_list(interaction_strings, and_text = " or ")]."))

	var/decl/interaction_handler/handler = get_quick_interaction_handler(user)
	if(handler)
		LAZYADD(., SPAN_NOTICE("<b>Ctrl-click</b> \the [src] while in your inventory to [lowertext(handler.name)]."))

	if(user?.get_preference_value(/datum/client_preference/inquisitive_examine) == PREF_ON && user.can_use_codex() && SScodex.get_codex_entry(get_codex_value(user)))
		LAZYADD(., SPAN_NOTICE("The codex has <b><a href='byond://?src=\ref[SScodex];show_examined_info=\ref[src];show_to=\ref[user]'>relevant information</a></b> available."))

/**
	Relay movement to this atom.

	Called by mobs, such as when the mob is inside the atom, their buckled
	var is set to this, or this atom is set as their machine.

	- See: code/modules/mob/mob_movement.dm
*/
/atom/proc/relaymove()
	return

/**
	Set the direction of this atom to `new_dir`

	- `new_dir`: The new direction the atom should face.
	- Return: `TRUE` if the direction has been changed.
	- Events: `dir_set`
*/
/atom/proc/set_dir(new_dir)
	SHOULD_CALL_PARENT(TRUE)

	// This attempts to mimic BYOND's handling of diagonal directions and cardinal icon states.
	var/old_dir = dir
	if((atom_flags & ATOM_FLAG_BLOCK_DIAGONAL_FACING) && !IS_POWER_OF_TWO(new_dir))
		if(old_dir & new_dir)
			new_dir = old_dir
		else
			new_dir &= global.adjacentdirs[old_dir]

	. = new_dir != dir
	if(!.)
		return

	dir = new_dir
	if(light_source_solo)
		light_source_solo.source_atom.update_light()
	else if(light_source_multi)
		var/datum/light_source/L
		for(var/thing in light_source_multi)
			L = thing
			if(L.light_angle)
				L.source_atom.update_light()

	if(event_listeners?[/decl/observ/dir_set])
		raise_event_non_global(/decl/observ/dir_set, old_dir, new_dir)


/// Set the icon to `new_icon`
/atom/proc/set_icon(new_icon)
	if(icon != new_icon)
		icon = new_icon
		return TRUE
	return FALSE

/// Set the icon_state to `new_icon_state`
/atom/proc/set_icon_state(var/new_icon_state)
	SHOULD_CALL_PARENT(TRUE)
	if(has_extension(src, /datum/extension/base_icon_state))
		var/datum/extension/base_icon_state/bis = get_extension(src, /datum/extension/base_icon_state)
		bis.base_icon_state = new_icon_state
		update_icon()
	else
		icon_state = new_icon_state

/**
	Update this atom's icon.

	- Events: `updated_icon`
*/
/atom/proc/update_icon()
	SHOULD_CALL_PARENT(TRUE)
	on_update_icon()
	if(event_listeners?[/decl/observ/updated_icon])
		raise_event_non_global(/decl/observ/updated_icon)

/**
 * Update this atom's icon.
 * If prior to SSicon_update's first flush, queues.
 * Otherwise, updates instantly.
 */
/atom/proc/lazy_update_icon()
	if(SSicon_update.init_state != SS_INITSTATE_NONE)
		return update_icon()
	queue_icon_update()

/**
	Update this atom's icon.

	Usually queue_icon_update() or update_icon() should be used instead.
*/
/atom/proc/on_update_icon()
	SHOULD_CALL_PARENT(FALSE) //Don't call the stub plz
	return

/**
 * Returns the sum of this atoms's reagents plus the combined matter of all its contents.
 * Obj adds matter contents. Other overrides may add extra handling for things like material storage.
 * Most useful for calculating worth or deconstructing something along with its contents.
 */
/atom/proc/get_contained_matter(include_reagents = TRUE)
	if(include_reagents && length(reagents?.reagent_volumes))
		LAZYINITLIST(.)
		for(var/decl/material/reagent as anything in reagents.reagent_volumes)
			.[reagent.type] += floor(REAGENT_VOLUME(reagents, reagent) / REAGENT_UNITS_PER_MATERIAL_UNIT)
	for(var/atom/contained_obj as anything in get_contained_external_atoms()) // machines handle component parts separately
		. = MERGE_ASSOCS_WITH_NUM_VALUES(., contained_obj.get_contained_matter(include_reagents))

/// Return a list of all simulated atoms inside this one.
/atom/proc/get_contained_external_atoms()
	for(var/atom/movable/AM in contents)
		if(!QDELETED(AM) && AM.simulated)
			LAZYADD(., AM)
	if(has_extension(src, /datum/extension/loaded_cell))
		var/datum/extension/loaded_cell/cell_loaded = get_extension(src, /datum/extension/loaded_cell)
		var/cell = cell_loaded?.get_cell()
		if(cell)
			LAZYREMOVE(., cell)

// Return a list of all stored (in inventory) atoms, defaulting to above.
/atom/proc/get_stored_inventory()
	SHOULD_CALL_PARENT(TRUE)
	return get_contained_external_atoms()

// Return a list of all temperature-sensitive atoms, defaulting to above.
/atom/proc/get_contained_temperature_sensitive_atoms()
	SHOULD_CALL_PARENT(TRUE)
	return get_contained_external_atoms()

/// Dump the contents of this atom onto its loc
/atom/proc/dump_contents(atom/forced_loc = loc, mob/user)
	for(var/thing in get_contained_external_atoms())
		var/atom/movable/AM = thing
		AM.dropInto(forced_loc)
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE

/**
	Handle the destruction of this atom, spilling its contents by default

	- `skip_qdel`: If calling qdel() on this atom should be skipped.
	- Return: Unknown, feel free to change this
*/
/atom/proc/physically_destroyed(var/skip_qdel)
	SHOULD_CALL_PARENT(TRUE)
	dump_contents()
	if(!skip_qdel && !QDELETED(src))
		qdel(src)
	. = TRUE

/**
	Attempt to detonate the reagents contained in this atom

	- `severity`: Strength of the explosion ranging from 1 to 3. Higher is weaker
*/
/atom/proc/try_detonate_reagents(var/severity = 3)
	if(reagents)
		for(var/decl/material/reagent as anything in reagents.reagent_volumes)
			reagent.explosion_act(src, severity)

/**
	Handle an explosion of `severity` affecting this atom

	- `severity`: Strength of the explosion ranging from 1 to 3. Higher is weaker
	- Return: `TRUE` if severity is within range and exploding should continue, otherwise `FALSE`
*/
/atom/proc/explosion_act(var/severity)
	SHOULD_CALL_PARENT(TRUE)
	. = !currently_exploding && severity > 0 && severity <= 3
	if(.)
		currently_exploding = TRUE
		if(severity < 3)
			for(var/atom/movable/AM in get_contained_external_atoms())
				AM.explosion_act(severity + 1)
			try_detonate_reagents(severity)
		currently_exploding = FALSE

/**
	Handle a `user` attempting to emag this atom

	- `remaining_charges`: Used for nothing TODO: Fix this
	- `user`: The user attempting to emag this atom
	- `emag_source`: The source of the emag
	- Returns: 1 if successful, -1 if not, NO_EMAG_ACT if it cannot be emaged
*/
/atom/proc/emag_act(var/remaining_charges, var/mob/user, var/emag_source)
	return NO_EMAG_ACT

/**
	Handle this atom being exposed to fire

	- `air`: The gas_mixture for this loc
	- `exposed_temperature`: The temperature of the air
	- `exposed_volume`: The volume of the air
*/
/atom/proc/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	SHOULD_CALL_PARENT(TRUE)
	handle_external_heating(exposed_temperature)

/// Handle this atom being destroyed through melting
/atom/proc/handle_melting(list/meltable_materials)
	SHOULD_CALL_PARENT(TRUE)

/atom/proc/handle_destroyed_by_heat()
	return handle_melting()

/**
	Handle this atom being exposed to lava. Calls qdel() by default

	- Returns: `TRUE` if qdel() was called, otherwise `FALSE`
*/
/atom/proc/lava_act()
	if(simulated)
		visible_message(SPAN_DANGER("\The [src] sizzles and melts away, consumed by the lava!"))
		playsound(src, 'sound/effects/flare.ogg', 100, 3)
		qdel(src)
		return TRUE
	return FALSE

/**
	Handle this atom being hit by a thrown atom

	- `AM`: The atom hitting this atom
	- `TT`: A datum wrapper for a thrown atom, containing important info
	- Returns: TRUE if successfully hit the atom.
*/
/atom/proc/hitby(atom/movable/AM, var/datum/thrownthing/TT)
	SHOULD_CALL_PARENT(TRUE)
	if(isliving(AM))
		var/mob/living/M = AM
		M.apply_damage(TT.speed*5, BRUTE)
	return TRUE

/**
	Attempt to add blood to this atom

	If a mob is provided, their blood will be used

	- `M?`: The mob whose blood will be used
	- Returns: TRUE if made bloody, otherwise FALSE
*/
/atom/proc/add_blood(mob/living/M, amount = 2, list/blood_data)
	if(atom_flags & ATOM_FLAG_NO_BLOOD)
		return FALSE

	if(!islist(blood_DNA))	//if our list of DNA doesn't exist yet (or isn't a list) initialize it.
		blood_DNA = list()

	was_bloodied = 1
	blood_color = istype(M) ? M.get_blood_color() : COLOR_BLOOD_HUMAN
	return TRUE

/**
	Remove any blood from this atom

	- Return: `TRUE` if blood with DNA was removed
*/
/atom/proc/clean(clean_forensics = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(!simulated)
		return
	fluorescent = FALSE
	germ_level = 0
	blood_color = null
	if(istype(blood_DNA, /list))
		blood_DNA = null
		var/datum/extension/forensic_evidence/forensics = get_extension(src, /datum/extension/forensic_evidence)
		if(forensics)
			forensics.remove_data(/datum/forensics/blood_dna)
			forensics.remove_data(/datum/forensics/gunshot_residue)
		return TRUE
	return FALSE

/**
	Check if this atom can be passed by another given the flags provided

	- `pass_flag`: The flags to check. See: flags.dm
	- Return: The flags present that allow it to pass, otherwise `0`
*/
/atom/proc/checkpass(pass_flag)
	SHOULD_BE_PURE(TRUE)
	return pass_flags & pass_flag

/**
	Show a message to all mobs and objects in sight of this atom.

	Used for atoms performing visible actions

	- `message`: The string output to any atom that can see this atom
	- `self_message?`: The string displayed to this atom if it's a mob. See: mobs.dm
	- `blind_message?`: The string blind mobs will see. Example: "You hear something!"
	- `range?`: The number of tiles away the message will be visible from. Default: world.view
	- `check_ghosts?`: Set to `TRUE` if ghosts should see the message if their preferences allow
*/
/atom/proc/visible_message(var/message, var/self_message, var/blind_message, var/range = world.view, var/check_ghosts = null)
	var/turf/T = get_turf(src)
	var/list/mobs = list()
	var/list/objs = list()
	get_listeners_in_range(T,range, mobs, objs, check_ghosts)

	for(var/o in objs)
		var/obj/O = o
		O.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)

	for(var/m in mobs)
		var/mob/M = m
		if(M.see_invisible >= invisibility)
			M.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
		else if(blind_message)
			M.show_message(blind_message, AUDIBLE_MESSAGE)

/**
	Show a message to all mobs and objects in earshot of this atom

	Used for atoms performing audible actions

	- `message`: The string to show to anyone who can hear this atom
	- `deaf_message?`: The string deaf mobs will see
	- `hearing_distance?`: The number of tiles away the message can be heard. Defaults to world.view
	- `check_ghosts?`: TRUE if ghosts should hear the message if their preferences allow
	- `radio_message?`: The string to send over radios
*/
/atom/proc/audible_message(var/message, var/deaf_message, var/hearing_distance = world.view, var/check_ghosts = null, var/radio_message)
	var/turf/T = get_turf(src)
	var/list/mobs = list()
	var/list/objs = list()
	get_listeners_in_range(T, hearing_distance, mobs, objs, check_ghosts)

	for(var/m in mobs)
		var/mob/M = m
		M.show_message(message,2,deaf_message,1)
	for(var/o in objs)
		var/obj/O = o
		O.show_message(message,2,deaf_message,1)

/**
	Attempt to drop this atom onto the destination.

	The destination can instead return another location, recursively chaining.

	- `destination`: The atom that this atom is dropped onto.
	- Return: The result of the forceMove() at the end.
*/
/atom/movable/proc/dropInto(var/atom/destination)
	while(!QDELETED(src) && istype(destination))
		var/atom/drop_destination = destination.onDropInto(src)
		if(!istype(drop_destination) || drop_destination == destination)
			return forceMove(destination)
		destination = drop_destination
	return forceMove(null)

/**
	Handle dropping an atom onto this atom.

	If the item should move into this atom, return null. Otherwise, return
	the destination atom where the item should be moved.

	- `AM`: The atom being dropped onto this atom
	- Return: A location for the atom AM to move to, or null to move it into this atom.
*/
/atom/proc/onDropInto(var/atom/movable/AM)
	RETURN_TYPE(/atom)
	return

/atom/movable/onDropInto(var/atom/movable/AM)
	return loc

/**
	Handle this atom being hit by a grab.

	Called by resolve_attackby()

	- `G`: The grab hitting this atom
	- Return: `TRUE` to skip attackby() and afterattack() or `FALSE`
*/
/atom/proc/grab_attack(obj/item/grab/grab, mob/user)
	return FALSE

/atom/proc/climb_on()

	set name = "Climb"
	set desc = "Climbs onto an object."
	set category = "Object"
	set src in oview(1)

	do_climb(usr)

/**
	Check if a user can climb this atom.

	- `user`: The mob to check
	- `post_climb_check?`: If we should check if the user can continue climbing
	- Return: `TRUE` if they can climb, otherwise `FALSE`
*/
/atom/proc/can_climb(var/mob/living/user, post_climb_check=0)
	if (!(atom_flags & ATOM_FLAG_CLIMBABLE) || !user.can_touch(src) || (!post_climb_check && climbers && (user in climbers)))
		return FALSE

	if (!user.Adjacent(src))
		to_chat(user, "<span class='danger'>You can't climb there, the way is blocked.</span>")
		return FALSE

	var/obj/occupied = turf_is_crowded(user)
	if(occupied)
		to_chat(user, "<span class='danger'>There's \a [occupied] in the way.</span>")
		return FALSE
	return TRUE

/**
	Check if this atom's turf is blocked.

	This doesn't handle border structures and should be preceded by an Adjacent() check.
	- `ignore?`: An atom that should be ignored by the check.
	- Return: The first atom blocking this atom's turf.
*/
/atom/proc/turf_is_crowded(var/atom/ignore)
	RETURN_TYPE(/atom)
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return 0
	for(var/atom/A in T.contents)
		if(ignore && ignore == A)
			continue
		if(A.atom_flags & ATOM_FLAG_CLIMBABLE)
			continue
		if(A.density && !(A.atom_flags & ATOM_FLAG_CHECKS_BORDER)) //ON_BORDER structures are handled by the Adjacent() check.
			return A
	return 0

/**
	Handle `user` climbing onto this atom.

	- `user`: The mob climbing onto this atom.
	- Return: `TRUE` if the user successfully climbs onto this atom, otherwise `FALSE`.
*/
/atom/proc/do_climb(var/mob/living/user)
	if (!can_climb(user))
		return FALSE

	add_fingerprint(user)
	user.visible_message("<span class='warning'>\The [user] starts climbing onto \the [src]!</span>")
	LAZYDISTINCTADD(climbers,user)

	if(!do_after(user,(issmall(user) ? MOB_CLIMB_TIME_SMALL : MOB_CLIMB_TIME_MEDIUM) * climb_speed_mult, src))
		LAZYREMOVE(climbers,user)
		return FALSE

	if(!can_climb(user, post_climb_check=1))
		LAZYREMOVE(climbers,user)
		return FALSE

	// handle multitile objects
	// this should also be fine for non-multitile objects
	// and ensures we don't ever move more than 1 tile
	var/target_turf = get_step(user, get_dir(user, src))

	//climbing over border objects like railings
	if((atom_flags & ATOM_FLAG_CHECKS_BORDER) && get_turf(user) == target_turf)
		target_turf = get_step(src, dir)

	user.forceMove(target_turf)

	if (get_turf(user) == target_turf)
		user.visible_message("<span class='warning'>\The [user] climbs onto \the [src]!</span>")
	LAZYREMOVE(climbers,user)
	return TRUE

/// Shake this atom and all its climbers.
/atom/proc/object_shaken()
	for(var/mob/living/M in climbers)
		SET_STATUS_MAX(M, STAT_WEAK, 1)
		to_chat(M, "<span class='danger'>You topple as you are shaken off \the [src]!</span>")
		climbers.Cut(1,2)

	for(var/mob/living/M in get_turf(src))
		if(M.current_posture.prone) return //No spamming this on people.

		SET_STATUS_MAX(M, STAT_WEAK, 3)
		to_chat(M, SPAN_DANGER("You topple as \the [src] moves under you!"))
		if(prob(25))
			var/damage = rand(15,30)
			var/obj/item/organ/external/affecting = SAFEPICK(M.get_external_organs())
			if(!affecting)
				to_chat(M, SPAN_DANGER("You land heavily!"))
				M.take_damage(damage)
			else
				to_chat(M, SPAN_DANGER("You land heavily on your [affecting.name]!"))
				affecting.take_damage(damage)
				if(affecting.parent)
					affecting.parent.add_autopsy_data("Misadventure", damage)

/// Get the current color of this atom.
/atom/proc/get_color()
	return color

/* Set the atom colour. This is a stub effectively due to the broad use of direct setting. */
// TODO: implement this everywhere that it should be used instead of direct setting.
/atom/proc/set_color(var/new_color)
	if(isnull(new_color))
		return reset_color()
	if(color != new_color)
		color = new_color
		return TRUE
	return FALSE

/atom/proc/reset_color()
	if(!isnull(color))
		color = null
		return TRUE
	return FALSE

/atom/proc/set_alpha(var/new_alpha)
	if(alpha != new_alpha)
		alpha = new_alpha
		return TRUE
	return FALSE

/// Get any power cell associated with this atom.
/atom/proc/get_cell()
	RETURN_TYPE(/obj/item/cell)
	var/datum/extension/loaded_cell/cell_loaded = get_extension(src, /datum/extension/loaded_cell)
	return cell_loaded?.get_cell()

/**
	Get any radio associated with this atom.

	Used for handle_message_mode or other radio-based logic.
	- `message_mode?`: Used to determine what subset of radio should be returned (ie. intercoms or ear radios)
	- Return: A radio appropriate for `message_mode`.
*/
/atom/proc/get_radio(var/message_mode)
	RETURN_TYPE(/obj/item/radio)
	return

/atom/Topic(href, href_list)
	var/mob/user = usr
	if(href_list["look_at_me"] && istype(user))
		var/turf/T = get_turf(src)
		if(T.CanUseTopic(user, global.view_topic_state) != STATUS_CLOSE)
			user.examine_verb(src)
			return TOPIC_HANDLED
	. = ..()

/// Get the temperature of this atom's heat source
/atom/proc/get_heat()
	. = temperature

/// Check if this atom is a source of fire
/atom/proc/isflamesource()
	. = FALSE

// === Transform setters. ===

/**
	Set the rotation of this atom's transform

	- `new_rotation`: The angle in degrees the transform will be rotated clockwise
*/
/atom/proc/set_rotation(new_rotation)
	icon_rotation = new_rotation
	update_transform()

/**
	Set the scale of this atom's transform.

	- `new_scale_x`: The multiplier to apply to the X axis
	- `new_scale_y`: The multiplier to apply to the Y axis
*/
/atom/proc/set_scale(new_scale_x, new_scale_y)
	if(isnull(new_scale_y))
		new_scale_y = new_scale_x
	if(new_scale_x != 0)
		icon_scale_x = new_scale_x
	if(new_scale_y != 0)
		icon_scale_y = new_scale_y
	update_transform()

/**
	Update this atom's transform from stored values.

	Applies icon_scale and icon_rotation. When transform_animate_time is set,
	the transform is animated over the specified duration. Otherwise, it is
	applied instantly.

	- Return: The transform `/matrix` after updates are applied
*/
/atom/proc/update_transform()
	RETURN_TYPE(/matrix)
	var/matrix/M = matrix()
	M.Scale(icon_scale_x, icon_scale_y)
	M.Turn(icon_rotation)
	if(transform_animate_time)
		animate(src, transform = M, transform_animate_time)
	else
		transform = M
	return transform

/// Get the first loc of the specified `loc_type` from walking up the loc tree of this atom.
/atom/get_recursive_loc_of_type(var/loc_type)
	RETURN_TYPE(/atom)
	var/atom/check_loc = loc
	while(check_loc)
		if(istype(check_loc, loc_type))
			return check_loc
		check_loc = check_loc.loc

/atom/proc/can_climb_from_below(var/mob/climber)
	return FALSE

/atom/proc/singularity_act()
	return 0

/atom/proc/singularity_pull(S, current_size)
	return

/atom/proc/get_overhead_text_x_offset()
	return 0

/atom/proc/get_overhead_text_y_offset()
	return 0

/atom/proc/can_be_injected_by(var/atom/injector)
	return FALSE

//Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area).
//Returns -1 if the atom was not found on container.
/atom/proc/storage_depth(atom/container)
	. = 0
	var/atom/cur_atom = src
	while (cur_atom && !(cur_atom in container.contents))
		if (isarea(cur_atom))
			return -1
		if(cur_atom.loc?.storage)
			.++
		cur_atom = cur_atom.loc
	if (!cur_atom)
		return -1	//inside something with a null loc.

//Like storage depth, but returns the depth to the nearest turf
//Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
/atom/proc/storage_depth_turf()
	. = 0
	var/atom/cur_atom = src
	while (cur_atom && !isturf(cur_atom))
		if (isarea(cur_atom))
			return -1
		if(cur_atom.loc?.storage)
			.++
		cur_atom = cur_atom.loc
	if (!cur_atom)
		. = -1	//inside something with a null loc.

/atom/proc/storage_inserted(atom/movable/thing)
	return

/atom/proc/storage_removed(atom/movable/thing)
	return

/atom/proc/OnSimulatedTurfEntered(turf/T, old_loc)
	set waitfor = FALSE
	return

/atom/proc/get_thermal_mass()
	return 0

/atom/proc/get_thermal_mass_coefficient(delta)
	return 1

/atom/proc/spark_act(obj/effect/sparks/sparks)
	return

/atom/proc/get_affecting_weather()
	return

/atom/proc/is_outside()
	var/turf/turf = get_turf(src)
	return istype(turf) ? turf.is_outside() : OUTSIDE_UNCERTAIN

/atom/proc/can_be_poured_into(atom/source)
	return (reagents?.maximum_volume > 0) && ATOM_IS_OPEN_CONTAINER(src)

/// This is whether it's physically possible to pour from this atom to the target atom, based on context like user intent and src being open, etc.
/// This should not check things like whether there is actually anything in src to pour.
/// It should also not check anything controlled by the target atom, because can_be_poured_into() already exists.
/atom/proc/can_be_poured_from(mob/user, atom/target)
	return (reagents?.maximum_volume > 0) && ATOM_IS_OPEN_CONTAINER(src)

/atom/proc/take_vaporized_reagent(reagent, amount)
	return

/atom/proc/is_watertight()
	return !ATOM_IS_OPEN_CONTAINER(src)

/atom/proc/can_drink_from(mob/user)
	return ATOM_IS_OPEN_CONTAINER(src) && reagents?.total_volume && user.check_has_mouth()

/atom/proc/adjust_required_attack_dexterity(mob/user, required_dexterity)
	if(storage) // TODO: possibly check can_be_inserted() to avoid being able to shoot mirrors as a drake.
		return DEXTERITY_HOLD_ITEM
	return required_dexterity

/atom/proc/immune_to_floor_hazards()
	return !simulated || !has_gravity()
/// The punctuation used for the "That's an X." string.
/atom/proc/get_examine_punctuation()
	// Could theoretically check if reagents in a coating are 'dangerous' or 'suspicious' (blood, acid, etc)
	// in an override, but that'd require setting such a var on a bunch of materials and I'm lazy.
	return blood_color ? "!" : "."

/// The prefix that goes before the atom name on examine.
/atom/proc/get_examine_prefix()
	if(blood_color)
		return FONT_COLORED(blood_color, "stained")
	return null
