/obj/screen/robot/store
	name       = "store"
	icon_state = "store"
	screen_loc = ui_borg_store

/obj/screen/robot/store/handle_click(mob/user, params)
	if(isrobot(user))
		var/mob/living/silicon/robot/robot = user
		if(robot.module)
			robot.uneq_active()
			robot.hud_used.update_robot_modules_display()
		else
			to_chat(robot, "You haven't selected a module yet.")
