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
	Plutonian Union of Workers that unofficially controls much of the planetoid."
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
	name = "Golden Crescent - Saint-Columbian Culture"
	uid = "heritage_sdcu"
	description = "The habitats of the Saint Columbia system have three times seceded from SolGov; \
	twice in the 23rd century and once just over a decade ago. Now under combined civilian-military control since \
	the end of the Almach war ten years ago, opinions within the colony are now split between \
	supporters of the charismatic leader of the new government, \
	and pro-tech anti-war socialists loyal to the failed revolutions."
	economic_power = 0.8
	subversive_potential = 1.2


/decl/background_detail/heritage/iserlohnrepublic
	name = "Golden Crescent - Iserlohner Culture"
	uid = "heritage_iserlohnrepublic"
	description = "During the seccesion of the Saint Columbia during the Almach War, \
	the civilian population of the enormous Saint Columbia Fleet Base broke away from the \
	system's government and declared themselves the independent Iserlohn Republic loyal to SolGov. \
	Iserlohn's population is large for a fleet base but tiny for a state, \
	and is composed primarily of the families of service personnel and those immediately involved in military industries. \
	Iserlohners tend to be conservative, patriotic, and are predictably staunch supporters of the armed forces."
	economic_power = 0.9
	subversive_potential = 0.9

/decl/background_detail/heritage/goldencrescent
	name = "Golden Crescent - Other Culture"
	description = "The Golden Crescent is a cultural region containing Vir and many of its neighbors. \
	Crescenti people are rugged and self-reliant, and the region has an eclectic and cosmopolitan culture from \
	centuries of welcoming alien and positronic migrants and refugees. Many of the systems within the Golden Crescent \
	seceded during the 23rd century before being absorbed back into SolGov, and they maintain a strong independent streak."
	uid = "heritage_goldencrescent"


//
// Sagittarius Heights
//

//
// New Ohio
/decl/background_detail/heritage/franklin
	name = "Sagittarius Heights - Frankliner Culture"
	uid = "heritage_franklin"
	description = "The jewel of New Ohio and the gateway to the Sagittarius Heights, Franklin is known for three things: \
	Tourism, aquaculture, and hosting the Sagittarius branch office of many a trans-stellar corporation. \
	Franklin's cities are a cosmopolitan mix, with significant skrell and teshari populations, \
	while its vast oceans are home to a number of sailors and mariners, recreational and professional."
	subversive_potential = 0.9


/decl/background_detail/heritage/wright
	name = "Sagittarius Heights - Wright Culture"
	description = "Formerly the industrial hub of New Ohio and a major exporter to the whole of the Sagittarius Heights, \
	Wright is now a shell of its former self. Wright is dominated by a Ward-Takahashi voter farm, \
	and its human population mainly consists of middle-management for what corporate concerns remain \
	and personnel from the New Ohio Fleet Base. Many have left Wright in recent years looking for better fortunes, \
	expecting them just about anywhere else in the galaxy."
	uid = "heritage_wright"
	economic_power = 0.7 //super space detroit. maybe it should be 0.8 or 0.75? I am overthinking it.


//
// Five Arrows
/decl/background_detail/heritage/sidhe
	uid = "heritage_sidhe"
	name = "Five Arrows - Sidhian Culture"
	description = "Sidhe hosts an eclectic mix of humans, skrell, and positronics, \
	co-existing in uneasy harmony for hundreds of years. The system saw a popular revolution and seceeded from SolGov alongside the rest of the Five Arrows. \
	Today, Sidhe is seen as one of the Five Arrows' most militant supporters and as a case study in human-skrellian cultural integration. "
	economic_power = 0.7 //Huh?
	subversive_potential = 1.1


