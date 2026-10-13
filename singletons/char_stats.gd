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

# How long each attack is
# How long must a state wait before the next attack can happen
# < 0 = cannot attack
# 0 = can attack without delay
# > 0 = attack with delay after
const ATTACK_TIMING = {
  Enums.CHAR_STATES.INIT: -1.0,
  Enums.CHAR_STATES.IDLE: 0.0,
  Enums.CHAR_STATES.RUNNING: 0.0,
  Enums.CHAR_STATES.ROLLING: -1.0,
  Enums.CHAR_STATES.JUMPING: 0.0,
  Enums.CHAR_STATES.FALLING: 0.0,
  Enums.CHAR_STATES.PICKING_UP: -1.0,
  Enums.CHAR_STATES.SWORD_1: 0.2,
  Enums.CHAR_STATES.SWORD_2: 0.3,
  Enums.CHAR_STATES.BOW: 0.3,
  Enums.CHAR_STATES.BOMB: 0.3,
  Enums.CHAR_STATES.HURT: -1.0,
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
