#define AB_ITEM 1
#define AB_SPELL 2
#define AB_INNATE 3
#define AB_GENERIC 4
#define AB_ITEM_USE_ICON 5

#define AB_CHECK_RESTRAINED 1
#define AB_CHECK_STUNNED 2
#define AB_CHECK_LYING 4
#define AB_CHECK_ALIVE 8
#define AB_CHECK_INSIDE 16


/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/action_type = AB_ITEM
	var/procname = null
	var/atom/movable/target = null
	var/check_flags = 0
	var/active = FALSE
	var/obj/screen/action_button/button = null
	var/button_icon = 'icons/obj/action_buttons/actions.dmi'
	var/button_icon_state = "default"
	/// The icon to use for the background icon state. Defaults to button_icon if unset.
	var/background_icon = 'icons/obj/action_buttons/actions.dmi'
	var/background_icon_state = "bg_default"
	var/mob/living/owner

/datum/action/New(var/Target)
	target = Target
	background_icon ||= button_icon

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	QDEL_NULL(button)
	if(target)
		var/obj/item/target_item = target
		if(istype(target_item) && target_item.action == src)
			target_item.action = null
		target = null
	return ..()

/datum/action/proc/SetTarget(var/atom/Target)
	target = Target

/datum/action/proc/Grant(mob/living/T)
	if(owner)
		if(owner == T)
			return
		Remove(owner)
	owner = T
	owner.actions.Add(src)
	owner.update_action_buttons()
	return

/datum/action/proc/Remove(mob/living/T)
	if(button)
		if(T.client)
			T.client.screen -= button
		qdel(button)
		button = null
	T.actions.Remove(src)
	T.update_action_buttons()
	owner = null

/datum/action/proc/Trigger()
	if(!Checks())
		return
	switch(action_type)
		if(AB_ITEM, AB_ITEM_USE_ICON)
			if(target)
				var/obj/item/item = target
				item.ui_action_click()
		//if(AB_SPELL)
		//	if(target)
		//		var/obj/effect/proc_holder/spell = target
		//		spell.Click()
		if(AB_INNATE)
			if(!active)
				Activate()
			else
				Deactivate()
		if(AB_GENERIC)
			if(target && procname)
				call(target,procname)(owner)
	return

/datum/action/proc/Activate()
	return

/datum/action/proc/Deactivate()
	return

/datum/action/proc/CheckRemoval(mob/living/user) // 1 if action is no longer valid for this mob and should be removed
	return 0

/datum/action/proc/IsAvailable()
	return Checks()

/datum/action/proc/Checks()// returns 1 if all checks pass
	if(!owner)
		return 0
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return 0
	if(check_flags & AB_CHECK_STUNNED)
		if(HAS_STATUS(owner, STAT_STUN))
			return 0
	if(check_flags & AB_CHECK_LYING)
		if(owner.current_posture.prone)
			return 0
	if(check_flags & AB_CHECK_ALIVE)
		if(owner.stat)
			return 0
	if(check_flags & AB_CHECK_INSIDE)
		if(!(target in owner))
			return 0
	return 1

/datum/action/proc/UpdateName()
	return name

/datum/action/proc/UpdateDesc()
	return desc

//This is the proc used to update all the action buttons. Properly defined in /mob/living/
/mob/proc/update_action_buttons()
	return

#define AB_WEST_OFFSET 4
#define AB_NORTH_OFFSET 26
#define AB_MAX_COLUMNS 10

/datum/hud/proc/ButtonNumberToScreenCoords(var/number) // TODO : Make this zero-indexed for readabilty
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1
	var/coord_col = "+[col-1]"
	var/coord_col_offset = AB_WEST_OFFSET+2*col
	var/coord_row = "[-1 - row]"
	var/coord_row_offset = AB_NORTH_OFFSET
	return "LEFT[coord_col]:[coord_col_offset],TOP[coord_row]:[coord_row_offset]"

//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_ALIVE|AB_CHECK_INSIDE

/datum/action/item_action/CheckRemoval(mob/living/user)
	return !(target in user)

/datum/action/item_action/hands_free
	check_flags = AB_CHECK_ALIVE|AB_CHECK_INSIDE

/datum/action/item_action/organ
	action_type = AB_ITEM_USE_ICON
	button_icon = 'icons/obj/action_buttons/organs.dmi'

/datum/action/item_action/organ/SetTarget(var/atom/Target)
	. = ..()
	var/obj/item/organ/O = target
	if(istype(O))
		O.refresh_action_button()

/datum/action/item_action/organ/augment
	button_icon = 'icons/obj/augment.dmi'

#undef AB_WEST_OFFSET
#undef AB_NORTH_OFFSET
#undef AB_MAX_COLUMNS