//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	name = "\improper ChemMaster 3000"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/chemistry/chemmaster.dmi'
	icon_state = "mixer0"
	layer = BELOW_OBJ_LAYER
	idle_power_usage = 20
	clicksound = "button"
	clickvol = 20
	construct_state = /decl/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0
	base_type = /obj/machinery/chem_master
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	core_skill = SKILL_CHEMISTRY

	var/obj/item/chems/beaker = null
	var/obj/item/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/useramount = 30 // Last used amount
	var/pillamount = 10
	var/pillsprite = "1"
	var/list/client/has_sprites = list()
	var/max_pill_count = 20
	var/sloppy = 1 //Whether reagents will not be fully purified (sloppy = 1) or there will be reagent loss (sloppy = 0) on reagent add.
	var/reagent_limit = 120
	var/bottle_label_color = COLOR_WHITE
	var/bottle_lid_color = COLOR_OFF_WHITE

/obj/machinery/chem_master/Initialize()
	. = ..()
	create_reagents(reagent_limit)

/obj/machinery/chem_master/proc/get_remaining_volume()
	return clamp(reagent_limit - reagents.total_volume, 0, reagent_limit)

/obj/machinery/chem_master/attackby(var/obj/item/B, var/mob/user)

	if(istype(B, /obj/item/chems/glass))

		if(beaker)
			to_chat(user, SPAN_WARNING("A beaker is already loaded into the machine."))
			return TRUE
		if(!user.try_unequip(B, src))
			return TRUE
		beaker = B
		to_chat(user, SPAN_NOTICE("You add the beaker to the machine!"))
		updateUsrDialog()
		icon_state = "mixer1"
		return TRUE

	if(istype(B, /obj/item/chems))
		to_chat(user, SPAN_WARNING("\The [src] will only accept beakers."))
		return TRUE

	if(istype(B, /obj/item/pill_bottle))

		if(loaded_pill_bottle)
			to_chat(user, SPAN_WARNING("A pill bottle is already loaded into the machine."))
			return TRUE
		if(!user.try_unequip(B, src))
			return TRUE
		loaded_pill_bottle = B
		to_chat(user, SPAN_NOTICE("You add the pill bottle into the dispenser slot!"))
		updateUsrDialog()
		return TRUE

	return ..()

