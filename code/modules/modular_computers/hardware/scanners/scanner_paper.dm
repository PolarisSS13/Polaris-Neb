/obj/item/stock_parts/computer/scanner/paper
	name = "paper scanner module"
	desc = "A paper scanning module. It can scan writing and save it to a file."
	external_slot = TRUE
	material = /decl/material/solid/metal/steel
	matter = list(/decl/material/solid/fiberglass = MATTER_AMOUNT_REINFORCEMENT)

/obj/item/stock_parts/computer/scanner/paper/can_use_scanner(mob/user, obj/item/paper/target, proximity = TRUE)
	if(!..())
		return 0
	if(!istype(target))
		return 0
	return 1

/obj/item/stock_parts/computer/scanner/paper/do_on_afterattack(mob/user, obj/item/paper/target, proximity)
	if(!driver || !driver.using_scanner)
		return
	if(!can_use_scanner(user, target, proximity))
		return
	var/data = html2pencode(target.info)
	if(!data)
		return
	if(target.metadata)
		driver.metadata_buffer = target.metadata.Copy()
	driver.paper_type = target.type

	driver.scan_file_type = target.scan_file_type

	if(target.type == /obj/item/paper/bodyscan)
		driver.data_buffer = display_medical_data(driver.metadata_buffer,user.get_skill_value(SKILL_MEDICAL), TRUE)
	else
		driver.data_buffer = data

	to_chat(user, "You scan \the [target] with [src].")
	SSnano.update_uis(driver.NM)

/obj/item/stock_parts/computer/scanner/paper/do_on_attackby(mob/user, atom/target)
	do_on_afterattack(user, target, TRUE)
	return can_use_scanner(user, target, TRUE)