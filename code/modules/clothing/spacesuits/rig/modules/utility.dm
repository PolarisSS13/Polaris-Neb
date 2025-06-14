/* Contains:
 * /obj/item/rig_module/device
 * /obj/item/rig_module/device/healthscanner
 * /obj/item/rig_module/device/defib
 * /obj/item/rig_module/device/drill
 * /obj/item/rig_module/device/orescanner
 * /obj/item/rig_module/device/rcd
 * /obj/item/rig_module/device/anomaly_scanner
 * /obj/item/rig_module/maneuvering_jets
 * /obj/item/rig_module/chem_dispenser
 * /obj/item/rig_module/chem_dispenser/injector
 * /obj/item/rig_module/voice
 * /obj/item/rig_module/device/paperdispenser
 * /obj/item/rig_module/device/pen
 * /obj/item/rig_module/device/stamp
 */

/obj/item/rig_module/device
	name = "mounted device"
	desc = "Some kind of hardsuit mount."
	usable = 0
	selectable = 1
	toggleable = 0
	disruptive = 0
	var/obj/item/device

/obj/item/rig_module/device/Destroy()
	QDEL_NULL(device)
	. = ..()

/obj/item/rig_module/device/healthscanner
	name = "health scanner module"
	desc = "A hardsuit-mounted health scanner."
	icon_state = "scanner"
	interface_name = "health scanner"
	interface_desc = "Shows an informative health readout when used on a subject."
	engage_string = "Display Readout"
	usable = 1
	use_power_cost = 200
	origin_tech = @'{"magnets":3,"biotech":3,"engineering":5}'
	device = /obj/item/scanner/health
	material = /decl/material/solid/organic/plastic
	matter = list(
		/decl/material/solid/metal/steel = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/fiberglass = MATTER_AMOUNT_TRACE
	)

/obj/item/rig_module/device/defib
	name = "mounted defibrillator"
	desc = "A complex Vey-Med circuit with two metal electrodes hanging from it."
	icon_state = "defib"

	interface_name = "mounted defibrillator"
	interface_desc = "A prototype defibrillator, palm-mounted for ease of use."

	use_power_cost = 0//Already handled by defib, but it's 150 Wh, normal defib takes 100
	device = /obj/item/shockpaddles/rig

/obj/item/rig_module/device/drill
	name = "hardsuit mounted drill"
	desc = "A very heavy diamond-tipped drill."
	icon_state = "drill"
	interface_name = "mounted drill"
	interface_desc = "A diamond-tipped industrial drill."
	suit_overlay_active = "mounted-drill"
	suit_overlay_inactive = null
	use_power_cost = 3600 //2 Wh per use
	module_cooldown = 0
	origin_tech = @'{"materials":6,"powerstorage":4,"engineering":6}'
	device = /obj/item/tool/drill/diamond
	material = /decl/material/solid/metal/steel
	matter = list(
		/decl/material/solid/fiberglass = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/gemstone/diamond = MATTER_AMOUNT_TRACE,
		/decl/material/solid/organic/plastic = MATTER_AMOUNT_TRACE
	)

/obj/item/rig_module/device/anomaly_scanner
	name = "anomaly scanner module"
	desc = "You think it's called an Elder Sarsparilla or something."
	icon_state = "eldersasparilla"
	interface_name = "Alden-Saraspova counter"
	interface_desc = "An exotic particle detector commonly used by xenoarchaeologists."
	engage_string = "Begin Scan"
	use_power_cost = 200
	usable = 1
	selectable = 0
	device = /obj/item/ano_scanner
	origin_tech = @'{"wormholes":4,"magnets":4,"engineering":6}'
	material = /decl/material/solid/organic/plastic
	matter = list(
		/decl/material/solid/metal/steel = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/fiberglass = MATTER_AMOUNT_TRACE
	)

/obj/item/rig_module/device/orescanner
	name = "ore scanner module"
	desc = "A clunky old ore scanner."
	icon_state = "scanner"
	interface_name = "ore detector"
	interface_desc = "A sonar system for detecting large masses of ore."
	activate_string = "Get Survey Data Disk"
	engage_string = "Display Readout"
	usable = 1
	toggleable = 1
	use_power_cost = 200
	device = /obj/item/scanner/mining
	origin_tech = @'{"materials":4,"magnets":4,"engineering":6}'
	material = /decl/material/solid/organic/plastic
	matter = list(
		/decl/material/solid/metal/steel = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/fiberglass = MATTER_AMOUNT_TRACE
	)

/obj/item/rig_module/device/orescanner/activate()
	if(!check() || !device)
		return 0

	var/obj/item/scanner/mining/scanner = device
	scanner.put_disk_in_hand(holder.wearer)

