//
// Golden Crescent
//



/decl/background_detail/heritage/sif
	name = "Golden Crescent - Sivian Culture"
	uid = "heritage_sivian"
	description = "Sivians were begrudgingly absorbed into SolGov after a period of staunch independence around two centuries ago. \
	Sif's factionalized colonies subsequently unified to wage bitter - though low-intensity - undeclared warfare against corporate \
	interests from Kara that they viewed as encroaching upon the system through much of the 24th century, though with limited success. \
	However, long-time resident Sivian families still tend to hold pro-autonomy sentiments, and harbour resentment against trans-stellar \
	 corporations  - at least so far as it benefits them."
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign,
		/decl/language/human/sivian
	)

/decl/background_detail/heritage/kara
	name = "Golden Crescent - Karan Culture"
	uid = "heritage_karan"
	description = "Karans are the inhabitants of the formerly smuggler- and pirate- dominated ring of Kara, now run almost exclusively by \
	corporate interests, which has given the population a distinctly cosmopolitan bent. Today Kara is composed of the descendants of \
	several distinct migration waves, including a large positronic population, a number of different aliens, and humans from all corners \
	of Solar space. Karans are generally considered modern, forward-thinking, and technophilic, in sharp contrast with their Sivian neighbors."
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)

//
// Other Crescent
/decl/background_detail/heritage/oasis
	name = "Golden Crescent - Oasisian Culture"
	uid = "heritage_oasis"
	description = "Once a cultural-breakaway society structured around intensive Work (August-February) and Rest (March-July) Seasons, \
	coinciding with the planet's year-long day, Gilthari Exports and several Near Kingdoms investors have exploited the traditional \
	\"rest season\" into a year-round tourist pastiche extravaganza with particular focus on wealthy and skrellian clientele \
	which has all but eclipsed its foundational way of life. \
	Though the sweeping organizational differences between life during the planet's seasons have largely been de-emphasized, \
	some practices such as a unique personal name system persist outside of the tourist facade. \
	Though virtually untouched by the Incursion due to its remoteness and high degree of corporate investment, \
	Oasis has suffered economically from a recent sharp decline in long-distance interstellar tourism."


//
// Sol heritages
/decl/background_detail/heritage/earth
	name = "Core Worlds - Earth Culture"
	uid = "heritage_earth"
	description = "Though almost all exist under the Solar Confederate Government, Earth remains divided between hundreds of 'old-world' \
	nations, many of which have fragmented further since the formation of the SCG. As such, Earth remains as culturally \
	diverse as it ever has been. However, due to the percieved prestige of the homeworld, the population skews towards \
	the wealthy and sentimental, with provisions for affordable housing and services in many of Earth's wealthiest nations \
	quite lacking, and many 'lower class' service workers expected to commute from those who do provide, or habitats \
	elsewhere in the system. In recent years, a small number of Earth's nations have opted to secede from SolGov, exchanging \
	representation in the Assembly for overscrupulous autonomy, while continuing to reap the benefits of existing directly \
	within the economic core."
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)

/decl/background_detail/heritage/mars
	name = "Core Worlds - Martian Culture"
	uid = "heritage_mars"
	description = "The stereotypical Martian is sedate, laid-back, and a hard worker. \
	Mars, like Earth, is fragmented into nation-states: some corresponding to some Earthly \
	colonial venture but many others reflecting ethnocultures formed over four centuries of life on the red planet."
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)

/decl/background_detail/heritage/luna
	name = "Core Worlds - Lunar Culture"
	description = "Nearly the whole of Luna's habitat space is given over to the vast grinding bureaucracy of the Solar Confederate Government. \
	Most people work in industries supporting these bureaucracies, with the local entertainment and tourism industries being especially well-known, \
	banking on the sentimental image of Luna as the birthplace of the SCG and first small step of humanity's giant leap into extra-terrestial existence."
	uid = "heritage_luna"
	economic_power = 1.1
	subversive_potential = 0.9
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)