/decl/background_detail/heritage/mahimahi
	uid = "heritage_mahimahi"
	name = "Five Arrows - Mahi Mahi Culture"  //dash space
	description = "A planet split into two distinct spheres of power, Mahi-Mahi hosts an ongoing struggle between \
	the dichotomous interests of its metropolitan centres and their surrounding rural populations. \
	The cities, using their economic and political power from their bygone colonial era, curry favour with corporate and foreign interests, \
	seeking investment for their research and cultural programmes. The rural townships and greenhouse compounds that dot the \
	surrounding continents have continuously chafed under the control of their capitals, believing that the technology and \
	cashflow that trickles out of the cities to be insufficient recompense for the dangerous environment and animal life that \
	they contend with regularly."


//New Seoul goes here
//22

//Parvati goes here

/decl/background_detail/heritage/kauqxum
	uid = "heritage_kauqxum"
	name = "Sagittarius Heights - Kauq'xum Culture"
	description = "Sandwiched between the prosperity of the Skrellian Interior and the human Sagittarius Heights, \
	the border systems have enjoyed heavy commerce as goods and people come and go across the border. \
	These systems have the highest human and positronic populations in Skrellian territory, \
	and their political structures aren't quite as steadfastly Monarchic, \
	with elected parliaments of Qerr-Koal -the advisors to the ruling Qerr-Katish- uncommon, but not unheard of."


/decl/background_detail/heritage/sagitheights
	uid = "heritage_sagitheights"
	name = "Sagittarius Heights - Other Culture"
	description = "The Sagittarius Heights have long benefitted from extensive trade and cultural exchange with Skrellian business interests, \
	and their position as some of the most wealthy and economically independent states in the human cultural sphere came to head when \
	much of the region split from SolGov to form the Five Arrows. Sagittarian culture is perhaps most typified by its blending of Solar and \
	Skrellian cultures, including the adoption of Tradeband as its official language, and while its residents are often stereotyped as arrogant, \
	wealthy, and snobbish, the truth is that the average Sagitarrian is a miner or farmer whose living conditions differ little from those anywhere in Solar space."
	economic_power = 1.1
//
// The Bowl
//

/decl/background_detail/heritage/love
	uid = "heritage_love"
	name = "The Bowl - Love Culture" //sure thing
	description = "Love is the wealthiest system in the Bowl, with a marginally habitable world and \
	generous social welfare programs that prevent Love from sucumbing to the same economic degeneration that plagues the rest of the Bowl. \
	However, the colony maintains extremely opaque finances and is believed to be controlled by the Golden Tiger Syndicate, as a manufactory of powerful narcotics, \
	weaponry, and other illegal or controlled substances. With that in mind, Love's social welfare program is essentially a legalized system of hush money payouts, \
	and potential whistleblowers and finks can expect to find themselves driven from government-controlled housing and healthcare in a perfectly legal manner. \
	Love's ties to organized crime only improved its position after the Incursion, which it weathered with relative ease, leaving it a major regional power."
	subversive_potential = 1.2


/decl/background_detail/heritage/bowl
	uid = "heritage_bowl"
	name = "The Bowl - Other Culture"
	description = "The Bowl is the poorest and least developed region of Solar space, \
	plagued by organized crime and resource scarcity, and this is reflected in the culture of the people who call the region home, \
	whether they originated from Sol or the tajaran frontier. \
	Bowlers tend to be distrustful of outsiders and value keeping their noses down and themselves out of trouble. \
	People from other regions often associate 'Bowler' with either \'hick\' or \'criminal\', and prejudge Bowlers accordingly."
	economic_power = 0.8

//
// Almach Rim
//

/decl/background_detail/heritage/relan
	uid = "heritage_relan"
	name = "Almach Rim - Relani Culture"
	description = "The Second Free Relan Federation consists of the entire Relan system except for the planet of Taron, \
	its moon Parker, and their immediate orbits. Despite a war with Sol and a brief Skrellian occupation, Relan has maintained its sovereignty, \
	at least offically, and is currently a voluntary member of the Almach Protectorate. \
	Due to investments from Morpheus and its place in Almach's regional governments, \
	Relan has a significant positronic minority and even a number of drones who are legally considered persons, \
	although the latter cannot travel into Solar space. Relan is a nation of spacers, dependent on its stations, \
	and the Relani engineer more protective of their station or ship than the life forms aboard it is a common, if inaccurate, stereotype."
	economic_power = 0.8
	subversive_potential = 1.1 // they're considered the Least Bad almachi now