/obj/item/rig_module/device/rcd
	name = "RCD mount"
	desc = "A cell-powered rapid construction device for a hardsuit."
	icon_state = "rcd"
	interface_name = "mounted RCD"
	interface_desc = "A device for building or removing walls. Cell-powered."
	usable = 1
	engage_string = "Configure RCD"
	use_power_cost = 300
	origin_tech = @'{"materials":6,"magnets":5,"engineering":7}'
	device = /obj/item/rcd/mounted
	material = /decl/material/solid/metal/steel
	matter = list(
		/decl/material/solid/fiberglass = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/organic/plastic = MATTER_AMOUNT_TRACE,
		/decl/material/solid/metal/gold = MATTER_AMOUNT_TRACE,
		/decl/material/solid/metal/silver = MATTER_AMOUNT_TRACE
	)

/obj/item/rig_module/device/Initialize()
	. = ..()
	if(ispath(device))
		device = new device(src)
		device.canremove = 0

/obj/item/rig_module/device/engage(atom/target)
	if(!..() || !device)
		return 0

	if(!target)
		device.attack_self(holder.wearer)
		return 1

	if(!target.Adjacent(holder.wearer))
		return 0

	var/resolved = target.attackby(device,holder.wearer)
	if(!resolved && device && target)
		device.afterattack(target,holder.wearer,1)
	return 1


/obj/item/rig_module/chem_dispenser
	name = "mounted chemical dispenser"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	icon_state = "injector"
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0
	use_power_cost = 500

	engage_string = "Inject"

	interface_name = "integrated chemical dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream."

	charges = list(
		list("oxygel",       "oxygel",       /decl/material/liquid/oxy_meds,     80),
		list("stabilizer",   "stabilizer",   /decl/material/liquid/stabilizer,   80),
		list("antitoxins",   "antitoxins",   /decl/material/liquid/antitoxins,   80),
		list("antirads",     "antirads",     /decl/material/liquid/antirads,     80),
		list("antibiotics",  "antibiotics",  /decl/material/liquid/antibiotics,  80),
		list("painkillers",  "painkillers",  /decl/material/liquid/painkillers,  80)
		)

	var/max_reagent_volume = 80 //Used when refilling.

/obj/item/rig_module/chem_dispenser/accepts_item(var/obj/item/input_item, var/mob/living/user)

	if(!ATOM_IS_OPEN_CONTAINER(input_item))
		return 0

	if(!input_item.reagents || !input_item.reagents.total_volume)
		to_chat(user, "\The [input_item] is empty.")
		return 0

	// Magical chemical filtration system, do not question it.
	var/total_transferred = 0
	for(var/decl/material/reagent as anything in input_item.reagents.reagent_volumes)
		for(var/chargetype in charges)
			var/datum/rig_charge/charge = charges[chargetype]
			if(charge.product_type == reagent.type)
				var/chems_to_transfer = REAGENT_VOLUME(input_item.reagents, reagent)
				if((charge.charges + chems_to_transfer) > max_reagent_volume)
					chems_to_transfer = max_reagent_volume - charge.charges
				charge.charges += chems_to_transfer
				input_item.remove_from_reagents(reagent, chems_to_transfer)
				total_transferred += chems_to_transfer
				break

	if(total_transferred)
		to_chat(user, SPAN_NOTICE("You transfer [total_transferred] units into the suit reservoir."))
	else
		to_chat(user, SPAN_WARNING("None of the reagents seem suitable."))
	return 1

/obj/item/rig_module/chem_dispenser/engage(atom/target)

	if(!..())
		return 0

	var/mob/living/human/H = holder.wearer

	if(!charge_selected)
		to_chat(H, SPAN_WARNING("You have not selected a chemical type."))
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return 0

	var/chems_to_use = 10
	if(charge.charges <= 0)
		to_chat(H, "<span class='danger'>Insufficient chems!</span>")
		return 0
	else if(charge.charges < chems_to_use)
		chems_to_use = charge.charges

	var/mob/living/target_mob
	if(target)
		if(!isliving(target))
			return FALSE
		target_mob = target
	else
		target_mob = H
	var/datum/reagents/bloodstream = target_mob.get_injected_reagents()
	if(!bloodstream)
		return FALSE

	if(target_mob != H)
		to_chat(H, SPAN_DANGER("You inject [target_mob] with [chems_to_use] unit\s of [charge.display_name]."))
	to_chat(target_mob, SPAN_DANGER("You feel a rushing in your veins as [chems_to_use] unit\s of [charge.display_name] [chems_to_use == 1 ? "is" : "are"] injected."))
	target_mob.add_to_reagents(charge.product_type, chems_to_use)
	charge.charges -= chems_to_use
	if(charge.charges < 0)
		charge.charges = 0
	return TRUE

