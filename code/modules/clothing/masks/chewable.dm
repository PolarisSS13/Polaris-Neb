/obj/item/clothing/mask/chewable
	abstract_type = /obj/item/clothing/mask/chewable
	name = "chewable item master"
	icon = 'icons/clothing/mask/chewables/lollipop.dmi'
	body_parts_covered = 0
	bodytype_equip_flags = null
	origin_tech = null
	matter = null // no plastic/fiberglass

	var/type_butt = null
	var/chem_volume = 0
	var/chewtime = 0
	var/brand

/obj/item/clothing/mask/chewable/Initialize()
	. = ..()
	atom_flags |= ATOM_FLAG_NO_CHEM_CHANGE // so it doesn't react until you light it
	initialize_reagents()

/obj/item/clothing/mask/chewable/initialize_reagents(populate = TRUE)
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 15
	. = ..()

/obj/item/clothing/mask/chewable/equipped(var/mob/living/user, var/slot)
	..()
	if(slot == slot_wear_mask_str)
		if(user.check_has_mouth())
			START_PROCESSING(SSobj, src)
		else
			to_chat(user, "<span class='notice'>You don't have a mouth, and can't make much use of \the [src].</span>")

/obj/item/clothing/mask/chewable/dropped()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/clothing/mask/chewable/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/chewable/proc/chew(amount)
	chewtime -= amount
	if(reagents && reagents.total_volume)
		if(ishuman(loc))
			var/mob/living/human/user = loc
			if (src == user.get_equipped_item(slot_wear_mask_str) && user.check_has_mouth())
				reagents.trans_to_mob(user, REM, CHEM_INGEST, 0.2)
			add_trace_DNA(user)
		else
			STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/chewable/Process()
	chew(1)
	if(chewtime < 1)
		extinguish_fire()

/obj/item/clothing/mask/chewable/tobacco
	name = "wad"
	desc = "A chewy wad of tobacco. Cut in long strands and treated with syrups so it doesn't taste like an ashtray when you stuff it into your face."
	throw_speed = 0.5
	icon = 'icons/clothing/mask/chewables/chew.dmi'
	type_butt = /obj/item/trash/cigbutt/spitwad
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS | SLOT_FACE
	chem_volume = 50
	chewtime = 300
	brand = "tobacco"
	material = /decl/material/solid/organic/plantmatter
	draw_on_mob_when_equipped = FALSE

/obj/item/trash/cigbutt/spitwad
	name = "spit wad"
	desc = "A disgusting spitwad."
	icon = 'icons/clothing/mask/chewables/chew_spit.dmi'

/obj/item/clothing/mask/chewable/extinguish_fire(mob/user, no_message = FALSE)
	STOP_PROCESSING(SSobj, src)
	if(type_butt)
		var/obj/item/trash/cigbutt/butt = new type_butt(get_turf(src))
		transfer_fingerprints_to(butt)
		if(istype(butt) && butt.use_color)
			butt.color = color
		if(brand)
			butt.desc += " This one is \a [brand]."
		if(ismob(loc))
			var/mob/living/M = loc
			if (!no_message)
				to_chat(M, "<span class='notice'>You spit out \the [src].</span>")
		qdel(src)

/obj/item/clothing/mask/chewable/tobacco/lenni
	name = "chewing tobacco"
	desc = "A chewy wad of tobacco. Cut in long strands and treated with syrups so it tastes less like an ashtray when you stuff it into your face."

/obj/item/clothing/mask/chewable/tobacco/lenni/populate_reagents()
	add_to_reagents(/decl/material/solid/tobacco, 2)

/obj/item/clothing/mask/chewable/tobacco/redlady
	name = "chewing tobacco"
	desc = "A chewy wad of fine tobacco. Cut in long strands and treated with syrups so it doesn't taste like an ashtray when you stuff it into your face"

/obj/item/clothing/mask/chewable/tobacco/redlady/populate_reagents()
	add_to_reagents(/decl/material/solid/tobacco/fine, 2)

/obj/item/clothing/mask/chewable/tobacco/nico
	name = "nicotine gum"
	desc = "A chewy wad of synthetic rubber, laced with nicotine. Possibly the least disgusting method of nicotine delivery."
	icon = 'icons/clothing/mask/chewables/gum_nicotine.dmi'
	type_butt = /obj/item/trash/cigbutt/spitgum

/obj/item/clothing/mask/chewable/tobacco/nico/initialize_reagents(populate = TRUE)
	. = ..()
	color = reagents.get_color()

/obj/item/clothing/mask/chewable/tobacco/nico/populate_reagents()
	add_to_reagents(/decl/material/liquid/nicotine, 2)

