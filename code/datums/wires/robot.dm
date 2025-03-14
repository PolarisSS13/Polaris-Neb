/datum/wires/robot
	random = 1
	holder_type = /mob/living/silicon/robot
	wire_count = 5
	descriptions = list(
		new /datum/wire_description(BORG_WIRE_LAWCHECK, "This wire runs to the unit's law module."),
		new /datum/wire_description(BORG_WIRE_MAIN_POWER, "This wire seems to be carrying a heavy current.", SKILL_EXPERT),
		new /datum/wire_description(BORG_WIRE_LOCKED_DOWN, "This wire connects to the unit's safety override."),
		new /datum/wire_description(BORG_WIRE_AI_CONTROL, "This wire connects to automated control systems."),
		new /datum/wire_description(BORG_WIRE_CAMERA,  "This wire runs to the unit's vision modules.")
	)

var/global/const/BORG_WIRE_LAWCHECK = 1
var/global/const/BORG_WIRE_MAIN_POWER = 2 // The power wires do nothing whyyyyyyyyyyyyy
var/global/const/BORG_WIRE_LOCKED_DOWN = 4
var/global/const/BORG_WIRE_AI_CONTROL = 8
var/global/const/BORG_WIRE_CAMERA = 16

/datum/wires/robot/GetInteractWindow(mob/user)

	. = ..()
	var/mob/living/silicon/robot/robot = holder
	var/datum/extension/network_device/camera/D = get_extension(holder, /datum/extension/network_device/)

	. += text("<br>\n[(robot.lawupdate ? "The LawSync light is on." : "The LawSync light is off.")]")
	. += text("<br>\n[(robot.connected_ai ? "The AI link light is on." : "The AI link light is off.")]")
	. += text("<br>\n[(D.is_functional() ? "The Camera light is on." : "The Camera light is off.")]")
	. += text("<br>\n[(robot.lockcharge ? "The lockdown light is on." : "The lockdown light is off.")]")
	return .

/datum/wires/robot/UpdateCut(var/index, var/mended)

	var/mob/living/silicon/robot/robot = holder
	switch(index)
		if(BORG_WIRE_LAWCHECK) //Cut the law wire, and the borg will no longer receive law updates from its AI
			if(!mended)
				if (robot.lawupdate == 1)
					to_chat(robot, "LawSync protocol engaged.")
					robot.show_laws()
			else
				if (robot.lawupdate == 0 && !robot.emagged)
					robot.lawupdate = 1

		if (BORG_WIRE_AI_CONTROL) //Cut the AI wire to reset AI control
			if(!mended)
				robot.disconnect_from_ai()

		if (BORG_WIRE_CAMERA)
			cameranet.update_visibility(src, FALSE)

		if(BORG_WIRE_LOCKED_DOWN)
			robot.SetLockdown(!mended)


/datum/wires/robot/UpdatePulsed(var/index)
	var/mob/living/silicon/robot/robot = holder
	switch(index)
		if (BORG_WIRE_AI_CONTROL) //pulse the AI wire to make the borg reselect an AI
			if(!robot.emagged)
				var/mob/living/silicon/ai/new_ai = select_active_ai(robot, get_z(robot))
				robot.connect_to_ai(new_ai)

		if (BORG_WIRE_CAMERA)
			var/datum/extension/network_device/camera/robot/D = get_extension(src, /datum/extension/network_device)
			if(D && D.is_functional())
				robot.visible_message("[robot]'s camera lens focuses loudly.")
				to_chat(robot, "Your camera lense focuses loudly.")

		if(BORG_WIRE_LOCKED_DOWN)
			robot.SetLockdown(!robot.lockcharge) // Toggle

/datum/wires/robot/CanUse(var/mob/living/L)
	var/mob/living/silicon/robot/robot = holder
	return robot.wiresexposed

/datum/wires/robot/proc/IsCameraCut()
	return wires_status & BORG_WIRE_CAMERA

/datum/wires/robot/proc/LockedCut()
	return wires_status & BORG_WIRE_LOCKED_DOWN