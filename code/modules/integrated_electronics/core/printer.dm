#define MAX_CIRCUIT_CLONE_TIME 3 MINUTES //circuit slow-clones can only take up this amount of time to complete

/obj/item/integrated_circuit_printer
	name = "integrated circuit printer"
	desc = "A portable(ish) machine made to print tiny modular circuitry out of metal."
	icon = 'icons/obj/assemblies/electronic_tools.dmi'
	icon_state = "circuit_printer"
	w_class = ITEM_SIZE_LARGE
	material = /decl/material/solid/metal/steel
	matter = list(/decl/material/solid/fiberglass = MATTER_AMOUNT_REINFORCEMENT)

	var/upgraded = FALSE		// When hit with an upgrade disk, will turn true, allowing it to print the higher tier circuits.
	var/can_clone = TRUE		// Allows the printer to clone circuits, either instantly or over time depending on upgrade. Set to FALSE to disable entirely.
	var/fast_clone = FALSE		// If this is false, then cloning will take an amount of deciseconds equal to the metal cost divided by 100.
	var/debug = FALSE			// If it's upgraded and can clone, even without config settings.
	var/current_category = null
	var/cloning = FALSE			// If the printer is currently creating a circuit
	var/recycling = FALSE		// If an assembly is being emptied into this printer
	var/list/program			// Currently loaded save, in form of list
	var/materials = list(/decl/material/solid/metal/steel = 0)
	var/metal_max = 25 * SHEET_MATERIAL_AMOUNT

/obj/item/integrated_circuit_printer/proc/check_interactivity(mob/user)
	return CanUseTopic(user)

/obj/item/integrated_circuit_printer/upgraded
	upgraded = TRUE
	can_clone = TRUE
	fast_clone = TRUE

/obj/item/integrated_circuit_printer/debug //translation: "integrated_circuit_printer/local_server"
	name = "debug circuit printer"
	debug = TRUE
	upgraded = TRUE
	can_clone = TRUE
	fast_clone = TRUE
	w_class = ITEM_SIZE_TINY

/obj/item/integrated_circuit_printer/proc/print_program(mob/user)
	if(!cloning)
		return

	visible_message("<span class='notice'>[src] has finished printing its assembly!</span>")
	playsound(src, 'sound/items/poster_being_created.ogg', 50, TRUE)
	var/obj/item/electronic_assembly/assembly = SScircuit.load_electronic_assembly(get_turf(src), program)
	assembly.creator = key_name(user)
	cloning = FALSE

/obj/item/integrated_circuit_printer/proc/recycle(obj/item/used_item, mob/user, obj/item/electronic_assembly/assembly)
	if(!used_item.canremove) //in case we have an augment circuit
		return
	for(var/material in used_item.matter)
		if(materials[material] + used_item.matter[material] > metal_max)
			var/decl/material/material_datum = GET_DECL(material)
			if(material_datum)
				to_chat(user, "<span class='notice'>[src] can't hold any more [material_datum.name]!</span>")
			return
	for(var/material in used_item.matter)
		materials[material] += used_item.matter[material]
	if(assembly)
		assembly.remove_component(used_item)
	if(user)
		to_chat(user, "<span class='notice'>You recycle [used_item]!</span>")
	qdel(used_item)
	return TRUE

