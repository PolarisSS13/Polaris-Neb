/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 */

/*******
* film *
*******/
/obj/item/camera_film
	name               = "film cartridge"
	icon               = 'icons/obj/photography.dmi'
	desc               = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state         = "film"
	item_state         = "electropack"
	w_class            = ITEM_SIZE_SMALL
	throw_range        = 10
	material           = /decl/material/solid/organic/plastic
	var/const/max_uses = 10
	var/uses_left      = max_uses

/obj/item/camera_film/Initialize(ml, material_key)
	set_extension(src, /datum/extension/base_icon_state, icon_state)
	. = ..()
	update_icon()

/obj/item/camera_film/on_update_icon()
	var/datum/extension/base_icon_state/bis = get_extension(src, /datum/extension/base_icon_state)
	if(uses_left > 1)
		icon_state = "[bis.base_icon_state]"
		SetName(initial(name))
	else
		icon_state = "[bis.base_icon_state]-empty"
		SetName("spent [initial(name)]")

/obj/item/camera_film/proc/use()
	if(uses_left < 1)
		return FALSE
	uses_left--
	update_icon()
	return TRUE

/obj/item/camera_film/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(uses_left < 1)
		. += SPAN_WARNING("This cartridge is completely spent!")
	else
		. += "[uses_left] uses left."

/obj/item/camera_film/proc/get_remaining()
	return uses_left

/********
* photo *
********/
/obj/item/photo
	name        = "photo"
	icon        = 'icons/obj/photography.dmi'
	icon_state  = "photo"
	item_state  = "paper"
	randpixel   = 10
	w_class     = ITEM_SIZE_TINY
	item_flags  = ITEM_FLAG_CAN_TAPE
	material    = /decl/material/solid/organic/plastic
	var/id              //Unique id used to name the photo resource to upload to the client, and for synthetic photo synchronization
	var/icon/img	    //The actual real photo image
	var/image/tiny      //A thumbnail of the image that's displayed on the actual world icon of the photo
	var/scribble	    //User written text on the backside of the photo
	var/photo_size = 3  //Square size of the pictured scene in turfs

/obj/item/photo/Initialize(ml, material_key, var/icon/_img, var/_scribble)
	. = ..()
	id = sequential_id("obj/item/photo")
	if(_img)
		img = _img
	if(length(_scribble))
		scribble = _scribble
	update_icon()

/obj/item/photo/GetCloneArgs()
	return list(null, material, img, scribble)

/obj/item/photo/PopulateClone(obj/item/photo/clone)
	clone = ..()
	clone.photo_size = photo_size
	return clone

/obj/item/photo/attack_self(mob/user)
	user.examine_verb(src)

/obj/item/photo/get_matter_amount_modifier()
	return 0.2

/obj/item/photo/on_update_icon()
	. = ..()

	var/scale = 8/(photo_size * WORLD_ICON_SIZE)
	var/image/small_img = image(img)
	small_img.transform *= scale
	small_img.pixel_x = -WORLD_ICON_SIZE * (photo_size-1)/2 - 3
	small_img.pixel_y = -WORLD_ICON_SIZE * (photo_size-1)/2
	add_overlay(small_img)
	tiny = image(img)
	tiny.transform *= 0.5 * scale
	tiny.underlays += image(icon, "photo_underlay")
	tiny.pixel_x = -WORLD_ICON_SIZE * (photo_size-1)/2 - 3
	tiny.pixel_y = -WORLD_ICON_SIZE * (photo_size-1)/2 + 3

/obj/item/photo/attackby(obj/item/used_item, mob/user)
	if(IS_PEN(used_item))
		if(!CanPhysicallyInteractWith(user, src))
			to_chat(user, SPAN_WARNING("You can't interact with this!"))
			return TRUE
		scribble = sanitize(input(user, "What would you like to write on the back? (Leave empty to erase)", "Photo Writing", scribble), MAX_DESC_LEN)
		return TRUE
	return ..()

/obj/item/photo/examined_by(mob/user, distance, infix, suffix)
	. = ..()
	if(distance > 1)
		to_chat(user, SPAN_NOTICE("It is too far away."))
		return
	if(!img)
		return
	interact(user)

