extends Character
class_name PlayerCharacter;

@export var char_type:Enums.CHARACTERS;
@export var is_p1 := true;

#region PRIVATE VARS ===============================================================================
var _input_buffer;
var _in_move := Vector2.ZERO;
var _in_roll := false;
var _in_attack := false;
var _in_interact := false;
var _in_use_item := false;
var _in_next_item := false;
var _in_prev_item := false;

var _move_vector := Vector3.ZERO;
#endregion =========================================================================================

#region BUILT IN FUNCTIONS =========================================================================
func _ready() -> void:
  super();
  _max_health = CharStats.MAX_HEALTH;
  _cur_health = CharStats.P1_CURRENT_HEALTH if is_p1 else CharStats.P2_CURRENT_HEALTH;
#/_ready

func _physics_process(delta: float) -> void:
  super(delta);
  _process_inputs();
  _process_movement(delta);
#/_physics_process
#endregion =========================================================================================

#region PRIVATE FUNCTIONS ==========================================================================
func _process_inputs() -> void:
  _input_buffer = Global.input_manager.p1_input_buffer if is_p1 else Global.input_manager.p2_input_buffer;
  _in_move = _input_buffer[Enums.INPUT_BUFFER.MOVE];
  _in_roll = _input_buffer[Enums.INPUT_BUFFER.ROLL_PRESSED];
  _in_attack = _input_buffer[Enums.INPUT_BUFFER.ATTACK_PRESSED];
  _in_interact = _input_buffer[Enums.INPUT_BUFFER.INTERACT_PRESSED];
  _in_use_item = _input_buffer[Enums.INPUT_BUFFER.USE_ITEM_PRESSED];
  _in_next_item = _input_buffer[Enums.INPUT_BUFFER.NEXT_ITEM_PRESSED];
  _in_prev_item = _input_buffer[Enums.INPUT_BUFFER.PREV_ITEM_PRESSED];
#/_process_inputs

func _process_movement(delta: float) -> void:
  var adjusted_move_speed := CharStats.WALK_SPEED;
  # do not include y so that it's not adjusted by move speed
  # TODO: Interpolate
  _move_vector = Vector3(_in_move.y, 0.0, _in_move.x).normalized() * adjusted_move_speed;
  _move_vector.y = velocity.y;

  velocity = _move_vector;
  if !is_on_floor():
    if(velocity.y > -2.0): velocity.y = -2.0;
    velocity.y = clamp(velocity.y - (_gravity * delta), -Global.MAX_Y_SPEED, Global.MAX_Y_SPEED);
  else:
    velocity.y = 0.0;
  move_and_slide();

  if(!_in_move.is_zero_approx()):
    # TODO: Interpolate
    var facing_point = global_position + Vector3(_in_move.y, 0.0, _in_move.x);
    look_at(facing_point, Vector3.UP);
  #/if
#/_process_movement

func _die():
  pass;
  # Either become ghost, or go to game over screen.
#/_die
#endregion =========================================================================================

#region PUBLIC FUNCTIONS ===========================================================================
#endregion =========================================================================================
