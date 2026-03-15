extends CharacterBody2D

class_name UnitBody
enum order_mode {STOP, MOVE, ATTACK, LOCKED}
enum unit_state {ACT, PREP, RECOVERY, MOVE, EXEC}

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

var speed: int = 1000
var acceleration: int = 2000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_order = order_mode.STOP
	current_state = unit_state.ACT
	set_animation = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	if current_order == order_mode.MOVE or current_order == order_mode.ATTACK:
		# clear all points
		# then draw line to mouse position
		travel_line.clear_points()
		travel_line.add_point(get_facing_direction_vector()  * circle_radius)
		travel_line.add_point(to_local(get_travel_line_first_point_mouse_relative()))
		travel_line.add_point(to_local(get_travel_mouse_position()))
		
		
	elif current_order == order_mode.LOCKED:
		travel_line.clear_points()
		travel_line.add_point(get_facing_direction_vector()  * circle_radius)
		travel_line.add_point(to_local(get_travel_line_first_point_dest_relative()))
		travel_line.add_point(to_local(dest))
		
		
		
		"""
		moving:
			units can ONLY move in the direction they are facing.
			IF it so happens that dest is behind them, then they must turn to face it
			units can turn only so much per game tick
		
		regarding velocity and acceleration:
			carries over between actions? so if you were moving fast at the end of last action, you still would be now
			
			
		"""
		facing_arrow.rotate(PI * delta * get_rotation_direction())
		
		speed = min(speed + (acceleration * delta), 4000)
		velocity = get_facing_direction_vector() * speed
		move_and_slide()
		
		# check if arrived at target
		# - this will preemptively end the exec phase
		
		animate()
		
	"""
	if gamestate == proceed:
	 	then forward, by jove
		- animate
		- accelerate and move towards your target destinations
		- collide if relevant
		- decrement your prep/rec/exec ticks
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

## Being ordered
func move_mode() -> void:
	# called by main, and tells you to start showing visual info for move mode.
	# in here, you will in real time:
	# - draw your line to where the mouse is
	# - display the tick prediction for how long the action will take
	travel_line.clear_points()
	current_order = order_mode.MOVE

func action_mode() -> void:
	travel_line.clear_points()
	current_order = order_mode.ATTACK

func lock_mode() -> void:
	# record information for prep and exec phases
	if current_order == order_mode.MOVE:
		moving = true
		attacking = false
	elif current_order == order_mode.ATTACK:
		attacking = true
		moving = false
	dest = to_global(travel_line.get_point_position(2))
	
	# then change phase. this will also let the boss know we can continue time
	current_order = order_mode.LOCKED
	
	# temp
	current_state = unit_state.MOVE
	set_animation = false

## Executing
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
	if current_state == unit_state.ACT:
		pass
	
	elif current_state == unit_state.PREP:
		animator.play("0_prep")
	elif current_state == unit_state.RECOVERY:
		animator.play("1_prep")
	elif current_state == unit_state.MOVE:
		animator.play("2_move")
	elif current_state == unit_state.EXEC:
		## TODO still have to draw it
		pass
	
	
	#animator.play()
