// If /client/var/parent_type ever stops being /datum, this proc will need to be redefined on client.
/datum/proc/get_view_variables_header()
	return "<b>[src]</b>"

/atom/get_view_variables_header()
	return {"
		<a href='byond://?_src_=vars;datumedit=\ref[src];varnameedit=name'><b>[src]</b></a>
		<br><font size='1'>
		<a href='byond://?_src_=vars;rotatedatum=\ref[src];rotatedir=left'>\<\<</a>
		<a href='byond://?_src_=vars;datumedit=\ref[src];varnameedit=dir'>[dir2text(dir)]</a>
		<a href='byond://?_src_=vars;rotatedatum=\ref[src];rotatedir=right'>\>\></a>
		</font>
		"}

/mob/living/get_view_variables_header()
	return {"
		<a href='byond://?_src_=vars;rename=\ref[src]'><b>[src]</b></a><font size='1'>
		<br><a href='byond://?_src_=vars;rotatedatum=\ref[src];rotatedir=left'>\<\<</a> <a href='byond://?_src_=vars;datumedit=\ref[src];varnameedit=dir'>[dir2text(dir)]</a> <a href='byond://?_src_=vars;rotatedatum=\ref[src];rotatedir=right'>\>\></a>
		<br><a href='byond://?_src_=vars;datumedit=\ref[src];varnameedit=ckey'>[ckey ? ckey : "No ckey"]</a> / <a href='byond://?_src_=vars;datumedit=\ref[src];varnameedit=real_name'>[real_name ? real_name : "No real name"]</a>
		<br>
		BRUTE:<a href='byond://?_src_=vars;mobToDamage=\ref[src];adjustDamage=[BRUTE]'>[get_damage(BRUTE)]</a>
		FIRE:<a href='byond://?_src_=vars;mobToDamage=\ref[src];adjustDamage=[BURN]'>[get_damage(BURN)]</a>
		TOXIN:<a href='byond://?_src_=vars;mobToDamage=\ref[src];adjustDamage=[TOX]'>[get_damage(TOX)]</a>
		OXY:<a href='byond://?_src_=vars;mobToDamage=\ref[src];adjustDamage=[OXY]'>[get_damage(OXY)]</a>
		CLONE:<a href='byond://?_src_=vars;mobToDamage=\ref[src];adjustDamage=[CLONE]'>[get_damage(CLONE)]</a>
		BRAIN:<a href='byond://?_src_=vars;mobToDamage=\ref[src];adjustDamage=[BP_BRAIN]'>[get_damage(BRAIN)]</a>
		</font>
		"}

// Same for these as for get_view_variables_header() above
/datum/proc/get_view_variables_options()
	return ""

/mob/get_view_variables_options()
	return ..() + {"
		<option value='?_src_=vars;mob_player_panel=\ref[src]'>Show player panel</option>
		<option>---</option>
		<option value='?_src_=vars;godmode=\ref[src]'>Toggle Godmode</option>
		<option value='?_src_=vars;build_mode=\ref[src]'>Toggle Build Mode</option>

		<option value='?_src_=vars;direct_control=\ref[src]'>Assume Direct Control</option>
		<option value='?_src_=vars;drop_everything=\ref[src]'>Drop Everything</option>

		<option value='?_src_=vars;updateicon=\ref[src]'>Update Icon</option>
		<option value='?_src_=vars;addlanguage=\ref[src]'>Add Language</option>
		<option value='?_src_=vars;remlanguage=\ref[src]'>Remove Language</option>
		<option value='?_src_=vars;addorgan=\ref[src]'>Add Organ</option>
		<option value='?_src_=vars;remorgan=\ref[src]'>Remove Organ</option>

		<option value='?_src_=vars;give_ability=\ref[src]'>Give Ability</option>
		<option value='?_src_=vars;remove_ability=\ref[src]'>Remove Ability</option>

		<option value='?_src_=vars;fix_nano=\ref[src]'>Fix NanoUI</option>

		<option value='?_src_=vars;addverb=\ref[src]'>Add Verb</option>
		<option value='?_src_=vars;remverb=\ref[src]'>Remove Verb</option>
		<option>---</option>
		<option value='?_src_=vars;gib=\ref[src]'>Gib</option>
		<option value='?_src_=vars;explode=\ref[src]'>Trigger explosion</option>
		<option value='?_src_=vars;emp=\ref[src]'>Trigger EM pulse</option>
		"}

/mob/living/get_view_variables_options()
	return ..() + {"
		<option value='?_src_=vars;add_mob_modifier=\ref[src]'>Add Modifier</option>
		<option value='?_src_=vars;remove_mob_modifier=\ref[src]'>Remove Modifier</option>
		<option value='?_src_=vars;addstressor=\ref[src]'>Add Stressor</option>
		<option value='?_src_=vars;removestressor=\ref[src]'>Remove Stressor</option>
		<option value='?_src_=vars;setstatuscond=\ref[src]'>Set Status Condition</option>
		"}

/mob/living/human/get_view_variables_options()
	return ..() + {"
		<option value='?_src_=vars;refreshoverlays=\ref[src]'>Refresh Visible Overlays</option>
		<option value='?_src_=vars;setspecies=\ref[src]'>Set Species</option>
		<option value='?_src_=vars;setbodytype=\ref[src]'>Set Bodytype</option>
		<option value='?_src_=vars;addailment=\ref[src]'>Add Ailment</option>
		<option value='?_src_=vars;remailment=\ref[src]'>Remove Ailment</option>
		<option value='?_src_=vars;dressup=\ref[src]'>Dressup</option>
		<option value='?_src_=vars;makeai=\ref[src]'>Make AI</option>
		<option value='?_src_=vars;makerobot=\ref[src]'>Make cyborg</option>
		<option value='?_src_=vars;makemonkey=\ref[src]'>Make monkey</option>
		<option value='?_src_=vars;makealien=\ref[src]'>Make alien</option>
		"}

/obj/get_view_variables_options()
	return ..() + {"
		<option value='?_src_=vars;delthis=\ref[src]'>Delete instance</option>
		<option value='?_src_=vars;delall=\ref[src]'>Delete all of type</option>
		<option value='?_src_=vars;explode=\ref[src]'>Trigger explosion</option>
		<option value='?_src_=vars;emp=\ref[src]'>Trigger EM pulse</option>
		"}

/obj/item/get_view_variables_options()
	return ..() + {"
		<option value='?_src_=vars;setmaterial=\ref[src]'>Set material</option>
		"}

/turf/get_view_variables_options()
	return ..() + {"
		<option value='?_src_=vars;explode=\ref[src]'>Trigger explosion</option>
		<option value='?_src_=vars;emp=\ref[src]'>Trigger EM pulse</option>
		"}

/datum/proc/VV_get_variables()
	. = vars - VV_hidden()
	if(!usr || !check_rights(R_ADMIN|R_DEBUG, FALSE))
		. -= VV_secluded()

/datum/proc/get_variable_value(varname)
	return vars[varname]

/datum/proc/set_variable_value(varname, value)
	vars[varname] = value

/datum/proc/get_initial_variable_value(varname)
	return initial(vars[varname])

/datum/proc/make_view_variables_variable_entry(var/varname, var/value, var/hide_watch = 0)
	return {"
			(<a href='byond://?_src_=vars;datumedit=\ref[src];varnameedit=[varname]'>E</a>)
			(<a href='byond://?_src_=vars;datumchange=\ref[src];varnamechange=[varname]'>C</a>)
			(<a href='byond://?_src_=vars;datummass=\ref[src];varnamemass=[varname]'>M</a>)
			[hide_watch ? "" : "(<a href='byond://?_src_=vars;datumwatch=\ref[src];varnamewatch=[varname]'>W</a>)"]
			"}

// No mass editing of clients
/client/make_view_variables_variable_entry(var/varname, var/value, var/hide_watch = 0)
	return {"
			(<a href='byond://?_src_=vars;datumedit=\ref[src];varnameedit=[varname]'>E</a>)
			(<a href='byond://?_src_=vars;datumchange=\ref[src];varnamechange=[varname]'>C</a>)
			[hide_watch ? "" : "(<a href='byond://?_src_=vars;datumwatch=\ref[src];varnamewatch=[varname]'>W</a>)"]
			"}

// These methods are all procs and don't use stored lists to avoid VV exploits

// The following vars cannot be viewed by anyone
/datum/proc/VV_hidden()
	return list()

// The following vars can only be viewed by R_ADMIN|R_DEBUG
/datum/proc/VV_secluded()
	return list()

// The following vars cannot be edited by anyone
/datum/proc/VV_static()
	return list("parent_type", "gc_destroyed", "is_processing")

/atom/VV_static()
	return ..() + list("bound_x", "bound_y", "bound_height", "bound_width", "bounds", "step_x", "step_y", "step_size")

/client/VV_static()
	return ..() + list("holder", "prefs")

/datum/admins/VV_static()
	return vars

// The following vars require R_DEBUG to edit
/datum/proc/VV_locked()
	return list("vars", "cuffed")

/client/VV_locked()
	return list("vars", "mob")

/mob/VV_locked()
	return ..() + list("client")

// The following vars require R_FUN|R_DEBUG to edit
/datum/proc/VV_icon_edit_lock()
	return list()

/atom/VV_icon_edit_lock()
	return ..() + list("icon", "icon_state", "overlays", "underlays")

// The following vars require R_SPAWN|R_DEBUG to edit
/datum/proc/VV_ckey_edit()
	return list()

/mob/VV_ckey_edit()
	return list("key", "ckey")

/client/VV_ckey_edit()
	return list("key", "ckey")

/datum/proc/may_edit_var(var/user, var/var_to_edit)
	if(!user)
		return FALSE
	if(!(var_to_edit in VV_get_variables()))
		to_chat(user, "<span class='warning'>\The [src] does not have a var '[var_to_edit]'</span>")
		return FALSE
	if((var_to_edit in VV_static()) || (var_to_edit in VV_hidden()))
		return FALSE
	if((var_to_edit in VV_secluded()) && !check_rights(R_ADMIN|R_DEBUG, FALSE, C = user))
		return FALSE
	if((var_to_edit in VV_locked()) && !check_rights(R_DEBUG, C = user))
		return FALSE
	if((var_to_edit in VV_ckey_edit()) && !check_rights(R_SPAWN|R_DEBUG, C = user))
		return FALSE
	if((var_to_edit in VV_icon_edit_lock()) && !check_rights(R_FUN|R_DEBUG, C = user))
		return FALSE
	return TRUE

/proc/forbidden_varedit_object_types()
 	return list(
		/datum/admins						//Admins editing their own admin-power object? Yup, sounds like a good idea.
	)