/obj/item/clothing/mask/chewable/candy
	name = "wad"
	desc = "A chewy wad of wadding material."
	icon = 'icons/clothing/mask/chewables/wad.dmi'
	throw_speed = 0.5
	type_butt = /obj/item/trash/cigbutt/spitgum
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS | SLOT_FACE
	chem_volume = 50
	chewtime = 300
	material = /decl/material/liquid/nutriment/sugar
	draw_on_mob_when_equipped = FALSE
	var/initial_payload_amount = 3

/obj/item/clothing/mask/chewable/candy/populate_reagents()
	add_to_reagents(/decl/material/liquid/nutriment/sugar, 2)
	var/list/possible_payloads = get_possible_initial_reagents()
	if(length(possible_payloads))
		add_to_reagents(pick(possible_payloads), initial_payload_amount)

/obj/item/clothing/mask/chewable/candy/proc/get_possible_initial_reagents()
	return

/obj/item/clothing/mask/chewable/candy/initialize_reagents()
	. = ..()
	if(reagents?.total_volume)
		set_color(reagents.get_color())
		desc += " This one is labeled '[reagents.get_primary_reagent_name()]'."

/obj/item/trash/cigbutt/spitgum
	name = "old gum"
	desc = "A disgusting chewed up wad of gum."
	icon = 'icons/clothing/mask/chewables/gum_spit.dmi'

/obj/item/trash/cigbutt/lollibutt
	name = "popsicle stick"
	desc = "A popsicle stick devoid of pop."
	icon = 'icons/clothing/mask/chewables/lollipop_stick.dmi'
	use_color = FALSE

/obj/item/clothing/mask/chewable/candy/gum
	name = "chewing gum"
	desc = "A chewy wad of fine synthetic rubber and artificial flavoring."
	icon = 'icons/clothing/mask/chewables/gum.dmi'

/obj/item/clothing/mask/chewable/candy/gum/get_possible_initial_reagents()
	return list(
		/decl/material/liquid/drink/juice/grape,
		/decl/material/liquid/drink/juice/orange,
		/decl/material/liquid/drink/juice/lemon,
		/decl/material/liquid/drink/juice/lime,
		/decl/material/liquid/drink/juice/apple,
		/decl/material/liquid/drink/juice/pear,
		/decl/material/liquid/drink/juice/banana,
		/decl/material/liquid/drink/juice/berry,
		/decl/material/liquid/drink/juice/watermelon
	)

/obj/item/clothing/mask/chewable/candy/lolli
	name = "lollipop"
	desc = "A simple artificially flavored sphere of sugar on a handle. Colloquially known as a sucker. Allegedly one is born every minute."
	icon = 'icons/clothing/mask/chewables/lollipop.dmi'
	type_butt = /obj/item/trash/cigbutt/lollibutt
	initial_payload_amount = 10
	draw_on_mob_when_equipped = TRUE

/obj/item/clothing/mask/chewable/candy/lolli/on_update_icon()
	. = ..()
	icon_state = get_world_inventory_state()
	add_overlay(overlay_image(icon, "[icon_state]-stick", color, RESET_COLOR))

/obj/item/clothing/mask/chewable/candy/lolli/get_possible_initial_reagents()
	return list(
		/decl/material/liquid/fuel,
		/decl/material/liquid/drink/juice/grape,
		/decl/material/liquid/drink/juice/orange,
		/decl/material/liquid/drink/juice/lemon,
		/decl/material/liquid/drink/juice/lime,
		/decl/material/liquid/drink/juice/apple,
		/decl/material/liquid/drink/juice/pear,
		/decl/material/liquid/drink/juice/banana,
		/decl/material/liquid/drink/juice/berry,
		/decl/material/liquid/drink/juice/watermelon
	)

/obj/item/clothing/mask/chewable/candy/lolli/meds
	name = "lollipop"
	desc = "A sucrose sphere on a small handle, it has been infused with medication."
	type_butt = /obj/item/trash/cigbutt/lollibutt

/obj/item/clothing/mask/chewable/candy/lolli/meds/get_possible_initial_reagents()
	return list(
		/decl/material/liquid/oxy_meds,
		/decl/material/liquid/regenerator,
		/decl/material/liquid/amphetamines,
		/decl/material/liquid/antirads,
		/decl/material/liquid/accumulated/stimulants,
		/decl/material/liquid/accumulated/antidepressants,
		/decl/material/liquid/antitoxins,
		/decl/material/liquid/brute_meds,
		/decl/material/liquid/burn_meds,
		/decl/material/liquid/stabilizer
	)

/obj/item/clothing/mask/chewable/candy/lolli/weak_meds
	name = "medicine lollipop"
	desc = "A sucrose sphere on a small handle, it has been infused with medication."
	initial_payload_amount = 15

/obj/item/clothing/mask/chewable/candy/lolli/weak_meds/get_possible_initial_reagents()
	return list(
		/decl/material/liquid/antibiotics,
		/decl/material/liquid/painkillers,
		/decl/material/liquid/regenerator,
		/decl/material/liquid/antitoxins,
		/decl/material/liquid/stabilizer
	)
