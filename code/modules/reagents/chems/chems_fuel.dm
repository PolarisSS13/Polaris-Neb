/decl/material/liquid/fuel
	name = "welding fuel"
	lore_text = "A stable hydrazine-based compound whose exact manufacturing specifications are a closely-guarded secret. One of the most common fuels in human space. Extremely flammable."
	taste_description = "gross metal"
	color = "#660000"
	touch_met = 5
	ignition_point = T0C+150
	accelerant_value = FUEL_VALUE_ACCELERANT + 0.2
	burn_product = /decl/material/gas/carbon_monoxide
	gas_flags = XGM_GAS_FUEL
	exoplanet_rarity_plant = MAT_RARITY_UNCOMMON
	exoplanet_rarity_gas = MAT_RARITY_UNCOMMON
	uid = "chem_fuel"
	toxicity = 2

	glass_name = "welder fuel"
	glass_desc = "Unless you are an industrial tool, this is probably not safe for consumption."
	value = 1.5

/decl/material/liquid/fuel/explosion_act(obj/item/chems/holder, severity)
	. = ..()
	if(.)
		var/volume = REAGENT_VOLUME(holder?.reagents, type)
		if(volume <= 50)
			return
		var/turf/T = get_turf(holder)
		var/datum/gas_mixture/products = new(_temperature = 5 * FLAMMABLE_GAS_FLASHPOINT)
		var/gas_moles = 3 * volume
		products.adjust_multi(/decl/material/gas/nitricoxide, 0.1 * gas_moles, /decl/material/gas/nitrodioxide, 0.1 * gas_moles, /decl/material/gas/nitrogen, 0.6 * gas_moles, /decl/material/gas/hydrogen, 0.02 * gas_moles)
		T.assume_air(products)
		if(volume > 500)
			explosion(T,1,2,4)
		else if(volume > 100)
			explosion(T,0,1,3)
		else if(volume > 50)
			explosion(T,-1,1,2)
		holder?.reagents?.remove_reagent(type, volume)

/decl/material/liquid/fuel/hydrazine
	name = "hydrazine"
	lore_text = "A toxic, colorless, flammable liquid with a strong ammonia-like odour, in hydrate form."
	taste_description = "sweet tasting metal"
	color = "#808080"
	metabolism = REM * 0.2
	touch_met = 5
	value = 1.2
	accelerant_value = FUEL_VALUE_ACCELERANT + 0.5
	uid = "chem_hydrazine"
