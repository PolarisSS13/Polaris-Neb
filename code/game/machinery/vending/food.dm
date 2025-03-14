
/obj/machinery/vending/snack
	name = "Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon = 'icons/obj/machines/vending/snacks.dmi'
	vend_delay = 25
	base_type = /obj/machinery/vending/snack
	products = list(
		/obj/item/clothing/mask/chewable/candy/lolli = 8,
		/obj/item/chewables/candy/gum = 4,
		/obj/item/chewables/candy/cookies = 4,
		/obj/item/food/junk/candy = 6,
		/obj/item/chems/drinks/dry_ramen = 6,
		/obj/item/food/junk/chips = 6,
		/obj/item/food/junk/sosjerky = 6,
		/obj/item/food/junk/no_raisin = 6,
		/obj/item/food/junk/spacetwinkie = 6,
		/obj/item/food/junk/cheesiehonkers = 6,
		/obj/item/food/junk/tastybread = 6
	)
	contraband = list(
		/obj/item/food/junk/syndicake = 6
	)

//a food variant of the boda machine - It carries slavic themed foods. Mostly beer snacks
/obj/machinery/vending/snix
	name = "Snix"
	desc = "An old snack vending machine, how did it get here? And are the snacks still good?"
	vend_delay = 30
	base_type = /obj/machinery/vending/snix
	product_slogans = "Snix!"
	icon = 'icons/obj/machines/vending/snix.dmi'
	products = list(/obj/item/food/junk/semki = 7,
					/obj/item/food/can/caviar = 7,
					/obj/item/food/junk/squid = 7,
					/obj/item/food/junk/croutons = 7,
					/obj/item/food/junk/salo = 7,
					/obj/item/food/junk/driedfish = 7,
					/obj/item/food/junk/pistachios = 7,
					)

	contraband = list(/obj/item/food/can/caviar/true = 1)

/obj/machinery/vending/snix/on_update_icon()
	..()
	if(!(stat & NOPOWER))
		add_overlay("[initial(icon_state)]-fan")

/obj/machinery/vending/sol
	name = "Mars-Mart"
	desc = "A SolCentric vending machine dispensing treats from home."
	vend_delay = 30
	product_slogans = "A taste of home!"
	icon = 'icons/obj/machines/vending/solsnacks.dmi'
	products = list(
		/obj/item/food/junk/lunacake = 8,
		/obj/item/food/junk/lunacake/mochicake = 8,
		/obj/item/food/junk/lunacake/mooncake = 8,
		/obj/item/food/junk/pluto = 8,
		/obj/item/food/junk/triton = 8,
		/obj/item/food/junk/saturn = 8,
		/obj/item/food/junk/jupiter = 8,
		/obj/item/food/junk/mars = 8,
		/obj/item/food/junk/venus = 8,
		/obj/item/food/junk/oort = 8
	)

/obj/machinery/vending/weeb
	name = "Nippon-tan!"
	desc = "A distressingly ethnic vending machine loaded with high sucrose low calorie for lack of better words snacks."
	vend_delay = 30
	product_slogans = "Konnichiwa gaijin senpai! ;Notice me senpai!; Kawaii-desu!"
	icon = 'icons/obj/machines/vending/weeb.dmi'
	products = list(
		/obj/item/food/junk/weebonuts = 8,
		/obj/item/food/junk/ricecake = 8,
		/obj/item/food/junk/dango = 8,
		/obj/item/food/junk/pokey = 8,
		/obj/item/food/junk/chocobanana = 8
	)

/obj/machinery/vending/weeb/on_update_icon()
	..()
	if(!(stat & NOPOWER))
		add_overlay("[initial(icon_state)]-fan")

/obj/machinery/vending/hotfood
	name = "Hot Foods"
	desc = "An old vending machine promising 'hot foods'. You doubt any of its contents are still edible."
	vend_delay = 40
	base_type = /obj/machinery/vending/hotfood
	icon = 'icons/obj/machines/vending/hotfood.dmi'
	products = list(/obj/item/food/old/pizza = 1,
					/obj/item/food/old/burger = 1,
					/obj/item/food/old/hamburger = 1,
					/obj/item/food/old/fries = 1,
					/obj/item/food/old/hotdog = 1,
					/obj/item/food/old/taco = 1
					)

