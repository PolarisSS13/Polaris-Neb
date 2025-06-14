/* Stack type objects!
 * Contains:
 * 		Stacks
 * 		Recipe datum
 * 		Recipe list datum
 */

/*
 * Stacks
 */

/obj/item/stack
	gender = PLURAL
	origin_tech = @'{"materials":1}'
	max_health = 32 //Stacks should take damage even if no materials
	/// A copy of initial matter list when this atom initialized. Stack matter should always assume a single tile.
	var/list/matter_per_piece
	var/name_modifier
	var/singular_name
	var/plural_name
	/// If unset, picks a/an based off of if the first letter is a vowel or not.
	var/indefinite_article
	var/base_state
	var/plural_icon_state
	var/max_icon_state
	var/amount = 1
	var/matter_multiplier = 1
	var/max_amount
	var/stack_merge_type  //determines whether different stack types can merge
	var/build_type //used when directly applied to a turf
	var/uses_charge
	var/list/charge_costs
	var/list/datum/matter_synth/synths
	/// Set this to a specific type to restrict the recipes generated by this stack.
	var/crafting_stack_type = /obj/item/stack
	var/craft_verb
	var/craft_verbing

/obj/item/stack/Initialize(mapload, amount, material)

	if(ispath(amount, /decl/material))
		PRINT_STACK_TRACE("Stack initialized with material ([amount]) instead of amount.")
		material = amount
	if (isnum(amount) && amount >= 1)
		src.amount = amount
	. = ..(mapload, material)
	if(!stack_merge_type)
		stack_merge_type = type
	if(!singular_name)
		singular_name = "sheet"
	if(!plural_name)
		plural_name = text_make_plural(singular_name)
	update_name()

/obj/item/stack/update_name()
	if(amount == 1)
		gender = NEUTER
		SetName(singular_name)
	else
		gender = PLURAL
		SetName(plural_name)

/obj/item/stack/Destroy()
	if (src && usr && usr.machine == src)
		close_browser(usr, "window=stack")
	if(length(synths))
		synths.Cut()
	return ..()

/obj/item/stack/proc/delete_if_empty()
	if (uses_charge)
		return FALSE
	var/real_amount = get_amount()
	if (real_amount <= 0)
		on_used_last()
		return TRUE
	return FALSE

/obj/item/stack/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(distance <= 1)
		if(uses_charge)
			. += "There is enough charge for [get_amount()]."
		else
			. += "There [src.amount == 1 ? "is" : "are"] [src.amount] [src.singular_name]\s in the stack."

/obj/item/stack/on_update_icon()
	. = ..()
	if(!isturf(loc))
		var/image/I = image(null)
		I.plane = HUD_PLANE
		I.layer = HUD_ABOVE_ITEM_LAYER
		I.appearance_flags |= (RESET_COLOR|RESET_TRANSFORM)
		I.maptext_x = 2
		I.maptext_y = 2
		I.maptext = STYLE_SMALLFONTS_OUTLINE(get_amount(), 6, (color || COLOR_WHITE), COLOR_BLACK)
		add_overlay(I)
	else
		compile_overlays() // prevent maptext from showing when we're dropped

/obj/item/stack/Move()
	var/on_turf = isturf(loc)
	. = ..()
	if(. && on_turf != isturf(loc))
		update_icon()

/obj/item/stack/forceMove()
	var/on_turf = isturf(loc)
	. = ..()
	if(. && on_turf != isturf(loc))
		update_icon()

/obj/item/stack/attack_self(mob/user)
	list_recipes(user)

/obj/item/stack/get_matter_amount_modifier()
	. = amount * matter_multiplier

/obj/item/stack/proc/get_reinforced_material()
	return null

