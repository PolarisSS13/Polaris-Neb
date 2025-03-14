/decl/codex_category/species
	name = "Species"
	desc = "Sapient species encountered in known space."

/decl/codex_category/species/Populate()

	for(var/decl/species/species as anything in decls_repository.get_decls_of_subtype_unassociated(/decl/species))
		if(!species.hidden_from_codex)
			var/entry_type = (species.secret_codex_info) ? /datum/codex_entry/scannable : /datum/codex_entry
			var/datum/codex_entry/entry = new entry_type(
				_display_name = "[species.name] (species)",
				_lore_text = species.codex_description,
				_mechanics_text = species.ooc_codex_information
			)

			if(species.secret_codex_info)
				var/datum/codex_entry/scannable/secret_entry = entry
				secret_entry.has_scannable_secrets = TRUE
				secret_entry.secret_text = species.secret_codex_info

			items |= entry.name
	. = ..()