/obj/machinery/vending/hotfood/on_update_icon()
	..()
	if(!(stat & NOPOWER))
		add_overlay("[initial(icon_state)]-heater")

/obj/machinery/vending/boozeomat
	name = "Booze-O-Mat"
	desc = "A refrigerated vending unit for alcoholic beverages and alcoholic beverage accessories."
	icon = 'icons/obj/machines/vending/bar.dmi'
	markup = 0
	products = list(
		/obj/item/chems/drinks/glass2/square = 10,
		/obj/item/chems/drinks/flask/barflask = 5,
		/obj/item/chems/drinks/flask/vacuumflask = 5,
		/obj/item/chems/drinks/bottle/gin = 5,
		/obj/item/chems/drinks/bottle/whiskey = 5,
		/obj/item/chems/drinks/bottle/tequila = 5,
		/obj/item/chems/drinks/bottle/vodka = 5,
		/obj/item/chems/drinks/bottle/vermouth = 5,
		/obj/item/chems/drinks/bottle/rum = 5,
		/obj/item/chems/drinks/bottle/wine = 5,
		/obj/item/chems/drinks/bottle/cognac = 5,
		/obj/item/chems/drinks/bottle/kahlua = 5,
		/obj/item/chems/drinks/bottle/sake = 5,
		/obj/item/chems/drinks/bottle/jagermeister = 5,
		/obj/item/chems/drinks/bottle/melonliquor = 5,
		/obj/item/chems/drinks/bottle/bluecuracao = 5,
		/obj/item/chems/drinks/bottle/absinthe = 5,
		/obj/item/chems/drinks/bottle/champagne = 5,
		/obj/item/chems/drinks/bottle/herbal = 5,
		/obj/item/chems/drinks/bottle/small/beer = 15,
		/obj/item/chems/drinks/bottle/small/ale = 15,
		/obj/item/chems/drinks/bottle/small/gingerbeer = 15,
		/obj/item/chems/drinks/cans/speer = 10,
		/obj/item/chems/drinks/cans/ale = 10,
		/obj/item/chems/drinks/bottle/cola = 5,
		/obj/item/chems/drinks/bottle/space_up = 5,
		/obj/item/chems/drinks/bottle/space_mountain_wind = 5,
		/obj/item/chems/drinks/cans/beastenergy = 5,
		/obj/item/chems/drinks/tea/black = 15,
		/obj/item/chems/drinks/bottle/orangejuice = 5,
		/obj/item/chems/drinks/bottle/tomatojuice = 5,
		/obj/item/chems/drinks/bottle/limejuice = 5,
		/obj/item/chems/drinks/cans/tonic = 15,
		/obj/item/chems/drinks/bottle/cream = 5,
		/obj/item/chems/drinks/cans/sodawater = 15,
		/obj/item/chems/drinks/bottle/grenadine = 5,
		/obj/item/chems/condiment/small/mint = 2,
		/obj/item/chems/drinks/ice = 10,
		/obj/item/glass_extra/stick = 15,
		/obj/item/glass_extra/straw = 15
	)
	contraband = list(
		/obj/item/chems/drinks/bottle/premiumwine = 3,
		/obj/item/chems/drinks/bottle/premiumvodka = 3,
		/obj/item/chems/drinks/bottle/patron = 5,
		/obj/item/chems/drinks/bottle/goldschlager = 5
	)
	vend_delay = 15
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	initial_access = list(access_bar)
	base_type = /obj/machinery/vending/boozeomat


/obj/machinery/vending/coffee
	name = "Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks and hot drinks accessories."
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon = 'icons/obj/machines/vending/coffee.dmi'
	vend_delay = 34
	base_type = /obj/machinery/vending/coffee
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	vend_power_usage = 85000 //85 kJ to heat a 250 mL cup of coffee
	products = list(
		/obj/item/chems/drinks/coffee = 15,
		/obj/item/chems/drinks/tea/black = 15,
		/obj/item/chems/drinks/tea/green = 15,
		/obj/item/chems/drinks/tea/chai = 15,
		/obj/item/chems/drinks/h_chocolate = 10,
		/obj/item/chems/packet/sugar = 25,
		/obj/item/chems/pill/pod/cream = 25,
		/obj/item/chems/pill/pod/cream_soy = 25,
		/obj/item/chems/pill/pod/orange = 10,
		/obj/item/chems/pill/pod/mint = 10,
		/obj/item/chems/drinks/ice = 10
	)

