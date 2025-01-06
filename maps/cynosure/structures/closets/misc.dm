//Gun Cabinets

/obj/structure/closet/secure_closet/guncabinet/sidearm
	name = "emergency weapon cabinet"
	req_access = list(access_armory,access_captain)

/obj/structure/closet/secure_closet/guncabinet/sidearm/WillContain()
	return list(
		/obj/item/gun/energy/gun = 4
	)

/obj/structure/closet/secure_closet/guncabinet/rifle
	name = "rifle cabinet"
	req_access = list(
		access_explorer,
		access_brig
	)

/obj/structure/closet/secure_closet/guncabinet/rifle/WillContain()
	. = list(
		/obj/item/ammo_magazine/clip/c762/hunter = 9,
		/obj/item/gun/projectile/shotgun/pump/rifle = 2
	)
	if(prob(85))
		. += /obj/item/gun/projectile/shotgun/pump/rifle
	else
		. += /obj/item/gun/projectile/shotgun/pump/rifle/lever

/obj/structure/closet/secure_closet/guncabinet/phase
	name = "explorer weapon cabinet"
	req_access = list(access_explorer,access_brig)

/obj/structure/closet/secure_closet/guncabinet/phase/WillContain()
	return list(
		/obj/item/gun/energy/phasegun = 2,
		/obj/item/gun/energy/phasegun/pistol,
		/obj/item/cell/gun = 2,
		/obj/item/clothing/permit/gun/planetside
	)

/obj/structure/closet/secure_closet/guncabinet/tranq
	name = "tranquilizer rifle cabinet"
	req_access = list(access_xenofauna,access_medical)

/obj/structure/closet/secure_closet/guncabinet/tranq/WillContain()
	return list(
		/obj/item/gun/energy/phasegun/tranq_rifle = 2,
		/obj/item/gun/energy/phasegun/tranq_pistol,
		/obj/item/gun/energy/phasegun/pistol,
		/obj/item/cell/gun = 2,
		/obj/item/clothing/permit/gun/planetside
	)

//Explorer Lockers

/obj/structure/closet/secure_closet/explorer
	name = "explorer locker"
	req_access = list(access_explorer)
	closet_appearance = /decl/closet_appearance/secure_closet/expedition

/obj/structure/closet/secure_closet/explorer/WillContain()
	. = list(
		/obj/item/clothing/jumpsuit/explorer,
		// /obj/item/clothing/suit/armor/pcarrier/explorer/light, // todo: port explorer plate carrier
		/obj/item/clothing/suit/toggle/explorer,
		/obj/item/clothing/mask/gas/explorer,
		/obj/item/clothing/shoes/winterboots/explorer,
		/obj/item/clothing/gloves/black,
		/obj/item/radio/headset/headset_exp,
		/obj/item/flashlight,
		/obj/item/gps/explorer,
		/obj/item/box/flares,
		/obj/item/geiger,
		/obj/item/cell/device,
		/obj/item/radio,
		/obj/item/stack/flag = 3, // 30, since each is a full stack of 10
		/obj/item/cataloguer)
	if(prob(50))
		. += /obj/item/backpack/rucksack
	else
		. += /obj/item/backpack/satchel
	if(prob(75))
		. += /obj/item/bladed/knife/survival
	else
		. += /obj/item/tool/machete

//Xenofauna tech lockers
/obj/structure/closet/secure_closet/xenofauna
	name = "xenofauna technician locker"
	req_access = list(access_xenofauna)
/obj/structure/closet/secure_closet/xenofauna/WillContain()
	return list(
		/obj/item/clothing/under/xenofauna,
		/obj/item/clothing/suit/hooded/explorer/xenofauna,
		/obj/item/clothing/mask/gas/explorer,
		/obj/item/clothing/shoes/winterboots/explorer,
		/obj/item/clothing/gloves/black,
		/obj/item/clothing/suit/jacket/winter/parka/purple,
		/obj/item/radio/headset/headset_exp,
		/obj/item/flashlight,
		/obj/item/gps/xenofauna,
		/obj/item/geiger,
		/obj/item/cell/device,
		/obj/item/radio,
		/obj/item/cataloguer,
		/obj/item/backpack/satchel,
		/obj/item/bladed/knife/survival,
		/obj/item/specimen_tagger
	)