/obj/item/integrated_circuit_printer/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, /obj/item/stack/material))
		var/obj/item/stack/material/stack = used_item
		var/amt = stack.amount
		if(amt * SHEET_MATERIAL_AMOUNT + materials[stack.material.type] > metal_max)
			amt = ceil((metal_max - materials[stack.material.type]) / SHEET_MATERIAL_AMOUNT)
		if(!stack.use(amt))
			return FALSE
		materials[stack.material.type] = min(metal_max, materials[stack.material.type] + amt * SHEET_MATERIAL_AMOUNT)
		to_chat(user, "<span class='warning'>You insert [stack.material.solid_name] into \the [src].</span>")
		if(user)
			attack_self(user) // We're really bad at refreshing the UI, so this is the best we've got.
		return TRUE
	if(istype(used_item, /obj/item/disk/integrated_circuit/upgrade/advanced))
		if(upgraded)
			to_chat(user, "<span class='warning'>[src] already has this upgrade. </span>")
			return TRUE
		to_chat(user, "<span class='notice'>You install [used_item] into [src]. </span>")
		upgraded = TRUE
		if(user)
			attack_self(user)
		return TRUE

	if(istype(used_item, /obj/item/disk/integrated_circuit/upgrade/clone))
		if(fast_clone)
			to_chat(user, "<span class='warning'>[src] already has this upgrade. </span>")
			return TRUE
		to_chat(user, "<span class='notice'>You install [used_item] into [src]. Circuit cloning will now be instant. </span>")
		fast_clone = TRUE
		if(user)
			attack_self(user)
		return TRUE

	if(istype(used_item, /obj/item/electronic_assembly))
		var/obj/item/electronic_assembly/EA = used_item //microtransactions not included
		if(EA.battery)
			to_chat(user, "<span class='warning'>Remove [EA]'s power cell first!</span>")
			return TRUE
		if(EA.assembly_components.len)
			if(recycling)
				return TRUE
			if(!EA.opened)
				to_chat(user, "<span class='warning'>You can't reach [EA]'s components to remove them!</span>")
				return TRUE
			for(var/V in EA.assembly_components)
				var/obj/item/integrated_circuit/IC = V
				if(!IC.removable)
					to_chat(user, "<span class='warning'>[EA] has irremovable components in the casing, preventing you from emptying it.</span>")
					return TRUE
			to_chat(user, "<span class='notice'>You begin recycling [EA]'s components...</span>")
			playsound(src, 'sound/items/electronic_assembly_emptying.ogg', 50, TRUE)
			if(!do_after(user, 30, target = src) || recycling) //short channel so you don't accidentally start emptying out a complex assembly
				return TRUE
			recycling = TRUE
			for(var/V in EA.assembly_components)
				recycle(V, null, EA)
			to_chat(user, "<span class='notice'>You recycle all the components[EA.assembly_components.len ? " you could " : " "]from [EA]!</span>")
			playsound(src, 'sound/items/electronic_assembly_empty.ogg', 50, TRUE)
			recycling = FALSE
			return TRUE
		else
			return recycle(EA, user)

	if(istype(used_item, /obj/item/integrated_circuit))
		return recycle(used_item, user)

	return ..()

/obj/item/integrated_circuit_printer/attack_self(mob/user)
	interact(user)

