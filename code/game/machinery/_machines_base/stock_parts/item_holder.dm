/**
 * Base class for stock parts that allow an item to be inserted while the maintenance panel is closed.
 */
/obj/item/stock_parts/item_holder
	name       = null
	desc       = null
	icon       = 'icons/obj/items/stock_parts/modular_components.dmi'
	var/decl/interaction_handler/eject_handler // The interaction handler type used for alt-interactions.
	var/datum/callback/on_insert_target //Callback to call when an item is inserted
	var/datum/callback/on_eject_target  //Callback to call when an item is ejected
	/// The verb used when a player inserts an item.
	/// e.g. You [insert/place/attach] the cup in the cupholder.
	var/place_verb = "insert"

/obj/item/stock_parts/item_holder/Destroy()
	unregister_on_insert()
	unregister_on_eject()
	. = ..()

/obj/item/stock_parts/item_holder/attackby(obj/item/used_item, mob/user)
	if(is_accepted_type(used_item))
		insert_item(used_item, user)
		return TRUE
	. = ..()


/obj/item/stock_parts/item_holder/attack_self(mob/user)
	if(is_item_inserted())
		eject_item(user)
		return TRUE
	. = ..()

///Returns whether there is an item contained in the component.
/obj/item/stock_parts/item_holder/proc/is_item_inserted()
	return FALSE

///Returns whether the object can be handled by the component.
/obj/item/stock_parts/item_holder/proc/is_accepted_type(var/obj/O)
	return FALSE

///Returns the inserted object if there is one, or null.
/obj/item/stock_parts/item_holder/proc/get_inserted()
	return

/obj/item/stock_parts/item_holder/on_machine_examined(mob/user)
	. = ..()
	if(is_item_inserted())
		LAZYADD(., SPAN_INFO("It has \a [get_inserted()] in \the [src]."))

///Handle putting the object in the component's contents. Doesn't trigger any callbacks, or messages.
/obj/item/stock_parts/item_holder/proc/set_inserted(var/obj/O)
	return

///Returns a string to describe the kind of item that can be inserted. For instance, "disk" in the case of a data disk.
/obj/item/stock_parts/item_holder/proc/get_description_insertable()
	return

///Insert the given object into the component, trigger callbacks, and transfer the item from the user if there is one.
/obj/item/stock_parts/item_holder/proc/insert_item(var/obj/O, var/mob/user)
	if(is_item_inserted())
		if(user)
			to_chat(user, SPAN_WARNING("There is already \a [get_inserted()] in \the [src]."))
		return FALSE

	if(user)
		if(user.try_unequip(O, src))
			to_chat(user, SPAN_NOTICE("You [place_verb] \the [O] into \the [src]."))
		else
			return FALSE
	else
		O.forceMove(src)

	set_inserted(O)

	if(on_insert_target)
		on_insert_target.InvokeAsync(O, user)
	return TRUE

///Eject the contained item.
/obj/item/stock_parts/item_holder/proc/eject_item(var/mob/user)
	if(!is_item_inserted())
		if(user)
			to_chat(user, SPAN_WARNING("There's no [get_description_insertable()] in \the [src]."))
		return

	var/obj/O = get_inserted()
	if(user && loc.Adjacent(user)) // Check adjacency in case this is called via UI stuff from a distance.
		user.put_in_hands(O)
		to_chat(user, SPAN_NOTICE("You remove \the [O] from \the [src]."))
	else
		O.forceMove(get_turf(src))

	. = O

	if(on_eject_target)
		on_eject_target.InvokeAsync(O, user)
	set_inserted(null)

///////////////////////////////////////////
// Callback Handling
///////////////////////////////////////////

/obj/item/stock_parts/item_holder/on_install(obj/machinery/machine)
	unregister_on_insert()
	unregister_on_eject()
	. = ..()

/obj/item/stock_parts/item_holder/on_uninstall(obj/machinery/machine, temporary)
	unregister_on_insert()
	unregister_on_eject()
	. = ..()

/obj/item/stock_parts/item_holder/proc/register_on_insert(var/datum/callback/cback)
	on_insert_target = cback

/obj/item/stock_parts/item_holder/proc/register_on_eject(var/datum/callback/cback)
	on_eject_target = cback

/obj/item/stock_parts/item_holder/proc/unregister_on_insert()
	QDEL_NULL(on_insert_target)

/obj/item/stock_parts/item_holder/proc/unregister_on_eject()
	QDEL_NULL(on_eject_target)

// Alt interaction handling
/decl/interaction_handler/remove_held_item
	abstract_type = /decl/interaction_handler/remove_held_item
	expected_target_type = /obj/machinery
	name = "Eject Item"
	icon = 'icons/screen/radial.dmi'
	icon_state = "radial_eject"
	examine_desc = "eject an item"
	var/obj/item/stock_parts/item_holder/expected_component_type

/decl/interaction_handler/remove_held_item/validate()
	. = ..()
	if(!ispath(expected_component_type))
		. += "Expected component type was [isnull(expected_component_type) ? "NULL" : expected_component_type], expected /obj/item/stock_parts/item_holder subtype"

/decl/interaction_handler/remove_held_item/is_possible(atom/target, mob/user, obj/item/prop)
	. = ..()
	if(.)
		var/obj/machinery/target_machine = target
		// Check all components, not just the first one. Maybe we have multiple!
		for(var/obj/item/stock_parts/item_holder/holder in target_machine.get_all_components_of_type(expected_component_type))
			if(holder.is_item_inserted())
				return TRUE

/decl/interaction_handler/remove_held_item/invoked(atom/target, mob/user, obj/item/prop)
	var/obj/machinery/target_machine = target
	// Check all components, not just the first one. Maybe we have multiple!
	for(var/obj/item/stock_parts/item_holder/holder in target_machine.get_all_components_of_type(expected_component_type))
		if(holder.is_item_inserted())
			holder.eject_item(user)
			return

/obj/item/stock_parts/item_holder/get_machine_alt_interactions(mob/user)
	. = ..()
	if(ispath(eject_handler))
		LAZYADD(., eject_handler)
