extends Camera2D

"""
Listens to input from the player.
Also responds to requests from the game to go to certain areas.

"""

# used to force camera movement to a certain place.
# when true, don't listen to player commands.
var locked_for_transit: bool = false  
var ordered_dest: Vector2
var pointer_followWeight : float = 0.25

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if locked_for_transit:
		# perform the ordered move and then stop when you've arrived.
		position = lerp(position, ordered_dest, 0.1)
		if position.distance_squared_to(ordered_dest) < 0.1:
			position = ordered_dest
			locked_for_transit = false
			get_parent().camera_move_completed()
	else:
		position += get_direction_input() * Coeffs.camera_constant * get_camera_speedup() * delta
		zoom = zoom.lerp(get_zoom_input(), 0.5)

func setup_borders(x_limit: int, y_limit: int) -> void:
	limit_smoothed = true
	@warning_ignore("integer_division")
	limit_left = -x_limit / 2
	@warning_ignore("integer_division")
	limit_right = x_limit / 2
	@warning_ignore("integer_division")
	limit_bottom = y_limit / 2
	@warning_ignore("integer_division")
	limit_top = -y_limit / 2
	
func move_over_there(to_here: Vector2) -> void:
	locked_for_transit = true
	ordered_dest = to_here

## Helpers
func get_direction_input() -> Vector2:		
	var input = Vector2()
	if Input.is_action_pressed('w_key'):
		input.y -= 1
	if Input.is_action_pressed('a_key'):
		input.x -= 1
	if Input.is_action_pressed('s_key'):
		input.y += 1
	if Input.is_action_pressed('d_key'):
		input.x += 1
	return input.normalized()

func get_zoom_input() -> Vector2:
	var input: Vector2 = zoom
	if Input.is_action_just_released('zoom_in'):
		input.x = clamp(input.x + Coeffs.camera_zoom_step, 0.1, 0.3)
		input.y = clamp(input.y + Coeffs.camera_zoom_step, 0.1, 0.3)
	elif Input.is_action_just_released('zoom_out'):
		input.x = clamp(input.x - Coeffs.camera_zoom_step, 0.1, 0.3)
		input.y = clamp(input.y - Coeffs.camera_zoom_step, 0.1, 0.3)
	return input

func get_camera_speedup() -> int:
	if Input.is_action_pressed('shift_key'):
		return 3
	return 1
