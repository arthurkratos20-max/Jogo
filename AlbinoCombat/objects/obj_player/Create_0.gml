state = PLAYER_STATE.FREE; move_speed = 3.5; body_radius = 13;
aim_dir = 90; locked_aim_dir = 90; facing8 = 2;
input = new InputState(); weapons = new WeaponManager(); combo_buffer = new InputBuffer();
attack = undefined; attack_kind = "light"; attack_timer = 0; attack_phase = ATTACK_PHASE.STARTUP;
combo_step = 0; hit_enemies = []; invulnerable = false;
dodge_timer = 0; dodge_roll = false; dodge_dir = 0; last_dodge_press = -100;
lock_target = noone; hp = 100; stagger_timer = 0;
queued_throw = ""; pending_aim_pressed = false; pending_recall = false; pending_light = false; pending_heavy = false; pending_dodge = false; pending_weapon = -1;

my_axe = instance_create_layer(x, y, "Actors", obj_axe);
my_axe.owner = id;

blade_pose = new BladePose();
my_blades = instance_create_layer(x, y, "Actors", obj_blades);
my_blades.owner = id;

spears = []; max_spears = 5;
my_spear = instance_create_layer(x, y, "Actors", obj_spear);
my_spear.owner = id;

shield = new ShieldController(); max_hp = 100; last_defense_result = "Pronto"; pending_block = false;
knockback_dir = 0; knockback_force = 0; knockback_friction = 0.6;

rage = {active: false, meter: 100, max_meter: 100, previous_weapon: WEAPON.AXE};
execution_target = noone; execution_timer = 0; execution_struck = false;
pending_execute = false; pending_rage = false;

execution_path = []; execution_approach_timer = 0;
