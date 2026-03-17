extends Node

"""
Coeffs, which holds constants useful for everyone in game.


"""

""" Game Running, not constants (because i am your sworn enemy) """
enum game_state {WAITING_TO_RESOLVE_HIT, RESOLVE_HIT, WAITING_TO_RESOLVE_ACT, RESOLVE_ACT, PROCEED} 
var state: game_state = game_state.PROCEED
func can_proceed() -> bool:
	return state == game_state.PROCEED

""" Movement Constants """
const rotation_constant: float = 2 * PI
const speed_constant: float = 5000
const acceleration_constant: float = 10
const camera_constant: int = 4000
const camera_zoom_step: float = 0.05
