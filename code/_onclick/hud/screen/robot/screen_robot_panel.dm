/obj/screen/robot/panel
	name       = "panel"
	icon_state = "panel"
	screen_loc = ui_borg_panel

/obj/screen/robot/panel/handle_click(mob/user, params)
	if(isrobot(user))
		var/mob/living/silicon/robot/robot = user
		robot.installed_modules()
