// Voidcraft Shuttle Walls
/turf/wall/shuttle/voidcraft
	name = "voidcraft wall"
	icon = 'maps/cynosure/icons/turf/shuttle_void.dmi'
	icon_state = "void"

/turf/wall/shuttle/voidcraft/red
	stripe_color = "#ff0000"

/turf/wall/shuttle/voidcraft/blue
	stripe_color = "#0000ff"

/turf/wall/shuttle/voidcraft/green
	stripe_color = "#00ff00"

/turf/wall/shuttle/voidcraft/get_wall_icon()
	return icon

/turf/wall/shuttle/voidcraft/Initialize()
	. = ..()
	update_icon()

/turf/wall/shuttle/voidcraft/update_wall_icon()
	icon_state = initial(icon_state)
	if(stripe_color)
		cut_overlays()
		var/image/I = image(icon = src.icon, icon_state = "o_[icon_state]")
		I.color = stripe_color
		add_overlay(I)

/turf/floor/natural/grass/sif/sif
	name = "growth"
	desc = "A layer of Sivian moss that has adapted to the sheer cold climate."
	color = "#447171"
	base_color = "#447171"

/turf/floor/natural/grass/wild/sif
	name = "thick growth"
	desc = "A thick, rough layer of Sivian moss that has adapted to the sheer cold climate."
	color = "#446471"
	base_color = "#446471"
