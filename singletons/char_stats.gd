extends Node

#region CONSTANTS ==============================================================
const MAX_VELOCITY := 25.0;
const MAX_COYOTE_TIME := 0.15;
const MAX_INPUT_BUFFER_TIME := 0.2;

const BASE_WALK_SPEED := 6;
const BASE_ROLL_SPEED := 12.0;
const BASE_ROLL_TIME := 0.4;
const BASE_JUMP_TIME := 0.08;
const BASE_JUMP_VELOCITY := 200.0;
const BASE_HURT_VELOCITY := 150.0;
const BASE_MAX_HEALTH := 6;

const HURT_TIME := .75;
const INVULN_TIME := 2.0;

var ACTION_RULES = {
  # Free action rules, these can interrupt each other sometimes, and interact with each other
  Enums.CHAR_STATES.FREE:       { move = 1.0, ground_only = false, turn = true, attack = true, roll = true, jump = true, gravity = 1.0, interrupt_after = 0.0, cancel_after = 0.0 },
  Enums.CHAR_STATES.ROLLING:    { move = 0.0, ground_only = true, turn = false, attack = true, roll = false, jump = true, gravity = 1.0, interrupt_after = ROLL_TIME/2.0, cancel_after = ROLL_TIME },
  Enums.CHAR_STATES.SWORD_1:    { move = 0.3, ground_only = false, turn = false, attack = true, roll = true, jump = true, gravity = 0.4, interrupt_after = 0.1, cancel_after = 0.2 },
  Enums.CHAR_STATES.SWORD_2:    { move = 0.3, ground_only = false, turn = false, attack = false, roll = true, jump = true, gravity = 0.4, interrupt_after = 0.2, cancel_after = 0.3 },
  # Special states with their own rules to enter and exit
  Enums.CHAR_STATES.INIT:       { move = 0.0, ground_only = false, turn = false, attack = false, roll = false, jump = false, gravity = 0.0, interrupt_after = -1.0, cancel_after = -1.0 },
  Enums.CHAR_STATES.PICKING_UP: { move = 0.0, ground_only = true, turn = false, attack = false, roll = false, jump = false, gravity = 0.0, interrupt_after = -1.0, cancel_after = -1.0 },
  Enums.CHAR_STATES.HURT:       { move = 0.0, ground_only = false, turn = false, attack = false, roll = false, jump = false, gravity = 1.0, interrupt_after = -1.0, cancel_after = HURT_TIME },
}
#endregion

#region ADJUSTABLES ============================================================
# These should always start at 0 on new game.
var ADJUST_WALK_SPEED := 0.0;
var ADJUST_ROLL_SPEED := 0.0;
var ADJUST_ROLL_TIME := 0.0;
var ADJUST_JUMP_TIME := 0.0;
var ADJUST_JUMP_VELOCITY := 0.0;
var ADJUST_MAX_HEALTH := 0;

var WALK_SPEED: float:
  get: return BASE_WALK_SPEED + ADJUST_WALK_SPEED;
var ROLL_SPEED: float:
  get: return BASE_ROLL_SPEED + ADJUST_ROLL_SPEED;
var ROLL_TIME: float:
  get: return BASE_ROLL_TIME + ADJUST_ROLL_TIME;
var JUMP_TIME: float:
  get: return BASE_JUMP_TIME + ADJUST_JUMP_TIME;
var JUMP_VELOCITY: float:
  get: return BASE_JUMP_VELOCITY + ADJUST_JUMP_VELOCITY;
var MAX_HEALTH: int:
  get: return BASE_MAX_HEALTH + ADJUST_MAX_HEALTH;
#endregion

#region PLAYER STATS =========================================================
var P1_CURRENT_HEALTH := MAX_HEALTH:
  set(value):
    P1_CURRENT_HEALTH = clampi(value, 0, MAX_HEALTH);
var P2_CURRENT_HEALTH := MAX_HEALTH:
  set(value):
    P2_CURRENT_HEALTH = clampi(value, 0, MAX_HEALTH);

var CURRENT_MONEY := 0;
#endregion
