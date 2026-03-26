extends Area2D

"""
Attached to a fire zone object on the map.

when a unit is inside it, you apply your effect and damage.
can only do so when game state is proceed, though.

finally, you also keep track of your lifetime and remove yourself when it has finished.
"""

var lifetime: float = 5.0
var slowdown: float = 0.5
var damage_per_tick: int = 10

func setup(arg_lifetime: float, arg_slowdown: float, arg_dpt: int) -> void:
	# called when created by a unit in its EXEC phase.
	# sets all the fire zone's attributes, like position, slow down effect, damage per tick, etc.
	lifetime  = arg_lifetime
	slowdown = arg_slowdown
	damage_per_tick = arg_dpt
	
#func _on_area_entered(area):
	#if Coeffs.can_proceed():
		#var unit = area.get_parent()
		#unit.slowdown = 0.5
#
#func _on_area_exited(area):
	#if Coeffs.can_proceed():
		#var unit = area.get_parent()
		#unit.slowdown = 1.0