/obj/item/integrated_circuit_printer/interact(mob/user)
	if(!(in_range(src, user) || issilicon(user)))
		return

	if(isnull(current_category))
		current_category = SScircuit.circuit_fabricator_recipe_list[1]

	//Preparing the browser
	var/datum/browser/written_digital/popup = new(user, "printernew", "Integrated Circuit Printer", 800, 630) // Set up the popup browser window

	var/list/HTML = list()
	HTML += "<center><h2>Integrated Circuit Printer</h2></center><br>"
	if(debug)
		HTML += "<center><h3>DEBUG PRINTER -- Infinite materials. Cloning available.</h3></center>"
	else
		HTML += "Materials: "
		var/list/dat = list()
		for(var/material in materials)
			var/decl/material/material_datum = GET_DECL(material)
			dat += "[materials[material]]/[metal_max] [material_datum.name]"
		HTML += jointext(dat, "; ")
		HTML += ".<br><br>"

	if(get_config_value(/decl/config/toggle/on/allow_ic_printing) || debug)
		HTML += "Assembly cloning: [can_clone ? (fast_clone ? "Instant" : "Available") : "Unavailable"].<br>"

	HTML += "Circuits available: [upgraded || debug ? "Advanced":"Regular"]."
	if(!upgraded)
		HTML += "<br>Crossed out circuits mean that the printer is not sufficiently upgraded to create that circuit."

	HTML += "<hr>"
	if((can_clone && get_config_value(/decl/config/toggle/on/allow_ic_printing)) || debug)
		HTML += "Here you can load script for your assembly.<br>"
		if(!cloning)
			HTML += " <A href='byond://?src=\ref[src];print=load'>{Load Program}</a> "
		else
			HTML += " {Load Program}"
		if(!program)
			HTML += " {[fast_clone ? "Print" : "Begin Printing"] Assembly}"
		else if(cloning)
			HTML += " <A href='byond://?src=\ref[src];print=cancel'>{Cancel Print}</a>"
		else
			HTML += " <A href='byond://?src=\ref[src];print=print'>{[fast_clone ? "Print" : "Begin Printing"] Assembly}</a>"

		HTML += "<br><hr>"
	HTML += "Categories:"
	for(var/category in SScircuit.circuit_fabricator_recipe_list)
		if(category != current_category)
			HTML += " <a href='byond://?src=\ref[src];category=[category]'>\[[category]\]</a> "
		else // Bold the button if it's already selected.
			HTML += " <b>\[[category]\]</b> "
	HTML += "<hr>"
	HTML += "<center><h4>[current_category]</h4></center>"

	var/list/current_list = SScircuit.circuit_fabricator_recipe_list[current_category]
	for(var/path in current_list)
		var/obj/building = path
		var/can_build = TRUE
		if(ispath(path, /obj/item/integrated_circuit))
			var/obj/item/integrated_circuit/IC = path
			if((initial(IC.spawn_flags) & IC_SPAWN_RESEARCH) && (!(initial(IC.spawn_flags) & IC_SPAWN_DEFAULT)) && !upgraded)
				can_build = FALSE
		if(can_build)
			HTML += "<A href='byond://?src=\ref[src];build=\ref[path]'>\[[initial(building.name)]\]</A>: [initial(building.desc)]<br>"
		else
			HTML += "<s>\[[initial(building.name)]\]</s>: [initial(building.desc)]<br>"

	popup.set_content(JOINTEXT(HTML))
	popup.open()

