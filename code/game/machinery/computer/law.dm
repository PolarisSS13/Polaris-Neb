/obj/machinery/computer/upload
	name = "unused upload console"
	icon_keyboard = "rd_key"
	icon_screen = "command"
	var/mob/living/silicon/current

/obj/machinery/computer/upload/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, /obj/item/aiModule))
		var/obj/item/aiModule/M = used_item
		M.install(src, user)
		return TRUE
	return ..()

/obj/machinery/computer/upload/ai
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."

/obj/machinery/computer/upload/ai/interface_interact(mob/user)
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE
	current = select_active_ai(user, get_z(src))
	if (!current)
		to_chat(user, "No active AIs detected.")
	else
		to_chat(user, "[current.name] selected for law changes.")
	return TRUE

/obj/machinery/computer/upload/robot
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."

/obj/machinery/computer/upload/robot/interface_interact(mob/user)
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE
	current = freeborg(get_z(src))
	if (!current)
		to_chat(user, "No free cyborgs detected.")
	else
		to_chat(user, "[current.name] selected for law changes.")
	return TRUE
