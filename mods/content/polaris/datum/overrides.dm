//Species

/decl/species
	available_background_info = list(
		/decl/background_category/citizenship = list(
			/decl/background_detail/citizenship/scg,
			/decl/background_detail/citizenship/fivearrows,
			/decl/background_detail/citizenship/almach,
			/decl/background_detail/citizenship/earthnation,
			/decl/background_detail/citizenship/stateless
		),
		/decl/background_category/faction =   list(
			/decl/background_detail/faction/nanotrasen,
			/decl/background_detail/faction/contractor,
			/decl/background_detail/faction/shadow_coalition,
			/decl/background_detail/faction/icarus_front,
			/decl/background_detail/faction/galactic_autonomy_party,
			/decl/background_detail/faction/sol_economic_org,
			/decl/background_detail/faction/mercurial,
			/decl/background_detail/faction/solgov,
			/decl/background_detail/faction/virgov,
			/decl/background_detail/faction/almach_protectorate,
			/decl/background_detail/faction/fivearrows,
			/decl/background_detail/faction/nosamis,
			/decl/background_detail/faction/rusmob,
			/decl/background_detail/faction/sampatti,
			/decl/background_detail/faction/xin_cohong,
			/decl/background_detail/faction/goldentiger,
			/decl/background_detail/faction/jaguar,
			/decl/background_detail/faction/revsol_peoples_party,
			/decl/background_detail/faction/other
		),
		/decl/background_category/heritage =   list(
			/decl/background_detail/heritage/earth,
			/decl/background_detail/heritage/mars,
			/decl/background_detail/heritage/luna,
			/decl/background_detail/heritage/venus,
			/decl/background_detail/heritage/titan,
			/decl/background_detail/heritage/pluto,
			/decl/background_detail/heritage/kishar,
			/decl/background_detail/heritage/heaven,
			/decl/background_detail/heritage/nisp,
			/decl/background_detail/heritage/binma,
			/decl/background_detail/heritage/altair,
			/decl/background_detail/heritage/coreworlds,
			/decl/background_detail/heritage/sif,
			/decl/background_detail/heritage/kara,
			/decl/background_detail/heritage/oasis,
			/decl/background_detail/heritage/sdcu,
			/decl/background_detail/heritage/iserlohnrepublic,
			/decl/background_detail/heritage/goldencrescent,
			/decl/background_detail/heritage/franklin,
			/decl/background_detail/heritage/wright,
			/decl/background_detail/heritage/sidhe,
			/decl/background_detail/heritage/mahimahi,
			/decl/background_detail/heritage/kauqxum,
			/decl/background_detail/heritage/sagitheights,
			/decl/background_detail/heritage/love,
			/decl/background_detail/heritage/bowl,
			/decl/background_detail/heritage/relan,
			/decl/background_detail/heritage/taron,
			/decl/background_detail/heritage/angessaspearl,
			/decl/background_detail/heritage/vounna,
			/decl/background_detail/heritage/shelf,
			/decl/background_detail/heritage/neonlight,
			/decl/background_detail/heritage/el,
			/decl/background_detail/heritage/raphael,
			/decl/background_detail/heritage/terminus,
			/decl/background_detail/heritage/nyx,
			/decl/background_detail/heritage/crypt,
			/decl/background_detail/heritage/eutopia,
			/decl/background_detail/heritage/casini,
			/decl/background_detail/heritage/natuna,
			/decl/background_detail/heritage/seccesionist,
			/decl/background_detail/heritage/frontier,
			/decl/background_detail/heritage/freetrader,
			/decl/background_detail/heritage/deep_space
		),
		/decl/background_category/religion =  list(
			/decl/background_detail/religion/no_religion,
			/decl/background_detail/religion/neopagan,
			/decl/background_detail/religion/unitarian,
			/decl/background_detail/religion/phactshinto,
			/decl/background_detail/religion/oldearth_faiths,
			/decl/background_detail/religion/kishari,
			/decl/background_detail/religion/pleromanism,
			/decl/background_detail/religion/spectralism,
			/decl/background_detail/religion/hauler_traditions,
			/decl/background_detail/religion/singulitarian_worship,
			/decl/background_detail/religion/the_starlit_path_of_angessa_martei,
			/decl/background_detail/religion/other
			)
	)

	default_background_info = list(
		/decl/background_category/citizenship = /decl/background_detail/citizenship/scg,
		/decl/background_category/faction   = /decl/background_detail/faction/nanotrasen,
		/decl/background_category/heritage   = /decl/background_detail/heritage/sif,
		/decl/background_category/religion  = /decl/background_detail/religion/other
	)