/obj/item/integrated_circuit_printer/Topic(href, href_list)
	if(!check_interactivity(usr))
		return
	if(..())
		return TRUE
	add_fingerprint(usr)

	if(href_list["category"])
		current_category = href_list["category"]

	if(href_list["build"])
		var/build_type = locate(href_list["build"])
		if(!build_type || !ispath(build_type))
			return TRUE

		var/list/cost = atom_info_repository.get_matter_for(build_type)
		if(!ispath(build_type, /obj/item/electronic_assembly) && !ispath(build_type, /obj/item/integrated_circuit) && !(build_type in SScircuit.circuit_fabricator_recipe_list["Tools"]))
			return

		if(!debug && !subtract_material_costs(cost, usr))
			return

		var/obj/item/built = new build_type(get_turf(src))
		usr.put_in_hands(built)

		if(istype(built, /obj/item/electronic_assembly))
			var/obj/item/electronic_assembly/E = built
			E.creator = key_name(usr)
			E.opened = TRUE
			E.update_icon()
		to_chat(usr, "<span class='notice'>[capitalize(built.name)] printed.</span>")
		playsound(src, 'sound/items/jaws_pry.ogg', 50, TRUE)

	if(href_list["print"])
		if(!get_config_value(/decl/config/toggle/on/allow_ic_printing) && !debug)
			to_chat(usr, "<span class='warning'>Your facility has disabled printing of custom circuitry due to recent allegations of copyright infringement.</span>")
			return
		if(!can_clone) // Copying and printing ICs is cloning
			to_chat(usr, "<span class='warning'>This printer does not have the cloning upgrade.</span>")
			return
		switch(href_list["print"])
			if("load")
				if(cloning)
					return
				var/input = usr.get_input("Put your code there:", "loading", null, MOB_INPUT_MESSAGE, src)
				if(cloning)
					return
				if(!input)
					program = null
					return

				var/validation = SScircuit.validate_electronic_assembly(input)

				// Validation error codes are returned as text.
				if(istext(validation))
					to_chat(usr, "<span class='warning'>Error: [validation]</span>")
					return
				else if(islist(validation))
					program = validation
					to_chat(usr, "<span class='notice'>This is a valid program for [program["assembly"]["type"]].</span>")
					if(program["requires_upgrades"])
						if(upgraded)
							to_chat(usr, "<span class='notice'>It uses advanced component designs.</span>")
						else
							to_chat(usr, "<span class='warning'>It uses unknown component designs. Printer upgrade is required to proceed.</span>")
					if(program["unsupported_circuit"])
						to_chat(usr, "<span class='warning'>This program uses components not supported by the specified assembly. Please change the assembly type in the save file to a supported one.</span>")
					to_chat(usr, "<span class='notice'>Used space: [program["used_space"]]/[program["max_space"]].</span>")
					to_chat(usr, "<span class='notice'>Complexity: [program["complexity"]]/[program["max_complexity"]].</span>")
					to_chat(usr, "<span class='notice'>Cost: [json_encode(program["cost"])].</span>")

			if("print")
				if(!program || cloning)
					return

				if(program["requires_upgrades"] && !upgraded && !debug)
					to_chat(usr, "<span class='warning'>This program uses unknown component designs. Printer upgrade is required to proceed.</span>")
					return
				if(program["unsupported_circuit"] && !debug)
					to_chat(usr, "<span class='warning'>This program uses components not supported by the specified assembly. Please change the assembly type in the save file to a supported one.</span>")
					return
				else if(fast_clone)
					var/list/cost = program["cost"]
					if(debug || subtract_material_costs(cost, usr))
						cloning = TRUE
						print_program(usr)
				else
					var/list/cost = program["cost"]
					if(!subtract_material_costs(cost, usr))
						return
					var/cloning_time = 0
					for(var/material in cost)
						cloning_time += cost[material]
					cloning_time = round(cloning_time/15)
					cloning_time = min(cloning_time, MAX_CIRCUIT_CLONE_TIME)
					cloning = TRUE
					to_chat(usr, "<span class='notice'>You begin printing a custom assembly. This will take approximately [round(cloning_time/10)] seconds. You can still print \
					off normal parts during this time.</span>")
					playsound(src, 'sound/items/poster_being_created.ogg', 50, TRUE)
					addtimer(CALLBACK(src, PROC_REF(print_program), usr), cloning_time)

			if("cancel")
				if(!cloning || !program)
					return

				to_chat(usr, "<span class='notice'>Cloning has been canceled. Cost has been refunded.</span>")
				cloning = FALSE
				var/cost = program["cost"]
				for(var/material in cost)
					materials[material] = min(metal_max, materials[material] + cost[material])

	interact(usr)

/obj/item/integrated_circuit_printer/proc/subtract_material_costs(var/list/cost, var/mob/user)
	for(var/material in cost)
		if(materials[material] < cost[material])
			var/decl/material/material_datum = GET_DECL(material)
			to_chat(user, "<span class='warning'>You need [cost[material]] [material_datum.name] to build that!</span>")
			return FALSE
	for(var/material in cost) //Iterate twice to make sure it's going to work before deducting
		materials[material] -= cost[material]
	return TRUE

// FUKKEN UPGRADE DISKS
/obj/item/disk/integrated_circuit/upgrade
	name = "integrated circuit printer upgrade disk"
	desc = "Install this into your integrated circuit printer to enhance it."
	color = COLOR_GRAY20
	label = "label_up"
	origin_tech = @'{"materials":2,"engineering":2}'

/obj/item/disk/integrated_circuit/upgrade/advanced
	name = "integrated circuit printer upgrade disk - advanced designs"
	desc = "Install this into your integrated circuit printer to enhance it.  This one adds new, advanced designs to the printer."
	material = /decl/material/solid/metal/steel
	matter = list(/decl/material/solid/fiberglass = MATTER_AMOUNT_REINFORCEMENT)
	origin_tech = @'{"materials":3,"engineering":3}'

/obj/item/disk/integrated_circuit/upgrade/clone
	name = "integrated circuit printer upgrade disk - instant cloner"
	desc = "Install this into your integrated circuit printer to enhance it.  This one allows the printer to duplicate assemblies instantaneously."
	origin_tech = @'{"materials":3,"programming":5}'
