extends Node2D

"""
Handles user interface and game coordination.

had a frustrating bug where suddenly all exports and stuff stopped working.
hardcoding paths works, so in the name of making progress, i'll continue like this, i suppose.
"""

@export var main_camera: Camera2D 

#var unitManager: UnitHolder
var unitManager: UnitHolder = UnitHolder.new()
var selected_unit: UnitBody
var unit_in_world: UnitBody

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# ui setup
	 #main_camera.setup_borders(abs_dist_to_x_border, abs_dist_to_y_border)

	# test setup
	Coeffs.state = Coeffs.game_state.PROCEED
	selected_unit = null
	
	create_world.call_deferred()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	# set the current state of the game
	run_game(delta)
	
	# listening for keyboard input when in order mode:
	if Coeffs.state == Coeffs.game_state.RESOLVE_ACT and selected_unit:
		# listen for input (move selection '1|2|3|4')
		if Input.is_action_pressed("num_1_key"):
			_plan_command(0)
		elif Input.is_action_pressed("num_2_key"):
			_plan_command(1)
		elif Input.is_action_pressed("num_3_key"):
			_plan_command(2)
		elif Input.is_action_pressed("num_4_key"):
			_plan_command(3)
		
		# listen for input (move lock-in 'left click')
		if selected_unit.current_order == 1 or selected_unit.current_order == 2:
			if Input.is_action_pressed("lmb_click"):
				_lock_command()
				# we can now continue time as well

## Setup
func create_world() -> void:
	spawn_unit()

func spawn_unit() -> void:
	var unit_scene: PackedScene = load("res://combat scenes/test_unit.tscn")
	
	unit_in_world = unit_scene.instantiate()
	unit_in_world.position = Vector2(500, 350)
	#unitManager.add_child(unit_in_world)
	unitManager.add_unit(unit_in_world)
	add_child(unit_in_world)

## Running the game
func run_game(delta):
	"""
	1. call unitHolder.look_for_hits()
		> returns null if there are no hits to witness
		> returns camera position and all the two actors if there is a hit
			> move the camera over
			> then call resolve_hit(unit 1, unit 2)
			(all the units need to know is what kind of damage they receive and knockback intensity and direction they will experience later.)
			(The two units' positions, states, and current actions are sufficient information to calculate everything.)
		call unitHolder.look_for_hits() until there are no more hits to report.
		
	2. call unitHolder.look_for_units_ready_to_order()
		> returns null if there are no units ready to receive orders (i.e. whose state is recovery and whose recovery ticks are equal to 0)
		> returns camera position and the actor in question if there is someone ready
			> move the camera over
				> if an ai unit, decide that way
				> if a player unit, then enter ACT state and wait for player input
		call unitHolder.look_for_hits() until there are no more hits to report.
		
	3. finally, if you made it this far, then set the game state to proceed and let units move
	"""
	#print_debug(Coeffs.state)
	if Coeffs.state != Coeffs.game_state.PROCEED:
		return
	
	#if unitManager.look_for_hits():
		## TODO still needs to be implemented
		#print_debug("here")
		#resolve_hit(unitManager.position_of_interest, unitManager.units_of_interest)
		#return
	
	if unitManager.look_for_units_ready_to_order():
		resolve_ready_to_order(unitManager.position_of_interest, unitManager.units_of_interest)
		return
	
	# otherwise,
	Coeffs.state = Coeffs.game_state.PROCEED
	unitManager.pass_ticks_for_units(delta)

func resolve_hit(over_here: Vector2, _units: Array[UnitBody]) -> void:
	camera_move(over_here)
	# we record the two units we care about
	# but then we wait for the camera to signal us back
	
func resolve_ready_to_order(over_here: Vector2, units: Array[UnitBody]) -> void:
	camera_move(over_here)
	selected_unit = units[0]  # there will only ever be a single unit here.
	Coeffs.state = Coeffs.game_state.WAITING_TO_RESOLVE_ACT
	# we must now wait for the 

func camera_move_completed() -> void:
	# called by the camera and telling us that the camera move we requested has been completed.
	# we will now witness whatever happens next.
	if Coeffs.state == Coeffs.game_state.WAITING_TO_RESOLVE_HIT:
		Coeffs.state = Coeffs.game_state.RESOLVE_HIT
	elif Coeffs.state == Coeffs.game_state.WAITING_TO_RESOLVE_ACT:
		Coeffs.state = Coeffs.game_state.RESOLVE_ACT
	else:
		print_debug("camera move reporting completed in the wrong state; you shouldn't ever see this.")

## Responding to User Input
func _plan_command(val: int) -> void:
	# called when '2|3|4' are pressed
	selected_unit.planning_mode(val)

func _lock_command() -> void:
	# called when the player finishes an action, locks it in and resumes game
	selected_unit.lock_mode()
	Coeffs.state = Coeffs.game_state.PROCEED

## Helpers
func camera_move(over_here: Vector2) -> void:
	main_camera.move_over_there(over_here)
