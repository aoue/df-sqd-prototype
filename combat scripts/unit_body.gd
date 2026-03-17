extends CharacterBody2D

class_name UnitBody
enum order_mode {INACTIVE, PLANNING, LOCKED}
enum unit_state {REC, ACT, PREP, EXEC}

const circle_radius = 600

@export var animator: AnimatedSprite2D
@export var facing_arrow: Sprite2D
@export var travel_line: Line2D

var set_animation: bool
var current_order: order_mode
var current_state: unit_state
var dest: Vector2
var moving: bool
var attacking: bool

var speed: int = 500
var acceleration: int = 2000

## Ticks
@export var tick_display_label: Label
var rec_ticks: int
var prep_ticks: int
var exec_ticks: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_order = order_mode.INACTIVE
	current_state = unit_state.REC
	rec_ticks = 100
	set_animation = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	if current_order == order_mode.PLANNING:
		# clear all points
		# then draw line to mouse position
		travel_line.clear_points()
		travel_line.add_point(get_facing_direction_vector()  * circle_radius)
		travel_line.add_point(to_local(get_travel_line_first_point_mouse_relative()))
		travel_line.add_point(to_local(get_travel_mouse_position()))
		
	elif Coeffs.can_proceed(): 
		if current_order == order_mode.LOCKED:
			if current_state == unit_state.PREP or current_state == unit_state.EXEC:
				travel_line.clear_points()
				travel_line.add_point(get_facing_direction_vector()  * circle_radius)
				travel_line.add_point(to_local(get_travel_line_first_point_dest_relative()))
				travel_line.add_point(to_local(dest))
			
			if current_state == unit_state.EXEC:
				facing_arrow.rotate(Coeffs.rotation_constant * delta * get_rotation_direction())
				
				speed = min(speed + (acceleration * delta), 4000)
				velocity = get_facing_direction_vector() * speed
				
				# Early exit; check if you've arrived at your destination.
				#print_debug(position.distance_squared_to(dest))
				if position.distance_squared_to(dest) < 1000:
					position = dest
					current_state = unit_state.REC
					travel_line.clear_points()
					
			elif current_state == unit_state.REC:
				# then deccelerate instead
				travel_line.clear_points()
				speed = max(speed - (5 * acceleration * delta), 0)
				velocity = get_facing_direction_vector() * speed
				
			move_and_slide()
				
		animate()
		#pass_ticks()
		
		# check if arrived at target
		# - this will preemptively end the exec phase and have you enter rec
		
		"""
		regarding velocity and acceleration:
			carries over between actions? so if you were moving fast at the end of last action, you still would be now
		"""

## Helpers
func get_rotation_direction() -> int:
	# returns 0, 1, or -1 to be multiplied with rotation.
	# negative angle means you have already passed it, clockwise
	# positive angle whens you have not yet passed it, clockwise
	var face_to_dest_angle: float = (get_facing_direction_vector() * circle_radius).angle_to(to_local(dest))
	
	if abs(face_to_dest_angle) < 0.05:
		facing_arrow.rotation = get_direction_vector_to_dest().angle()
		return 0
	if face_to_dest_angle < 0:
		return -1
	else:
		return 1
	
func get_facing_direction_vector() -> Vector2:
	return Vector2(cos(facing_arrow.rotation), sin(facing_arrow.rotation)).normalized()

func get_travel_line_first_point_mouse_relative() -> Vector2:
	var first_point: Vector2 = (get_direction_vector_to_mouse() * circle_radius) + position
	return first_point

func get_travel_line_first_point_dest_relative() -> Vector2:
	var first_point: Vector2 = (get_direction_vector_to_dest() * circle_radius) + position
	return first_point

func get_direction_vector_to_mouse() -> Vector2:
	return (get_travel_mouse_position() - position).normalized()

func get_direction_vector_to_dest() -> Vector2:
	return (dest - position).normalized()
	
func get_travel_mouse_position() -> Vector2:
	return get_global_mouse_position()

## Relatig to Orders and Acting
func planning_mode(_arg_value: int) -> void:
	# called by main, and tells you to start showing visual info for planning mode.
	# in here, you will in real time:
	# - draw your line to where the mouse is
	# - display the tick prediction for how long the action will take (?)
	# - arg_value is used so we know which move the player is thinking of using.
	travel_line.clear_points()
	current_order = order_mode.PLANNING

func lock_mode() -> void:
	# record information for prep and exec phases
	dest = to_global(travel_line.get_point_position(2))
	
	# then change phase. this will also let the boss know we can continue time
	current_order = order_mode.LOCKED
	current_state = unit_state.PREP
	
	# temp
	set_animation = false
	
	# set ticks here for now; in the future, you'll scrape this info from the move in question.
	rec_ticks = 80
	prep_ticks = 40
	exec_ticks = 120  # something relative to the distance for all types; i.e. moving further takes longer, or aiming further takes longer

func pass_ticks(delta) -> void:
	if current_state == unit_state.REC:
		rec_ticks = max(rec_ticks - delta, 0)
		if rec_ticks == 0:
			current_state = unit_state.ACT
			
	elif current_state == unit_state.ACT:
		return
		
	elif current_state == unit_state.PREP:
		prep_ticks = max(prep_ticks - delta, 0)
		if prep_ticks == 0:
			current_state = unit_state.EXEC
			
	elif current_state == unit_state.EXEC:
		exec_ticks = max(exec_ticks - delta, 0)
		if exec_ticks == 0:
			current_state = unit_state.REC
	display_ticks()

## Visuals
func display_ticks() -> void:
	"""
	use tick_label to show relevant tick count. 
	Possible states:
		- REC: 'rec_ticks|REC'
		- ACT: 'ACT'
		- PREP and EXEC: 'prep_ticks|exec_ticks'
	"""
	if current_state == unit_state.REC:
		tick_display_label.text = str(rec_ticks) + "|REC"
	elif current_state == unit_state.ACT:
		tick_display_label.text = "ACT"
	else: 
		tick_display_label.text = str(prep_ticks) + "|" + str(exec_ticks)

func animate() -> void:
	if set_animation:
		return
	# flip if relevant
	var direction_help_vector: Vector2 = get_facing_direction_vector()
	if direction_help_vector.x > 0:
		animator.flip_h = false
	else:
		animator.flip_h = true
	
	# check state
	# -prep
	# -rec
	# -moving
	# -attacks (not yet implemented)
	if current_state == unit_state.REC:
		animator.play("0_rec")
	elif current_state == unit_state.ACT:
		#animator.play("1_prep")
		pass
	elif current_state == unit_state.PREP:
		animator.play("1_prep")
	elif current_state == unit_state.EXEC:
		animator.play("2_exec")
		## TODO still have to draw it
		
	
	
