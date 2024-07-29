/decl/cultural_info/culture/other
	name = "Other Culture"
	description = "You are from one of the many small, relatively unknown cultures scattered across the galaxy."
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/common,
		/decl/language/sign
	)


/decl/cultural_info/culture/sif
	name = "Golden Crescent - Sivian Culture"
	description = "Sivians were begrudgingly absorbed into SolGov after a period of staunch independence around two centuries ago, \
	Sif's factionalized colonies subsequently unified to wage bitter - though low-intensity - undeclared warfare against corporate \
	interests from Kara that they viewed as encroaching upon the system through much of the 24th century, though to limited success. \
	However, longstanding Sivians still tend to hold pro-autonomy sentiments, and harbour resentment against trans-stellar corporations \
	 - at least so far as it benefits them."
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/common,
		/decl/language/sign,
		/decl/language/human/sivian
	)

/decl/cultural_info/culture/kara
	name = "Golden Crescent - Karan Culture"
	description = "Karans are the inhabitants of the formerly smuggler and pirate dominated ring of Kara, now run almost exclusively by \
	corporate interests, which has given the population a distinctly cosmopolitan bent. Today Kara is composed of the descendants of \
	several distinct migration waves, including a large positronic population, a number of different aliens, and humans from all corners \
	of Solar space. Karans are generally considered modern, forward-thinking, and technophilic, in sharp contrast with their Sivian neighbors."
	language = /decl/language/human/common
	secondary_langs = list(
		/decl/language/human/common,
		/decl/language/sign
	)

/decl/cultural_info/culture/earth
	name = "Core Worlds - Solar Culture"
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
		/decl/language/human/common,
		/decl/language/sign
	)

/decl/cultural_info/culture/synthetic
	name = "Artificial Intelligence"
	description = "You are a simple artificial intelligence created by humanity to serve a menial purpose."
	secondary_langs = list(
		/decl/language/machine,
		/decl/language/human/common,
		/decl/language/sign
	)

/decl/cultural_info/culture/synthetic/sanitize_cultural_name(new_name)
	return sanitize_name(new_name, allow_numbers = TRUE)
