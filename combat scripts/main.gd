extends Control

enum unit_act {STOP, ACT, PROCEED}

"""
Handles combat interface and main stepping logic.

currently working on:

Act menu:
- pause game and float camera over
- unit is selected (by game, for now: trivial)
- select action (by clicking button/pressing number key)
now you are in 'plan action' mode:
- as you move your mouse, draw a line from the unit to the mouse location. this shows the unit's predicted path.
- when you click, it locks the move down. the plan line stays exactly as you left it.
- time resumes and the unit executes it.

"""


@export var selected_unit: UnitBody
var selected_act: unit_act

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# ui setup

	# test setup
	selected_act = unit_act.ACT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	# listening for keyboard input when in order mode:
	if selected_act == unit_act.ACT:
		# listen for input (move selection '1|2|3|4')
		if Input.is_action_pressed("num_1_key"):
			_move_command()
		elif Input.is_action_pressed("num_2_key"):
			_action_command()
		elif Input.is_action_pressed("num_3_key"):
			_action_command()
		elif Input.is_action_pressed("num_4_key"):
			_action_command()
		
		# listen for input (move lock-in 'left click')
		if selected_unit.current_order == 1 or selected_unit.current_order == 2:
			if Input.is_action_pressed("lmb_click"):
				_lock_command()
				# we can now continue time as well

## User Interface
func stop_and_await_orders() -> void:
	# called when the game pauses and the player should order a unit
	# order camera move to this specific part of the map
	#selected_unit = guy
	selected_act = unit_act.ACT

func _move_command() -> void:
	# called when '1' pressed
	selected_unit.move_mode()

func _action_command() -> void:
	# called when '2|3|4' are pressed
	selected_unit.action_mode()

func _lock_command() -> void:
	# called when the player finishes an action, locks it in and resumes game
	selected_unit.lock_mode()
	selected_act = unit_act.PROCEED