/decl/background_detail/heritage/taron
	uid = "heritage_taron"
	name = "Almach Rim - Taronian Culture"
	description = "Despite being a settled planet, living on Taron feels more like living on an uninhabitable moon. \
	Taron once ruled the Relan system, but following its loss it faced economic and social collapse, \
	marked by closing habitats, overcrowding, and political chaos. During this time, many left the planet, \
	often to Solar space. Despite a brief recovery and maintaining neutrality during the Almach War, \
	Taron faced more chaotic years after the Incursion, and has only recently began to truly stabilize."
	economic_power = 0.7
	subversive_potential = 1.1

/decl/background_detail/heritage/angessaspearl
	uid = "heritage_angessaspearl"
	name = "Almach Rim - Angessian Culture"
	description = "One of the Almach Protectorate's major population centers, \
	Angessa's Pearl is a barren planet colonized by a pseudo-religious movement led by Angessa Martei, \
	and was one of the first states to join the Almach Association. A significant portion of the Pearl's population are vatborn known as 'community children' \
	who were raised collectively within the theocracy. The Pearl is split between the skrellian collaborators of the Republic of Exalt's Light \
	and the recidivists of the Angessian Technocracy. Both mandate adherence to competing branches of the Starlit Path, \
	a philosophy that demands radical self-improvement and bestows cyberneting augmentations on those who prove their worth."
	economic_power = 0.7
	subversive_potential = 1.3 //the Most Bad almachi now

/decl/background_detail/heritage/vounna
	uid = "heritage_vounna"
	name = "Almach Rim - Vounnan Culture"
	description = "Vounna is the host star to the marshy planet Aetolus, \
	and the mobile mining station Agrafa, now under the banner of the Almach Protectorate. \
	After the coup of the NRS Prometheus in orbit, the capture of the Deliah, and the formation of the Almach Association, \
	the civilian population expanded rapidly due to the unrestricted creation of Prometheans on 'their' world."
	economic_power = 0.6 // It's difficult to be prosperous when your previous government committed warcrimes, and also spent most of their time scrambling to back their word.
	subversive_potential = 1.2

/decl/background_detail/heritage/shelf
	uid = "heritage_shelf"
	name = "Almach Rim - Shelfican Culture" //if you're from here it's because you were from here when it was in the rim
	description = "Shelf was the ever-moving birthplace and headquarters of Morpheus Cyberkinetics. \
	Shelf was an important cultural center for positronics and the Mercurial Movement until it \
	vanished from its place in the Almach Rim at the conclusion of the Almach War. \
	Since then, it has been located hundreds of years down the Almach Stream from any known colony, \
	maintaining a connection with Sol only through bluespace communications and suffering tremendously under the Skathari Incursion."
	economic_power = 0.8 //never forget that shelf's broke
	subversive_potential = 1.2

/decl/background_detail/heritage/neonlight
	uid = "heritage_neonlight"
	name = "Almach Rim - Neon Light Culture"
	description = "The Neon Light is a massive arkship, built before second-generation bluespace drives enabled \
	the golden age of colonization in the 22nd and 23rd centuries. Obsoleted as soon as it was completed, \
	the Neon Light became home to a culture of squatters and black marketeers; notionally a SolGov protectorate but in practice outside of its laws, \
	ruled by squabbling matriarchal crime families."
	economic_power = 0.8
	subversive_potential = 1.3

//crypt

//Precursor's Crypt
/decl/background_detail/heritage/el
	uid = "heritage_el"
	name = "Precursors' Crypt - Sophian Heritage"
	description = "El is a dull red star with one dusty, lifeless plant to its name. \
	However, the centuries-old discovery of early positronic brains in a local asteroid called Sophia makes \
	El the de facto home system of the positronics and the focal point of their diaspora. \
	Modern El is a wealthy cosmopolitan mid-system with the densest positronic population in SolGov, \
	with Sophia as its unofficial capital and hegemon."
	economic_power = 1.1