/obj/item/rig_module/chem_dispenser/combat

	name = "combat chemical injector"
	desc = "A complex web of tubing and needles suitable for hardsuit use."

	charges = list(
		list("antidepressants", "antidepressants",  /decl/material/liquid/accumulated/antidepressants,    30),
		list("stimulants",      "stimulants",       /decl/material/liquid/accumulated/stimulants,         30),
		list("amphetamines",    "amphetamines",     /decl/material/liquid/amphetamines,                   30),
		list("painkillers",     "painkillers",      /decl/material/liquid/painkillers/strong,             30),
		list("glucose",         "glucose",          /decl/material/liquid/nutriment/glucose,              80)
		)

	interface_name = "combat chem dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the bloodstream."


/obj/item/rig_module/chem_dispenser/injector

	name = "mounted chemical injector"
	desc = "A complex web of tubing and a large needle suitable for hardsuit use."
	usable = 0
	selectable = 1
	disruptive = 1

	suit_overlay_active = "mounted-injector"

	interface_name = "mounted chem injector"
	interface_desc = "Dispenses loaded chemicals via an arm-mounted injector."

/obj/item/rig_module/voice

	name = "hardsuit voice synthesiser"
	desc = "A speaker box and sound processor."
	icon_state = "megaphone"
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0
	active_power_cost = 100

	engage_string = "Configure Synthesiser"

	interface_name = "voice synthesiser"
	interface_desc = "A flexible and powerful voice modulator system."

	var/obj/item/voice_changer/voice_holder

/obj/item/rig_module/voice/Initialize()
	. = ..()
	voice_holder = new(src)
	voice_holder.active = 0

/obj/item/rig_module/voice/installed()
	. = ..()
	if(holder)
		holder.speech = src
		holder.verbs |= /obj/item/rig/proc/alter_voice

/obj/item/rig_module/voice/removed()
	if(holder)
		holder.speech = null
		holder.verbs -= /obj/item/rig/proc/alter_voice
	. = ..()

/obj/item/rig_module/voice/engage()

	if(!..())
		return 0

	var/choice= input("Would you like to toggle the synthesiser or set the name?") as null|anything in list("Enable","Disable","Set Name")

	if(!choice)
		return 0

	switch(choice)
		if("Enable")
			active = 1
			voice_holder.active = 1
			to_chat(usr, SPAN_NOTICE("You enable the speech synthesiser."))
		if("Disable")
			active = 0
			voice_holder.active = 0
			to_chat(usr, SPAN_NOTICE("You disable the speech synthesiser."))
		if("Set Name")
			var/raw_choice = sanitize(input(usr, "Please enter a new name.")  as text|null, MAX_NAME_LEN)
			if(!raw_choice)
				return 0
			voice_holder.voice = raw_choice
			to_chat(usr, SPAN_NOTICE("You are now mimicking <B>[voice_holder.voice]</B>."))
	return 1

/obj/item/rig_module/maneuvering_jets

	name = "hardsuit maneuvering jets"
	desc = "A compact gas thruster system for a hardsuit."
	icon_state = "thrusters"
	usable = 1
	toggleable = 1
	selectable = 0
	disruptive = 0
	active_power_cost = 200

	suit_overlay_active = "maneuvering_active"
	suit_overlay_inactive = null //"maneuvering_inactive"

	engage_string = "Toggle Stabilizers"
	activate_string = "Activate Thrusters"
	deactivate_string = "Deactivate Thrusters"

	interface_name = "maneuvering jets"
	interface_desc = "An inbuilt EVA maneuvering system that runs off a separate gas supply."
	origin_tech = @'{"materials":6,"engineering":7}'
	material = /decl/material/solid/metal/steel
	matter = list(
		/decl/material/solid/organic/plastic = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/fiberglass = MATTER_AMOUNT_TRACE
	)
	var/obj/item/tank/jetpack/rig/jets

/obj/item/rig_module/maneuvering_jets/attackby(obj/item/used_item, mob/user)
	if(used_item.do_tool_interaction(TOOL_WRENCH, user, src, 1, "removing the propellant tank", "removing the propellant tank"))
		jets.forceMove(get_turf(user))
		user.put_in_hands(jets)
		jets = null
		return TRUE

	if(istype(used_item, /obj/item/tank/jetpack/rig))
		if(jets)
			to_chat(user, SPAN_WARNING("There's already a propellant tank inside of \the [src]!"))
			return TRUE
		if(user.try_unequip(used_item))
			to_chat(user, SPAN_NOTICE("You insert \the [used_item] into [src]."))
			used_item.forceMove(src)
			jets = used_item
			return TRUE
	. = ..()

