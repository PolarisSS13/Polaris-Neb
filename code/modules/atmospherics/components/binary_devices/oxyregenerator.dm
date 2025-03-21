/obj/machinery/atmospherics/binary/oxyregenerator
	name ="oxygen regenerator"
	desc = "A machine for breaking bonds in carbon dioxide and releasing pure oxygen."
	icon = 'icons/atmos/oxyregenerator.dmi'
	icon_state = "off"
	density = TRUE
	use_power = POWER_USE_OFF
	idle_power_usage = 200		//internal circuitry, friction losses and stuff
	power_rating = 10000
	base_type = /obj/machinery/atmospherics/binary/oxyregenerator
	construct_state = /decl/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0
	obj_flags = OBJ_FLAG_ANCHORABLE | OBJ_FLAG_ROTATABLE
	layer = STRUCTURE_LAYER

	var/target_pressure = 10 ATM
	var/power_setting = 1 //power consumption setting, 1 through five
	var/carbon_stored = 0
	var/carbon_efficiency = 0.5
	var/intake_power_efficiency = 1
	var/const/carbon_moles_per_piece = 50 //One 12g per mole * 50 = 600 g chunk of coal
	var/phase = "filling"//"filling", "processing", "releasing"
	var/datum/gas_mixture/inner_tank = new

/obj/machinery/atmospherics/binary/oxyregenerator/RefreshParts()
	carbon_efficiency = initial(carbon_efficiency)
	carbon_efficiency += 0.25 * total_component_rating_of_type(/obj/item/stock_parts/matter_bin)
	carbon_efficiency -= 0.25 * number_of_components(/obj/item/stock_parts/matter_bin)
	carbon_efficiency = clamp(carbon_efficiency, initial(carbon_efficiency), 5)

	intake_power_efficiency = initial(intake_power_efficiency)
	intake_power_efficiency -= 0.1 * total_component_rating_of_type(/obj/item/stock_parts/manipulator)
	intake_power_efficiency += 0.1 * number_of_components(/obj/item/stock_parts/manipulator)
	intake_power_efficiency = clamp(intake_power_efficiency, 0.1, initial(intake_power_efficiency))

	power_rating = 1
	power_rating -= 0.05 * total_component_rating_of_type(/obj/item/stock_parts/micro_laser)
	power_rating += 0.05 * number_of_components(/obj/item/stock_parts/micro_laser)
	power_rating = clamp(power_rating, 0.1, 1)
	power_rating *= initial(power_rating)
	..()

/obj/machinery/atmospherics/binary/oxyregenerator/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	. += "Its outlet port is to the [dir2text(dir)]."

/obj/machinery/atmospherics/binary/oxyregenerator/Process(wait, tick)
	..()
	if((stat & (NOPOWER|BROKEN)) || !use_power)
		return

	var/power_draw = -1
	last_power_draw = 0
	//TODO Add overlay with F-P-R letter to display current state
	if (phase == "filling")//filling tank
		var/pressure_delta = target_pressure - inner_tank.return_pressure()
		if (pressure_delta > 0.01 && air1.temperature > 0)
			var/transfer_moles = calculate_transfer_moles(air1, inner_tank, pressure_delta)
			power_draw = pump_gas(src, air1, inner_tank, transfer_moles, power_rating*power_setting) * intake_power_efficiency
			if (power_draw >= 0)
				last_power_draw = power_draw
				use_power_oneoff(power_draw)
			if(transfer_moles > 0)
				update_networks(turn(dir, 180))
		if (air1.return_pressure() < (0.1 ATM) || inner_tank.return_pressure() >= target_pressure * 0.95)//if pipe is good as empty or tank is full
			phase = "processing"

	if (phase == "processing")//processing CO2 in tank
		if (inner_tank.gas[/decl/material/gas/carbon_dioxide])
			var/co2_intake = clamp(inner_tank.gas[/decl/material/gas/carbon_dioxide], 0, power_setting*wait/10)
			last_flow_rate = co2_intake
			inner_tank.adjust_gas(/decl/material/gas/carbon_dioxide, -co2_intake, 1)
			var/datum/gas_mixture/new_oxygen = new
			new_oxygen.adjust_gas(/decl/material/gas/oxygen,  co2_intake)
			new_oxygen.temperature = T20C+30 //it's sort of hot after molecular bond breaking
			inner_tank.merge(new_oxygen)
			carbon_stored += co2_intake * carbon_efficiency
			while (carbon_stored >= carbon_moles_per_piece)
				carbon_stored -= carbon_moles_per_piece
				SSmaterials.create_object(/decl/material/solid/graphite, get_turf(src), 1)
			power_draw = power_rating * co2_intake
			last_power_draw = power_draw
			use_power_oneoff(power_draw)
		else
			phase = "releasing"

	if (phase == "releasing")//releasing processed gas mix
		power_draw = -1
		var/pressure_delta = target_pressure - air2.return_pressure()
		if (pressure_delta > 0.01 && inner_tank.temperature > 0)
			var/datum/pipe_network/output = network_in_dir(dir)
			var/transfer_moles = calculate_transfer_moles(inner_tank, air2, pressure_delta, output?.volume)
			power_draw = pump_gas(src, inner_tank, air2, transfer_moles, power_rating*power_setting)
			if (power_draw >= 0)
				last_power_draw = power_draw
				use_power_oneoff(power_draw)
			if(transfer_moles > 0)
				update_networks(dir)
		else//can't push outside harder than target pressure. Device is not intended to be used as a pump after all
			phase = "filling"
		if (inner_tank.return_pressure() <= 0.1)
			phase = "filling"

/obj/machinery/atmospherics/binary/oxyregenerator/on_update_icon()
	if(stat & NOPOWER)
		icon_state = "off"
	else
		icon_state = "[use_power ? "on" : "off"]"

/obj/machinery/atmospherics/binary/oxyregenerator/interface_interact(user)
	ui_interact(user)
	return TRUE

/obj/machinery/atmospherics/binary/oxyregenerator/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	data["on"] = use_power ? 1 : 0
	data["powerSetting"] = power_setting
	data["gasProcessed"] = last_flow_rate
	data["air1Pressure"] = round(air1.return_pressure())
	data["air2Pressure"] = round(air2.return_pressure())
	data["tankPressure"] = round(inner_tank.return_pressure())
	data["targetPressure"] = round(target_pressure)
	data["phase"] = phase
	if (inner_tank.total_moles > 0)
		data["co2"] = round(100 * inner_tank.gas[/decl/material/gas/carbon_dioxide]/inner_tank.total_moles)
		data["o2"] = round(100 * inner_tank.gas[/decl/material/gas/oxygen]/inner_tank.total_moles)
	else
		data["co2"] = 0
		data["o2"] = 0
		// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "oxyregenerator.tmpl", "Oxygen Regeneration System", 440, 300)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/atmospherics/binary/oxyregenerator/OnTopic(mob/user, href_list)
	if((. = ..()))
		return
	if(href_list["toggleStatus"])
		update_use_power(!use_power)
		return TOPIC_REFRESH
	if(href_list["setPower"]) //setting power to 0 is redundant anyways
		power_setting = clamp(text2num(href_list["setPower"]), 1, 5)
		return TOPIC_REFRESH
