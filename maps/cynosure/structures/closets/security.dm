/obj/structure/closet/secure_closet/hos/cynosure
	name = "head of security's locker"
	req_access = list(access_hos)
	storage_capacity = 2.6 * MOB_SIZE_MEDIUM
	closet_appearance = /decl/closet_appearance/secure_closet/security/hos

/obj/structure/closet/secure_closet/hos/cynosure/WillContain()
	. = list(
		/obj/item/clothing/head/helmet/HoS,
		/obj/item/clothing/head/helmet/HoS/cap,
		/obj/item/clothing/suit/armor/pcarrier/light/nt/cynosure,
		/obj/item/clothing/under/rank/head_of_security/jensen,
		/obj/item/clothing/under/rank/head_of_security/corp,
		/obj/item/clothing/suit/vest/hoscoat/jensen,
		/obj/item/clothing/suit/vest/hoscoat,
		/obj/item/clothing/head/helmet/dermal,
		/obj/item/cartridge/hos,
		/obj/item/radio/headset/heads/hos,
		/obj/item/radio/headset/heads/hos/alt,
		/obj/item/clothing/glasses/sunglasses/sechud,
		/obj/item/taperoll/police,
		/obj/item/shield/riot/tele,
		/obj/item/box/holobadge/hos,
		/obj/item/clothing/medal/badge/holo/hos,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/crowbar/red,
		/obj/item/box/flashbangs,
		/obj/item/belt/security,
		/obj/item/flash,
		/obj/item/baton/loaded,
		/obj/item/gun/energy/gun,
		/obj/item/cell/device/weapon,
		/obj/item/clothing/webbing/holster/waist,
		/obj/item/telebaton,
		/obj/item/clothing/head/beret/sec/corporate/hos,
		/obj/item/clothing/suit/jacket/winter/security/hos,
		/obj/item/clothing/shoes/winterboots/security,
		/obj/item/flashlight/maglight,
		/obj/item/clothing/mask/gas/half,
		/obj/item/clothing/mask/gas/sechailer/swat/hos,
		/obj/item/clothing/black_vest
	)
	if(prob(50))
		. += /obj/item/backpack/security
	else
		. += /obj/item/backpack/satchel/sec
	if(prob(50))
		. += /obj/item/backpack/dufflebag/sec


/obj/structure/closet/secure_closet/warden/cynosure
	name = "warden's locker"
	storage_capacity = 42
	req_access = list(access_armory)
	closet_appearance = /decl/closet_appearance/secure_closet/security/warden

/obj/structure/closet/secure_closet/warden/cynosure/WillContain()
	. = list(
		/obj/item/clothing/suit/armor/pcarrier/light/nt/cynosure,
		/obj/item/clothing/under/rank/warden,
		/obj/item/clothing/under/rank/warden/corp,
		/obj/item/clothing/suit/vest/wardencoat,
		/obj/item/clothing/suit/vest/wardencoat/alt,
		/obj/item/clothing/head/helmet/dermal,
		/obj/item/clothing/head/helmet/warden,
		/obj/item/clothing/head/helmet/warden/hat,
		/obj/item/cartridge/security,
		/obj/item/radio/headset/sec,
		/obj/item/radio/headset/sec/alt,
		/obj/item/clothing/glasses/sunglasses/sechud,
		/obj/item/taperoll/police,
		/obj/item/clothing/medal/badge/holo/warden,
		/obj/item/box/flashbangs,
		/obj/item/belt/security,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/baton/loaded,
		/obj/item/gun/energy/gun,
		/obj/item/cell/device/weapon,
		/obj/item/box/holobadge,
		/obj/item/clothing/head/beret/sec/corporate/warden,
		/obj/item/clothing/suit/jacket/winter/security,
		/obj/item/clothing/shoes/winterboots/security,
		/obj/item/flashlight/maglight,
		/obj/item/megaphone,
		/obj/item/clothing/mask/gas/half,
		/obj/item/clothing/mask/gas/sechailer/swat/warden
	)
	if(prob(50))
		. += /obj/item/backpack/security
	else
		. += /obj/item/backpack/satchel/sec
	if(prob(50))
		. += /obj/item/backpack/dufflebag/sec

/obj/structure/closet/secure_closet/security/cynosure
	name = "security officer's locker"
	req_access = list(access_brig)
	closet_appearance = /decl/closet_appearance/secure_closet/security

/obj/structure/closet/secure_closet/security/cynosure/WillContain()
	. = list(
		/obj/item/clothing/suit/armor/pcarrier/light/nt/cynosure,
		/obj/item/clothing/head/helmet,
		/obj/item/cartridge/security,
		/obj/item/radio/headset/sec,
		/obj/item/radio/headset/sec/alt,
		/obj/item/belt/security,
		/obj/item/flash,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/grenade/flashbang,
		/obj/item/baton/loaded,
		/obj/item/clothing/glasses/sunglasses/sechud,
		/obj/item/taperoll/police,
		/obj/item/hailer,
		/obj/item/flashlight/flare,
		/obj/item/clothing/black_vest,
		/obj/item/clothing/head/soft/sec/corp,
		/obj/item/clothing/under/rank/security/corp,
		/obj/item/ammo_magazine/m45/rubber,
		/obj/item/gun/energy/taser,
		/obj/item/cell/device/weapon,
		/obj/item/clothing/suit/jacket/winter/security,
		/obj/item/clothing/shoes/winterboots/security,
		/obj/item/flashlight/maglight
	)
	if(prob(50))
		. += /obj/item/backpack/security
	else
		. += /obj/item/backpack/satchel/sec
	if(prob(50))
		. += /obj/item/backpack/dufflebag/sec

/obj/structure/closet/secure_closet/security/cargo/WillContain()
	. = ..()
	. += /obj/item/clothing/armband/cargo
	. += /obj/item/encryptionkey/cargo

/obj/structure/closet/secure_closet/security/engine/WillContain()
	. = ..()
	. += /obj/item/clothing/armband/engine
	. += /obj/item/encryptionkey/eng

/obj/structure/closet/secure_closet/security/science/WillContain()
	. = ..()
	. += /obj/item/clothing/armband/science
	. += /obj/item/encryptionkey/sci

/obj/structure/closet/secure_closet/security/med/WillContain()
	. = ..()
	. += /obj/item/clothing/armband/medblue
	. += /obj/item/encryptionkey/med

/obj/structure/closet/secure_closet/detective/cynosure
	name = "detective's cabinet"
	req_access = list(access_forensics_lockers)
	closet_appearance = /decl/closet_appearance/cabinet/secure

/obj/structure/closet/secure_closet/detective/cynosure/WillContain()
	. = list(
		/obj/item/clothing/medal/badge/holo/detective,
		/obj/item/clothing/gloves/black,
		/obj/item/gunbox,
		/obj/item/belt/detective,
		/obj/item/box/evidence,
		/obj/item/radio/headset/sec,
		/obj/item/radio/headset/sec/alt,
		/obj/item/clothing/suit/vest/detective,
		/obj/item/taperoll/police,
		/obj/item/clothing/webbing/holster/armpit,
		/obj/item/flashlight/maglight,
		/obj/item/reagent_containers/food/drinks/flask/detflask,
		/obj/item/briefcase/crimekit,
		/obj/item/taperecorder,
		/obj/item/bag/detective,
		/obj/item/magnetic_tape/random = 3
	)
