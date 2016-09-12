// Crew has to build a bluespace cannon
// Cargo orders part for high price
// Requires high amount of power
// Requires high level stock parts
/datum/station_goal/bluespace_cannon
	name = "Bluespace Artillery"

/datum/station_goal/bluespace_cannon/get_report()
	return {"Our military presence is inadequate in your sector.
	 We need you to construct BSA-[rand(1,99)] Artillery position aboard your station.

	 Base parts should be availible for shipping by your cargo shuttle.
	 -Nanotrasen Naval Command"}

/datum/station_goal/bluespace_cannon/on_report()
	//Unlock BSA parts
	var/datum/supply_pack/misc/bsa/P = SSshuttle.supply_packs[/datum/supply_pack/misc/bsa]
	P.special_enabled = TRUE

/datum/station_goal/bluespace_cannon/check_completion()
	if(..())
		return TRUE
	var/obj/machinery/bsa/full/B = locate()
	if(B && !B.stat)
		return TRUE
	return FALSE

/obj/machinery/bsa
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	density = 1
	anchored = 1

/obj/machinery/bsa/back
	name = "Bluespace Artillery Generator"
	desc = "Generates cannon pulse. Needs to be linked with a fusor. "
	icon_state = "power_box"

/obj/machinery/bsa/back/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		M.buffer = src
		user << "<span class='notice'>You store linkage information in [W]'s buffer.</span>"
	else
		return ..()

/obj/machinery/bsa/front
	name = "Bluespace Artillery Bore"
	desc = "Do not stand in front of cannon during operation. Needs to be linked with a fusor."
	icon_state = "emitter_center"

/obj/machinery/bsa/front/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		M.buffer = src
		user << "<span class='notice'>You store linkage information in [W]'s buffer.</span>"
	else
		return ..()

/obj/machinery/bsa/middle
	name = "Bluespace Artillery Fusor"
	desc = "Contents classifed by Nanotrasen Naval Command. Needs to be linked with the other BSA parts using multitool."
	icon_state = "fuel_chamber"
	var/obj/machinery/bsa/back/back 
	var/obj/machinery/bsa/front/front

/obj/machinery/bsa/middle/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		if(M.buffer)
			if(istype(M.buffer,/obj/machinery/bsa/back))
				back = M.buffer
				M.buffer = null
				user << "<span class='notice'>You link [src] with [back].</span>"
			else if(istype(M.buffer,/obj/machinery/bsa/front))
				front = M.buffer
				M.buffer = null
				user << "<span class='notice'>You link [src] with [front].</span>"
	else
		return ..()

/obj/machinery/bsa/middle/proc/check_completion()
	if(!front || !back)
		return "No linked parts detected!"
	if(front.y != y || back.y != y || !(front.x > x && back.x < x || front.x < x && back.x > x) || front.z != z || back.z != z)
		return "Parts misaligned!"
	if(!has_space())
		return "Not enough free space!"

/obj/machinery/bsa/middle/proc/has_space()
	var/cannon_dir = get_cannon_direction()
	var/x_min
	var/x_max
	switch(cannon_dir)
		if(EAST)
			x_min = x - 4 //replace with defines later
			x_max = x + 6
		if(WEST)
			x_min = x + 4
			x_max = x - 6

	for(var/turf/T in block(locate(x_min,y-1,z),locate(x_max,y+1,z)))
		if(T.density || istype(T, /turf/open/space))
			return FALSE
	return TRUE

/obj/machinery/bsa/middle/proc/get_cannon_direction()
	if(front.x > x && back.x < x)
		return EAST
	else if(front.x < x && back.x > x)
		return WEST


/obj/machinery/bsa/full
	name = "Bluespace Artillery"
	desc = "Long range bluespace artillery."
	icon = 'icons/obj/lavaland/cannon.dmi'
	icon_state = "orbital_cannon1"
	unsecuring_tool = null
	var/static/image/top_layer = null
	var/ex_power = 3
	var/power_used_per_shot = 2000000 //enough to kil standard apc - todo : make this use wires instead and scale explosion power with it
	pixel_y = -32
	pixel_x = -192
	bound_width = 352
	bound_x = -192
	appearance_flags = NONE //Removes default TILE_BOUND

/obj/machinery/bsa/full/proc/get_front_turf()
	switch(dir)
		if(WEST)
			return locate(x - 6,y,z)
		if(EAST)
			return locate(x + 4,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/proc/get_back_turf()
	switch(dir)
		if(WEST)
			return locate(x + 4,y,z)
		if(EAST)
			return locate(x - 6,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/proc/get_target_turf()
	switch(dir)
		if(WEST)
			return locate(1,y,z)
		if(EAST)
			return locate(world.maxx,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/New(loc,cannon_direction = WEST)
	..()
	switch(cannon_direction)
		if(WEST)
			dir = WEST
			pixel_x = -192
			top_layer = image("icons/obj/lavaland/orbital_cannon.dmi", "top_west")
			top_layer.layer = ABOVE_MOB_LAYER
			icon_state = "cannon_west"
		if(EAST)
			dir = EAST
			top_layer = image("icons/obj/lavaland/orbital_cannon.dmi", "top_east")
			top_layer.layer = ABOVE_MOB_LAYER
			icon_state = "cannon_east"
	add_overlay(top_layer)

/obj/machinery/bsa/full/proc/fire()
	var/turf/point = get_front_turf()
	for(var/turf/T in getline(get_step(point,dir),get_target_turf()))
		T.ex_act(1)
	point.Beam(get_target_turf(),icon_state="bsa_beam",icon='icons/effects/beam.dmi',time=50,maxdistance = world.maxx) //ZZZAP


/obj/structure/filler
	name = "big machinery part"
	density = 1
	anchored = 1
	invisibility = INVISIBILITY_ABSTRACT
	var/obj/machinery/parent

/obj/structure/filler/ex_act()
	return

/obj/item/weapon/circuitboard/machine/bsa/back
	name = "circuit board (Bluespace Artillery Generator)"
	build_path = /obj/machinery/bsa/back
	origin_tech = "engineering=2;combat=2;bluespace=2" //No freebies!
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor/quadratic = 5,
							/obj/item/stack/cable_coil = 2)

/obj/item/weapon/circuitboard/machine/bsa/middle
	name = "circuit board (Bluespace Artillery Fusor)"
	build_path = /obj/machinery/bsa/middle
	origin_tech = "engineering=2;combat=2;bluespace=2"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 20,
							/obj/item/stack/cable_coil = 2)

/obj/item/weapon/circuitboard/machine/bsa/front
	name = "circuit board (Bluespace Artillery Bore)"
	build_path = /obj/machinery/bsa/front
	origin_tech = "engineering=2;combat=2;bluespace=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator/femto = 5,
							/obj/item/stack/cable_coil = 2)

/obj/item/weapon/circuitboard/machine/computer/bsa_control
	name = "circuit board (Bluespace Artillery Controls)"
	build_path = /obj/machinery/computer/bsa_control
	origin_tech = "engineering=2;combat=2;bluespace=2"

/obj/machinery/computer/bsa_control
	name = "Bluespace Artillery Control"
	var/obj/machinery/bsa/full/cannon
	var/ready = FALSE
	var/notice
	var/target
	use_power = 0
	circuit = /obj/item/weapon/circuitboard/machine/computer/bsa_control
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_boxp"
	var/area_aim = FALSE //should also show areas for targeting

/obj/machinery/computer/bsa_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "bsa", name, 400, 305, master_ui, state)
		ui.open()

