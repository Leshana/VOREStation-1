//
// Garbage Collector Subsystem - Implements qdel() and the GC queue
//
SUBSYSTEM_DEF(turbolifts)
	name = "Turbolifts"
	wait = 10
	init_order = INIT_ORDER_TURBOLIFTS
	flags = SS_POST_FIRE_TIMING
	runlevels = RUNLEVELS_DEFAULT

	var/list/turbolift_map_holders = list()
	var/list/moving_lifts = list()	// Lifts in motion. Other code may add, but ONLY WE can remove from this list.
	var/list/currentrun = list()	// Lists still to process this cycle.

/datum/controller/subsystem/turbolifts/Initialize(start_timeofday)
	admin_notice("<span class='danger'>Initializing turbolifts</span>", R_DEBUG)
	for(var/thing in turbolift_map_holders)
		var/obj/turbolift_map_holder/lift = thing
		if(!QDELETED(lift))
			lift.initialize()
			CHECK_TICK
	return ..()

/datum/controller/subsystem/turbolifts/fire(resumed = 0)
	if (!resumed)
		src.currentrun = moving_lifts.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/liftref = currentrun[currentrun.len]
		currentrun.len--
		// Handle Lift Processing
		if(world.time < moving_lifts[liftref])
			continue
		var/datum/turbolift/lift = locate(liftref)
		if(lift.busy)
			continue
		lift.busy = 1
		var/floor_delay
		if(!(floor_delay = lift.do_move()))
			moving_lifts[liftref] = null
			moving_lifts -= liftref
			if(lift.target_floor)
				lift.target_floor.ext_panel.reset()
				lift.target_floor = null
		else
			lift_is_moving(lift,floor_delay)
		lift.busy = 0
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/turbolifts/proc/lift_is_moving(var/datum/turbolift/lift,var/floor_delay)
	moving_lifts["\ref[lift]"] = world.time + floor_delay