/decl/background_detail/heritage/venus
	name = "Core Worlds - Venusian Culture"
	uid = "heritage_venus"
	description = "Most of Venus is given way to aerostatic farm-platforms, many of which are heavily automated. \
	Venusian farmers are well-paid technicians keeping the whole ediface up-and-running, and much of the rest of the world's population caters to their needs."
	economic_power = 1.1
	subversive_potential = 0.8
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)

/decl/background_detail/heritage/titan
	name = "Core Worlds - Titanian Culture"
	uid = "heritage_titan"
	description = "Titanians frquently suffer from wanderlust, and it's hard to blame them - \
	the cold moon is entirely reliant on Sol for basic necessities,\
	and the local government is usually beholden to corporate interests."
	economic_power = 0.9
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)

// Core World - Callisto

/decl/background_detail/heritage/pluto
	name = "Core Worlds - Plutonian Culture"
	uid = "heritage_pluto"
	description = "Pluto's population is predominantly poor and Jewish, \
	holding fast to their beliefs despite the rise of Unitarianism elsewhere. \
	Corruption and ties to the Russian Mafia are common, both within Pluto's official government and within the \
	Plutonian Union of Workers that unofficially controls much of the planetoid.""
	economic_power = 0.8
	subversive_potential = 1.1
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)

//
// Alpha Centauri heritages
/decl/background_detail/heritage/kishar
	name = "Core Worlds - Kisharian Culture"
	uid = "heritage_kishar"
	description = "Kishar is the oldest extrasolar human planetary colony, located in Alpha Centauri, \
	Kishar prides itself on self-sufficiency and is split into many different countries. \
	The Kishari population is almost exclusively human and very bioconservative, \
	and its ethnic makeup slants heavily towards Romani, Native Americans, Ainu, \
	and other marginalized groups. Kishar is known for being a powerhouse of arts, \
	entertainment, tourism, and the social sciences."
	economic_power = 1.1
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)

// Core World - Anshar

/decl/background_detail/heritage/heaven
	name = "Core Worlds - Heavener Culture"
	uid = "heritage_heaven"
	description = "Heaven is the oldest human extrasolar colony, a 400-year-old orbital complex located in Alpha Centauri. \
	Heavener society features great economic inequality. The twin cylinders of Valhalla and Elysium are the poorly-lit, \
	poorly-maintained industrial hub of the colony, while the seven increasingly-wealthy rings have a much more white-collar focus. \
	Heaven is primarily populated by humans, but Valhalla and Elysium feature sizable positronic and Tajaran minorities."
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)

//
// Other star systems
/decl/background_detail/heritage/nisp
	name = "Core Worlds - Nispian Culture"
	uid = "heritage_nisp"
	description = "Nisp is a garden world known for its vast scarlet jungles and ferocious wildlife. \
	Nisp is home to one of the largest core system Skrellian populations, and was an early adopter of the Tradeband language, \
	which remains the primary vernacular language in a large number of settlements. \
	In order to defend colonies from notoriously aggressive wildlife - some large and persistent enough to pose a danger to buildings - \
	Nisp boasts an unusually large ground-based military, and a number of major PMCs and arms manufacturers maintain facilities on the surface. \
	Pharmaceutical corporations have a long history of studying Nisp's unique biosphere seeking novel applications for its diverse flora and fauna. \
	The planet is governed primarily by individual city-states, with smaller settlements typically holding SCG Protectorate status, \
	while cities with a population of at least 5 million are given seats on a planetary council that handles global concerns and international diplomacy."
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
		//tradeband
	)

/decl/background_detail/heritage/binma
	name = "Core Worlds - Binmasian Culture"
	uid = "heritage_binma"
	description = "Binma's system-wide government, the United Binmasian Conglomerate, represents more individual citizens than any other SolGov member state, \
	giving it an outsided influence in the legislature tempered by the system's traditional isolationalism and \
	the recent loss of public confidence in their massive stock exchange after an emergent drone attack in 2559."
	economic_power = 1.1
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)