/obj/machinery/computer/bsa_control/ui_data()
	var/list/data = list()
	data["ready"] = ready
	data["connected"] = cannon
	data["notice"] = notice
	if(target)
		data["target"] = get_target_name()
	return data

/obj/machinery/computer/bsa_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("build")
			cannon = deploy()
			. = TRUE
		if("fire")
			fire(usr)
			. = TRUE
		if("recalibrate")
			calibrate(usr)
			. = TRUE
	update_icon()

/obj/machinery/computer/bsa_control/proc/calibrate(mob/user)
	var/list/gps_locators = list()
	for(var/obj/item/device/gps/G in GPS_list) //nulls on the list somehow
		gps_locators[G.gpstag] = G

	var/list/options = gps_locators
	if(area_aim)
		options += teleportlocs
	var/V = input(user,"Select target", "Select target",null) in options|null
	target = options[V]


/obj/machinery/computer/bsa_control/proc/get_target_name()
	if(istype(target,/area))
		var/area/A = target
		return A.name
	else if(istype(target,/obj/item/device/gps))
		var/obj/item/device/gps/G = target
		return G.gpstag

/obj/machinery/computer/bsa_control/proc/get_impact_turf()
	if(istype(target,/area))
		return pick(get_area_turfs(target))
	else if(istype(target,/obj/item/device/gps))
		return get_turf(target)

/obj/machinery/computer/bsa_control/proc/fire(mob/user)
	if(cannon.stat)
		notice = "Cannon unpowered!"
		return
	notice = null
	cannon.use_power(cannon.power_used_per_shot)
	cannon.fire()
	ready = FALSE
	var/turf/bullseye = get_impact_turf()
	message_admins("[key_name_admin(usr)] has launched an artillery strike.")
	explosion(bullseye,cannon.ex_power,cannon.ex_power*2,cannon.ex_power*4)
	addtimer(src,"ready_cannon",600)

/obj/machinery/computer/bsa_control/proc/ready_cannon()
	ready = TRUE

/obj/machinery/computer/bsa_control/proc/deploy(force=FALSE)
	var/obj/machinery/bsa/full/prebuilt = locate() in range(7) //In case of adminspawn
	if(prebuilt)
		ready = TRUE
		return prebuilt

	var/obj/machinery/bsa/middle/centerpiece = locate() in range(7)
	if(!centerpiece)
		notice = "No BSA parts detected nearby."
		return null
	notice = centerpiece.check_completion()
	if(notice)
		return null
	//Totally nanite construction system not an immersion breaking spawning
	var/datum/effect_system/smoke_spread/s = new
	s.set_up(4, 1, get_turf(centerpiece), 0)
	s.start()
	var/obj/machinery/bsa/full/cannon = new(get_turf(centerpiece),cannon_direction=centerpiece.get_cannon_direction())
	qdel(centerpiece.front)
	qdel(centerpiece.back)
	qdel(centerpiece)
	ready = TRUE
	return cannon