//SAR Lockers
/obj/structure/closet/secure_closet/sar
	name = "search and rescue locker"
	desc = "Supplies for a wilderness first responder."
	req_access = list(access_medical_equip)
	closet_appearance = /decl/closet_appearance/secure_closet/medical

/obj/structure/closet/secure_closet/sar/WillContain()
	return list(
		/obj/item/backpack/dufflebag/med,
		/obj/item/box/autoinjectors,
		/obj/item/box/syringes,
		/obj/item/chems/glass/bottle/stabilizer,
		/obj/item/chems/glass/bottle/antitoxin,
		/obj/item/belt/medical/emt,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/suit/jacket/winter/medical/sar,
		/obj/item/clothing/shoes/winterboots/explorer,
		/obj/item/radio/headset/headset_sar,
		/obj/item/flashlight,
		/obj/item/tank/emergency/oxygen/engi,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/scanner/health,
		/obj/item/radio/off,
		/obj/random/medical,
		/obj/item/crowbar,
		/obj/item/chems/spray/extinguisher/mini,
		/obj/item/box/freezer,
		/obj/item/clothing/webbing/vest,
		/obj/item/stack/tape_roll/barricade_tape/medical,
		/obj/item/gps,
		/obj/item/geiger,
		/obj/item/bodybag/cryobag
	)

//Cynosure Paramedic Locker
/obj/structure/closet/secure_closet/paramedic
	name = "paramedic locker"
	desc = "Supplies for a first responder."
	req_access = list(access_medical_equip)
	closet_appearance = /decl/closet_appearance/secure_closet/medical/paramedic

/obj/structure/closet/secure_closet/paramedic/WillContain()
	return list(
		/obj/item/backpack/dufflebag/med,
		/obj/item/box/autoinjectors,
		/obj/item/box/syringes,
		/obj/item/chems/glass/bottle/stabilizer,
		/obj/item/chems/glass/bottle/antitoxin,
		/obj/item/belt/medical/emt,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/suit/toggle/fr_jacket,
		/obj/item/clothing/suit/toggle/labcoat/emt,
		/obj/item/clothing/suit/jacket/winter/medical/sar,
		/obj/item/clothing/shoes/winterboots/explorer,
		/obj/item/radio/headset/headset_med/bowman,
		/obj/item/radio/headset/headset_sar,
		/obj/item/briefcase/inflatable,
		/obj/item/flashlight,
		/obj/item/tank/emergency/oxygen/engi,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/scanner/health,
		/obj/item/radio/off,
		/obj/random/medical,
		/obj/item/crowbar,
		/obj/item/chems/spray/extinguisher/mini,
		/obj/item/box/freezer,
		/obj/item/clothing/webbing/vest,
		/obj/item/stack/tape_roll/barricade_tape/medical,
		/obj/item/gps/medical,
		/obj/item/geiger,
		/obj/item/gun/energy/phasegun/pistol,
		/obj/item/cell/gun
	)

//Pilot Locker
/obj/structure/closet/secure_closet/pilot
	name = "pilot locker"
	req_access = list(access_explorer)

/obj/structure/closet/secure_closet/pilot/WillContain()
	. = list(
		/obj/item/backpack/parachute,
		/obj/item/bladed/knife/survival,
		/obj/item/clothing/head/pilot,
		/obj/item/clothing/jumpsuit/pilot/nanotrasen/blue,
		/obj/item/clothing/suit/jacket/bomber/pilot,
		/obj/item/clothing/mask/gas/half,
		/obj/item/clothing/shoes/color/black,
		/obj/item/clothing/gloves/fingerless,
		/obj/item/radio/headset/headset_exp/bowman,
		/obj/item/flashlight,
		/obj/item/food/junk/liquidfood,
		/obj/item/chems/drinks/cans/waterbottle,
		/obj/item/box/flares,
		/obj/item/cell/device,
		/obj/item/radio
	)
	if(prob(50))
		. += /obj/item/backpack
	else
		. += /obj/item/backpack/satchel

//Exotic Seeds Crate
/obj/structure/closet/crate/hydroponics/exotic
	name = "exotic seeds crate"
	desc = "All you need to destroy that pesky planet."

/obj/structure/closet/crate/hydroponics/WillContain()
	return list(
		/obj/item/seeds/random = 6,
		/obj/item/seeds/ambrosiavulgarisseed = 2,
		/obj/item/seeds/kudzuseed,
		/obj/item/seeds/libertymycelium,
		/obj/item/seeds/reishimycelium
	)