/obj/item/photo/interact(mob/user)
	send_rsc(user, img, "tmp_photo_[id].png")
	// todo: remove -ms-interpolation-mode once 516 is required
	var/photo_html = {"
		<html><head><title>[name]</title></head>
		<body style='overflow:hidden;margin:0;text-align:center'>
		<img src='tmp_photo_[id].png' width='[64*photo_size]' style='-ms-interpolation-mode:nearest-neighbor;image-rendering:pixelated;' />
		[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]
		</body></html>
	"}
	user.set_machine(src)
	show_browser(user, photo_html, "window=book;size=[64*photo_size]x[scribble ? 400 : 64*photo_size]")
	onclose(user, "[name]")

/obj/item/photo/proc/copy(var/copy_id = FALSE)
	var/obj/item/photo/p = new

	p.SetName(name) // Do this first, manually, to make sure listeners are alerted properly.
	p.appearance = appearance

	p.tiny = new
	p.tiny.appearance = tiny.appearance
	p.img = icon(img)

	p.photo_size = photo_size
	p.scribble = scribble

	if(copy_id)
		p.id = id

	return p

/obj/item/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = sanitize_safe(input(usr, "What would you like to label the photo?", "Photo Labelling", null)  as text, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if(!n_name || !CanInteract(usr, global.deep_inventory_topic_state))
		return
	SetName("[(n_name ? text("[n_name]") : "photo")]")
	add_fingerprint(usr)
	return

/**************
* photo album *
**************/
//#TODO: This thing is awful. Might as well use a trashbag instead since you get the same thing, just with more space....
/obj/item/photo_album
	name          = "photo album"
	icon          = 'icons/obj/photo_album.dmi'
	icon_state    = ICON_STATE_WORLD
	w_class       = ITEM_SIZE_NORMAL //same as book
	storage       = /datum/storage/photo_album
	material      = /decl/material/solid/organic/plastic

/obj/item/photo_album/handle_mouse_drop(atom/over, mob/user, params)
	if(over == user && in_range(src, user) || loc == user)
		if(user.active_storage)
			user.active_storage.close(user)
		storage?.show_to(user)
		return TRUE
	. = ..()

/*********
* camera *
*********/
/obj/item/camera
	name                 = "camera"
	icon                 = 'icons/obj/photography.dmi'
	desc                 = "A polaroid camera."
	icon_state           = "camera"
	item_state           = "electropack"
	item_flags           = ITEM_FLAG_NO_BLUDGEON
	w_class              = ITEM_SIZE_SMALL
	obj_flags            = OBJ_FLAG_CONDUCTIBLE
	slot_flags           = SLOT_LOWER_BODY
	material             = /decl/material/solid/metal/aluminium
	matter               = list(/decl/material/solid/organic/plastic = MATTER_AMOUNT_REINFORCEMENT)
	var/turned_on        = TRUE
	var/field_of_view    = 3 // squared, so 3 is a 3x3 of tiles
	var/obj/item/camera_film/film = new //Currently loaded film

/obj/item/camera/loaded/Initialize()
	film = new(src)
	return ..()

/obj/item/camera/Initialize()
	set_extension(src, /datum/extension/base_icon_state, icon_state)
	. = ..()
	update_icon()

/obj/item/camera/loaded/Initialize()
	. = ..()
	film = new /obj/item/camera_film(src)

/obj/item/camera/on_update_icon()
	. = ..()
	var/datum/extension/base_icon_state/bis = get_extension(src, /datum/extension/base_icon_state)
	if(turned_on)
		icon_state = "[bis.base_icon_state]"
	else
		icon_state = "[bis.base_icon_state]_off"

/obj/item/camera/use_on_mob(mob/living/target, mob/living/user, animate = TRUE)
	return FALSE

/obj/item/camera/attack_self(mob/user)
	if(film)
		turned_on = !turned_on
		to_chat(user, SPAN_NOTICE("You switch the camera [turned_on ? "on" : "off"]."))
		update_icon()
		return TRUE
	else
		to_chat(user, SPAN_WARNING("\The [src] needs film loaded to turn on!"))
	return FALSE

/obj/item/camera/get_alt_interactions(mob/user)
	. = ..()
	LAZYADD(., /decl/interaction_handler/camera_eject_film)

/obj/item/camera/proc/eject_film(mob/user)
	if(film)
		user.visible_message(SPAN_NOTICE("[user] ejects \the [film] from \the [src]."), SPAN_NOTICE("You eject \the [film] from \the [src]."))
		playsound(user, 'sound/machines/button1.ogg', 40, TRUE)
		user.put_in_hands(film)
		film = null
		turned_on = FALSE
		update_icon()
		return TRUE

	to_chat(user, SPAN_WARNING("There is no cartridge in \the [src] to eject!"))

/obj/item/camera/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, /obj/item/camera_film))
		if(film)
			//Skilled people don't have to remove the film first!
			if(user.get_skill_value(SKILL_DEVICES) >= SKILL_EXPERT)
				if(user.do_skilled(1 SECONDS, SKILL_DEVICES, src))
					user.visible_message(
						SPAN_NOTICE("In a swift flick of the finger, [user] ejects \the [film], and slides in \the [used_item]!"),
						SPAN_NOTICE("From habit you instinctively pop the old [film] from \the [src] and insert a new [used_item] deftly!"))
					user.try_unequip(used_item, src)
					user.put_in_active_hand(film)
					film = used_item
					return TRUE
				return TRUE
			//Unskilled losers have to remove it first
			to_chat(user, SPAN_NOTICE("[src] already has some film in it! Remove it first!"))
			return TRUE
		else
			if(user.do_skilled(1 SECONDS, SKILL_DEVICES, src))
				if(user.get_skill_value(SKILL_DEVICES) >= SKILL_EXPERT)
					user.visible_message(
						SPAN_NOTICE("[user] swiftly slides \the [used_item] into \the [src]!"),
						SPAN_NOTICE("You insert \a [used_item] swiftly into \the [src]!"))
				else
					user.visible_message(
						SPAN_NOTICE("[user] inserts \a [used_item] into his [src]."),
						SPAN_NOTICE("You insert \the [used_item] into \the [src]."))
				user.try_unequip(used_item, src)
				film = used_item
				return TRUE
			return TRUE
	return ..()