/obj/machinery/vending/coffee/on_update_icon()
	..()
	if((stat & BROKEN) && prob(20))
		icon_state = "[initial(icon_state)]-hellfire"
	else if(!(stat & NOPOWER))
		add_overlay("[initial(icon_state)]-screen")

/obj/machinery/vending/cola
	name = "Robust Softdrinks"
	desc = "A soft drinks vendor provided by Robust Industries, LLC."
	icon = 'icons/obj/machines/vending/drinks.dmi'
	vend_delay = 11
	base_type = /obj/machinery/vending/cola
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not cola?;Please, have a drink!;Drink up!;The best drinks in space."
	products = list(
		/obj/item/chems/drinks/cans/cola = 10,
		/obj/item/chems/drinks/cans/space_mountain_wind = 10,
		/obj/item/chems/drinks/cans/dr_gibb = 10,
		/obj/item/chems/drinks/cans/starkist = 10,
		/obj/item/chems/drinks/cans/waterbottle = 10,
		/obj/item/chems/drinks/cans/space_up = 10,
		/obj/item/chems/drinks/cans/iced_tea = 10,
		/obj/item/chems/drinks/cans/grape_juice = 10,
		/obj/item/chems/drinks/juicebox/apple = 10,
		/obj/item/chems/drinks/juicebox/orange = 10,
		/obj/item/chems/drinks/juicebox/grape = 10
	)
	contraband = list(
		/obj/item/chems/drinks/cans/thirteenloko = 5,
		/obj/item/food/junk/liquidfood = 6
	)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.

/obj/machinery/vending/fitness
	name = "SweatMAX"
	desc = "An exercise aid and nutrition supplement vendor that preys on your inadequacy."
	product_slogans = "SweatMAX, get robust!"
	product_ads = "Pain is just weakness leaving the body!;Run! Your fat is catching up to you;Never forget leg day!;Push out!;This is the only break you get today.;Don't cry, sweat!;Healthy is an outfit that looks good on everybody."
	icon = 'icons/obj/machines/vending/fitness.dmi'
	vend_delay = 6
	base_type = /obj/machinery/vending/fitness
	products = list(
		/obj/item/chems/drinks/milk/smallcarton = 8,
		/obj/item/chems/drinks/milk/smallcarton/chocolate = 8,
		/obj/item/chems/drinks/cans/waterbottle = 8,
		/obj/item/chems/drinks/glass2/fitnessflask/proteinshake = 8,
		/obj/item/chems/drinks/glass2/fitnessflask = 8,
		/obj/item/food/junk/candy/proteinbar = 8,
		/obj/item/mre/random = 8,
		/obj/item/mre/menu9 = 4,
		/obj/item/mre/menu10 = 4,
		/obj/item/towel/random = 8
	)
	contraband = list(/obj/item/chems/syringe/steroid = 4)

/obj/machinery/vending/fitness/on_update_icon()
	..()
	if(!(stat & NOPOWER))
		add_overlay("[initial(icon_state)]-overlay")

/obj/machinery/vending/sovietsoda
	name = "BODA"
	desc = "An old soda vending machine. How could this have got here?"
	icon = 'icons/obj/machines/vending/soviet.dmi'
	base_type = /obj/machinery/vending/sovietsoda
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(
		/obj/item/chems/drinks/cans/syndicola =         8,
		/obj/item/chems/drinks/cans/syndicolax =        8,
		/obj/item/chems/drinks/cans/artbru =            8,
		/obj/item/chems/drinks/glass2/square/boda =     8,
		/obj/item/chems/drinks/glass2/square/bodaplus = 8
	)
	contraband = list(/obj/item/chems/drinks/bottle/space_up = 8) // TODO Russian cola can
	idle_power_usage = 211