/datum/appearance_descriptor/age/polaris_human
	name = "age"
	chargen_max_index = 9
	standalone_value_descriptors = list(
		"an infant" =      1,
		"a toddler" =      3,
		"a child" =        7,
		"a teenager" =    12,
		"a young adult" = 17,
		"an adult" =      28,
		"middle-aged" =   45,
		"aging" =         65,
		"elderly" =       90,
		"ancient" =      110
	)

/decl/bodytype
	age_descriptor = /datum/appearance_descriptor/age/polaris_human

//Humans get New Kyoto and Vystholm cultures
/decl/species/human
	description = "Humanity originated in the Sol system, \
	and over the last five centuries have spread colonies across a wide swathe of space. \
	They hold a wide range of beliefs and creeds.<br/><br/> \
	While the Sol-based Solar Confederate Government governs over most of their far-ranging populations, \
	powerful corporate interests, fledgling splinter states, rampant cyber and bio-augmentation, \
	and secretive factions make life on most human worlds a tumultuous affair."
	available_background_info = list(
		/decl/background_category/citizenship = list(
			/decl/background_detail/citizenship/scg,
			/decl/background_detail/citizenship/fivearrows,
			/decl/background_detail/citizenship/almach,
			/decl/background_detail/citizenship/earthnation,
			/decl/background_detail/citizenship/stateless
		),
		/decl/background_category/faction =   list(
			/decl/background_detail/faction/nanotrasen,
			/decl/background_detail/faction/contractor,
			/decl/background_detail/faction/shadow_coalition,
			/decl/background_detail/faction/icarus_front,
			/decl/background_detail/faction/galactic_autonomy_party,
			/decl/background_detail/faction/sol_economic_org,
			/decl/background_detail/faction/mercurial,
			/decl/background_detail/faction/solgov,
			/decl/background_detail/faction/virgov,
			/decl/background_detail/faction/almach_protectorate,
			/decl/background_detail/faction/fivearrows,
			/decl/background_detail/faction/nosamis,
			/decl/background_detail/faction/rusmob,
			/decl/background_detail/faction/sampatti,
			/decl/background_detail/faction/xin_cohong,
			/decl/background_detail/faction/goldentiger,
			/decl/background_detail/faction/jaguar,
			/decl/background_detail/faction/revsol_peoples_party,
			/decl/background_detail/faction/other
		),
		/decl/background_category/heritage =   list(
			/decl/background_detail/heritage/earth,
			/decl/background_detail/heritage/mars,
			/decl/background_detail/heritage/luna,
			/decl/background_detail/heritage/venus,
			/decl/background_detail/heritage/titan,
			/decl/background_detail/heritage/pluto,
			/decl/background_detail/heritage/kishar,
			/decl/background_detail/heritage/heaven,
			/decl/background_detail/heritage/nisp,
			/decl/background_detail/heritage/binma,
			/decl/background_detail/heritage/altair,
			/decl/background_detail/heritage/coreworlds,
			/decl/background_detail/heritage/sif,
			/decl/background_detail/heritage/kara,
			/decl/background_detail/heritage/oasis,
			/decl/background_detail/heritage/sdcu,
			/decl/background_detail/heritage/iserlohnrepublic,
			/decl/background_detail/heritage/goldencrescent,
			/decl/background_detail/heritage/franklin,
			/decl/background_detail/heritage/wright,
			/decl/background_detail/heritage/sidhe,
			/decl/background_detail/heritage/mahimahi,
			/decl/background_detail/heritage/kauqxum,
			/decl/background_detail/heritage/sagitheights,
			/decl/background_detail/heritage/love,
			/decl/background_detail/heritage/bowl,
			/decl/background_detail/heritage/relan,
			/decl/background_detail/heritage/taron,
			/decl/background_detail/heritage/angessaspearl,
			/decl/background_detail/heritage/vounna,
			/decl/background_detail/heritage/shelf,
			/decl/background_detail/heritage/neonlight,
			/decl/background_detail/heritage/el,
			/decl/background_detail/heritage/raphael,
			/decl/background_detail/heritage/terminus,
			/decl/background_detail/heritage/nyx,
			/decl/background_detail/heritage/crypt,
			/decl/background_detail/heritage/eutopia,
			/decl/background_detail/heritage/casini,
			/decl/background_detail/heritage/natuna,
			/decl/background_detail/heritage/newkyoto,
			/decl/background_detail/heritage/seccesionist,
			/decl/background_detail/heritage/frontier,
			/decl/background_detail/heritage/freetrader,
			/decl/background_detail/heritage/deep_space
		),
		/decl/background_category/religion =  list(
			/decl/background_detail/religion/no_religion,
			/decl/background_detail/religion/neopagan,
			/decl/background_detail/religion/unitarian,
			/decl/background_detail/religion/phactshinto,
			/decl/background_detail/religion/oldearth_faiths,
			/decl/background_detail/religion/kishari,
			/decl/background_detail/religion/pleromanism,
			/decl/background_detail/religion/spectralism,
			/decl/background_detail/religion/hauler_traditions,
			/decl/background_detail/religion/singulitarian_worship,
			/decl/background_detail/religion/the_starlit_path_of_angessa_martei,
			/decl/background_detail/religion/other
			)
	)

	default_background_info = list(
		/decl/background_category/citizenship = /decl/background_detail/citizenship/scg,
		/decl/background_category/faction   = /decl/background_detail/faction/nanotrasen,
		/decl/background_category/heritage   = /decl/background_detail/heritage/sif,
		/decl/background_category/religion  = /decl/background_detail/religion/other
	)