/obj/machinery/chem_master/Topic(href, href_list, state)
	if(..())
		return 1
	var/mob/user = usr

	if (href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.dropInto(loc)
			loaded_pill_bottle = null
	else if(href_list["close"])
		show_browser(user, null, "window=chem_master")
		user.unset_machine()
		return

	if(beaker)
		var/datum/reagents/R = beaker.reagents
		if (href_list["analyze"])
			var/decl/material/reagent = locate(href_list["analyze"])
			var/dat = get_chem_info(reagent)
			if(dat && REAGENT_VOLUME(beaker.reagents, reagent.type))
				show_browser(user, dat, "window=chem_master;size=575x400")
			return

		else if (href_list["add"])
			if(href_list["amount"])
				var/decl/material/their_reagent = locate(href_list["add"])
				if(their_reagent)
					var/mult = 1
					var/amount = clamp((text2num(href_list["amount"])), 0, get_remaining_volume())
					if(sloppy)
						var/contaminants = fetch_contaminants(user, R, their_reagent)
						for(var/decl/material/reagent in contaminants)
							R.trans_type_to(src, reagent.type, round(rand()*amount/5, 0.1))
					else
						mult -= 0.4 * (SKILL_MAX - user.get_skill_value(core_skill))/(SKILL_MAX-SKILL_MIN) //10% loss per skill level down from max
					R.trans_type_to(src, their_reagent.type, amount, mult)



		else if (href_list["addcustom"])
			var/decl/material/their_reagent = locate(href_list["addcustom"])
			if(their_reagent)
				useramount = input("Select the amount to transfer.", 30, useramount) as null|num
				if(useramount)
					useramount = clamp(useramount, 0, 200)
					src.Topic(href, list("amount" = "[useramount]", "add" = href_list["addcustom"]), state)

		else if (href_list["remove"])
			if(href_list["amount"])
				var/decl/material/my_reagents = locate(href_list["remove"])
				if(my_reagents)
					var/amount = clamp((text2num(href_list["amount"])), 0, 200)
					var/contaminants = fetch_contaminants(user, reagents, my_reagents)
					if(mode)
						reagents.trans_type_to(beaker, my_reagents.type, amount)
						for(var/decl/material/reagent in contaminants)
							reagents.trans_type_to(beaker, reagent.type, round(rand()*amount, 0.1))
					else
						remove_from_reagents(my_reagents.type, amount)
						for(var/decl/material/reagent in contaminants)
							remove_from_reagents(reagent.type, round(rand()*amount, 0.1))

		else if (href_list["removecustom"])
			var/decl/material/my_reagents = locate(href_list["removecustom"])
			if(my_reagents)
				useramount = input("Select the amount to transfer.", 30, useramount) as null|num
				if(useramount)
					useramount = clamp(useramount, 0, 200)
					src.Topic(href, list("amount" = "[useramount]", "remove" = href_list["removecustom"]), state)

		else if (href_list["toggle"])
			mode = !mode
		else if (href_list["toggle_sloppy"])
			sloppy = !sloppy

		else if (href_list["main"])
			interact(user)
			return
		else if (href_list["eject"])
			beaker.forceMove(loc)
			beaker = null
			reagents.clear_reagents()
			icon_state = "mixer0"
		else if (href_list["createpill"] || href_list["createpill_multiple"])
			var/count = 1

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			if (href_list["createpill_multiple"])
				count = input("Select the number of pills to make.", "Max [max_pill_count]", pillamount) as num
				if(!CanInteract(user, state))
					return
				count = clamp(count, 1, max_pill_count)

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			var/amount_per_pill = reagents.total_volume/count
			if (amount_per_pill > 30) amount_per_pill = 30

			var/name = sanitize_safe(input(usr,"Name:","Name your pill!","[reagents.get_primary_reagent_name()] ([amount_per_pill]u)"), MAX_NAME_LEN)
			if(!CanInteract(user, state))
				return

			if(reagents.total_volume/count < 1) //Sanity checking.
				return
			while (count-- && count >= 0)
				var/obj/item/chems/pill/dispensed/P = new(loc)
				if(!name) name = reagents.get_primary_reagent_name()
				P.SetName("[name] pill")
				P.icon_state = "pill"+pillsprite
				reagents.trans_to_obj(P,amount_per_pill)
				P.update_icon()
				if(loaded_pill_bottle && loaded_pill_bottle.storage && loaded_pill_bottle.contents.len < loaded_pill_bottle.storage.max_storage_space)
					P.forceMove(loaded_pill_bottle)

		else if (href_list["createbottle"])
			create_bottle(user)
		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 25 //max icon state of the pill sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_PILL_SPRITE)
				dat += "<tr><td><a href=\"byond://?src=\ref[src]&pill_sprite=[i]\"><img src=\"pill[i].png\" /></a></td></tr>"
			dat += "</table>"
			show_browser(user, dat, "window=chem_master")
			return
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
		else if(href_list["label_color"])
			bottle_label_color = input(usr, "Pick new bottle label color", "Label color", bottle_label_color) as color
		else if(href_list["lid_color"])
			bottle_lid_color = input(usr, "Pick new bottle lid color", "Lid color", bottle_lid_color) as color

	updateUsrDialog()

/obj/machinery/chem_master/proc/fetch_contaminants(mob/user, datum/reagents/reagents, decl/material/main_reagent)
	. = list()
	for(var/rtype in reagents.reagent_volumes)
		var/decl/material/reagent = GET_DECL(rtype)
		if(reagent != main_reagent && prob(user.skill_fail_chance(core_skill, 100)))
			. += reagent

/obj/machinery/chem_master/proc/get_chem_info(decl/material/reagent, heading = "Chemical infos", detailed_blood = 1)
	if(!beaker || !reagent)
		return
	. = list()
	. += "<TITLE>[name]</TITLE>"
	. += "[heading]:<BR><BR>Name:<BR>[reagent.use_name]"
	. += "<BR><BR>Description:<BR>"
	if(detailed_blood && istype(reagent, /decl/material/liquid/blood))
		var/blood_data = REAGENT_DATA(beaker?.reagents, /decl/material/liquid/blood)
		. += "Blood Type: [LAZYACCESS(blood_data, DATA_BLOOD_TYPE)]<br>DNA: [LAZYACCESS(blood_data, DATA_BLOOD_DNA)]"
	else
		. += "[reagent.lore_text]"
	. += "<BR><BR><BR><A href='byond://?src=\ref[src];main=1'>(Back)</A>"
	. = JOINTEXT(.)

/obj/machinery/chem_master/proc/create_bottle(mob/user)
	var/name = sanitize_safe(input(usr,"Name:","Name your bottle!",reagents.get_primary_reagent_name()), MAX_NAME_LEN)
	var/obj/item/chems/glass/bottle/P = new/obj/item/chems/glass/bottle(loc)
	if(!name)
		name = reagents.get_primary_reagent_name()
	P.label_text = name
	P.update_name()
	P.lid_color = bottle_lid_color
	P.label_color = bottle_label_color
	reagents.trans_to_obj(P,60)
	P.update_icon()

/obj/machinery/chem_master/DefaultTopicState()
	return global.physical_topic_state

/obj/machinery/chem_master/interface_interact(mob/user)
	interact(user)
	return TRUE

/obj/machinery/chem_master/interact(mob/user)
	user.set_machine(src)
	if(!(user.client in has_sprites))
		spawn()
			has_sprites += user.client
			for(var/i = 1 to MAX_PILL_SPRITE)
				send_rsc(user, icon('icons/obj/items/chem/pill.dmi', "pill" + num2text(i)), "pill[i].png")
	var/dat = list()
	dat += "<TITLE>[name]</TITLE>"
	dat += "[name] Menu:"
	if(!beaker)
		dat += "Please insert beaker.<BR>"
		if(loaded_pill_bottle?.storage)
			dat += "<A href='byond://?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage.max_storage_space]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		dat += "<A href='byond://?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker.reagents
		dat += "<A href='byond://?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		dat += "Toggle purification mode: <A href='byond://?src=\ref[src];toggle_sloppy=1'>[sloppy ? "Quick" : "Thorough"]</A><BR>"
		if(loaded_pill_bottle?.storage)
			dat += "<A href='byond://?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage.max_storage_space]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/rtype in R.reagent_volumes)
				var/decl/material/G = GET_DECL(rtype)
				dat += "[G.use_name], [REAGENT_VOLUME(R, rtype)] Units - "
				dat += "<A href='byond://?src=\ref[src];analyze=\ref[G]'>(Analyze)</A> "
				dat += "<A href='byond://?src=\ref[src];add=\ref[G];amount=1'>(1)</A> "
				dat += "<A href='byond://?src=\ref[src];add=\ref[G];amount=5'>(5)</A> "
				dat += "<A href='byond://?src=\ref[src];add=\ref[G];amount=10'>(10)</A> "
				dat += "<A href='byond://?src=\ref[src];add=\ref[G];amount=[REAGENT_VOLUME(R, rtype)]'>(All)</A> "
				dat += "<A href='byond://?src=\ref[src];addcustom=\ref[G]'>(Custom)</A><BR>"

		dat += "<HR>Transfer to <A href='byond://?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/rtype in reagents.reagent_volumes)
				var/decl/material/N = GET_DECL(rtype)
				dat += "[N.use_name], [REAGENT_VOLUME(reagents, rtype)] Units - "
				dat += "<A href='byond://?src=\ref[src];analyze=\ref[N]'>(Analyze)</A> "
				dat += "<A href='byond://?src=\ref[src];remove=\ref[N];amount=1'>(1)</A> "
				dat += "<A href='byond://?src=\ref[src];remove=\ref[N];amount=5'>(5)</A> "
				dat += "<A href='byond://?src=\ref[src];remove=\ref[N];amount=10'>(10)</A> "
				dat += "<A href='byond://?src=\ref[src];remove=\ref[N];amount=[REAGENT_VOLUME(reagents, rtype)]'>(All)</A> "
				dat += "<A href='byond://?src=\ref[src];removecustom=\ref[N]'>(Custom)</A><BR>"
		else
			dat += "Empty<BR>"
		dat += extra_options()
	show_browser(user, strip_improper(JOINTEXT(dat)), "window=chem_master;size=575x400")
	onclose(user, "chem_master")

//Use to add extra stuff to the end of the menu.
/obj/machinery/chem_master/proc/extra_options()
	. = list()
	. += "<HR><BR><A href='byond://?src=\ref[src];createpill=1'>Create pill (30 units max)</A><a href=\"byond://?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><BR>"
	. += "<A href='byond://?src=\ref[src];createpill_multiple=1'>Create multiple pills</A><BR>"
	. += "<A href='byond://?src=\ref[src];createbottle=1'>Create bottle (60 units max)</A>"
	. += "<BR><A href='byond://?src=\ref[src];label_color=1'>Bottle Label Color:</a><span style='color:[bottle_label_color];border: 1px solid black;'>\t▉</span>"
	. += "<BR><A href='byond://?src=\ref[src];lid_color=1'>Bottle Lid Color:</a><span style='color:[bottle_lid_color];border: 1px solid black;'>\t▉</span>"
	return JOINTEXT(.)

/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	core_skill = SKILL_COOKING

/obj/machinery/chem_master/condimaster/get_chem_info(decl/material/reagent)
	return ..(reagent, "Condiment infos", 0)

/obj/machinery/chem_master/condimaster/create_bottle(mob/user)
	var/obj/item/chems/condiment/P = new/obj/item/chems/condiment(src.loc)
	reagents.trans_to_obj(P,50)

/obj/machinery/chem_master/condimaster/extra_options()
	return "<A href='byond://?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"
