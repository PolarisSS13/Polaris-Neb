/decl/species
	available_cultural_info = list(
		TAG_HOMECULTURE = list(
			/decl/cultural_info/homeculture/fantasy,
			/decl/cultural_info/homeculture/fantasy/mountains,
			/decl/cultural_info/homeculture/fantasy/steppe,
			/decl/cultural_info/homeculture/fantasy/woods,
			/decl/cultural_info/homeculture/other
		),
		TAG_FACTION =   list(
			/decl/cultural_info/faction/fantasy,
			/decl/cultural_info/faction/other
		),
		TAG_CULTURE =   list(
			/decl/cultural_info/culture/fantasy,
			/decl/cultural_info/culture/fantasy/steppe,
			/decl/cultural_info/culture/other
		),
		TAG_RELIGION =  list(
			/decl/cultural_info/religion/ancestors,
			/decl/cultural_info/religion/folk_deity,
			/decl/cultural_info/religion/anima_materialism,
			/decl/cultural_info/religion/virtuist,
			/decl/cultural_info/religion/other
		)
	)
	default_cultural_info = list(
		TAG_HOMECULTURE = /decl/cultural_info/homeculture/fantasy,
		TAG_FACTION   = /decl/cultural_info/faction/fantasy,
		TAG_CULTURE   = /decl/cultural_info/culture/fantasy,
		TAG_RELIGION  = /decl/cultural_info/religion/other
	)

// Rename grafadreka
/decl/species/grafadreka
	name = "Meredrake"
	name_plural = "Meredrakes"
	description = "Meredrakes, sometimes called mire-drakes, are large reptillian pack predators, widely assumed to be cousins to true dragons. \
	They are commonly found living in caves or burrows bordering grassland or forest, and while they prefer to hunt deer or rabbits, they will sometimes attack travellers if pickings are slim enough. \
	While they are not domesticated, they can be habituated and trained as working animals if captured young enough."

/decl/sprite_accessory/marking/grafadreka
	species_allowed = list("Meredrake")

/decl/language/grafadreka
	desc = "Hiss hiss, feed me rabbits."

/decl/material/liquid/sifsap
	name = "drake spittle"
	lore_text = "A complex chemical slurry brewed up in the gullet of meredrakes."

/obj/aura/sifsap_salve
	name = "Drakespittle Salve"
	descriptor = "glowing spittle"

// Rename wooden prostheses
/decl/bodytype/prosthetic/wooden
	name = "carved wooden" // weird to call it 'crude' when it's cutting-edge for the setting