//Loadout

/decl/loadout_option/uniform/dress_selection
	name = "dress selection (short)"
	description = "A selection of dresses above knee length."
	path = /obj/item/clothing/dress/blackcorset

/decl/loadout_option/uniform/dress_selection/get_gear_tweak_options()
	. = ..()
	LAZYINITLIST(.[/datum/gear_tweak/path/specified_types_list])
	.[/datum/gear_tweak/path/specified_types_list] |= list(
		/obj/item/clothing/dress/blackcorset,
		/obj/item/clothing/dress/cropdress,
		/obj/item/clothing/dress/cropsweater,
		/obj/item/clothing/dress,
		/obj/item/clothing/dress/blue,
		/obj/item/clothing/dress/green,
		/obj/item/clothing/dress/orange,
		/obj/item/clothing/dress/pink,
		/obj/item/clothing/dress/purple,
		/obj/item/clothing/dress/gold,
		/obj/item/clothing/dress/littleblack,
		/obj/item/clothing/dress/pentagram,
		/obj/item/clothing/dress/polkadot,
		/obj/item/clothing/dress/sailor,
		/obj/item/clothing/dress/striped,
		/obj/item/clothing/dress/sun,
		/obj/item/clothing/dress/sun/white,
		/obj/item/clothing/dress/tango,
		/obj/item/clothing/dress/twistfront,
		/obj/item/clothing/dress/tutu,
		/obj/item/clothing/dress/twopiece,
		/obj/item/clothing/dress/vneck
	)

/decl/loadout_option/uniform/suit
	name = "suit selection"
	description = "A selection of non-modular suits."

/decl/loadout_option/uniform/dress_simple
	name = "dress selection (colour select)"
	path = /obj/item/clothing/dress/colourable
	loadout_flags = (GEAR_HAS_COLOR_SELECTION | GEAR_HAS_TYPE_SELECTION)


