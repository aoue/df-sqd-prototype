class_name UnitHolder

"""
Holds and checks up on the units for Main.
- reports on hits and orders.
"""


var all_units: Array[UnitBody] = []
var position_of_interest: Vector2 = Vector2.ZERO
var units_of_interest: Array[UnitBody] = []  # array of units involved in the event

## Reporting on events for Main
func look_for_hits() -> bool:
	# check every unit to see if any are in collision a projectile or another unit
	return false

func look_for_units_ready_to_order() -> bool:
	# go through all units and check to see:
	# - in ACT (entered when unit was in recovery and had 0 rec ticks left)
	for unit in all_units:
		if unit.current_state == UnitBody.unit_state.ACT:
			position_of_interest = unit.position
			units_of_interest = [unit]
			return true
	
	return false

## Managing Units
func pass_ticks_for_units() -> void:
	for unit in all_units:
		unit.pass_ticks()

func add_unit(add_me: UnitBody) -> void:
	print_debug(add_me)
	all_units.append(add_me)

func remove_unit(remove_me: UnitBody) -> void:
	all_units.erase(remove_me)
