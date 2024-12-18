// == Updated intent system ==
// - Use mob.get_intent() to retrieve the entire decl structure.
// - Use mob.check_intent(I_FOO) for 1:1 intent type checking.
// - Use mob.check_intent(I_FLAG_FOO) for 'close enough for government work' flag checking.
// - Use mob.set_intent(I_FOO) to set intent to a type
// - Use mob.set_intent(I_FLAG_FOO) to set intent to whatever available type has the flag.
// - Use mob.cycle_intent(INTENT_HOTKEY_LEFT) or mob.cycle_intent(INTENT_HOTKEY_RIGHT) to step up or down the mob intent list.
// - Override mob.get_available_intents() if you want to change the intents from the default four.

// TODO:
// - dynamic intent options based on equipped weapons, species, bodytype of active hand

/proc/resolve_intent(intent)
	RETURN_TYPE(/decl/intent)
	// Legacy, should not proc.
	if(istext(intent))
		intent = decls_repository.get_decl_by_id_or_var(intent, /decl/intent, "name")
	// Saves constantly calling GET_DECL(I_FOO)
	if(ispath(intent, /decl/intent))
		intent = GET_DECL(intent)
	if(istype(intent, /decl/intent))
		return intent
	return null

/decl/intent
	abstract_type    = /decl/intent
	decl_flags       = DECL_FLAG_MANDATORY_UID
	/// Replacing the old usage of I_HARM etc. in attackby() and such. Refer to /mob/proc/check_intent().
	var/intent_flags = 0
	/// Descriptive string used in status panel.
	var/name
	/// Icon used to draw this intent in the selector.
	var/icon = 'icons/screen/intents.dmi'
	/// State used to update intent selector.
	var/icon_state

/decl/intent/validate()
	. = ..()
	if(!istext(name))
		. += "null or invalid name"
	if(!istext(icon_state))
		. += "null or invalid icon_state"
	if(!icon)
		. += "null icon"
	if(icon && istext(icon_state))
		if(!check_state_in_icon(icon_state, icon))
			. += "missing icon_state '[icon_state]' from icon '[icon]'"
		if(!check_state_in_icon("[icon_state]_off", icon))
			. += "missing icon_state '[icon_state]_off' from icon '[icon]'"

// Basic subtypes.
/decl/intent/harm
	name             = "harm"
	uid              = "intent_harm"
	intent_flags     = I_FLAG_HARM
	icon_state       = "intent_harm"
	sort_order       = 1 // Bottom left of intent selector.

/decl/intent/grab
	name             = "grab"
	uid              = "intent_grab"
	intent_flags     = I_FLAG_GRAB
	icon_state       = "intent_grab"
	sort_order       = 2 // Bottom left of the intent selector.

/decl/intent/help
	name             = "help"
	uid              = "intent_help"
	intent_flags     = I_FLAG_HELP
	icon_state       = "intent_help"
	sort_order       = 3 // Top left of the intent selector.

/decl/intent/disarm
	name             = "disarm"
	uid              = "intent_disarm"
	intent_flags     = I_FLAG_DISARM
	icon_state       = "intent_disarm"
	sort_order       = 4 // Top right of the intent selector.

// Used by nymphs.
/decl/intent/harm/binary
	icon             = 'icons/screen/intents_wide.dmi'
	uid              = "intent_harm_simple"
	intent_flags     = (I_FLAG_HARM|I_FLAG_DISARM)

/decl/intent/help/binary
	icon             = 'icons/screen/intents_wide.dmi'
	uid              = "intent_help_simple"
	intent_flags     = (I_FLAG_HARM|I_FLAG_GRAB)

/mob
	/// Decl for current 'intent' of mob; hurt, harm, etc. Initialized by get_intent().
	var/decl/intent/_a_intent

/mob/proc/check_intent(checking_intent)
	var/decl/intent/intent = get_intent() // Ensures intent has been initalised.
	. = (intent == checking_intent)
	if(!.)
		if(isnum(checking_intent))
			return (intent.intent_flags & checking_intent)
		else if(istext(checking_intent) || ispath(checking_intent, /decl/intent))
			return (intent == resolve_intent(checking_intent))

/mob/proc/set_intent(decl/intent/new_intent)

	if(!isnum(new_intent))
		new_intent = resolve_intent(new_intent)
	else // Retrieve intent decl based on flag.
		for(var/decl/intent/intent as anything in get_available_intents())
			if(intent.intent_flags & new_intent)
				new_intent = intent
				break

	if(istype(new_intent) && get_intent() != new_intent)
		_a_intent = new_intent
		if(istype(hud_used) && hud_used.action_intent)
			hud_used.action_intent.update_icon()
		return TRUE

	return FALSE

/mob/proc/get_intent()
	RETURN_TYPE(/decl/intent)
	if(!_a_intent)
		_a_intent = get_default_intent()
	return _a_intent

/mob/proc/get_default_intent()
	return GET_DECL(/decl/intent/help)

/mob/proc/get_available_intents()
	var/static/list/available_intents
	if(!available_intents)
		available_intents = list(
			GET_DECL(/decl/intent/help),
			GET_DECL(/decl/intent/disarm),
			GET_DECL(/decl/intent/grab),
			GET_DECL(/decl/intent/harm)
		)
		available_intents = sortTim(available_intents, /proc/cmp_decl_sort_value_asc)
	return available_intents

/mob/proc/cycle_intent(input)
	set name = "a-intent"
	set hidden = TRUE
	switch(input)
		if(INTENT_HOTKEY_RIGHT)
			return set_intent(next_in_list(get_intent(), get_available_intents()))
		if(INTENT_HOTKEY_LEFT)
			return set_intent(previous_in_list(get_intent(), get_available_intents()))
		else // Fallback, should just use set_intent() directly
			return set_intent(input)