// TODO: add some kind of tracking for the last viewed list so the user can go back up one level for nested lists
/obj/item/stack/proc/list_recipes(mob/user, list/recipes)

	if(!user?.client)
		return

	if(get_amount() <= 0)
		close_browser(user, "window=stack_crafting")
		return

	if(!recipes)
		recipes = get_stack_recipes(get_material(), get_reinforced_material(), crafting_stack_type, user?.get_active_held_item()?.get_best_tool_archetype())

	var/list/dat = list()

	var/popup_title
	var/datum/stack_recipe_list/recipe_list = recipes
	if (istype(recipe_list))
		popup_title = "Crafting [recipe_list.name] with \the [src]"
		dat += "<p><a href='byond://?src=\ref[src];back=1'>Back</a></p>"
		recipes = recipe_list.recipes
	else if(islist(recipes) && length(recipes))
		popup_title = "Crafting with \the [src]"
	else
		return

	dat += "<p>[capitalize(plural_name)] left: [get_amount()]</p>"
	dat += "<table border = '1px' padding = '1px' style = 'margin-left: auto; margin-right: auto;'>"
	dat += "<tr><th width = '150px'>Product</th><th width = '75px'>Cost</th><th width = '75px'>Time</th><th width = '200px'>Required skill</th><th width = '200px'>Amount to craft</tr>"
	var/list/recipe_strings = list()
	for(var/thing in recipes)
		if(istype(thing, /decl/stack_recipe))
			var/decl/stack_recipe/recipe = thing
			recipe_strings[recipe.name] = recipe.get_list_display(user, src, recipe_list)
		else if(istype(thing, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/sub_recipe_list = thing
			recipe_strings[sub_recipe_list.name] = sub_recipe_list.get_list_display(user, src)
	for(var/recipe_name in sortTim(recipe_strings.Copy(), /proc/cmp_text_asc))
		dat += recipe_strings[recipe_name]
	dat += "</table>"

	var/datum/browser/popup = new(user, "stack_crafting", popup_title, 800, 800)
	popup.set_content(JOINTEXT(dat))
	popup.open()


/obj/item/stack/proc/produce_recipe(decl/stack_recipe/recipe, var/producing, var/expending, mob/user, paint_color)

	if(producing <= 0 || expending <= 0 || expending > get_amount())
		return

	if(expending > recipe.get_required_stack_amount(src, product_amount = producing))
		PRINT_STACK_TRACE("Possible HREF hacking attempt, recipe amount consumed and produced doesn't match!")
		return

	var/decl/material/mat       = get_material()
	var/decl/material/reinf_mat = get_reinforced_material()
	if (!can_use(expending))
		to_chat(user, SPAN_WARNING("You haven't got enough [plural_name] to [recipe.get_craft_verb(src)] [recipe.get_display_name(producing, mat, reinf_mat)]!"))
		return
	if(!recipe.can_make(user))
		return
	var/used_skill = recipe.get_skill(mat, reinf_mat)
	var/used_difficulty = recipe.get_skill_difficulty(mat, reinf_mat)
	var/used_time = recipe.get_adjusted_time(mat, reinf_mat)
	if (used_time)
		to_chat(user, SPAN_NOTICE("You set about [recipe.get_craft_verbing(src)] [recipe.get_display_name(producing, mat, reinf_mat)]..."))
		if (!user.do_skilled(used_time, used_skill))
			return

	if(!use(expending))
		return

	if(user.skill_fail_prob(used_skill, 90, used_difficulty))
		to_chat(user, SPAN_WARNING("You waste some [name] and fail to [recipe.get_craft_verb(src)] [recipe.get_display_name(producing, mat, reinf_mat)]!"))
		return

	to_chat(user, SPAN_NOTICE("You [recipe.get_craft_verb(src)] [recipe.get_display_name(producing, mat, reinf_mat)]!"))
	var/list/atom/results = recipe.spawn_result(user, user.loc, producing, mat, reinf_mat, paint_color, crafting_stack_type, expending)
	var/was_put_in_hand = FALSE
	for(var/atom/result in results)
		if(QDELETED(result))
			continue
		result.add_fingerprint(user)
		if(isitem(result) && !was_put_in_hand)
			if(user.put_in_hands(result))
				was_put_in_hand = TRUE

/obj/item/stack/OnTopic(mob/user, list/href_list)
	. = ..()

	if(. || !istype(user) || QDELETED(user) || user.incapacitated() || !((src in user.get_held_items()) || Adjacent(user)))
		return TOPIC_NOACTION

	if(href_list["back"])
		var/datum/stack_recipe_list/previous_list = locate(href_list["back"])
		if(istype(previous_list))
			list_recipes(user, previous_list)
		else
			list_recipes(user)
		return TOPIC_HANDLED

	if(href_list["sublist"])

		var/datum/stack_recipe_list/recipe_list = locate(href_list["sublist"])
		if(istype(recipe_list))
			var/list/recipes = get_stack_recipes(get_material(), get_reinforced_material(), crafting_stack_type, user?.get_active_held_item()?.get_best_tool_archetype())
			if(recipe_list in recipes)
				list_recipes(user, recipe_list)
				return TOPIC_HANDLED
		return TOPIC_NOACTION

	if(href_list["make"])

		// Retrieve our recipe decl.
		var/decl/stack_recipe/recipe = locate(href_list["make"])
		if(!istype(recipe))
			return TOPIC_NOACTION

		// Check that the recipe is still available to us.
		var/list/recipes = get_stack_recipes(get_material(), get_reinforced_material(), crafting_stack_type, user?.get_active_held_item()?.get_best_tool_archetype())
		if(!(recipe in recipes))
			var/found_recipe = FALSE
			for(var/datum/stack_recipe_list/recipe_list in recipes)
				if(recipe in recipe_list.recipes)
					found_recipe = TRUE
					break
			if(!found_recipe)
				return TOPIC_NOACTION

		// Validate the target amount and create the product.
		var/producing = text2num(href_list["producing"])
		var/expending = text2num(href_list["expending"])
		var/datum/stack_recipe_list/returning = locate(href_list["returning"])
		if(producing > 0 && expending > 0 && expending <= recipe.get_required_stack_amount(src, product_amount = producing))
			produce_recipe(recipe, producing, expending, user, paint_color)
			list_recipes(user, returning)
			return TOPIC_HANDLED // Don't attempt to refresh, list_recipes should handle that already...

	return TOPIC_NOACTION

/**
 * Return 1 if an immediate subsequent call to use() would succeed.
 * Ensures that code dealing with stacks uses the same logic.
*/
/obj/item/stack/proc/can_use(var/used)
	return get_amount() >= used

/obj/item/stack/create_matter()

	// Append our material, if set; this would normally be done in the parent call.
	if(istype(material))
		LAZYSET(matter, material.type, MATTER_AMOUNT_PRIMARY) // No matter_multiplier as this is applied below.

	// We do this here rather than a parent call because the base application would multiply by our stack amount.
	// We want to keep a base init matter list so that we know how much matter is in one unit of the stack.
	if(LAZYLEN(matter))
		matter_per_piece = list()
		for(var/mat in matter)
			matter_per_piece[mat] = round(matter[mat] * matter_multiplier)

	// No parent call because we're already tracking our materials and we're going to rebuild the matter list in
	// update_matter() immediately anyway.
	update_matter()

// Nuke and rebuild matter from our matter_per_piece list to keep all our values in line.
/obj/item/stack/proc/update_matter()
	if(length(matter_per_piece))
		matter = list()
		for(var/mat in matter_per_piece)
			matter[mat] = (matter_per_piece[mat] * amount)
	else
		matter_per_piece = null
		matter = null

/obj/item/stack/proc/use(var/used)
	if (!can_use(used))
		return FALSE
	if(!uses_charge)
		amount -= used
		if(!delete_if_empty())
			update_icon()
			update_matter()
		return TRUE
	if(get_amount() < used)
		return FALSE
	for(var/i = 1 to charge_costs.len)
		var/datum/matter_synth/S = synths[i]
		S.use_charge(charge_costs[i] * used) // Doesn't need to be deleted
	update_name()
	update_icon()
	return TRUE

/obj/item/stack/proc/on_used_last()
	qdel(src) //should be safe to qdel immediately since if someone is still using this stack it will persist for a little while longer

/obj/item/stack/proc/add(var/extra)
	if(!uses_charge)
		if(amount + extra > get_max_amount())
			return FALSE
		else
			amount += extra
			update_icon()
			update_matter()
	else if(!synths || synths.len < uses_charge)
		return FALSE
	else
		for(var/i = 1 to uses_charge)
			var/datum/matter_synth/S = synths[i]
			S.add_charge(charge_costs[i] * extra)
	return TRUE

/*
	The transfer and split procs work differently than use() and add().
	Whereas those procs take no action if the desired amount cannot be added or removed these procs will try to transfer whatever they can.
	They also remove an equal amount from the source stack.
*/

//attempts to transfer amount to S, and returns the amount actually transferred
/obj/item/stack/proc/transfer_to(obj/item/stack/S, var/tamount=null)
	if (!get_amount() || !istype(S))
		return 0
	if (stack_merge_type != S.stack_merge_type)
		return 0
	if (isnull(tamount))
		tamount = src.get_amount()

	var/transfer = max(min(tamount, src.get_amount(), (S.get_max_amount() - S.get_amount())), 0)

	var/orig_amount = src.get_amount()
	if (transfer && src.use(transfer))
		S.add(transfer)
		S.drying_wetness = max(drying_wetness, S.drying_wetness)
		if(!S.dried_type && dried_type)
			S.dried_type = dried_type
		if(!QDELETED(src))
			drying_wetness = S.drying_wetness
		if (prob(transfer/orig_amount * 100))
			transfer_fingerprints_to(S)
		return transfer
	return 0

//creates a new stack with the specified amount
/obj/item/stack/proc/split(var/tamount, var/force=FALSE)
	if (!can_split() || !amount || (uses_charge && !force))
		return null

	var/transfer = max(min(tamount, amount, initial(max_amount)), 0)

	var/orig_amount = src.amount
	if (transfer && src.use(transfer))
		var/obj/item/stack/newstack = new src.type(loc, transfer, material?.type)
		newstack.dropInto(loc) // avoid being placed inside mobs
		newstack.copy_from(src)
		if (prob(transfer/orig_amount * 100))
			transfer_fingerprints_to(newstack)
		return newstack
	return null

/obj/item/stack/proc/copy_from(var/obj/item/stack/other)
	other.set_color(paint_color)
	dried_type = other.dried_type
	drying_wetness = other.drying_wetness

/obj/item/stack/proc/get_amount()
	if(uses_charge)
		if(!synths || synths.len < uses_charge)
			return 0
		var/datum/matter_synth/S = synths[1]
		. = round(S.get_charge() / charge_costs[1])
		if(charge_costs.len > 1)
			for(var/i = 2 to charge_costs.len)
				S = synths[i]
				. = min(., round(S.get_charge() / charge_costs[i]))
		return
	return amount

/obj/item/stack/proc/get_max_amount()
	if(uses_charge)
		if(!synths || synths.len < uses_charge)
			return 0
		var/datum/matter_synth/S = synths[1]
		. = round(S.max_energy / charge_costs[1])
		if(uses_charge > 1)
			for(var/i = 2 to uses_charge)
				S = synths[i]
				. = min(., round(S.max_energy / charge_costs[i]))
		return
	return max_amount

/obj/item/stack/proc/add_to_stacks(mob/user, check_hands)
	var/list/stacks = list()
	if(check_hands && user)
		for(var/obj/item/stack/item in user.get_held_items())
			stacks |= item
	for (var/obj/item/stack/item in user?.loc)
		stacks |= item
	for (var/obj/item/stack/item in loc)
		stacks |= item
	for (var/obj/item/stack/item in stacks)
		if(item == src || !(can_merge_stacks(item) || item.can_merge_stacks(src)))
			continue
		var/transfer = transfer_to(item)
		if(user && transfer)
			to_chat(user, SPAN_NOTICE("You add [item.get_string_for_amount(transfer)] to the stack. It now contains [item.amount] [item.singular_name]\s."))
		if(!amount)
			break
	return !QDELETED(src)

/obj/item/stack/get_storage_cost()	//Scales storage cost to stack size
	. = ..()
	if (amount < max_amount)
		. = ceil(. * amount / max_amount)

/obj/item/stack/get_mass() // Scales mass to stack size
	. = ..()
	if (amount < max_amount)
		. *= amount / max_amount // Don't round, this can be non-integer

/obj/item/stack/attack_hand(mob/user)
	if(!user.is_holding_offhand(src) || !can_split())
		return ..()

	var/N = input(user, "How many stacks of [src] would you like to split off?", "Split stacks", 1) as num|null
	if(!N)
		return TRUE

	var/obj/item/stack/F = src.split(N)
	if(F)
		user.put_in_hands(F)
		src.add_fingerprint(user)
		F.add_fingerprint(user)
		spawn(0)
			if (src && usr.machine==src)
				src.interact(usr)
	return TRUE

/obj/item/stack/attackby(obj/item/used_item, mob/user)
	if (istype(used_item, /obj/item/stack) && can_merge_stacks(used_item))
		var/obj/item/stack/S = used_item
		. = src.transfer_to(S)

		spawn(0) //give the stacks a chance to delete themselves if necessary
			if (S && usr.machine==S)
				S.interact(usr)
			if (src && usr.machine==src)
				src.interact(usr)
		return

	return ..()

/**Whether a stack has the capability to be split. */
/obj/item/stack/proc/can_split()
	return !(uses_charge && !is_robot_module(src))

/**Whether a stack type has the capability to be merged. */
/obj/item/stack/proc/can_merge_stacks(var/obj/item/stack/other)
	return !(uses_charge && !is_robot_module(src)) && (!istype(other) || other.paint_color == paint_color)

/// Returns the string describing an amount of the stack, i.e. "an ingot" vs "a flag"
/obj/item/stack/proc/get_string_for_amount(amount)
	if(amount == 1)
		if(gender == PLURAL)
			return "some [singular_name]"
		return indefinite_article ? "[indefinite_article] [singular_name]" : ADD_ARTICLE(singular_name)
	return "[amount] [plural_name]"

/obj/item/stack/ProcessAtomTemperature()
	. = ..()
	if(QDELETED(src))
		return
	matter_per_piece = list()
	for(var/mat in matter)
		matter_per_piece[mat] = round(matter[mat] / amount)
	update_icon()

// TODO.
/obj/item/stack/update_attack_force()
	. = ..()
	//_throwforce = round(0.25*material.get_edge_damage())
	//_force = round(0.5*material.get_blunt_damage())
