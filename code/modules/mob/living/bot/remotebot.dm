/mob/living/bot/remotebot
	name = "Remote-Bot"
	desc = "A remote controlled robot used by lazy people to switch channels and get pizza."
	icon = 'icons/mob/bot/fetchbot.dmi'
	icon_state = "fetchbot1"
	max_health = 15

	var/working = 0
	var/speed = 10 //lower = better
	var/obj/item/holding = null
	var/obj/item/bot_controller/controller = null

/mob/living/bot/remotebot/get_movement_delay(var/travel_dir)
	var/tally = ..()
	tally += speed
	if(holding)
		tally += (2 * holding.w_class)
	return tally

/mob/living/bot/remotebot/get_other_examine_strings(mob/user, distance, infix, suffix, hideflags, decl/pronouns/pronouns)
	. = ..()
	if(holding)
		. += SPAN_NOTICE("It is holding \the [html_icon(holding)] [holding].")

/mob/living/bot/remotebot/gib(do_gibs = TRUE)
	var/turf/my_turf = get_turf(src)
	. = ..()
	if(. && my_turf)
		if(controller)
			controller.bot = null
			controller = null
		for(var/i in 1 to rand(3,5))
			var/obj/item/stack/material/cardstock/mapped/cardboard/C = new(my_turf)
			if(prob(50))
				C.forceMove(get_step(src, pick(global.alldirs)))

/mob/living/bot/remotebot/attackby(var/obj/item/used_item, var/mob/user)
	if(istype(used_item, /obj/item/bot_controller) && !controller)
		user.visible_message("\The [user] waves \the [used_item] over \the [src].")
		to_chat(user, "<span class='notice'>You link \the [src] to \the [used_item].</span>")
		var/obj/item/bot_controller/B = used_item
		B.bot = src
		controller = B
	return ..()

/mob/living/bot/remotebot/on_update_icon()
	..()
	icon_state = "fetchbot[on]"

/mob/living/bot/remotebot/Destroy()
	if(holding)
		holding.forceMove(loc)
		holding = null
	return ..()

/mob/living/bot/remotebot/proc/pickup(var/obj/item/used_item)
	if(holding || get_dist(src,used_item) > 1)
		return
	src.visible_message("<b>\The [src]</b> picks up \the [used_item].")
	flick("fetchbot-c", src)
	working = 1
	sleep(10)
	working = 0
	used_item.forceMove(src)
	holding = used_item

/mob/living/bot/remotebot/proc/drop()
	if(working || !holding)
		return
	holding.forceMove(loc)
	holding = null

/mob/living/bot/remotebot/proc/hit(var/atom/movable/a)
	src.visible_message("<b>\The [src]</b> taps \the [a] with its claw.")
	flick("fetchbot-c", src)
	working = 1
	sleep(10)
	working = 0

/mob/living/bot/remotebot/proc/command(var/atom/a)
	if(working || stat || !on || a == src) //can't touch itself
		return
	if(isturf(a) || get_dist(src,a) > 1)
		start_automove(a)
	else if(istype(a, /obj/item))
		pickup(a)
	else
		hit(a)

/obj/item/bot_controller
	name = "remote control"
	desc = "Used to control something remotely. Even has a tiny screen!"
	icon = 'icons/obj/items/remote_control.dmi'
	icon_state = ICON_STATE_WORLD
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_LOWER_BODY
	material = /decl/material/solid/organic/plastic
	matter = list(
		/decl/material/solid/silicon      = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/metal/copper = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/metal/steel  = MATTER_AMOUNT_REINFORCEMENT,
	)
	var/mob/living/bot/remotebot/bot

/obj/item/bot_controller/attack_self(var/mob/user)
	src.interact(user)

/obj/item/bot_controller/interact(var/mob/user)
	user.set_machine(src)
	if(!(src in user) || !bot)
		close_browser(user, "window=bot_controller")
		return
	var/dat = "<center><TT><b>Remote Control: [bot.name]</b></TT><br>"
	dat += "Currently Holding: [bot.holding ? bot.holding.name : "Nothing"]<br><br>"
	var/is_looking = (user.client.eye == bot)
	dat += "<a href='byond://?src=\ref[src];look=[is_looking];'>[is_looking ? "Stop" : "Start"] Looking</a><br>"
	dat += "<a href='byond://?src=\ref[src];drop=1;'>Drop Item</a><br></center>"

	show_browser(user, dat, "window=bot_controller")
	onclose(user, "botcontroller")

/obj/item/bot_controller/check_eye()
	return 0

/obj/item/bot_controller/Topic(href, href_list)
	..()
	if(!bot)
		return

	if(href_list["drop"])
		bot.drop()
	if(href_list["look"])
		if(href_list["look"] == "1")
			usr.reset_view(usr)
			usr.visible_message("\The [usr] looks up from \the [src]'s screen.")
		else
			usr.reset_view(bot)
			usr.visible_message("\The [usr] looks intently on \the [src]'s screen.")

	src.interact(usr)


/obj/item/bot_controller/dropped(var/mob/living/user)
	if(user.client.eye == bot)
		user.client.eye = user
	return ..()


/obj/item/bot_controller/afterattack(atom/A, mob/living/user)
	if(bot)
		bot.command(A)

/obj/item/bot_controller/Destroy()
	if(bot)
		bot.controller = null
		bot = null
	return ..()

/obj/item/bot_kit
	name = "Remote-Bot Kit"
	desc = "The cover says 'control your own cardboard nuclear powered robot. Comes with real plutonium!"
	icon = 'icons/obj/items/bot_kit.dmi'
	icon_state = "remotebot"
	obj_flags = OBJ_FLAG_HOLLOW
	material = /decl/material/solid/organic/cardboard

/obj/item/bot_kit/attack_self(var/mob/user)
	to_chat(user, "You quickly dismantle the box and retrieve the controller and the remote bot itself.")
	var/turf/T = get_turf(src.loc)
	new /mob/living/bot/remotebot(T)
	new /obj/item/bot_controller(T)
	qdel(src)