/obj/item/camera/proc/get_mob_details(turf/the_turf)
	var/mob_detail
	for(var/mob/living/seen in the_turf)
		if(seen.invisibility)
			continue
		var/holding
		for(var/obj/item/thing in seen.get_held_items())
			LAZYADD(holding, "\a [thing]")
		if(length(holding))
			var/decl/pronouns/mob_pronouns = seen.get_pronouns()
			holding = "[mob_pronouns.He] [mob_pronouns.is] holding [english_list(holding)]."
		if(!mob_detail)
			mob_detail = "You can see [seen] on the photo[seen.get_health_ratio() < 0.75 ? " - [seen] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [seen] on the photo[seen.get_health_ratio() < 0.75 ? " - [seen] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_detail

/obj/item/camera/afterattack(atom/target, mob/user, flag)
	if(!turned_on && (user.get_skill_value(SKILL_LITERACY) < SKILL_EXPERT))
		to_chat(user, SPAN_WARNING("Turn \the [src] on first!"))
		return
	else if(!turned_on)
		to_chat(user, SPAN_NOTICE("From habit you turn your [src] on."))
		turned_on = TRUE
		update_icon()

	if(!film?.get_remaining())
		//If out of pictures, and if we're an expert and are holding a film offhand, try to automatically load it
		if((user.get_skill_value(SKILL_LITERACY) >= SKILL_EXPERT))
			var/obj/item/camera_film/F = locate(/obj/item/camera_film) in user.get_held_items()
			if(F && F.get_remaining() > 0)
				attackby(F, user)

	if(!film?.get_remaining())
		update_icon()
		to_chat(user, SPAN_WARNING("It's out of film!"))
		return

	film.use()
	captureimage(target, user, flag)
	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)
	to_chat(user, SPAN_NOTICE("[film.get_remaining()] photo\s left."))
	return TRUE

/obj/item/camera/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(film)
		. += "It has [film?.get_remaining()] photo\s left."
	else
		. += "It doesn't have a film cartridge."

/obj/item/camera/proc/captureimage(atom/target, mob/living/user, flag)
	var/x_c = target.x - (field_of_view-1)/2
	var/y_c = target.y + (field_of_view-1)/2
	var/z_c	= target.z
	var/mob_details = ""
	for(var/i = 1 to field_of_view)
		for(var/j = 1 to field_of_view)
			var/turf/T = locate(x_c, y_c, z_c)
			if(user.can_capture_turf(T))
				mob_details += get_mob_details(T)
			x_c++
		y_c--
		x_c = x_c - field_of_view

	var/obj/item/photo/p = createpicture(target, user, mob_details, flag)
	printpicture(user, p)

/obj/item/camera/proc/createpicture(atom/target, mob/user, new_description, flag)
	var/x_c = target.x - (field_of_view-1)/2
	var/y_c = target.y - (field_of_view-1)/2
	var/z_c	= target.z
	var/icon/photoimage = create_area_image(x_c, y_c, z_c, field_of_view, TRUE, user)

	var/obj/item/photo/p = new()
	p.img = photoimage
	p.desc = new_description
	p.photo_size = field_of_view
	p.update_icon()

	return p

/obj/item/camera/proc/printpicture(mob/user, obj/item/photo/p)
	if(!user.put_in_inactive_hand(p))
		p.dropInto(loc)

/obj/item/camera/verb/change_size()
	set name = "Set Photo Focus"
	set category = "Object"
	var/nsize = input("Photo Size","Pick a size of resulting photo.") as null|anything in list(1,3,5,7)
	if(nsize)
		field_of_view = nsize
		to_chat(usr, SPAN_NOTICE("Camera will now take [field_of_view]x[field_of_view] photos."))

//Proc for capturing check
/mob/living/proc/can_capture_turf(turf/T)
	var/viewer = src
	if(src.client)		//To make shooting through security cameras possible
		viewer = src.client.eye
	var/can_see = (T in view(viewer))
	return can_see

////////////////////////////////////////////
// Eject Film Interaction
////////////////////////////////////////////
/decl/interaction_handler/camera_eject_film
	name                 = "eject film cartridge"
	icon                 = 'icons/screen/radial.dmi'
	icon_state           = "radial_eject"
	expected_target_type = /obj/item/camera
	examine_desc         = "eject the film"

/decl/interaction_handler/camera_eject_film/invoked(atom/target, mob/user, obj/item/prop)
	var/obj/item/camera/camera = target
	camera.eject_film(user)