/obj/item/rig_module/maneuvering_jets/engage()
	if(!..())
		return 0
	jets.toggle_rockets()
	return 1

/obj/item/rig_module/maneuvering_jets/activate()

	if(active)
		return 0

	active = 1

	spawn(1)
		if(suit_overlay_active)
			suit_overlay = suit_overlay_active
		else
			suit_overlay = null
		holder.update_icon()

	if(!jets.on)
		jets.toggle()
	return 1

/obj/item/rig_module/maneuvering_jets/deactivate()
	if(!..())
		return 0
	if(jets.on)
		jets.toggle()
	return 1

/obj/item/rig_module/maneuvering_jets/Initialize()
	. = ..()
	jets = new(src)

/obj/item/rig_module/maneuvering_jets/installed()
	..()
	jets.holder = holder
	jets.ion_trail.set_up(holder)

/obj/item/rig_module/maneuvering_jets/removed()
	..()
	jets.holder = null
	jets.ion_trail.set_up(jets)

/obj/item/rig_module/maneuvering_jets/Destroy()
	. = ..()
	QDEL_NULL(jets)

/obj/item/rig_module/device/paperdispenser
	name = "hardsuit paper dispenser"
	desc = "Crisp sheets."
	icon_state = "paper"
	interface_name = "paper dispenser"
	interface_desc = "Dispenses warm, clean, and crisp sheets of paper."
	engage_string = "Dispense"
	use_power_cost = 200
	usable = 1
	selectable = 0
	device = /obj/item/form_printer

/obj/item/rig_module/device/pen
	name = "mounted pen"
	desc = "For exosuit John Hancocks."
	icon_state = "pen"
	interface_name = "mounted pen"
	interface_desc = "Signatures with style(tm)."
	engage_string = "Change color"
	usable = 1
	device = /obj/item/pen/multi

/obj/item/rig_module/device/stamp
	name = "mounted stamp"
	desc = "DENIED."
	icon_state = "stamp"
	interface_name = "mounted stamp"
	interface_desc = "Leave your mark."
	engage_string = "Toggle stamp type"
	usable = 1
	var/stamp
	var/deniedstamp

/obj/item/rig_module/device/stamp/Initialize()
	. = ..()
	stamp = new /obj/item/stamp(src)
	deniedstamp = new /obj/item/stamp/denied(src)
	device = stamp

/obj/item/rig_module/device/stamp/engage(atom/target)
	if(!..() || !device)
		return 0

	if(!target)
		if(device == stamp)
			device = deniedstamp
			to_chat(holder.wearer, "<span class='notice'>Switched to denied stamp.</span>")
		else if(device == deniedstamp)
			device = stamp
			to_chat(holder.wearer, "<span class='notice'>Switched to rubber stamp.</span>")
		return 1

/obj/item/rig_module/device/decompiler
	name = "mounted matter decompiler"
	desc = "A drone matter decompiler reconfigured for hardsuit use."
	icon_state = "ewar"
	interface_name = "mounted matter decompiler"
	interface_desc = "Eats trash like no one's business."
	origin_tech = @'{"materials":5,"engineering":5}'
	device = /obj/item/matter_decompiler
	material = /decl/material/solid/metal/steel
	matter = list(
		/decl/material/solid/organic/plastic = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/fiberglass = MATTER_AMOUNT_TRACE
	)

/obj/item/rig_module/cooling_unit
	name = "mounted cooling unit"
	toggleable = 1
	origin_tech = @'{"magnets":2,"materials":2,"engineering":5}'
	interface_name = "mounted cooling unit"
	interface_desc = "A heat sink with a liquid cooled radiator."
	module_cooldown = 0 SECONDS //no cd because its critical for a life-support module
	material = /decl/material/solid/metal/steel
	matter = list(
		/decl/material/solid/fiberglass = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/organic/plastic = MATTER_AMOUNT_TRACE
	)
	var/charge_consumption = 0.5 KILOWATTS
	var/max_cooling = 12
	var/thermostat = T20C

/obj/item/rig_module/cooling_unit/Process()
	if(!active)
		return passive_power_cost

	var/mob/living/human/H = holder.wearer

	var/temp_adj = min(H.bodytemperature - thermostat, max_cooling) //Actually copies the original CU code

	if (temp_adj < 0.5)
		return passive_power_cost

	H.bodytemperature -= temp_adj
	active_power_cost = round((temp_adj/max_cooling)*charge_consumption)
	return active_power_cost
