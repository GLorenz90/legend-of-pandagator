extends Character
class_name PlayerCharacter;

signal action_changed(prev_action: Enums.CHAR_STATES, next_action: Enums.CHAR_STATES);

@export var char_type:Enums.CHARACTERS;
@export var is_p1 := true;
@export var debug_actions := false;

const SHAPE_NORMAL: CapsuleShape3D = preload("res://resources/shapes/player_shape_normal.tres");
const SHAPE_ROLL: CapsuleShape3D = preload("res://resources/shapes/player_shape_roll.tres");

#region PRIVATE VARS ===============================================================================
var _input_buffer;
var _in_move := Vector2.ZERO;
var _in_roll := false;
var _in_attack := false;
var _in_interact := false;
var _in_use_item := false;
var _in_next_item := false;
var _in_prev_item := false;

# Seconds since each action was last pressed. INF = nothing buffered.
var _buf_roll := INF;
var _buf_attack := INF;
var _buf_interact := INF;

var _action: Enums.CHAR_STATES = Enums.CHAR_STATES.INIT;
var _action_time := 0.0;
var _recoil_dir := Vector3.ZERO;
#endregion =========================================================================================

#region BUILT IN FUNCTIONS =========================================================================
func _ready() -> void:
  super();
  _max_health = CharStats.MAX_HEALTH;
  _cur_health = CharStats.P1_CURRENT_HEALTH if is_p1 else CharStats.P2_CURRENT_HEALTH;
  _set_action(Enums.CHAR_STATES.FREE);
#/_ready

func _physics_process(delta: float) -> void:
  super(delta);
  _process_inputs(delta);
  _process_action(delta);
  _process_movement(delta);
#/_physics_process
#endregion =========================================================================================

#region PRIVATE FUNCTIONS ==========================================================================
func _process_inputs(delta: float) -> void:
  _input_buffer = Global.input_manager.p1_input_buffer if is_p1 else Global.input_manager.p2_input_buffer;
  _in_move = _input_buffer[Enums.INPUT_BUFFER.MOVE];
  _in_roll = _input_buffer[Enums.INPUT_BUFFER.ROLL_PRESSED];
  _in_attack = _input_buffer[Enums.INPUT_BUFFER.ATTACK_PRESSED];
  _in_interact = _input_buffer[Enums.INPUT_BUFFER.INTERACT_PRESSED];
  _in_use_item = _input_buffer[Enums.INPUT_BUFFER.USE_ITEM_PRESSED];
  _in_next_item = _input_buffer[Enums.INPUT_BUFFER.NEXT_ITEM_PRESSED];
  _in_prev_item = _input_buffer[Enums.INPUT_BUFFER.PREV_ITEM_PRESSED];

  # A press stays "live" for MAX_INPUT_BUFFER_TIME so it can fire as soon as the
  # current action allows it, instead of being dropped mid-swing.
  _buf_roll = 0.0 if _in_roll else _buf_roll + delta;
  _buf_attack = 0.0 if _in_attack else _buf_attack + delta;
  _buf_interact = 0.0 if _in_interact else _buf_interact + delta;
#/_process_inputs

func _is_buffered(time_since_press: float) -> bool:
  return time_since_press <= CharStats.MAX_INPUT_BUFFER_TIME;
#/_is_buffered

func _move_dir() -> Vector3:
  return Vector3(_in_move.x, 0.0, _in_move.y);
#/_move_dir

func _process_movement(delta: float) -> void:
  var rule := _rules();
  var horizontal := Vector3.ZERO;

  match _action:
    Enums.CHAR_STATES.ROLLING:
      horizontal = -global_basis.z * CharStats.ROLL_SPEED;
    Enums.CHAR_STATES.HURT:
      # Knockback that eases out over the hurt time.
      var falloff := 1.0 - clampf(_action_time / rule.cancel_after, 0.0, 1.0);
      horizontal = _recoil_dir * CharStats.HURT_KNOCKBACK_SPEED * falloff;
    _:
      # TODO: Interpolate
      horizontal = _move_dir().normalized() * CharStats.WALK_SPEED * rule.move;
  #/match

  velocity.x = horizontal.x;
  velocity.z = horizontal.z;

  if !is_on_floor():
    if(velocity.y > -2.0): velocity.y = -2.0;
    velocity.y = clamp(velocity.y - (_gravity * rule.gravity * delta), -Global.MAX_Y_SPEED, Global.MAX_Y_SPEED);
  else:
    velocity.y = 0.0;
  #/if
  move_and_slide();

  if rule.turn && !_in_move.is_zero_approx():
    # TODO: Interpolate
    _face(_move_dir());
  #/if