/decl/background_detail/heritage/raphael
	uid = "heritage_raphael"
	name = "Precursors' Crypt - Raphael Culture"
	description = "Raphael is the oldest 'voter farm', where positronics are produced and \
	educated en masse as a combination labor force and captive pro-corporate demographic. \
	Each of its three major habitats is an independent nation under heavy corporate control, \
	and the system saw no shortage of infighting prior to the Hegemony invasion. \
	Heavy losses to the Skathari Incursion have seen corporate influence grow even stronger and sparked a massive refugee crisis. \
	Raphael also hosts the first permenant vox settlement in the local cluster, with the remains of the arkship Bolt seeking refugee status at Raphael's docks."
	economic_power = 0.7
	subversive_potential = 0.8 //nanotrasen may well have Literally Made You

/decl/background_detail/heritage/terminus
	uid = "heritage_terminus"
	name = "Precusors' Crypt - Terminus Heritage"
	description = "One of the oldest deep-space stations in existence, Terminus Station orbited the Stream Terminus, \
	a bizarre spatial anomaly at the downstream end of the Almach Stream. Research into the Terminus, \
	where the tachyons making up the Almach Stream appear to simply vanish, \
	provided crucial data to the advancement of exonet communication and galactic tachyography, \
	though the ultimate nature of natural tachyon field generation remains unknown to this day. \
	Once a hotbed for research and cultural experimentation, Terminus was briefly the port of last call for \
	the convoys leaving for the Nyxian Corridor before being almost completely decimated by a massive Skathari Incursion in 2566. \
	Part of the deep-space convoy infrastructure in the area remains intact, but the main body of Terminus Station is now a quarantine zone."
	economic_power = 1.1 //it didn't USED to be apocalypse hell


/decl/background_detail/heritage/nyx
	uid = "heritage_nyx"
	name = "Precursors' Crypt - Nyxian Culture"
	description = "Nyx is on the edge of colonized human space; a frontier system. It holds the dubious distinction of \
	containing the only known and recently identified phoron giant, Erebus, making it a hotbed of both \
	Trans-Stellar Corporate interest and, due to its distance from the better-policed parts of human space, criminal activity. \
	Although Brinkburn and Roanoke play host to significant and stable colonies backed by SolGov support, \
	the Federation presence in the system has been only nominal for years; what justice there is, you bring with you. \
	The universally accepted currency in Nyx is the SolGov-backed Thaler (þ), although simple barter is often an acceptable alternative. \
	With the advances of technology the overall standard of living and education is high even out in the frontier - if you can afford it." // extremely very rewrite
	economic_power = 0.7 // who the fuck is even from nyx
	//i have a miner from emerald station :)

/decl/background_detail/heritage/crypt
	uid = "heritage_crypt"
	name = "Precursors' Crypt - Other Culture"
	description = "Crypters come from the stations of the Precursor's Crypt, the region of Solar space where positronics were first discovered. \
	The culture that grew in this region is technophilic, neophilic, tightly interconnected, and constantly racing to outdo itself. \
	Crypt systems are usually sparsely inhabited, but most of their population is well-off, with intellectual services the backbone of the Crypt's economy. \
	Crypter culture is also influenced by the officers and servicepeople of the region's heavy Fleet presence, \
	and by the legacy of the Hegemony invasion during the First Contact War." // sure ok


/decl/background_detail/heritage/eutopia
	uid = "heritage_eutopia"
	name = "Seccessionist - Eutopian Culture"
	description = "Created as an 'objectivist paradise', Eutopia typifies the cut-throat ideology of anarcho-capitalism. \
	Less than 10 percent of the population own all property in the system, with the remainder rent-paying tenants, \
	or indentured servants - though the latter rarely have the opportunity to leave. \
	Most of Eutopia's economy exists to serve the unregulated banking and entertainment needs of Trans-stellar Corporation and \
	Skrell moguls from across the galaxy. To be Eutopian is to become ultra-rich, or die trying, \
	an attitude that has lead an increasing number of Eutopians to become semi-legitimate 'mercenary' pirates, \
	and to their leadership courting the favor of the fascists of Vystholm."
	economic_power = 1.1
	subversive_potential= 1.3

