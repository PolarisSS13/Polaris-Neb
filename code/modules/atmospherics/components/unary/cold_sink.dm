//TODO: Put this under a common parent type with heaters to cut down on the copypasta
#define FREEZER_PERF_MULT 2.5

/obj/machinery/atmospherics/unary/freezer
	name = "gas cooling system"
	desc = "Cools gas when connected to a pipe network."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer_0"
	layer = STRUCTURE_LAYER
	density = TRUE
	anchored = TRUE
	use_power = POWER_USE_OFF
	idle_power_usage = 5			// 5 Watts for thermostat related circuitry
	base_type = /obj/machinery/atmospherics/unary/freezer
	construct_state = /decl/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0

	var/heatsink_temperature = T20C	// The constant temperature reservoir into which the freezer pumps heat. Probably the hull of the station or something.
	var/internal_volume = 600		// L

	var/max_power_rating = 20000	// Power rating when the usage is turned up to 100
	var/power_setting = 100

	var/set_temperature = T20C		// Thermostat
	var/cooling = 0

/obj/machinery/atmospherics/unary/freezer/on_update_icon()
	if(LAZYLEN(nodes_to_networks))
		if(use_power && cooling)
			icon_state = "freezer_1"
		else
			icon_state = "freezer"
	else
		icon_state = "freezer_0"

/obj/machinery/atmospherics/unary/freezer/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/atmospherics/unary/freezer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	// this is the data which will be sent to the ui
	var/data[0]
	data["on"] = use_power ? 1 : 0
	data["gasPressure"] = round(air_contents.return_pressure())
	data["gasTemperature"] = round(air_contents.temperature)
	data["minGasTemperature"] = 0
	data["maxGasTemperature"] = round(T20C+500)
	data["targetGasTemperature"] = round(set_temperature)
	data["powerSetting"] = power_setting

	var/temp_class = "good"
	if(air_contents.temperature > (T0C - 20))
		temp_class = "bad"
	else if(air_contents.temperature < (T0C - 20) && air_contents.temperature > (T0C - 100))
		temp_class = "average"
	data["gasTemperatureClass"] = temp_class

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "freezer.tmpl", "Gas Cooling System", 440, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/unary/freezer/OnTopic(mob/user, href_list)
	if((. = ..()))
		return
	if(href_list["toggleStatus"])
		update_use_power(!use_power)
		. = TOPIC_REFRESH
	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		set_temperature = clamp(set_temperature + amount, 0, 1000)
		. = TOPIC_REFRESH
	if(href_list["setPower"]) //setting power to 0 is redundant anyways
		var/new_setting = clamp(text2num(href_list["setPower"]), 0, 100)
		set_power_level(new_setting)
		. = TOPIC_REFRESH

/obj/machinery/atmospherics/unary/freezer/Process()
	..()

	if(stat & (NOPOWER|BROKEN) || !use_power)
		cooling = 0
		update_icon()
		return

	if(LAZYLEN(nodes_to_networks) && air_contents.temperature > set_temperature)
		cooling = 1

		var/heat_transfer = max( -air_contents.get_thermal_energy_change(set_temperature - 5), 0 )

		//Assume the heat is being pumped into the hull which is fixed at heatsink_temperature
		//not /really/ proper thermodynamics but whatever
		var/cop = FREEZER_PERF_MULT * air_contents.temperature/heatsink_temperature	//heatpump coefficient of performance from thermodynamics -> power used = heat_transfer/cop
		heat_transfer = min(heat_transfer, cop * power_rating)	//limit heat transfer by available power

		var/removed = -air_contents.add_thermal_energy(-heat_transfer)		//remove the heat
		if(debug)
			visible_message("[src]: Removing [removed] W.")

		use_power_oneoff(power_rating)

		update_networks()
	else
		cooling = 0

	update_icon()

//upgrading parts
/obj/machinery/atmospherics/unary/freezer/RefreshParts()
	..()
	var/cap_rating = clamp(total_component_rating_of_type(/obj/item/stock_parts/capacitor), 0, 20)
	var/manip_rating = clamp(total_component_rating_of_type(/obj/item/stock_parts/manipulator), 1, 10)
	var/bin_rating = clamp(total_component_rating_of_type(/obj/item/stock_parts/matter_bin), 0, 10)

	power_rating = initial(power_rating) * cap_rating / 2			//more powerful
	heatsink_temperature = initial(heatsink_temperature) / ((manip_rating + bin_rating) / 2)	//more efficient
	air_contents.volume = max(initial(internal_volume) - 200, 0) + 200 * bin_rating
	set_power_level(power_setting)

/obj/machinery/atmospherics/unary/freezer/proc/set_power_level(var/new_power_setting)
	power_setting = new_power_setting
	power_rating = max_power_rating * (power_setting/100)

/obj/machinery/atmospherics/unary/freezer/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(panel_open)
		. += "The maintenance hatch is open."