/decl/background_detail/heritage/altair
	name = "Core Worlds - Altairian Culture"
	uid = "heritage_altair"
	description = "Home to the Solar Confederate Government's primary maximum security correctional facility for confederation-level criminals, and very little else. \
	Residents of the system are invariably associated with the operation of the notorious \"Altair Stack\".\
	Life in Altair is one lived under constant police scrutiny, \
	and those who do not mesh with the highly authoritarian environment tend not to stick around long by choice. \
	The <i>inmates</i> of the Stack tend not to be from the system's own cultural background, with rare exception."
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)


/decl/background_detail/heritage/coreworlds
	name = "Core Worlds - Other Culture"
	uid = "heritage_coreworlds"
	description = "The Core Worlds are densely populated and heavily developed, most relying on imports from \
	other Solar member states to fuel their economy. The culture of the Core heavily influences the rest of Solar \
	society by way of media, painting the Core as glamorous, cosmopolitan... and largely biological human."
	economic_power = 1.1
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/solcom,
		/decl/language/sign
	)






/decl/background_detail/heritage/sdcu
	name = "Saint Columbia Democratic Union, Saint Columbia"
	uid = "heritage_sdcu"

	economic_power = 0.8
	subversive_potential = 1.2


/decl/background_detail/heritage/iserlohnrepublic
	name = "Iserlohn Republic, Saint Columbia"
	uid = "heritage_iserlohnrepublic"

	economic_power = 0.9
	subversive_potential = 0.9

/decl/background_detail/heritage/goldencrescent
	name = "Golden Crescent"
	uid = "heritage_goldencrescent"


//
// Sagittarius Heights
//

//
// New Ohio
/decl/background_detail/heritage/franklin
	name = "Franklin, New Ohio"
	uid = "heritage_franklin"

	subversive_potential = 0.9


/decl/background_detail/heritage/wright
	name = "Wright, New Ohio"
	uid = "heritage_wright"
	economic_power = 0.7 //super space detroit. maybe it should be 0.8 or 0.75? I am overthinking it.


//
// Five Arrows
/decl/background_detail/heritage/sidhe
	uid = "heritage_sidhe"
	name = "Sidhe"

	economic_power = 0.7
	subversive_potential = 1.1


/decl/background_detail/heritage/mahimahi
	uid = "heritage_mahimahi"
	name = "Mahi-Mahi, Mahi Mahi"  //dash space



//New Seoul goes here
//22

//Parvati goes here

/decl/background_detail/heritage/kauqxum
	uid = "heritage_kauqxum"
	name = "Sagittarius Heights - Kauq'xum"



/decl/background_detail/heritage/sagitheights
	uid = "heritage_sagitheights"
	name = "Sagittarius Heights"

	economic_modifier = 1.1

//
// The Bowl
//

/decl/background_detail/heritage/love
	uid = "heritage_love"
	name = "Love, The Bowl" //sure thing

	subversive_potential = 1.2

//
// Almach Rim
//

/decl/background_detail/heritage/relan
	uid = "heritage_relan"
	name = "Relan"

	economic_power = 0.8
	subversive_potential = 1.1 // they're considered the Least Bad almachi now

/decl/background_detail/heritage/taron
	uid = "heritage_taron"
	name = "Taron, Relan"

	economic_power = 0.7
	subversive_potential = 1.1

/decl/background_detail/heritage/angessaspearl
	uid = "heritage_angessaspearl"
	name = "Angessa's Pearl, Exalt's Light"

	economic_power = 0.7
	subversive_potential = 1.3 //the Most Bad almachi now

/decl/background_detail/heritage/vounna
	uid = "heritage_vounna"
	name = "Vounna"

	economic_power = 0.6 // It's difficult to be prosperous when your previous government committed warcrimes, and also spent most of their time scrambling to back their word.
	subversive_potential = 1.2

/decl/background_detail/heritage/shelf
	uid = "heritage_shelf"
	name = "Shelf, Deep Space" //it's not on the rim anymore and this is information about how places are

	economic_power = 0.8 //never forget that shelf's broke
	subversive_potential = 1.2



/decl/background_detail/heritage/deep_space
	name = "Deep Space"
	uid = "heritage_space"
	description = "You came from the void between the stars."
	language =         null
	secondary_langs =  null
	additional_langs = null
	economic_power =   null
