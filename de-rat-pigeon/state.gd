## Virtual base class for all states.
## Extend this class and override its methods to implement a state.
class_name State extends Node


const IDLE = "Idle"
const RUNNING = "Running"
const JUMPING = "Jumping"
const FALLING = "Falling"
const WALL_SLIDING = "WallSliding"

var player: Player
var stateVersion:bool


func _ready() -> void:
	await owner.ready
	#player = owner.player as Player
	#assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")


## Emitted when the state finishes and wants to transition to another state.
signal finished(next_state_path: String, data: Dictionary)

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	pass

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass
