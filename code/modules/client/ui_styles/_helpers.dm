/proc/get_ui_styles(var/filter_available = TRUE)
	var/list/all_ui_styles = decls_repository.get_decls_of_subtype(/decl/ui_style)
	for(var/ui_type in all_ui_styles)
		var/decl/ui_style/ui = all_ui_styles[ui_type]
		if(!ui.restricted || !filter_available)
			LAZYADD(., ui)

/proc/get_default_ui_icon(ui_key)
	return get_ui_icon(global.using_map.default_ui_style, ui_key)

/proc/get_ui_icon(ui_style, ui_key)
	var/decl/ui_style/style = GET_DECL(ui_style)
	return style?.get_icon(ui_key) || get_default_ui_icon(ui_key)