//They get the vatcult background.
/decl/species/human/vatborn
	available_background_info = list(
		/decl/background_category/citizenship = list(
			/decl/background_detail/citizenship/scg,
			/decl/background_detail/citizenship/fivearrows,
			/decl/background_detail/citizenship/almach,
			/decl/background_detail/citizenship/earthnation,
			/decl/background_detail/citizenship/stateless
		),
		/decl/background_category/faction =   list(
			/decl/background_detail/faction/nanotrasen,
			/decl/background_detail/faction/contractor,
			/decl/background_detail/faction/shadow_coalition,
			/decl/background_detail/faction/icarus_front,
			/decl/background_detail/faction/galactic_autonomy_party,
			/decl/background_detail/faction/sol_economic_org,
			/decl/background_detail/faction/mercurial,
			/decl/background_detail/faction/solgov,
			/decl/background_detail/faction/virgov,
			/decl/background_detail/faction/almach_protectorate,
			/decl/background_detail/faction/fivearrows,
			/decl/background_detail/faction/nosamis,
			/decl/background_detail/faction/rusmob,
			/decl/background_detail/faction/sampatti,
			/decl/background_detail/faction/xin_cohong,
			/decl/background_detail/faction/goldentiger,
			/decl/background_detail/faction/jaguar,
			/decl/background_detail/faction/revsol_peoples_party,
			/decl/background_detail/faction/other
		),
		/decl/background_category/heritage =   list(
			/decl/background_detail/heritage/earth,
			/decl/background_detail/heritage/mars,
			/decl/background_detail/heritage/luna,
			/decl/background_detail/heritage/venus,
			/decl/background_detail/heritage/titan,
			/decl/background_detail/heritage/pluto,
			/decl/background_detail/heritage/kishar,
			/decl/background_detail/heritage/heaven,
			/decl/background_detail/heritage/nisp,
			/decl/background_detail/heritage/binma,
			/decl/background_detail/heritage/altair,
			/decl/background_detail/heritage/coreworlds,
			/decl/background_detail/heritage/sif,
			/decl/background_detail/heritage/kara,
			/decl/background_detail/heritage/oasis,
			/decl/background_detail/heritage/sdcu,
			/decl/background_detail/heritage/iserlohnrepublic,
			/decl/background_detail/heritage/goldencrescent,
			/decl/background_detail/heritage/franklin,
			/decl/background_detail/heritage/wright,
			/decl/background_detail/heritage/sidhe,
			/decl/background_detail/heritage/mahimahi,
			/decl/background_detail/heritage/kauqxum,
			/decl/background_detail/heritage/sagitheights,
			/decl/background_detail/heritage/love,
			/decl/background_detail/heritage/bowl,
			/decl/background_detail/heritage/relan,
			/decl/background_detail/heritage/taron,
			/decl/background_detail/heritage/angessaspearl,
			/decl/background_detail/heritage/vounna,
			/decl/background_detail/heritage/shelf,
			/decl/background_detail/heritage/neonlight,
			/decl/background_detail/heritage/el,
			/decl/background_detail/heritage/raphael,
			/decl/background_detail/heritage/terminus,
			/decl/background_detail/heritage/nyx,
			/decl/background_detail/heritage/crypt,
			/decl/background_detail/heritage/eutopia,
			/decl/background_detail/heritage/casini,
			/decl/background_detail/heritage/natuna,
			/decl/background_detail/heritage/vatcult,
			/decl/background_detail/heritage/seccesionist,
			/decl/background_detail/heritage/frontier,
			/decl/background_detail/heritage/freetrader,
			/decl/background_detail/heritage/deep_space
		),
		/decl/background_category/religion =  list(
			/decl/background_detail/religion/no_religion,
			/decl/background_detail/religion/neopagan,
			/decl/background_detail/religion/unitarian,
			/decl/background_detail/religion/phactshinto,
			/decl/background_detail/religion/oldearth_faiths,
			/decl/background_detail/religion/kishari,
			/decl/background_detail/religion/pleromanism,
			/decl/background_detail/religion/spectralism,
			/decl/background_detail/religion/hauler_traditions,
			/decl/background_detail/religion/singulitarian_worship,
			/decl/background_detail/religion/the_starlit_path_of_angessa_martei,
			/decl/background_detail/religion/other
			)
	)

	default_background_info = list(
		/decl/background_category/citizenship = /decl/background_detail/citizenship/scg,
		/decl/background_category/faction   = /decl/background_detail/faction/nanotrasen,
		/decl/background_category/heritage   = /decl/background_detail/heritage/sif,
		/decl/background_category/religion  = /decl/background_detail/religion/other
	)