#/_process_movement

func _face(dir: Vector3) -> void:
  look_at(global_position + dir, Vector3.UP);
#/_face

func _die():
  pass;
  # Either become ghost, or go to game over screen.
#/_die
#endregion =========================================================================================

#region ACTION STATE ===============================================================================
func _rules_for(state: Enums.CHAR_STATES) -> Dictionary:
  return CharStats.ACTION_RULES[state];
#/_rules_for

func _rules() -> Dictionary:
  return _rules_for(_action);
#/_rules

# Can the current state be interrupted by `flag` ("attack", "roll", "jump") to enter `target`?
func _can_interrupt_into(flag: String, target: Enums.CHAR_STATES) -> bool:
  var rule := _rules();
  if !rule[flag] || rule.interrupt_after < 0.0 || _action_time < rule.interrupt_after:
    return false;
  #/if
  if _rules_for(target).ground_only && !is_on_floor():
    return false;
  #/if
  return true;
#/_can_interrupt_into

func _set_action(next: Enums.CHAR_STATES) -> void:
  var prev: Enums.CHAR_STATES = _action;
  _action = next;
  _action_time = 0.0;

  # Swap to the short capsule while rolling, keeping its base on the floor.
  if next == Enums.CHAR_STATES.ROLLING || prev == Enums.CHAR_STATES.ROLLING:
    var shape: CapsuleShape3D = SHAPE_ROLL if next == Enums.CHAR_STATES.ROLLING else SHAPE_NORMAL;
    $Collision.shape = shape;
    $Collision.position.y = shape.height * 0.5;
  #/if

  if debug_actions:
    print("%s: %s -> %s" % [name, Enums.CHAR_STATES.keys()[prev], Enums.CHAR_STATES.keys()[next]]);
  #/if
  action_changed.emit(prev, next);
#/_set_action

func _process_action(delta: float) -> void:
  _action_time += delta;

  # cancel_after: the action is over, back to FREE. (< 0 = only ends by its own rules, e.g. INTERACT)
  var cancel_after: float = _rules().cancel_after;
  if _action != Enums.CHAR_STATES.FREE && cancel_after >= 0.0 && _action_time >= cancel_after:
    _set_action(Enums.CHAR_STATES.FREE);
  #/if

  # interrupt_after: the action may be cut short by any action its rules allow.
  # Roll is checked first so a dodge always wins over a swing pressed the same frame.
  if _is_buffered(_buf_roll) && _can_interrupt_into("roll", Enums.CHAR_STATES.ROLLING):
    _buf_roll = INF;
    _start_roll();
    return;
  #/if

  # TODO: Jump. The rules support it ("jump" flag, e.g. roll -> jump), but there's no input yet.

  if _is_buffered(_buf_attack):
    var next_attack: Enums.CHAR_STATES = _next_attack_state();
    if _can_interrupt_into("attack", next_attack):
      _buf_attack = INF;
      _start_attack(next_attack);
      return;
    #/if
  #/if

  # Interact only starts from FREE, on the ground, and only if there's something to interact with.
  if _is_buffered(_buf_interact) && _action == Enums.CHAR_STATES.FREE && is_on_floor():
    var target := _find_interactable();
    if target:
      _buf_interact = INF;
      _invulnerable = true;
      _set_action(Enums.CHAR_STATES.INTERACT);
      # TODO: target.interact(self), which calls end_interact() when it's done
    #/if
  #/if
#/_process_action

func _next_attack_state() -> Enums.CHAR_STATES:
  return Enums.CHAR_STATES.SWORD_2 if _action == Enums.CHAR_STATES.SWORD_1 else Enums.CHAR_STATES.SWORD_1;
#/_next_attack_state

func _start_roll() -> void:
  # Roll toward the stick if it's held, otherwise the way we're facing.
  if !_in_move.is_zero_approx():
    _face(_move_dir());
  #/if
  _set_action(Enums.CHAR_STATES.ROLLING);
#/_start_roll

func _start_attack(state: Enums.CHAR_STATES) -> void:
  # Turning is locked during swings, so snap to the stick on the first frame.
  if !_in_move.is_zero_approx():
    _face(_move_dir());
  #/if
  _set_action(state);
  # TODO: Spawn / enable sword hitbox
#/_start_attack

func _find_interactable() -> Node3D:
  # TODO: Check an Area3D in front of the player for interactables (signs, chests, pots).
  return null;
#/_find_interactable
#endregion =========================================================================================

#region PUBLIC FUNCTIONS ===========================================================================
func end_interact() -> void:
  _invulnerable = false;
#/end_interact
#endregion =========================================================================================
