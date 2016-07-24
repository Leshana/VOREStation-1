/obj/item/frame
	name = "frame parts"
	desc = "Used for building frames."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "frame_bitem"
	flags = CONDUCT
	var/build_machine_type
	var/refund_amt = 5
	var/refund_type = /obj/item/stack/material/steel
	var/reverse = 0 //if resulting object faces opposite its dir (like light fixtures)
	var/list/frame_types_floor
	var/list/frame_types_wall

/obj/item/frame/proc/update_type_list()
	if(!frame_types_floor)
		frame_types_floor = construction_frame_floor
	if(!frame_types_wall)
		frame_types_wall = construction_frame_wall

/obj/item/frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		new refund_type(get_turf(loc), refund_amt)
		qdel(src)
		return
	..()

/obj/item/frame/attack_self(mob/user as mob)
	..()
	update_type_list()
	var/datum/frame/frame_types/frame_type
	if(!build_machine_type)
		var/datum/frame/frame_types/response = input(usr, "What kind of frame would you like to make?", "Frame type request", null) in frame_types_floor
		if(!response || response.name == "Cancel")
			return
		frame_type = response

		build_machine_type = /obj/structure/frame

		if(frame_type.frame_size != 5)
			new /obj/item/stack/material/steel(usr.loc, (5 - frame_type.frame_size))

	var/ndir
	ndir = usr.dir
	if(!(ndir in cardinal))
		return

	var/obj/machinery/M = new build_machine_type(get_turf(loc), ndir, 1, frame_type)
	M.fingerprints = fingerprints
	M.fingerprintshidden = fingerprintshidden
	M.fingerprintslast = fingerprintslast
	qdel(src)

/obj/item/frame/proc/try_build(turf/on_wall, mob/user as mob)
	update_type_list()
	var/datum/frame/frame_types/frame_type
	if(!build_machine_type)
		var/datum/frame/frame_types/response = input(usr, "What kind of frame would you like to make?", "Frame type request", null) in frame_types_wall
		if(!response || response.name == "Cancel")
			return
		frame_type = response

		build_machine_type = /obj/structure/frame

		if(frame_type.frame_size != 5)
			new /obj/item/stack/material/steel(usr.loc, (5 - frame_type.frame_size))

	if(get_dist(on_wall,usr)>1)
		return

	var/ndir
	if(reverse)
		ndir = get_dir(usr,on_wall)
	else
		ndir = get_dir(on_wall,usr)

	if(!(ndir in cardinal))
		return

	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if(!istype(loc, /turf/simulated/floor))
		usr << "<span class='danger'>\The frame cannot be placed on this spot.</span>"
		return

	if(A.requires_power == 0 || A.name == "Space")
		usr << "<span class='danger'>\The [src] Alarm cannot be placed in this area.</span>"
		return

	if(gotwallitem(loc, ndir))
		usr << "<span class='danger'>There's already an item on this wall!</span>"
		return

	var/obj/machinery/M = new build_machine_type(loc, ndir, 1, frame_type)
	M.fingerprints = fingerprints
	M.fingerprintshidden = fingerprintshidden
	M.fingerprintslast = fingerprintslast
	qdel(src)

/obj/item/frame/light
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	build_machine_type = /obj/machinery/light_construct
	reverse = 1

/obj/item/frame/light/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-item"
	refund_amt = 1
	build_machine_type = /obj/machinery/light_construct/small

/obj/item/frame/extinguisher_cabinet
	name = "extinguisher cabinet frame"
	desc = "Used for building fire extinguisher cabinets."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_empty"
	refund_amt = 4
	build_machine_type = /obj/structure/extinguisher_cabinet

/obj/item/frame/noticeboard
	name = "noticeboard frame"
	desc = "Used for building noticeboards."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	refund_amt = 4
	refund_type = /obj/item/stack/material/wood
	build_machine_type = /obj/structure/noticeboard

/obj/item/frame/mirror
	name = "mirror frame"
	desc = "Used for building mirrors."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror_frame"
	refund_amt = 1
	build_machine_type = /obj/structure/mirror

/obj/item/frame/fireaxe_cabinet
	name = "fire axe cabinet frame"
	desc = "Used for building fire axe cabinets."
	icon = 'icons/obj/closet.dmi'
	icon_state = "fireaxe0101"
	refund_amt = 4
	build_machine_type = /obj/structure/closet/fireaxecabinet