/decl/background_detail/heritage/casini
	uid = "heritage_casini"
	name = "Seccessionist - Casinian Culture"
	description = "The communes of Casini's Reach vary in size and prosperity, united only by a defensive pact and a shared sense of mutual aid. \
	Most consist of small, tight-knit communities focused around the extraction or production of a particular resource, \
	supplied to other colonies in exchange for their own necessities. Though minerals are abundant, life is tough and there is always work to be done, \
	but most Casinians know they can always rely on their neighbors in times of need."
	economic_power = 0.7
	subversive_potential= 1.1

/decl/background_detail/heritage/natuna
	uid = "heritage_natuna"
	name = "Seccessionist - Natuna Culture"
	description = "Until very recently, Natuna Bhumi Bariśāl existed as a collection of autonomous colonies on the border of Human and Skrell space, \
	notable for being the first system to accept the two species living alongside one another. Heavily embargoed by all major governments, \
	the system became notorious as a haven for society's dregs from both sides of the border - casteless skrell, refugees, deserters, and gangsters alike. \
	The system is known as a hub for pirates in the region, with a botched Moghes Hegemony occupation in 2563 \
	devastating its infrastructure and pushing it further into alignment with increasingly bold Ue-Katish pirates." //where did the bhumi come from. its not on the wiki. help
	economic_power = 0.5 //its LOW babey
	subversive_potential= 1.4 //Hive of scum and villainy. Or, was.

/* Commented out until species restrictions exist.
/decl/background_detail/heritage/newkyoto
	uid = "heritage_newkyoto"
	name = "Seccessionist - New Kyoto Culture"
	description = "Modelled closely on an idealized version of Edo period Japan, the independent human colony of New Kyoto is \
	fiercly traditionalist and openly hostile to outside influence. A highly regimented society with outside trade heavily restricted, \
	and the influence of trans-stellar corporations and their products kept to a minimum, \
	New Kyoto instills in its populace a strong sense of national loyalty, self-sufficiency and of course, militarism."
	economic_power = 0.9
	subversive_potential= 1.1 //(independents? prolly up to SOMETHING)
	//restricted_to_species = list(SPECIES_HUMAN)

/decl/background_detail/heritage/vystholm
	uid = "heritage_vystholm"

*/
/decl/background_detail/heritage/seccesionist
	uid = "heritage_seccesionist"
	name = "Seccesionist - Other Culture"
	description = "The \"seccesionist systems\" split from SolGov during the so-called Age of Seccesion in 25th century, \
	marking a final end to SolGov's formal control of all human-colonized systems. Their cultures tend towards the idiosyncratic and \
	isolationist, and all have suffered periods of poor relations with the largest government in local space. \
	Recent changes to SolGov's foreign policy have improved matters, especially in light of more recent, larger seccession movements in the \
	Almach Rim and Sagittarius Heights, but expatriates from the seccesionist systems are still seen as potentially dangerous iconoclasts."
	economic_power = 0.8
	subversive_potential = 1.1

/decl/background_detail/heritage/frontier
	uid = "heritage_frontier"
	name = "Other Culture - Unincorporated Rim"
	description = "The unincorporated rim represents the small, local cultures on the frontier of human colonization, outside of any major interstellar cultural spheres. \
	Life on the frontier is usually cold, hard, and lonely, with the only sporadic contact with the rest of civilization coming from occasional visits from \
	tax collectors and Free Traders and perhaps a low-quality Exonet connection. \
	Successful frontier colonies band together tightly, sometimes becoming almost insular, \
	while failed colonies dissolve as, bit by bit, colonists trickle back to the core worlds." //or die
	economic_power = 0.4 //do they even HAVE money from where you come from


/decl/background_detail/heritage/deep_space
	name = "Deep Space"
	uid = "heritage_space"
	description = "You came from the void between the stars."
	language =         null
	secondary_langs =  null
	additional_langs = null
	economic_power =   null
