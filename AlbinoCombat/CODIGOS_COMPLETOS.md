# Códigos completos — Fase 7

## objects/obj_axe/Create_0.gml

```gml
owner = noone;
state = AXE_STATE.HAND; throw_dir = 0; spin_angle = 0;
heavy_throw = false; fly_speed = 0; fly_distance = 0; return_speed = 0;
stuck_target = noone; stuck_offset_x = 0; stuck_offset_y = 0;
hit_enemies = []; trail = [];
quick_damage = axe_damage_data(25, 28, 3);
heavy_damage = axe_damage_data(45, 45, 6);
return_damage = axe_damage_data(18, 15, 2);

```

## objects/obj_axe/Draw_0.gml

```gml
if (!instance_exists(owner)) exit;
if ((state == AXE_STATE.HAND || state == AXE_STATE.MELEE) && owner.weapons.current_weapon != WEAPON.AXE) exit;
for (var _i = 0; _i < array_length(trail); ++_i) {
    var _t = trail[_i]; draw_set_color(c_aqua); draw_set_alpha(_t.life / 20);
    draw_circle(_t.x, _t.y, 4, false);
}
draw_set_alpha(1); draw_axe_shape(x, y - 12, spin_angle, 1);
if (global.debug_combat) {
    draw_set_color(c_aqua); draw_circle(x, y, 6, true);
    draw_text(x + 10, y - 30, "axe " + string(state));
}
draw_set_color(c_white);

```

## objects/obj_axe/Step_2.gml

```gml
if (!global.combat_frozen && !global.equipment_open) axe_tick(id);

```

## objects/obj_blades/Create_0.gml

```gml
owner = noone;
state = BLADE_STATE.IDLE; trail = [];

chain_left = new SoftChain(); chain_right = new SoftChain();

```

## objects/obj_blades/Draw_0.gml

```gml
if (!instance_exists(owner) || owner.weapons.current_weapon != WEAPON.BLADES) exit;
var _b = owner.blade_pose;
for (var _i = 0; _i < array_length(trail); ++_i) {
    var _t = trail[_i]; draw_blade_shape(_t.x, _t.y, _t.angle, _t.life / 20);
}
draw_soft_chain(chain_left);
draw_soft_chain(chain_right);
draw_blade_shape(_b.blade_x, _b.blade_y, _b.current_angle, 1);
draw_blade_shape(_b.offblade_x, _b.offblade_y, _b.off_angle, 1);
if (global.debug_combat && _b.attacking) {
    draw_set_color(c_orange); draw_circle(_b.blade_x, _b.blade_y, 5, true);
    draw_text(_b.blade_x + 10, _b.blade_y + 10, "corrente " + string(round(_b.chain_length)));
}
draw_set_color(c_white);

```

## objects/obj_blades/Step_2.gml

```gml
if (!instance_exists(owner)) { instance_destroy(); exit; }
if (global.combat_frozen || global.equipment_open) exit;
if (owner.weapons.current_weapon != WEAPON.BLADES || owner.state != PLAYER_STATE.ATTACK) blades_pose_update(owner);
state = BLADE_STATE.IDLE;
if (owner.weapons.current_weapon == WEAPON.BLADES && owner.state == PLAYER_STATE.ATTACK)
    state = (owner.attack_kind == "heavy" ? BLADE_STATE.HEAVY_COMBO : BLADE_STATE.LIGHT_COMBO);
for (var _i = array_length(trail) - 1; _i >= 0; --_i) {
    trail[_i].life -= 1;
    if (trail[_i].life <= 0) array_delete(trail, _i, 1);
}
if (state != BLADE_STATE.IDLE && global.combat_clock mod 2 == 0) {
    var _b = owner.blade_pose;
    array_push(trail, {x: _b.blade_x, y: _b.blade_y, angle: _b.current_angle, life: 8});
    array_push(trail, {x: _b.offblade_x, y: _b.offblade_y, angle: _b.off_angle, life: 8});
}
x = owner.x; y = owner.y; depth = -y - 2;

var _pose = owner.blade_pose;
var _slack = 1; var _taut = false;
if (_pose.attacking) {
    _slack = (owner.attack_phase == ATTACK_PHASE.ACTIVE ? 0.12 : 0.85);
    _taut = owner.attack.is_blade_heavy && _pose.attack_frame == owner.attack.impact_frame;
}
if (owner.weapons.current_weapon != WEAPON.BLADES) { chain_left.initialized = false; chain_right.initialized = false; }
soft_chain_tick(chain_left, _pose.hand_x, _pose.hand_y, _pose.blade_x, _pose.blade_y, _slack, 1, _taut);
soft_chain_tick(chain_right, _pose.offhand_x, _pose.offhand_y, _pose.offblade_x, _pose.offblade_y, _slack, -1, _taut);

```

## objects/obj_camera/CleanUp_0.gml

```gml
if (cam != -1) {
    if (view_camera[0] == cam) view_camera[0] = -1;
    camera_destroy(cam);
}

```

## objects/obj_camera/Create_0.gml

```gml
view_enabled = true; view_visible[0] = true;
cam = camera_create_view(0, 0, 960, 540, 0, noone, -1, -1, -1, -1);
view_camera[0] = cam;
view_xport[0] = 0; view_yport[0] = 0; view_wport[0] = 1280; view_hport[0] = 720;
window_set_size(1280, 720); display_set_gui_size(960, 540);
cam_x = 320; cam_y = 280;

```

## objects/obj_camera/Draw_0.gml

```gml
for (var _i = 0; _i < array_length(global.fx); ++_i) {
    var _f = global.fx[_i]; draw_set_alpha(_f.life / 12); draw_set_color(c_orange);
    var _radius = ((_f.kind == "blade_explosion" || _f.kind == "spear_explosion") ? (12 - _f.life) * 5 : (_f.kind == "blade_impact" ? (12 - _f.life) * 3 : 16 - _f.life));
    draw_circle(_f.x, _f.y, _radius, true);
}
draw_set_alpha(1); draw_set_color(c_white);

draw_shield_tests();

```

## objects/obj_camera/Step_2.gml

```gml
if (!instance_exists(global.player) || global.equipment_open) exit;
var _p = global.player;
var _tx = clamp(_p.x + lengthdir_x(45, _p.aim_dir) - 480, 0, room_width - 960);
var _ty = clamp(_p.y + lengthdir_y(30, _p.aim_dir) - 270, 0, room_height - 540);
cam_x = lerp(cam_x, _tx, 0.12); cam_y = lerp(cam_y, _ty, 0.12);
var _sx = 0; var _sy = 0;
if (global.shake_remaining > 0) {
    _sx = random_range(-global.shake_strength, global.shake_strength);
    _sy = random_range(-global.shake_strength, global.shake_strength);
    global.shake_remaining -= 1;
    if (global.shake_remaining <= 0) global.shake_strength = 0;
}
camera_set_view_pos(cam, cam_x + _sx, cam_y + _sy);

```

## objects/obj_enemy_parent/Create_0.gml

```gml
burn_amount = 0; burn_max = 100; burn_timer = 0; burn_tick_timer = 0; burn_source = noone;
frost_amount = 0; frost_max = 100; frost_timer = 0; frozen_timer = 0; frost_slow_scale = 1;
execution_owner = noone; is_elite = false; stun_until = -1; last_stun_hit = -100;
state = ENEMY_STATE.IDLE; hp = 500; max_hp = 500;
stun = 0; max_stun = 100; body_radius = 16; invulnerable = false;
knockback_dir = 0; knockback_force = 0; knockback_friction = 0.5; knockback_resistance = 0.2;
stagger_timer = 0; last_damage = 0; hit_count = 0;

ai_enabled = false; ai_has_token = false; ai_timer = 0; ai_struck = false;
ai_dir = 270; ai_cooldown = 60; ai_sequence = 0; ai_attack_type = 0; ai_startup = 36;
ai_path = []; ai_repath = 0;

```

## objects/obj_enemy_parent/Draw_0.gml

```gml
draw_actor(x, y, 270, state == ENEMY_STATE.DEAD ? c_dkgray : make_color_rgb(194, 151, 99), false);
draw_set_color(c_dkgray); draw_rectangle(x - 30, y - 55, x + 30, y - 50, false);
draw_set_color(c_red); draw_rectangle(x - 30, y - 55, x - 30 + 60 * hp / max_hp, y - 50, false);
draw_set_color(c_yellow); draw_rectangle(x - 30, y - 48, x - 30 + 60 * stun / max_stun, y - 45, false);
if (global.debug_combat) {
    draw_set_color(c_white); draw_circle(x, y, body_radius, true);
    draw_text(x - 42, y + 12, "HP " + string(hp) + " hits " + string(hit_count));
    draw_text(x - 42, y + 28, "stun " + string(stun) + " dano " + string(last_damage));
draw_set_color(c_orange);
    draw_text(x - 42, y + 60, "burn " + string(floor(burn_amount)) + " DOT " + string(burn_timer));
    draw_set_color(c_aqua);
    draw_text(x - 42, y + 44, "gelo " + string(floor(frost_amount)) + " freeze " + string(frozen_timer));
    draw_set_color(c_white);
}

if (is_elite) draw_text(x - 18, y - 94, "ELITE");
if (state == ENEMY_STATE.STUNNED) { draw_set_color(c_yellow); draw_text(x - 30, y - 74, "STUNNED"); }
draw_set_color(c_white);

enemy_ai_draw(id);

```

## objects/obj_enemy_parent/Step_0.gml

```gml
if (global.combat_frozen || global.equipment_open) exit;
if (instance_exists(execution_owner)) exit;
if (state == ENEMY_STATE.EXECUTION) { execution_owner = noone; stun = 0; state = ENEMY_STATE.IDLE; }
enemy_stun_tick(id);
frost_tick(id);
burn_tick(id);
if (knockback_force > 0) {
    arena_move(id, lengthdir_x(knockback_force, knockback_dir), lengthdir_y(knockback_force, knockback_dir));
    knockback_force = max(0, knockback_force - knockback_friction);
}
if (state == ENEMY_STATE.STAGGER) {
    stagger_timer -= 1; if (stagger_timer <= 0) state = ENEMY_STATE.IDLE;
}
depth = -y;

enemy_ai_tick(id);

```

## objects/obj_game/Create_0.gml

```gml
game_set_speed(60, gamespeed_fps);
global.debug_combat = true;
global.equipment_open = false; global.equipment_selection = 0; global.test_attacks = [];
global.combat_clock = 0; global.hitstop_remaining = 0; global.combat_frozen = false;
global.shake_strength = 0; global.shake_remaining = 0;
global.fx = []; global.sfx = {};
global.attack_database = build_attack_database(); global.fury_attacks = build_fury_attacks();
global.walls = [{x1: 580, y1: 330, x2: 680, y2: 530}, {x1: 1080, y1: 600, x2: 1300, y2: 660}];
global.player = instance_create_layer(800, 570, "Actors", obj_player);
instance_create_layer(800, 420, "Actors", obj_dummy);
instance_create_layer(960, 420, "Actors", obj_dummy);
var _elite = instance_create_layer(920, 590, "Actors", obj_dummy);
_elite.is_elite = true; _elite.max_hp = 800; _elite.hp = 800;
instance_create_layer(0, 0, "Systems", obj_camera);

var _raider = instance_create_layer(430, 660, "Actors", obj_enemy_parent);
_raider.ai_enabled = true; _raider.hp = 180; _raider.max_hp = 180;
var _raider2 = instance_create_layer(1120, 420, "Actors", obj_enemy_parent);
_raider2.ai_enabled = true; _raider2.hp = 180; _raider2.max_hp = 180; _raider2.ai_cooldown = 95;
var _guardian = instance_create_layer(1100, 850, "Actors", obj_enemy_parent);
_guardian.ai_enabled = true; _guardian.is_elite = true; _guardian.hp = 420; _guardian.max_hp = 420;
_guardian.max_stun = 140; _guardian.knockback_resistance = 0.5; _guardian.ai_cooldown = 140;

```

## objects/obj_game/Draw_0.gml

```gml
draw_clear(make_color_rgb(24, 29, 36));
draw_set_color(make_color_rgb(39, 46, 54));
for (var _x = 40; _x < room_width; _x += 64) draw_line(_x, 40, _x, room_height - 40);
for (var _y = 40; _y < room_height; _y += 64) draw_line(40, _y, room_width - 40, _y);
draw_set_color(make_color_rgb(81, 91, 105));
draw_rectangle(0, 0, room_width, 40, false);
draw_rectangle(0, room_height - 40, room_width, room_height, false);
draw_rectangle(0, 0, 40, room_height, false);
draw_rectangle(room_width - 40, 0, room_width, room_height, false);
for (var _i = 0; _i < array_length(global.walls); ++_i) {
    var _w = global.walls[_i]; draw_rectangle(_w.x1, _w.y1, _w.x2, _w.y2, false);
}
draw_set_color(c_white);

```

## objects/obj_game/Draw_64.gml

```gml
draw_set_color(c_white);
draw_text(16, 12, "ALBINO COMBAT | FASE 6 | F1 debug | F5 reiniciar");
draw_text(16, 34, "WASD / LS mover | mouse / RS mirar | LMB / RB leve | RMB / RT pesado");
draw_text(16, 56, "Space / A esquiva (2 toques: roll) | Ctrl / LT mira | MMB / RS lock");
draw_text(16, 78, "1-4 / D-pad armas de TESTE | Shift / LS correr | R / Y recall ou detonar | Q / LB escudo | Tab / Back menu");
if (instance_exists(global.player)) {
    var _p = global.player;
    var _names = ["Machado", "Laminas", "Lanca", "Socos"];
    draw_text(16, 112, "Arma: " + _names[_p.weapons.current_weapon] + " | estado: " + string(_p.state) + " | fora da mao: " + string(_p.weapons.outside_hand) + " | lancas: " + string(array_length(_p.spears)) + "/5");
    if (global.debug_combat) {
        draw_text(16, 134, "Combo: " + string(_p.combo_step + 1) + " | timer: " + string(_p.attack_timer)
            + " | fase: " + string(_p.attack_phase) + " | hitstop: " + string(global.hitstop_remaining));
        draw_text(16, 156, "Buffer: " + _p.combo_buffer.action + " | throw fila: " + _p.queued_throw + " | i-frames: " + string(_p.invulnerable)
            + " | direcao 8: " + string(_p.facing8));
        draw_text(16, 178, "FREE=0 ATTACK=1 AIM=2 DODGE=3 | STARTUP=0 ACTIVE=1 RECOVERY=2");
    }
}

if (instance_exists(global.player)) {
    var _p = global.player; var _s = _p.shield; var _d = _s.profiles[_s.equipped];
    draw_text(16, 200, "HP " + string(_p.hp) + "/100 | " + _d.name + " | guarda " + string(round(_s.guard)) + "/" + string(_d.max_guard));
    draw_text(16, 222, "Defesa: " + _p.last_defense_result);
    if (global.debug_combat) draw_text(16, 244, "F6 normal | F7 quebra | F8 imbloqueavel | F9 tras | F10 cura (teste em 60 frames)");
}
draw_equipment_menu();

if (instance_exists(global.player)) {
    var _p = global.player; draw_text(16, 270, "Colera " + string(round(_p.rage.meter)) + "/100 | Shift+MMB / LS+RS: ativar | MMB/RS: executar alvo stunned");
}

if (!global.equipment_open) { draw_set_color(c_white); draw_text(24, 224, "Fase 7: F11 ativa/pausa os inimigos | F5 reinicia a arena"); }

```

## objects/obj_game/Step_1.gml

```gml
if (keyboard_check_pressed(vk_f1)) global.debug_combat = !global.debug_combat;
if (keyboard_check_pressed(vk_f5)) { room_restart(); exit; }
global.combat_frozen = global.equipment_open || global.hitstop_remaining > 0;
if (!global.equipment_open) {
    if (global.hitstop_remaining > 0) global.hitstop_remaining -= 1;
    else global.combat_clock += 1;
}
if (!global.combat_frozen) {
    for (var _i = array_length(global.fx) - 1; _i >= 0; --_i) {
        global.fx[_i].life -= 1;
        if (global.fx[_i].life <= 0) array_delete(global.fx, _i, 1);
    }
}

if (keyboard_check_pressed(vk_f11)) {
    for (var _i = 0; _i < instance_number(obj_enemy_parent); ++_i) {
        var _e = instance_find(obj_enemy_parent, _i);
        if (_e.object_index == obj_enemy_parent) {
            _e.ai_enabled = !_e.ai_enabled; _e.ai_has_token = false;
            if (_e.state == ENEMY_STATE.ATTACK || _e.state == ENEMY_STATE.RECOVERY || _e.state == ENEMY_STATE.CHASE) _e.state = ENEMY_STATE.IDLE;
        }
    }
}

```

## objects/obj_game/Step_2.gml

```gml
if (!global.combat_frozen && !global.equipment_open) shield_test_tick();

```

## objects/obj_player/Create_0.gml

```gml
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

```

## objects/obj_player/Draw_0.gml

```gml
draw_actor(x, y, state == PLAYER_STATE.ATTACK ? locked_aim_dir : aim_dir, c_white, true);
if (global.debug_combat) {
    draw_set_color(invulnerable ? c_aqua : c_white); draw_circle(x, y, body_radius, true);
    draw_set_color(c_aqua); draw_line(x, y, x + lengthdir_x(65, aim_dir), y + lengthdir_y(65, aim_dir));
    draw_attack_arc(id);
}
if (instance_exists(lock_target)) {
    draw_set_color(c_yellow); draw_circle(lock_target.x, lock_target.y - 20, 26, true);
}
draw_set_color(c_white);

draw_player_shield(id);

draw_fists(id); draw_execution_indicators(id);

```

## objects/obj_player/Step_0.gml

```gml
read_input(input);
if (input.menu) {
    if (global.equipment_open) global.equipment_open = false;
    else if (state == PLAYER_STATE.FREE || state == PLAYER_STATE.AIM || state == PLAYER_STATE.BLOCK || state == PLAYER_STATE.PARRY) {
        global.equipment_open = true; global.combat_frozen = true; global.equipment_selection = shield.equipped;
        shield_lower(id); combat_cancel(id);
        pending_light = false; pending_heavy = false; pending_dodge = false; pending_weapon = -1;
        pending_recall = false; pending_execute = false; pending_rage = false; pending_block = false; pending_aim_pressed = false;
    }
    exit;
}
if (global.equipment_open) {
    if (input.menu_left) global.equipment_selection = (global.equipment_selection + 2) mod 3;
    if (input.menu_right) global.equipment_selection = (global.equipment_selection + 1) mod 3;
    if (input.menu_confirm) { shield_equip(id, global.equipment_selection); global.equipment_open = false; }
    exit;
}
// Preservar comandos de acao recebidos durante hitstop.
if (global.combat_frozen) {
    pending_execute = pending_execute || input.execute; pending_rage = pending_rage || input.rage;
    pending_block = pending_block || input.block_pressed;
    pending_aim_pressed = pending_aim_pressed || input.aim_pressed;
    pending_recall = pending_recall || input.recall;
    pending_light = pending_light || input.light;
    pending_heavy = pending_heavy || input.heavy;
    pending_dodge = pending_dodge || input.dodge;
    if (input.weapon >= 0) pending_weapon = input.weapon;
} else {
    input.execute = input.execute || pending_execute; input.rage = input.rage || pending_rage;
    input.block_pressed = input.block_pressed || pending_block;
    input.aim_pressed = input.aim_pressed || pending_aim_pressed;
    input.recall = input.recall || pending_recall;
    input.light = input.light || pending_light;
    input.heavy = input.heavy || pending_heavy;
    input.dodge = input.dodge || pending_dodge;
    if (input.weapon < 0) input.weapon = pending_weapon;
    pending_execute = false; pending_rage = false; pending_block = false; pending_aim_pressed = false; pending_recall = false; pending_light = false; pending_heavy = false; pending_dodge = false; pending_weapon = -1;
}
if (input.lock && execution_find(id) == noone) {
    if (instance_exists(lock_target)) lock_target = noone;
    else {
        var _best = 420;
        for (var _i = 0; _i < instance_number(obj_enemy_parent); ++_i) {
            var _t = instance_find(obj_enemy_parent, _i);
            var _dist = point_distance(x, y, _t.x, _t.y);
            if (_t.state != ENEMY_STATE.DEAD && _dist < _best) { _best = _dist; lock_target = _t; }
        }
    }
}
if (instance_exists(lock_target)) {
    if (lock_target.state == ENEMY_STATE.DEAD || point_distance(x, y, lock_target.x, lock_target.y) > 600) lock_target = noone;
}
if (instance_exists(lock_target)) aim_dir = point_direction(x, y, lock_target.x, lock_target.y);
else if (input.use_pad) {
    if (input.aim_x != 0 || input.aim_y != 0) aim_dir = point_direction(0, 0, input.aim_x, input.aim_y);
} else aim_dir = point_direction(x, y, mouse_x, mouse_y);
facing8 = (round((state == PLAYER_STATE.ATTACK ? locked_aim_dir : aim_dir) / 45) + 8) mod 8;
if (!global.combat_frozen) player_tick(id);
depth = -y;

```

## objects/obj_spear/Create_0.gml

```gml
owner = noone; state = SPEAR_STATE.HAND; facing = 0;

```

## objects/obj_spear/Draw_0.gml

```gml
if (!instance_exists(owner) || owner.weapons.current_weapon != WEAPON.SPEAR) exit;
draw_spear_shape(x, y - 12, facing, 1);

```

## objects/obj_spear/Step_2.gml

```gml
if (!global.combat_frozen && !global.equipment_open) spear_held_tick(id);

```

## objects/obj_spear_projectile/Create_0.gml

```gml
owner = noone; state = SPEAR_PROJECTILE_STATE.FLYING;
fly_dir = 0; fly_speed = 22; fly_distance = 0; heavy_throw = false;
stuck_target = noone; offset_x = 0; offset_y = 0; detonate_at = -1;
explosion_radius = 80;
impact_data = {damage: 20, stun: 8, stagger: 8, knockback: 2, hitstop: 2, shake: 1, element: ELEMENT.NONE, element_amount: 0};
explosion_data = {damage: 35, stun: 25, stagger: 22, knockback: 6, hitstop: 4, shake: 4, element: ELEMENT.NONE, element_amount: 0};

```

## objects/obj_spear_projectile/Draw_0.gml

```gml
draw_spear_shape(x, y - 10, fly_dir, 0.65);
if (global.debug_combat) {
    draw_set_color(c_yellow); draw_circle(x, y, 5, true);
    if (detonate_at >= 0) draw_circle(x, y, explosion_radius, true);
}
draw_set_color(c_white);

```

## objects/obj_spear_projectile/Step_2.gml

```gml
if (!global.combat_frozen && !global.equipment_open) spear_projectile_tick(id);

```

## scripts/scr_attack_data/scr_attack_data.gml

```gml
function AttackData(_name, _startup, _active, _recovery, _damage, _range, _arc, _stun, _knockback) constructor {
    name = _name;
    startup = _startup; active = _active; recovery = _recovery;
    damage = _damage; range = _range; arc = _arc;
    stun = _stun; stagger = 10; knockback = _knockback;
    is_blade_heavy = false; blade_spin = false; blade_sign = 1; impact_frame = 0; throw_weapon = WEAPON.AXE; is_throw = false; throw_heavy = false; hitstop = 2; element = ELEMENT.NONE; element_amount = 0;
    buffer_start = max(0, startup - 3);
    buffer_end = startup + active + recovery;
    combo_start = startup + active + floor(recovery * 0.65);
    dodge_cancel_start = startup + active + floor(recovery * 0.4);
    weapon_cancel_start = startup + active + floor(recovery * 0.6);
    block_cancel_start = startup + active + floor(recovery * 0.7);
    movement_scale = 0.4;
    shake = 1;
}
function build_attack_database() {
    var _db = [];
    for (var _w = 0; _w < 4; ++_w) {
        var _light = []; var _heavy = [];
        var _names = ["Machado", "Laminas", "Lanca", "Socos"];
        var _range = [92, 115, 125, 52];
        var _damage = [18, 12, 14, 8];
        var _count = [4, 5, 4, 5];
        for (var _i = 0; _i < _count[_w]; ++_i) {
            var _a = new AttackData(_names[_w] + " leve " + string(_i + 1), 7, 4, 15,
                _damage[_w] + _i * 2, _range[_w], 95, (_w == WEAPON.FISTS ? 22 : 10), 3);
            if (_i == _count[_w] - 1) { _a.damage *= 1.5; _a.hitstop = 4; _a.shake = 3; }
            if (_w == WEAPON.AXE) { _a.element = ELEMENT.FROST; _a.element_amount = 18; }
            array_push(_light, _a);
        }
        for (var _j = 0; _j < 3; ++_j) {
            var _h = new AttackData(_names[_w] + " pesado " + string(_j + 1), 17, 5, 25,
                _damage[_w] * 2 + _j * 4, _range[_w] + 20, 110, 25, 7);
            _h.movement_scale = 0.12; _h.hitstop = 5; _h.shake = 4; _h.stagger = 18;
            if (_w == WEAPON.AXE) { _h.element = ELEMENT.FROST; _h.element_amount = 30; }
            array_push(_heavy, _h);
        }
        array_push(_db, {light: _light, heavy: _heavy});
    }
    var _bl = _db[WEAPON.BLADES];
    for (var _i = 0; _i < array_length(_bl.light); ++_i) {
        var _a = _bl.light[_i];
        _a.startup = 6; _a.active = 6; _a.recovery = 14;
        _a.range = 90 + _i * 7; _a.arc = (_i == 3 ? 360 : 145);
        _a.blade_spin = _i == 3; _a.blade_sign = (_i mod 2 == 0 ? 1 : -1);
        _a.element = ELEMENT.BURN; _a.element_amount = 16;
        _a.combo_start = 20; _a.buffer_start = 7; _a.buffer_end = 26;
        _a.dodge_cancel_start = 16; _a.weapon_cancel_start = 18;
        _a.movement_scale = 0.5;
    }
    for (var _j = 0; _j < array_length(_bl.heavy); ++_j) {
        var _a = _bl.heavy[_j];
        _a.startup = 15; _a.active = 5; _a.recovery = 24;
        _a.range = (_j == 2 ? 220 : 185 + _j * 5); _a.arc = 130;
        _a.is_blade_heavy = true; _a.blade_sign = (_j mod 2 == 0 ? 1 : -1);
        _a.impact_frame = _a.startup + 2;
        _a.combo_start = 36; _a.buffer_start = 15; _a.buffer_end = 44;
        _a.dodge_cancel_start = 27; _a.weapon_cancel_start = 31;
        _a.element = ELEMENT.BURN; _a.element_amount = (_j == 2 ? 40 : 28);
        _a.stagger = (_j == 2 ? 25 : 16); _a.shake = (_j == 2 ? 5 : 3);
    }
    for (var _i = 0; _i < array_length(_db[WEAPON.SPEAR].light); ++_i) {
        var _a = _db[WEAPON.SPEAR].light[_i];
        _a.startup = 5; _a.active = 4; _a.recovery = 12; _a.range = 120; _a.arc = 28;
        _a.stagger = 6; _a.stun = 7; _a.hitstop = 2; _a.movement_scale = 0.55;
        _a.combo_start = 16; _a.buffer_start = 5; _a.buffer_end = 21;
        _a.dodge_cancel_start = 13; _a.weapon_cancel_start = 15;
    }
    for (var _i = 0; _i < array_length(_db[WEAPON.SPEAR].heavy); ++_i) {
        var _a = _db[WEAPON.SPEAR].heavy[_i]; _a.arc = 40; _a.range = 145; _a.stagger = 12;
    }
    var _fist_names = ["Jab", "Direto", "Gancho", "Soco forte", "Finalizador"];
    for (var _i = 0; _i < array_length(_db[WEAPON.FISTS].light); ++_i) {
        var _a = _db[WEAPON.FISTS].light[_i]; _a.name = _fist_names[_i];
        _a.startup = 4; _a.active = 4; _a.recovery = 10; _a.range = 55; _a.arc = 90;
        _a.damage = 7 + _i; _a.stun = 22 + _i * 3; _a.stagger = 9; _a.knockback = 1;
        _a.combo_start = 14; _a.buffer_start = 4; _a.buffer_end = 18;
        _a.dodge_cancel_start = 11; _a.weapon_cancel_start = 13; _a.block_cancel_start = 13;
        _a.movement_scale = 0.6;
        if (_i == 4) { _a.knockback = 4; _a.hitstop = 4; _a.stun = 40; }
    }
    return _db;
}

```

## scripts/scr_axe/scr_axe.gml

```gml
// ================= MACHADO: COMANDOS E DADOS =================
function axe_damage_data(_damage, _frost, _force) {
    return {damage: _damage, stun: 12, stagger: 14, knockback: _force,
        hitstop: 3, shake: 2, element: ELEMENT.FROST, element_amount: _frost};
}
function combat_begin_throw(_p, _heavy) {
    combat_cancel(_p);
    var _a = new AttackData(_heavy ? "Arremesso pesado" : "Arremesso rapido", _heavy ? 16 : 8, 1, _heavy ? 18 : 12, 0, 0, 0, 0, 0);
    _a.is_throw = true; _a.throw_weapon = _p.weapons.current_weapon; _a.throw_heavy = _heavy; _a.movement_scale = 0.25;
    _p.attack = _a; _p.attack_kind = "throw"; _p.attack_timer = 0;
    _p.attack_phase = ATTACK_PHASE.STARTUP; _p.locked_aim_dir = _p.aim_dir;
    _p.state = PLAYER_STATE.ATTACK;
}
function axe_throw(_axe, _dir, _heavy) {
    if (!instance_exists(_axe) || !instance_exists(_axe.owner)) return;
    if (_axe.state != AXE_STATE.HAND && _axe.state != AXE_STATE.MELEE) return;
    _axe.state = AXE_STATE.FLYING; _axe.throw_dir = _dir;
    _axe.heavy_throw = _heavy; _axe.fly_speed = (_heavy ? 13 : 18);
    _axe.fly_distance = 0; _axe.hit_enemies = []; _axe.stuck_target = noone;
    _axe.owner.weapons.outside_hand = true;
    _axe.owner.weapons.axe_state = AXE_STATE.FLYING;
    combat_sfx("throw");
}
function axe_recall(_axe) {
    if (!instance_exists(_axe) || !instance_exists(_axe.owner)) return;
    if (_axe.state == AXE_STATE.HAND || _axe.state == AXE_STATE.MELEE || _axe.state == AXE_STATE.RETURNING) return;
    _axe.state = AXE_STATE.RETURNING; _axe.return_speed = 4;
    _axe.hit_enemies = []; _axe.stuck_target = noone;
    combat_sfx("recall");
}
function axe_stick(_axe, _target) {
    _axe.state = AXE_STATE.STUCK; _axe.stuck_target = _target;
    if (instance_exists(_target)) {
        _axe.stuck_offset_x = _axe.x - _target.x;
        _axe.stuck_offset_y = _axe.y - _target.y;
    }
    combat_fx("frost", _axe.x, _axe.y);
}
function axe_tick(_axe) {
    if (!instance_exists(_axe.owner)) { instance_destroy(_axe); return; }
    var _p = _axe.owner;
    if (_axe.state == AXE_STATE.HAND || _axe.state == AXE_STATE.MELEE) {
        _axe.state = (_p.state == PLAYER_STATE.ATTACK && _p.weapons.current_weapon == WEAPON.AXE ? AXE_STATE.MELEE : AXE_STATE.HAND);
        var _dir = (_axe.state == AXE_STATE.MELEE ? _p.locked_aim_dir : _p.aim_dir);
        var _range = 24;
        if (_axe.state == AXE_STATE.MELEE && !_p.attack.is_throw) {
            var _a = _p.attack;
            var _progress = clamp((_p.attack_timer - _a.startup) / max(1, _a.active - 1), 0, 1);
            var _sign = (_p.combo_step mod 2 == 0 ? 1 : -1);
            _dir += lerp(-_a.arc / 2, _a.arc / 2, _progress) * _sign;
            var _extension = (_p.attack_timer < _a.startup ? _p.attack_timer / max(1, _a.startup) : 1);
            if (_p.attack_timer >= _a.startup + _a.active)
                _extension = 1 - clamp((_p.attack_timer - _a.startup - _a.active) / max(1, _a.recovery), 0, 1);
            _range = lerp(24, _a.range, _extension);
        }
        _axe.x = _p.x + lengthdir_x(_range, _dir);
        _axe.y = _p.y + lengthdir_y(_range, _dir);
        _axe.spin_angle = _dir - 90;
    } else if (_axe.state == AXE_STATE.STUCK) {
        if (instance_exists(_axe.stuck_target)) {
            _axe.x = _axe.stuck_target.x + _axe.stuck_offset_x;
            _axe.y = _axe.stuck_target.y + _axe.stuck_offset_y;
        }
    } else {
        var _returning = _axe.state == AXE_STATE.RETURNING;
        var _dir = _axe.throw_dir; var _distance = _axe.fly_speed;
        var _hx = _p.x + lengthdir_x(24, _p.aim_dir);
        var _hy = _p.y + lengthdir_y(24, _p.aim_dir);
        if (_returning) {
            _axe.return_speed = min(26, _axe.return_speed + 1.1);
            _dir = point_direction(_axe.x, _axe.y, _hx, _hy);
            _distance = min(_axe.return_speed, point_distance(_axe.x, _axe.y, _hx, _hy));
        }
        var _steps = max(1, ceil(_distance / 4));
        for (var _s = 0; _s < _steps; ++_s) {
            var _nx = _axe.x + lengthdir_x(_distance / _steps, _dir);
            var _ny = _axe.y + lengthdir_y(_distance / _steps, _dir);
            // Recall atravessa paredes para nunca deixar a arma inacessivel.
            if (!_returning && (segment_wall_blocked(_axe.x, _axe.y, _nx, _ny)
                || _nx < 40 || _ny < 40 || _nx > room_width - 40 || _ny > room_height - 40)) {
                axe_stick(_axe, noone); break;
            }
            _axe.x = _nx; _axe.y = _ny;
            var _stopped = false;
            for (var _i = 0; _i < instance_number(obj_enemy_parent); ++_i) {
                var _t = instance_find(obj_enemy_parent, _i);
                if (!instance_exists(_t) || _t.state == ENEMY_STATE.DEAD || hit_registry_has(_axe.hit_enemies, _t)) continue;
                if (point_distance(_axe.x, _axe.y, _t.x, _t.y) <= _t.body_radius + 6) {
                    var _dmg = (_returning ? _axe.return_damage : (_axe.heavy_throw ? _axe.heavy_damage : _axe.quick_damage));
                    if (apply_damage(_p, _t, _dmg)) {
                        array_push(_axe.hit_enemies, _t);
                        if (!_returning && _axe.heavy_throw) { axe_stick(_axe, _t); _stopped = true; break; }
                    }
                }
            }
            if (_stopped) break;
        }
        _axe.spin_angle += (_returning ? -38 : 32);
        if (!_returning && _axe.state == AXE_STATE.FLYING) {
            _axe.fly_distance += _distance;
            if (_axe.fly_distance >= 650) axe_stick(_axe, noone);
        }
        if (_returning && point_distance(_axe.x, _axe.y, _hx, _hy) <= 16) {
            _axe.state = AXE_STATE.HAND; _p.weapons.outside_hand = false;
            _axe.x = _hx; _axe.y = _hy;
            combat_fx("catch", _hx, _hy); combat_sfx("catch");
        }
    }
    _p.weapons.axe_state = _axe.state;
    for (var _i = array_length(_axe.trail) - 1; _i >= 0; --_i) {
        _axe.trail[_i].life -= 1;
        if (_axe.trail[_i].life <= 0) array_delete(_axe.trail, _i, 1);
    }
    if ((_axe.state == AXE_STATE.FLYING || _axe.state == AXE_STATE.RETURNING || _axe.state == AXE_STATE.MELEE)
        && global.combat_clock mod 2 == 0) array_push(_axe.trail, {x: _axe.x, y: _axe.y, life: 10});
    _axe.depth = -_axe.y - 1;
}
function frost_apply(_target, _amount) {
    if (_amount <= 0) return;
    _target.frost_amount = min(_target.frost_max, _target.frost_amount + _amount);
    _target.frost_timer = 180;
    if (_target.frost_amount >= _target.frost_max) {
        _target.frost_amount = 0; _target.frozen_timer = 120;
        combat_fx("freeze", _target.x, _target.y);
    }
}
function frost_tick(_target) {
    _target.frozen_timer = max(0, _target.frozen_timer - 1);
    _target.frost_timer = max(0, _target.frost_timer - 1);
    if (_target.frost_timer == 0) _target.frost_amount = max(0, _target.frost_amount - 0.5);
    _target.frost_slow_scale = (_target.frozen_timer > 0 ? 0 : 1 - 0.4 * _target.frost_amount / _target.frost_max);
    // AI futura deve consumir frost_slow_scale no movimento e nos timers de ataques.
}
function draw_axe_shape(_x, _y, _angle, _alpha) {
    draw_set_alpha(_alpha); draw_set_color(make_color_rgb(136, 96, 66));
    draw_line_width(_x + lengthdir_x(15, _angle), _y + lengthdir_y(15, _angle),
        _x + lengthdir_x(-15, _angle), _y + lengthdir_y(-15, _angle), 4);
    var _hx = _x + lengthdir_x(12, _angle); var _hy = _y + lengthdir_y(12, _angle);
    draw_set_color(c_aqua);
    draw_triangle(_hx + lengthdir_x(13, _angle + 90), _hy + lengthdir_y(13, _angle + 90),
        _hx + lengthdir_x(13, _angle - 90), _hy + lengthdir_y(13, _angle - 90),
        _hx + lengthdir_x(10, _angle), _hy + lengthdir_y(10, _angle), false);
    draw_set_alpha(1); draw_set_color(c_white);
}

```

## scripts/scr_blades/scr_blades.gml

```gml
// ================= POSICAO UNICA PARA DRAW / HIT / IMPACTO =================
function BladePose() constructor {
    hand_x = 0; hand_y = 0; blade_x = 0; blade_y = 0;
    offhand_x = 0; offhand_y = 0; offblade_x = 0; offblade_y = 0;
    current_angle = 0; off_angle = 0; chain_length = 24;
    previous_angle = 0; previous_length = 24;
    attacking = false; attack_frame = -1;
}
function blades_pose_update(_p) {
    var _b = _p.blade_pose;
    _b.previous_angle = _b.current_angle; _b.previous_length = _b.chain_length;
    _b.hand_x = _p.x; _b.hand_y = _p.y;
    _b.offhand_x = _p.x + lengthdir_x(10, _p.locked_aim_dir + 90);
    _b.offhand_y = _p.y + lengthdir_y(10, _p.locked_aim_dir + 90);
    _b.attacking = _p.state == PLAYER_STATE.ATTACK && _p.weapons.current_weapon == WEAPON.BLADES;
    _b.attack_frame = _p.attack_timer;
    if (!_b.attacking) {
        _b.current_angle = _p.aim_dir - 25; _b.chain_length = 24;
        _b.off_angle = _p.aim_dir + 25;
    } else {
        var _a = _p.attack; var _t = _p.attack_timer;
        // Todos os golpes varrem o arco inteiro ao alcance maximo durante ACTIVE.
        var _q = clamp((_t - _a.startup) / max(1, _a.active - 1), 0, 1);
        _b.current_angle = _p.locked_aim_dir + lerp(-_a.arc / 2, _a.arc / 2, _q) * _a.blade_sign;
        var _extension = (_t < _a.startup ? _t / max(1, _a.startup) : 1);
        if (_t >= _a.startup + _a.active)
            _extension = 1 - clamp((_t - _a.startup - _a.active) / max(1, _a.recovery), 0, 1);
        _b.chain_length = lerp(24, _a.range, _extension);
        if (_a.is_blade_heavy && _t == _a.impact_frame) {
            _b.current_angle = _p.locked_aim_dir; _b.chain_length = _a.range;
        }
        _b.off_angle = (_a.blade_spin ? _b.current_angle + 180 : 2 * _p.locked_aim_dir - _b.current_angle);
        if (_t == 0) { _b.previous_angle = _b.current_angle; _b.previous_length = _b.chain_length; }
    }
    _b.blade_x = _b.hand_x + lengthdir_x(_b.chain_length, _b.current_angle);
    _b.blade_y = _b.hand_y + lengthdir_y(_b.chain_length, _b.current_angle);
    _b.offblade_x = _b.offhand_x + lengthdir_x(_b.chain_length * 0.7, _b.off_angle);
    _b.offblade_y = _b.offhand_y + lengthdir_y(_b.chain_length * 0.7, _b.off_angle);
}
function combat_sector_intersects(_p, _target, _range, _arc, _dir) {
    var _dist = point_distance(_p.x, _p.y, _target.x, _target.y);
    var _radius = _target.body_radius;
    if (_dist > _range + _radius) return false;
    if (_dist <= _radius || _arc >= 360) return true;
    var _target_dir = point_direction(_p.x, _p.y, _target.x, _target.y);
    var _diff = angle_difference(_target_dir, _dir);
    if (abs(_diff) <= _arc / 2) return true;
    // Angulo da borda mais proxima: intersecao real de hurtbox circular com setor.
    var _edge = _dir + clamp(_diff, -_arc / 2, _arc / 2);
    // Escolher a borda por proximidade evita depender do sinal de angle_difference.
    var _left = _dir - _arc / 2; var _right = _dir + _arc / 2;
    _edge = (abs(angle_difference(_target_dir, _left)) < abs(angle_difference(_target_dir, _right)) ? _left : _right);
    var _ux = lengthdir_x(1, _edge); var _uy = lengthdir_y(1, _edge);
    var _projection = clamp((_target.x - _p.x) * _ux + (_target.y - _p.y) * _uy, 0, _range);
    return point_distance(_target.x, _target.y, _p.x + _projection * _ux, _p.y + _projection * _uy) <= _radius;
}
function blades_hit_tick(_p) {
    var _a = _p.attack; var _b = _p.blade_pose;
    if (_a.is_blade_heavy && _p.attack_timer == _a.impact_frame) {
        combat_fx(_p.combo_step == 2 ? "blade_explosion" : "blade_impact", _b.blade_x, _b.blade_y);
        combat_sfx("chain");
    }
    // O setor e o mesmo desenhado no debug. Correntes e pontas causam dano igual.
    for (var _i = 0; _i < instance_number(obj_enemy_parent); ++_i) {
        var _target = instance_find(obj_enemy_parent, _i);
        if (!instance_exists(_target) || hit_registry_has(_p.hit_enemies, _target) || _target.state == ENEMY_STATE.DEAD) continue;
        if (combat_sector_intersects(_p, _target, _a.range, _a.arc, _p.locked_aim_dir)
            && !segment_wall_blocked(_p.x, _p.y, _target.x, _target.y)) {
            _target.burn_source = _p;
            if (apply_damage(_p, _target, _a)) array_push(_p.hit_enemies, _target);
        }
    }
}
function burn_apply(_target, _amount) {
    if (_amount <= 0) return;
    _target.burn_amount = min(_target.burn_max, _target.burn_amount + _amount);
    if (_target.burn_amount >= _target.burn_max) {
        _target.burn_amount = 0; _target.burn_timer = 240; _target.burn_tick_timer = 30;
    }
}
function burn_tick(_target) {
    if (_target.state == ENEMY_STATE.DEAD) return;
    if (_target.burn_timer > 0) {
        _target.burn_timer -= 1; _target.burn_tick_timer -= 1;
        if (_target.burn_tick_timer <= 0) {
            _target.burn_tick_timer = 30;
            if (instance_exists(_target.burn_source)) {
                var _dot = {damage: 4, stun: 0, stagger: 0, knockback: 0, hitstop: 0, shake: 0,
                    element: ELEMENT.NONE, element_amount: 0, is_dot: true};
                apply_damage(_target.burn_source, _target, _dot);
            }
        }
    } else _target.burn_amount = max(0, _target.burn_amount - 0.1);
}
function draw_blade_shape(_x, _y, _dir, _alpha) {
    draw_set_alpha(_alpha); draw_set_color(c_orange);
    draw_triangle(_x + lengthdir_x(15, _dir), _y + lengthdir_y(15, _dir),
        _x + lengthdir_x(6, _dir + 105), _y + lengthdir_y(6, _dir + 105),
        _x + lengthdir_x(6, _dir - 105), _y + lengthdir_y(6, _dir - 105), false);
    draw_set_alpha(1); draw_set_color(c_white);
}

```

## scripts/scr_combat/scr_combat.gml

```gml
function combat_cancel(_p) {
    if (_p.state == PLAYER_STATE.EXECUTION_APPROACH) execution_approach_cancel(_p);
    _p.queued_throw = "";
    _p.state = PLAYER_STATE.FREE; _p.attack = undefined;
    _p.attack_timer = 0; _p.combo_step = 0; _p.hit_enemies = [];
    buffer_clear(_p.combo_buffer);
}
function combat_start(_p, _kind, _step) {
    var _weapon = _p.weapons.current_weapon;
    if (_weapon == WEAPON.AXE && _p.weapons.outside_hand) _weapon = WEAPON.FISTS;
    var _list = (_kind == "light" ? global.attack_database[_weapon].light : global.attack_database[_weapon].heavy);
    if (_p.rage.active) _list = (_kind == "light" ? global.fury_attacks.light : global.fury_attacks.heavy);
    _p.combo_step = _step mod array_length(_list);
    _p.attack = _list[_p.combo_step]; _p.attack_kind = _kind;
    _p.attack_timer = 0; _p.attack_phase = ATTACK_PHASE.STARTUP;
    _p.locked_aim_dir = _p.aim_dir; _p.hit_enemies = [];
    _p.state = PLAYER_STATE.ATTACK; buffer_clear(_p.combo_buffer);
    combat_sfx("swing");
}
function combat_attack_tick(_p) {
    var _a = _p.attack;
    if (_p.attack_timer < _a.startup) _p.attack_phase = ATTACK_PHASE.STARTUP;
    else if (_p.attack_timer < _a.startup + _a.active) _p.attack_phase = ATTACK_PHASE.ACTIVE;
    else _p.attack_phase = ATTACK_PHASE.RECOVERY;
    if (_a.is_throw) {
        if (_p.attack_timer == _a.startup) {
            if (_a.throw_weapon == WEAPON.AXE && instance_exists(_p.my_axe)) axe_throw(_p.my_axe, _p.locked_aim_dir, _a.throw_heavy);
            else if (_a.throw_weapon == WEAPON.SPEAR) spear_throw(_p, _p.locked_aim_dir, _a.throw_heavy);
        }
        _p.attack_timer += 1;
        if (_p.attack_timer >= _a.startup + _a.active + _a.recovery) combat_cancel(_p);
        return;
    }
    if (_p.weapons.current_weapon == WEAPON.BLADES) {
        blades_pose_update(_p);
        if (_p.attack_phase == ATTACK_PHASE.ACTIVE) blades_hit_tick(_p);
    }
    if (_p.attack_phase == ATTACK_PHASE.ACTIVE && _p.weapons.current_weapon != WEAPON.BLADES) {
        for (var _i = 0; _i < instance_number(obj_enemy_parent); ++_i) {
            var _target = instance_find(obj_enemy_parent, _i);
            if (!instance_exists(_target) || hit_registry_has(_p.hit_enemies, _target)) continue;
            if (combat_sector_intersects(_p, _target, _a.range, _a.arc, _p.locked_aim_dir)
                && !segment_wall_blocked(_p.x, _p.y, _target.x, _target.y)) {
                if (apply_damage(_p, _target, _a)) array_push(_p.hit_enemies, _target);
            }
        }
    }
    if (_p.queued_throw == "" && _p.attack_timer >= _a.combo_start && buffer_valid(_p.combo_buffer)) {
        var _kind = _p.combo_buffer.action;
        var _step = (_kind == _p.attack_kind ? _p.combo_step + 1 : 0);
        combat_start(_p, _kind, _step); return;
    }
    _p.attack_timer += 1;
    if (_p.attack_timer >= _a.startup + _a.active + _a.recovery) {
        var _throw = _p.queued_throw;
        combat_cancel(_p);
        if (_throw != "" && ((_p.weapons.current_weapon == WEAPON.AXE && !_p.weapons.outside_hand) || _p.weapons.current_weapon == WEAPON.SPEAR))
            combat_begin_throw(_p, _throw == "heavy");
    }
}
function dodge_start(_p, _roll) {
    combat_cancel(_p);
    shield_lower(_p);
    _p.state = PLAYER_STATE.DODGE; _p.dodge_timer = 0; _p.dodge_roll = _roll;
    if (_p.input.move_x != 0 || _p.input.move_y != 0)
        _p.dodge_dir = point_direction(0, 0, _p.input.move_x, _p.input.move_y);
    else _p.dodge_dir = _p.aim_dir + 180;
    _p.last_dodge_press = global.combat_clock;
}
function player_tick(_p) {
    var _i = _p.input;
    _p.invulnerable = false;
    shield_tick(_p);
    if (_p.state == PLAYER_STATE.EXECUTION) { execution_tick(_p); return; }
    if (_p.state == PLAYER_STATE.DEAD) { if (_p.rage.active) fury_end(_p); return; }
    fury_tick(_p);
    if (_i.rage) fury_toggle(_p);
    if (_p.state == PLAYER_STATE.EXECUTION_APPROACH) { execution_approach_tick(_p); return; }
    if (_i.execute && execution_start(_p)) return;
    if (_p.rage.active) _i.block = false;
    spear_prune(_p);
    if (_i.recall) {
        if (_p.weapons.current_weapon == WEAPON.SPEAR) spear_detonate_all(_p);
        else if (instance_exists(_p.my_axe)) axe_recall(_p.my_axe);
    }
    _p.weapons.switch_cooldown = max(0, _p.weapons.switch_cooldown - 1);
    if (_i.weapon >= 0) weapon_switch(_p, _i.weapon);
    if (_p.state == PLAYER_STATE.DEAD) return;
    if (_p.state == PLAYER_STATE.STAGGER) {
        _p.stagger_timer -= 1;
        if (_p.knockback_force > 0) {
            arena_move(_p, lengthdir_x(_p.knockback_force, _p.knockback_dir), lengthdir_y(_p.knockback_force, _p.knockback_dir));
            _p.knockback_force = max(0, _p.knockback_force - _p.knockback_friction);
        }
        if (_p.stagger_timer <= 0) { _p.state = PLAYER_STATE.FREE; _p.knockback_force = 0; }
        return;
    }
    if (_i.dodge) {
        var _roll = global.combat_clock - _p.last_dodge_press <= 16;
        if (_p.state == PLAYER_STATE.FREE || _p.state == PLAYER_STATE.AIM
            || (_p.state == PLAYER_STATE.ATTACK && _p.attack_timer >= _p.attack.dodge_cancel_start)
            || _p.state == PLAYER_STATE.BLOCK || _p.state == PLAYER_STATE.PARRY
            || (_p.state == PLAYER_STATE.DODGE && !_p.dodge_roll && _roll)) dodge_start(_p, _roll);
    }
    if (_p.state == PLAYER_STATE.DODGE) {
        var _duration = (_p.dodge_roll ? 25 : 16);
        var _end_iframe = (_p.dodge_roll ? 17 : 9);
        _p.invulnerable = _p.dodge_timer >= 2 && _p.dodge_timer < _end_iframe;
        var _speed = (_p.dodge_roll ? 8 : 7) * (1 - _p.dodge_timer / _duration);
        arena_move(_p, lengthdir_x(_speed, _p.dodge_dir), lengthdir_y(_speed, _p.dodge_dir));
        _p.dodge_timer += 1;
        if (_p.dodge_timer >= _duration) _p.state = PLAYER_STATE.FREE;
        return;
    }
    if (_i.block && _p.shield.state != SHIELD_STATE.BROKEN) {
        var _can_defend = _p.state == PLAYER_STATE.FREE || _p.state == PLAYER_STATE.AIM
            || _p.state == PLAYER_STATE.BLOCK || _p.state == PLAYER_STATE.PARRY
            || (_p.state == PLAYER_STATE.ATTACK && _p.attack_timer >= _p.attack.block_cancel_start);
        if (_can_defend) {
            if (_p.state == PLAYER_STATE.ATTACK) combat_cancel(_p);
            shield_raise(_p, _i.block_pressed);
        }
    } else if (_p.state == PLAYER_STATE.BLOCK || _p.state == PLAYER_STATE.PARRY) {
        shield_lower(_p); _p.state = PLAYER_STATE.FREE;
    }
    if (_p.state == PLAYER_STATE.BLOCK || _p.state == PLAYER_STATE.PARRY) {
        arena_move(_p, _i.move_x * _p.move_speed * 0.35, _i.move_y * _p.move_speed * 0.35);
        return;
    }
    if (_p.state == PLAYER_STATE.ATTACK) {
        var _can_queue_throw = ((_p.weapons.current_weapon == WEAPON.AXE && !_p.weapons.outside_hand) || _p.weapons.current_weapon == WEAPON.SPEAR) && !_p.attack.is_throw;
        if (_can_queue_throw && (_i.aim_pressed || (_i.aim && (_i.light || _i.heavy)))) {
            _p.queued_throw = (_i.heavy ? "heavy" : "light");
            buffer_clear(_p.combo_buffer);
        }
        if (_p.queued_throw == "" && _p.attack_timer >= _p.attack.buffer_start && _p.attack_timer <= _p.attack.buffer_end) {
            if (_i.light) buffer_push(_p.combo_buffer, "light");
            if (_i.heavy) buffer_push(_p.combo_buffer, "heavy");
        }
        arena_move(_p, _i.move_x * _p.move_speed * _p.attack.movement_scale,
            _i.move_y * _p.move_speed * _p.attack.movement_scale);
        combat_attack_tick(_p); return;
    }
    _p.state = (_i.aim ? PLAYER_STATE.AIM : PLAYER_STATE.FREE);
    if (_i.aim && ((_p.weapons.current_weapon == WEAPON.AXE && !_p.weapons.outside_hand) || _p.weapons.current_weapon == WEAPON.SPEAR)) {
        if (_i.light || _i.heavy) combat_begin_throw(_p, _i.heavy);
    } else {
        if (_i.light) combat_start(_p, "light", 0);
        else if (_i.heavy) combat_start(_p, "heavy", 0);
    }
    var _scale = (_p.state == PLAYER_STATE.ATTACK ? _p.attack.movement_scale : (_i.aim ? 0.55 : 1));
    var _speed = _p.move_speed * _scale;
    if (_i.sprint && _p.state == PLAYER_STATE.FREE) _speed *= 1.5;
    arena_move(_p, _i.move_x * _speed, _i.move_y * _speed);
}

```

## scripts/scr_damage/scr_damage.gml

```gml
function hit_registry_has(_registry, _target) {
    for (var _i = 0; _i < array_length(_registry); ++_i)
        if (_registry[_i] == _target) return true;
    return false;
}
function combat_hitstop(_frames) { global.hitstop_remaining = max(global.hitstop_remaining, _frames); }
function camera_shake(_strength, _duration) {
    global.shake_strength = max(global.shake_strength, _strength);
    global.shake_remaining = max(global.shake_remaining, _duration);
}
function combat_fx(_kind, _x, _y) {
    // Hook visual independente: dados atualizados no Step, desenhados pelo controlador.
    array_push(global.fx, {kind: _kind, x: _x, y: _y, life: 12});
}
function combat_sfx(_kind) {
    // Registrar sons em global.sfx quando houver assets de audio.
    if (variable_struct_exists(global.sfx, _kind)) {
        var _sound = variable_struct_get(global.sfx, _kind);
        if (audio_exists(_sound)) audio_play_sound(_sound, 0, false);
    }
}
function apply_damage(_attacker, _target, _data) {
    if (!instance_exists(_attacker) || !instance_exists(_target)) return false;
    if (_target.object_index == obj_player) return player_receive_damage(_attacker, _target, _data);
    if (_target.state == ENEMY_STATE.DEAD || _target.invulnerable) return false;
    if (instance_exists(_target.execution_owner) && !(variable_struct_exists(_data, "is_execution") && _data.is_execution)) return false;
    var _dealt = _data.damage * (_target.frozen_timer > 0 ? 1.25 : 1);
    _target.hp = max(0, _target.hp - _dealt);
    if (_data.element == ELEMENT.FROST) frost_apply(_target, _data.element_amount);
    if (_data.element == ELEMENT.BURN) burn_apply(_target, _data.element_amount);
    if (variable_struct_exists(_data, "is_dot") && _data.is_dot) {
        _target.last_damage = _dealt;
        if (_target.hp <= 0) _target.state = ENEMY_STATE.DEAD;
        combat_fx("burn", _target.x, _target.y - 16);
        return true;
    }
    if (_data.stun > 0) {
        _target.last_stun_hit = global.combat_clock;
        var _was_full = _target.stun >= _target.max_stun;
        _target.stun = min(_target.max_stun, _target.stun + _data.stun);
        if (!_was_full && _target.stun >= _target.max_stun) _target.stun_until = global.combat_clock + 180;
    }
    if (_attacker.object_index == obj_player && _data.damage > 0) {
        if (_attacker.rage.active) _attacker.hp = min(_attacker.max_hp, _attacker.hp + 1);
        else _attacker.rage.meter = min(_attacker.rage.max_meter, _attacker.rage.meter + 3);
    }
    var _origin_x = (variable_struct_exists(_data, "origin_x") ? _data.origin_x : _attacker.x);
    var _origin_y = (variable_struct_exists(_data, "origin_y") ? _data.origin_y : _attacker.y);
    _target.knockback_dir = point_direction(_origin_x, _origin_y, _target.x, _target.y);
    _target.knockback_force = _data.knockback * (1 - _target.knockback_resistance);
    _target.stagger_timer = _data.stagger;
    _target.state = ENEMY_STATE.STAGGER;
    if (_target.stun >= _target.max_stun) _target.state = ENEMY_STATE.STUNNED;
    if (_target.hp <= 0) _target.state = ENEMY_STATE.DEAD;
    _target.last_damage = _dealt;
    _target.hit_count += 1;
    combat_hitstop(_data.hitstop); camera_shake(_data.shake, 8);
    combat_fx("hit", _target.x, _target.y - 16); combat_sfx("impact");
    return true;
}

```

## scripts/scr_drawing/scr_drawing.gml

```gml
function draw_actor(_x, _y, _dir, _color, _player) {
    draw_set_alpha(0.25); draw_set_color(c_black);
    draw_ellipse(_x - 15, _y - 6, _x + 15, _y + 6, false); draw_set_alpha(1);
    draw_set_color(_color);
    draw_triangle(_x, _y - 29, _x - 14, _y - 3, _x + 14, _y - 3, false);
    draw_circle(_x, _y - 29, 8, false);
    draw_set_color(_player ? make_color_rgb(155, 35, 45) : c_dkgray);
    draw_rectangle(_x - 11, _y - 13, _x + 11, _y - 10, false);
    draw_set_color(c_gray);
    var _front = lengthdir_y(1, _dir) >= 0;
    if (_front) draw_line(_x - 4, _y - 29, _x + 4, _y - 29);
    draw_line_width(_x, _y - 17, _x + lengthdir_x(21, _dir), _y - 17 + lengthdir_y(12, _dir), 3);
    draw_set_color(c_white);
}
function draw_attack_arc(_p) {
    if (_p.state != PLAYER_STATE.ATTACK) return;
    var _a = _p.attack;
    draw_set_color(_p.attack_phase == ATTACK_PHASE.ACTIVE ? c_lime : c_yellow);
    var _start = _p.locked_aim_dir - _a.arc / 2;
    for (var _j = 0; _j < 16; ++_j) {
        var _d1 = _start + _a.arc * _j / 16;
        var _d2 = _start + _a.arc * (_j + 1) / 16;
        draw_line(_p.x + lengthdir_x(_a.range, _d1), _p.y + lengthdir_y(_a.range, _d1),
            _p.x + lengthdir_x(_a.range, _d2), _p.y + lengthdir_y(_a.range, _d2));
    }
    draw_line(_p.x, _p.y, _p.x + lengthdir_x(_a.range, _start), _p.y + lengthdir_y(_a.range, _start));
    draw_line(_p.x, _p.y, _p.x + lengthdir_x(_a.range, _start + _a.arc), _p.y + lengthdir_y(_a.range, _start + _a.arc));
    draw_set_color(c_white);
}

```

## scripts/scr_execution/scr_execution.gml

```gml
function enemy_stun_tick(_t) {
    if (_t.state == ENEMY_STATE.DEAD) return;
    if (_t.state == ENEMY_STATE.STUNNED && global.combat_clock >= _t.stun_until) {
        _t.stun = 0; _t.state = ENEMY_STATE.IDLE;
    } else if (_t.state != ENEMY_STATE.STUNNED && global.combat_clock - _t.last_stun_hit > 120)
        _t.stun = max(0, _t.stun - 0.35);
}
function execution_find(_p) {
    // Prefer the locked target when it is eligible and reachable.
    var _locked = _p.lock_target;
    if (instance_exists(_locked) && _locked.state == ENEMY_STATE.STUNNED && !instance_exists(_locked.execution_owner)
        && global.combat_clock < _locked.stun_until && point_distance(_p.x, _p.y, _locked.x, _locked.y) <= 520) {
        if (array_length(nav_route(_p, _locked.x, _locked.y)) > 0) return _locked;
    }
    var _best = noone; var _distance = 520;
    for (var _i = 0; _i < instance_number(obj_enemy_parent); ++_i) {
        var _t = instance_find(obj_enemy_parent, _i);
        if (!instance_exists(_t) || _t.state != ENEMY_STATE.STUNNED || instance_exists(_t.execution_owner)) continue;
        var _d = point_distance(_p.x, _p.y, _t.x, _t.y);
        if (_d < _distance && global.combat_clock < _t.stun_until) {
            if (_d <= 56 && !segment_wall_blocked(_p.x, _p.y, _t.x, _t.y)) { _best = _t; _distance = _d; }
            else if (array_length(nav_route(_p, _t.x, _t.y)) > 0) { _best = _t; _distance = _d; }
        }
    }
    return _best;
}
function execution_start(_p) {
    var _can = _p.state == PLAYER_STATE.FREE || _p.state == PLAYER_STATE.AIM || _p.state == PLAYER_STATE.BLOCK || _p.state == PLAYER_STATE.PARRY
        || (_p.state == PLAYER_STATE.ATTACK && _p.attack_timer >= _p.attack.weapon_cancel_start);
    if (!_can) return false;
    var _t = execution_find(_p); if (!instance_exists(_t)) return false;
    combat_cancel(_p); shield_lower(_p);
    if (point_distance(_p.x, _p.y, _t.x, _t.y) <= 56 && !segment_wall_blocked(_p.x, _p.y, _t.x, _t.y)) return execution_commit(_p, _t);
    _p.execution_target = _t; _p.execution_path = nav_route(_p, _t.x, _t.y);
    _p.execution_approach_timer = 0; _p.state = PLAYER_STATE.EXECUTION_APPROACH;
    return true;
}
function execution_finish(_p) {
    var _t = _p.execution_target;
    if (instance_exists(_t) && _t.execution_owner == _p) {
        _t.execution_owner = noone;
        if (_t.state != ENEMY_STATE.DEAD) { _t.state = ENEMY_STATE.IDLE; _t.stun = 0; _t.stun_until = -1; }
    }
    _p.execution_target = noone; _p.state = PLAYER_STATE.FREE; _p.invulnerable = false;
}
function execution_tick(_p) {
    var _t = _p.execution_target;
    _p.invulnerable = true;
    if (!instance_exists(_t)) { execution_finish(_p); return; }
    _p.aim_dir = point_direction(_p.x, _p.y, _t.x, _t.y);
    if (_p.execution_timer == 18 && !_p.execution_struck) {
        _p.execution_struck = true;
        var _damage = (_t.is_elite ? _t.max_hp * 0.35 : _t.hp);
        var _d = {damage: _damage, stun: 0, stagger: 0, knockback: 0, hitstop: 6, shake: 5,
            element: ELEMENT.NONE, element_amount: 0, is_execution: true};
        apply_damage(_p, _t, _d); _t.stun = 0;
        combat_fx("execution", _t.x, _t.y - 16); combat_sfx("execution_impact");
        _p.rage.meter = min(_p.rage.max_meter, _p.rage.meter + 15);
    }
    _p.execution_timer += 1;
    if (_p.execution_timer >= 36) execution_finish(_p);
}
function draw_execution_indicators(_p) {
    var _t = execution_find(_p);
    if (instance_exists(_t)) {
        draw_set_color(c_yellow); draw_circle(_t.x, _t.y - 22, 25, true);
        draw_text(_t.x - 44, _t.y - 78, "MMB / RS: executar");
    }
    if (_p.state == PLAYER_STATE.EXECUTION_APPROACH && instance_exists(_p.execution_target)) {
        draw_set_color(c_yellow); draw_text(_p.x - 55, _p.y - 82, "Aproximando para executar");
    }
    if (_p.state == PLAYER_STATE.EXECUTION && instance_exists(_p.execution_target)) {
        var _t = _p.execution_target;
        draw_set_color(c_orange);
        draw_line_width(_p.x, _p.y - 18, _t.x, _t.y - 18, 5);
        draw_circle(_t.x, _t.y - 20, 12 + sin(_p.execution_timer * 0.3) * 6, true);
    }
    draw_set_color(c_white);
}
function build_fury_attacks() {
    var _light = []; var _heavy = [];
    for (var _i = 0; _i < 5; ++_i) {
        var _a = new AttackData("Colera " + string(_i + 1), 3, 4, 10, 18 + _i * 2, 75, 120, 30, 2);
        _a.combo_start = 13; _a.buffer_start = 3; _a.buffer_end = 17;
        _a.dodge_cancel_start = 10; _a.weapon_cancel_start = 13; _a.block_cancel_start = 13;
        _a.movement_scale = 0.7; array_push(_light, _a);
    }
    for (var _i = 0; _i < 3; ++_i) {
        var _a = new AttackData("Colera pesada", 9, 5, 18, 32, 100, 180, 45, 6);
        _a.hitstop = 5; _a.shake = 4; array_push(_heavy, _a);
    }
    return {light: _light, heavy: _heavy};
}
function fury_end(_p) {
    _p.rage.active = false;
    _p.weapons.current_weapon = _p.rage.previous_weapon;
    if (_p.state != PLAYER_STATE.DEAD) combat_cancel(_p);
}
function fury_toggle(_p) {
    if (_p.rage.active) { fury_end(_p); return; }
    if (_p.rage.meter < 20 || _p.state == PLAYER_STATE.DEAD || _p.state == PLAYER_STATE.EXECUTION) return;
    combat_cancel(_p); shield_lower(_p);
    _p.rage.previous_weapon = _p.weapons.current_weapon;
    _p.weapons.current_weapon = WEAPON.FISTS; _p.rage.active = true;
    combat_fx("fury_start", _p.x, _p.y); camera_shake(4, 8);
}
function fury_tick(_p) {
    if (!_p.rage.active) return;
    _p.rage.meter = max(0, _p.rage.meter - 0.2);
    if (_p.rage.meter <= 0) fury_end(_p);
}
function draw_fists(_p) {
    if (_p.weapons.current_weapon != WEAPON.FISTS && !(_p.weapons.current_weapon == WEAPON.AXE && _p.weapons.outside_hand)) return;
    var _dir = (_p.state == PLAYER_STATE.ATTACK ? _p.locked_aim_dir : _p.aim_dir);
    var _reach = 18;
    if (_p.state == PLAYER_STATE.ATTACK) {
        var _q = clamp((_p.attack_timer - _p.attack.startup) / max(1, _p.attack.active), 0, 1);
        _reach += sin(pi * _q) * 32;
    }
    draw_set_color(_p.rage.active ? c_orange : c_white);
    draw_circle(_p.x + lengthdir_x(_reach, _dir), _p.y - 16 + lengthdir_y(_reach, _dir), 6, false);
    draw_set_color(c_white);
}

```

## scripts/scr_input/scr_input.gml

```gml
function InputState() constructor {
    move_x = 0; move_y = 0; aim_x = 0; aim_y = 0;
    execute = false; rage = false; rage_chord_last = false; recall = false; light = false; heavy = false; dodge = false; lock = false;
    block_pressed = false; last_block = false; menu = false; menu_left = false; menu_right = false; menu_confirm = false; aim_pressed = false; last_aim = false; aim = false; block = false; sprint = false;
    weapon = -1; pad = -1; use_pad = false;
    mouse_last_x = mouse_x; mouse_last_y = mouse_y;
}
function read_input(_i) {
    _i.move_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    _i.move_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
    _i.recall = keyboard_check_pressed(ord("R"));
    _i.light = mouse_check_button_pressed(mb_left);
    _i.heavy = mouse_check_button_pressed(mb_right);
    _i.dodge = keyboard_check_pressed(vk_space);
    _i.execute = mouse_check_button_pressed(mb_middle);
    _i.rage = _i.execute && keyboard_check(vk_shift);
    _i.lock = _i.execute && !_i.rage;
    if (_i.rage) _i.execute = false;
    _i.aim = keyboard_check(vk_control);
    _i.block = keyboard_check(ord("Q"));
    _i.menu = keyboard_check_pressed(vk_tab);
    _i.menu_left = keyboard_check_pressed(vk_left);
    _i.menu_right = keyboard_check_pressed(vk_right);
    _i.menu_confirm = keyboard_check_pressed(vk_enter);
    _i.sprint = keyboard_check(vk_shift);
    _i.weapon = -1; _i.aim_x = 0; _i.aim_y = 0;
    for (var _k = 0; _k < 4; ++_k)
        if (keyboard_check_pressed(ord("1") + _k)) _i.weapon = _k;
    if (_i.move_x != 0 || _i.move_y != 0 || _i.light || _i.heavy || _i.dodge
        || _i.rage || _i.execute || _i.recall || _i.aim || mouse_x != _i.mouse_last_x || mouse_y != _i.mouse_last_y) _i.use_pad = false;
    _i.mouse_last_x = mouse_x; _i.mouse_last_y = mouse_y;
    _i.pad = -1;
    for (var _p = 0; _p < 12; ++_p) {
        if (gamepad_is_connected(_p)) { _i.pad = _p; break; }
    }
    if (_i.pad >= 0) {
        var _p = _i.pad;
        var _mx = gamepad_axis_value(_p, gp_axislh);
        var _my = gamepad_axis_value(_p, gp_axislv);
        var _ax = gamepad_axis_value(_p, gp_axisrh);
        var _ay = gamepad_axis_value(_p, gp_axisrv);
        var _ml = point_distance(0, 0, _mx, _my);
        var _al = point_distance(0, 0, _ax, _ay);
        var _l = gamepad_button_check_pressed(_p, gp_shoulderr);
        var _h = gamepad_button_check_pressed(_p, gp_shoulderrb);
        var _d = gamepad_button_check_pressed(_p, gp_face1);
        var _lock = gamepad_button_check_pressed(_p, gp_stickr);
        var _recall = gamepad_button_check_pressed(_p, gp_face4);
        var _rage_chord = gamepad_button_check(_p, gp_stickl) && gamepad_button_check(_p, gp_stickr);
        var _rage = _rage_chord && !_i.rage_chord_last;
        _i.rage_chord_last = _rage_chord;
        var _menu = gamepad_button_check_pressed(_p, gp_select);
        var _w = -1;
        if (gamepad_button_check_pressed(_p, gp_padl)) _w = WEAPON.BLADES;
        if (gamepad_button_check_pressed(_p, gp_padr)) _w = WEAPON.AXE;
        if (gamepad_button_check_pressed(_p, gp_padd)) _w = WEAPON.SPEAR;
        if (gamepad_button_check_pressed(_p, gp_padu)) _w = WEAPON.FISTS;
        if (_ml > 0.2 || _al > 0.2 || _l || _h || _d || _lock || _rage || _menu || _recall || gamepad_button_check(_p, gp_shoulderlb) || _w >= 0
            || gamepad_button_check(_p, gp_shoulderl)) _i.use_pad = true;
        if (_i.use_pad) {
            _i.move_x = (_ml > 0.2 ? _mx : 0); _i.move_y = (_ml > 0.2 ? _my : 0);
            _i.aim_x = (_al > 0.2 ? _ax : 0); _i.aim_y = (_al > 0.2 ? _ay : 0);
            _i.execute = _lock && !_rage_chord; _i.rage = _rage; _i.lock = _lock && !_rage_chord;
            _i.recall = _recall; _i.light = _l; _i.heavy = _h; _i.dodge = _d;
            _i.aim = gamepad_button_check(_p, gp_shoulderlb);
            _i.block = gamepad_button_check(_p, gp_shoulderl);
            _i.menu = _menu; _i.menu_left = gamepad_button_check_pressed(_p, gp_padl);
            _i.menu_right = gamepad_button_check_pressed(_p, gp_padr);
            _i.menu_confirm = gamepad_button_check_pressed(_p, gp_face1);
            _i.sprint = gamepad_button_check(_p, gp_stickl); _i.weapon = _w;
        }
    }
    _i.block_pressed = _i.block && !_i.last_block;
    _i.last_block = _i.block;
    _i.aim_pressed = _i.aim && !_i.last_aim;
    _i.last_aim = _i.aim;
    var _len = point_distance(0, 0, _i.move_x, _i.move_y);
    if (_len > 1) { _i.move_x /= _len; _i.move_y /= _len; }
}
function InputBuffer() constructor { action = ""; expires = -1; }
function buffer_push(_b, _action) { _b.action = _action; _b.expires = global.combat_clock + 10; }
function buffer_clear(_b) { _b.action = ""; _b.expires = -1; }
function buffer_valid(_b) { return _b.action != "" && global.combat_clock <= _b.expires; }

```

## scripts/scr_movement/scr_movement.gml

```gml
function arena_move(_actor, _dx, _dy) {
    // Colisao circular contra retangulos. Subpassos impedem atravessar paredes.
    var _steps = max(1, ceil(max(abs(_dx), abs(_dy)) / 4));
    for (var _s = 0; _s < _steps; ++_s) {
        var _nx = _actor.x + _dx / _steps;
        var _ny = _actor.y + _dy / _steps;
        var _r = _actor.body_radius;
        _nx = clamp(_nx, 40 + _r, room_width - 40 - _r);
        _ny = clamp(_ny, 40 + _r, room_height - 40 - _r);
        for (var _i = 0; _i < array_length(global.walls); ++_i) {
            var _w = global.walls[_i];
            if (_actor.y + _r > _w.y1 && _actor.y - _r < _w.y2) {
                if (_dx > 0 && _actor.x + _r <= _w.x1 && _nx + _r > _w.x1) _nx = _w.x1 - _r;
                if (_dx < 0 && _actor.x - _r >= _w.x2 && _nx - _r < _w.x2) _nx = _w.x2 + _r;
            }
        }
        _actor.x = _nx;
        for (var _i = 0; _i < array_length(global.walls); ++_i) {
            var _w = global.walls[_i];
            if (_actor.x + _r > _w.x1 && _actor.x - _r < _w.x2) {
                if (_dy > 0 && _actor.y + _r <= _w.y1 && _ny + _r > _w.y1) _ny = _w.y1 - _r;
                if (_dy < 0 && _actor.y - _r >= _w.y2 && _ny - _r < _w.y2) _ny = _w.y2 + _r;
            }
        }
        _actor.y = _ny;
    }
}
function segment_wall_blocked(_x1, _y1, _x2, _y2) {
    var _steps = max(1, ceil(point_distance(_x1, _y1, _x2, _y2) / 4));
    for (var _s = 0; _s <= _steps; ++_s) {
        var _x = lerp(_x1, _x2, _s / _steps); var _y = lerp(_y1, _y2, _s / _steps);
        for (var _i = 0; _i < array_length(global.walls); ++_i) {
            var _w = global.walls[_i];
            if (_x >= _w.x1 && _x <= _w.x2 && _y >= _w.y1 && _y <= _w.y2) return true;
        }
    }
    return false;
}

```

## scripts/scr_navigation_ai/scr_navigation_ai.gml

```gml
// Visibility graph with wall clearance; no teleportation or sprite collision dependency.
function nav_clear(_ax, _ay, _bx, _by, _radius) {
    var _n = max(1, ceil(point_distance(_ax, _ay, _bx, _by) / 3));
    for (var _s = 0; _s <= _n; ++_s) {
        var _x = lerp(_ax, _bx, _s / _n); var _y = lerp(_ay, _by, _s / _n);
        if (_x < 40 + _radius || _x > room_width - 40 - _radius || _y < 40 + _radius || _y > room_height - 40 - _radius) return false;
        for (var _i = 0; _i < array_length(global.walls); ++_i) {
            var _w = global.walls[_i];
            if (_x >= _w.x1 - _radius && _x <= _w.x2 + _radius && _y >= _w.y1 - _radius && _y <= _w.y2 + _radius) return false;
        }
    }
    return true;
}
function nav_route(_a, _tx, _ty) {
    var _nodes = [{x: _a.x, y: _a.y}, {x: _tx, y: _ty}];
    var _r = _a.body_radius; var _margin = _r + 6;
    for (var _i = 0; _i < array_length(global.walls); ++_i) {
        var _w = global.walls[_i];
        array_push(_nodes, {x: _w.x1 - _margin, y: _w.y1 - _margin});
        array_push(_nodes, {x: _w.x2 + _margin, y: _w.y1 - _margin});
        array_push(_nodes, {x: _w.x2 + _margin, y: _w.y2 + _margin});
        array_push(_nodes, {x: _w.x1 - _margin, y: _w.y2 + _margin});
    }
    var _count = array_length(_nodes);
    var _dist = array_create(_count, 1000000); var _prev = array_create(_count, -1); var _done = array_create(_count, false); _dist[0] = 0;
    for (var _step = 0; _step < _count; ++_step) {
        var _best = -1; var _cost = 1000000;
        for (var _i = 0; _i < _count; ++_i) if (!_done[_i] && _dist[_i] < _cost) { _best = _i; _cost = _dist[_i]; }
        if (_best < 0) break;
        if (_best == 1) break;
        _done[_best] = true; var _from = _nodes[_best];
        for (var _j = 0; _j < _count; ++_j) {
            if (_done[_j] || _j == _best) continue; var _to = _nodes[_j];
            var _new = _cost + point_distance(_from.x, _from.y, _to.x, _to.y);
            if (_new < _dist[_j] && nav_clear(_from.x, _from.y, _to.x, _to.y, _r)) { _dist[_j] = _new; _prev[_j] = _best; }
        }
    }
    if (_prev[1] < 0) return [];
    var _reverse = []; var _index = 1;
    while (_index > 0) { array_push(_reverse, _nodes[_index]); _index = _prev[_index]; }
    var _path = [];
    for (var _i = array_length(_reverse) - 1; _i >= 0; --_i) array_push(_path, _reverse[_i]);
    return _path;
}
function nav_follow(_a, _path, _speed) {
    if (array_length(_path) == 0) return false;
    var _point = _path[0]; var _distance = point_distance(_a.x, _a.y, _point.x, _point.y);
    var _dir = point_direction(_a.x, _a.y, _point.x, _point.y);
    arena_move(_a, lengthdir_x(min(_speed, _distance), _dir), lengthdir_y(min(_speed, _distance), _dir));
    if (point_distance(_a.x, _a.y, _point.x, _point.y) <= 2) array_delete(_path, 0, 1);
    return true;
}
function execution_approach_cancel(_p) {
    _p.execution_target = noone; _p.execution_path = []; _p.execution_approach_timer = 0;
    if (_p.state == PLAYER_STATE.EXECUTION_APPROACH) _p.state = PLAYER_STATE.FREE;
}
function execution_commit(_p, _t) {
    _p.execution_target = _t; _p.execution_timer = 0; _p.execution_struck = false;
    _p.state = PLAYER_STATE.EXECUTION; _p.invulnerable = true;
    _p.aim_dir = point_direction(_p.x, _p.y, _t.x, _t.y); _p.locked_aim_dir = _p.aim_dir;
    _t.execution_owner = _p; _t.state = ENEMY_STATE.EXECUTION; _t.knockback_force = 0;
    combat_sfx("execution_start"); return true;
}
function execution_approach_tick(_p) {
    var _t = _p.execution_target;
    if (_p.input.dodge) { dodge_start(_p, false); return; }
    if (!instance_exists(_t)) { execution_approach_cancel(_p); return; }
    if (_t.state != ENEMY_STATE.STUNNED || global.combat_clock >= _t.stun_until || instance_exists(_t.execution_owner)) { execution_approach_cancel(_p); return; }
    _p.execution_approach_timer += 1;
    if (_p.execution_approach_timer > 150) { execution_approach_cancel(_p); return; }
    _p.aim_dir = point_direction(_p.x, _p.y, _t.x, _t.y);
    _p.facing8 = round(_p.aim_dir / 45) mod 8;
    if (point_distance(_p.x, _p.y, _t.x, _t.y) <= 56 && !segment_wall_blocked(_p.x, _p.y, _t.x, _t.y)) { execution_commit(_p, _t); return; }
    if (_p.execution_approach_timer mod 12 == 1 || array_length(_p.execution_path) == 0) _p.execution_path = nav_route(_p, _t.x, _t.y);
    if (!nav_follow(_p, _p.execution_path, 8)) execution_approach_cancel(_p);
}
function enemy_ai_tick(_e) {
    if (!_e.ai_enabled || global.combat_frozen || global.equipment_open) return;
    if (_e.state == ENEMY_STATE.DEAD || _e.state == ENEMY_STATE.STAGGER || _e.state == ENEMY_STATE.STUNNED || _e.state == ENEMY_STATE.EXECUTION || instance_exists(_e.execution_owner)) { _e.ai_has_token = false; return; }
    var _p = global.player;
    if (!instance_exists(_p) || _p.state == PLAYER_STATE.DEAD) { _e.ai_has_token = false; _e.state = ENEMY_STATE.IDLE; return; }
    var _scale = _e.frost_slow_scale; if (_scale <= 0) return;
    var _distance = point_distance(_e.x, _e.y, _p.x, _p.y);
    if (_e.state == ENEMY_STATE.ATTACK) {
        _e.ai_timer += _scale;
        if (_e.ai_timer >= _e.ai_startup && !_e.ai_struck) {
            _e.ai_struck = true;
            if (combat_sector_intersects(_e, _p, 105, 95, _e.ai_dir) && !segment_wall_blocked(_e.x, _e.y, _p.x, _p.y)) {
                var _d = {damage: (_e.is_elite ? 22 : 12), stun: 0, stagger: 18, knockback: 4, hitstop: 3, shake: 2,
                    element: ELEMENT.NONE, element_amount: 0, guard_damage: 35, guard_break: _e.ai_attack_type == 1,
                    unblockable: _e.ai_attack_type == 2, parryable: _e.ai_attack_type != 2, origin_x: _e.x, origin_y: _e.y};
                apply_damage(_e, _p, _d);
            }
        }
        if (_e.state == ENEMY_STATE.ATTACK && _e.ai_timer >= _e.ai_startup + 6) { _e.state = ENEMY_STATE.RECOVERY; _e.ai_timer = 0; }
        return;
    }
    if (_e.state == ENEMY_STATE.RECOVERY) {
        _e.ai_timer += _scale;
        if (_e.ai_timer >= 32) { _e.state = ENEMY_STATE.CHASE; _e.ai_has_token = false; _e.ai_cooldown = 55; }
        return;
    }
    _e.ai_cooldown = max(0, _e.ai_cooldown - _scale);
    _e.ai_dir = point_direction(_e.x, _e.y, _p.x, _p.y); _e.state = ENEMY_STATE.CHASE;
    var _tokens = 0;
    for (var _i = 0; _i < instance_number(obj_enemy_parent); ++_i) {
        var _other = instance_find(obj_enemy_parent, _i);
        if (_other.ai_enabled && _other.ai_has_token && (_other.state == ENEMY_STATE.ATTACK || _other.state == ENEMY_STATE.RECOVERY)) _tokens += 1;
    }
    if (_distance <= 100 && _e.ai_cooldown <= 0 && _tokens < 2 && !segment_wall_blocked(_e.x, _e.y, _p.x, _p.y)) {
        _e.ai_has_token = true; _e.state = ENEMY_STATE.ATTACK; _e.ai_timer = 0; _e.ai_struck = false;
        _e.ai_attack_type = (_e.is_elite ? _e.ai_sequence mod 3 : 0); _e.ai_sequence += 1;
        _e.ai_startup = (_e.ai_attack_type == 2 ? 48 : 36); return;
    }
    var _desired = (_tokens >= 2 ? 155 : 80);
    if (_distance > _desired) {
        if (global.combat_clock >= _e.ai_repath || array_length(_e.ai_path) == 0) { _e.ai_path = nav_route(_e, _p.x, _p.y); _e.ai_repath = global.combat_clock + 24; }
        nav_follow(_e, _e.ai_path, (_e.is_elite ? 1.8 : 2.1) * _scale);
    }
    // Prevent waiting enemies from occupying the same position.
    for (var _i = 0; _i < instance_number(obj_enemy_parent); ++_i) {
        var _other = instance_find(obj_enemy_parent, _i);
        if (_other == _e || _other.state == ENEMY_STATE.DEAD) continue;
        var _d = point_distance(_e.x, _e.y, _other.x, _other.y);
        if (_d < 38) { var _dir = (_d < 1 ? (_e.id mod 8) * 45 : point_direction(_other.x, _other.y, _e.x, _e.y)); arena_move(_e, lengthdir_x(0.8 * _scale, _dir), lengthdir_y(0.8 * _scale, _dir)); }
    }
}
function enemy_ai_draw(_e) {
    if (!_e.ai_enabled || _e.state == ENEMY_STATE.DEAD) return;
    draw_set_color(c_white); draw_text(_e.x - 28, _e.y - 108, _e.is_elite ? "GUARDIAO" : "SAQUEADOR");
    if (_e.state == ENEMY_STATE.ATTACK) {
        draw_set_color(_e.ai_attack_type == 2 ? c_red : (_e.ai_attack_type == 1 ? c_yellow : c_white));
        draw_circle(_e.x, _e.y - 20, 24 + 12 * clamp(_e.ai_timer / _e.ai_startup, 0, 1), true);
        draw_line_width(_e.x, _e.y, _e.x + lengthdir_x(105, _e.ai_dir), _e.y + lengthdir_y(105, _e.ai_dir), 2);
    }
    draw_set_color(c_white);
}

```

## scripts/scr_shield/scr_shield.gml

```gml
// ================= ESCUDOS: DADOS MODULARES =================
function ShieldController() constructor {
    equipped = 0; state = SHIELD_STATE.NONE; guard = 0;
    parry_started = -100; next_parry = 0; parry_consumed = false;
    broken_until = 0; last_hit = -100; reward = 0;
    profiles = [
        {name: "Equilibrado", arc: 120, parry_frames: 6, perfect_frames: 2, max_guard: 100, guard_scale: 1, parry_stun: 28, break_frames: 30},
        {name: "Contra-ataque", arc: 110, parry_frames: 8, perfect_frames: 3, max_guard: 75, guard_scale: 1.2, parry_stun: 40, break_frames: 34},
        {name: "Baluarte", arc: 140, parry_frames: 3, perfect_frames: 1, max_guard: 160, guard_scale: 0.65, parry_stun: 20, break_frames: 42}
    ];
}
function shield_equip(_p, _index) {
    if (_index < 0 || _index >= array_length(_p.shield.profiles)) return;
    var _s = _p.shield; var _ratio = _s.guard / _s.profiles[_s.equipped].max_guard;
    _s.equipped = _index; _s.guard = _ratio * _s.profiles[_index].max_guard;
    // Trocar escudo nao cura guarda nem remove quebra/cooldown.
    if (_s.state != SHIELD_STATE.BROKEN) shield_lower(_p);
}
function shield_lower(_p) {
    if (_p.shield.state != SHIELD_STATE.BROKEN) _p.shield.state = SHIELD_STATE.NONE;
    _p.shield.parry_consumed = true;
}
function shield_tick(_p) {
    var _s = _p.shield; var _profile = _s.profiles[_s.equipped];
    if (_s.state == SHIELD_STATE.BROKEN && global.combat_clock >= _s.broken_until) {
        _s.state = SHIELD_STATE.NONE; _s.guard = 0;
    }
    if (_s.state != SHIELD_STATE.BROKEN && _s.state != SHIELD_STATE.BLOCK && _s.state != SHIELD_STATE.PARRY
        && global.combat_clock - _s.last_hit > 60) _s.guard = max(0, _s.guard - 0.8);
}
function shield_raise(_p, _pressed) {
    var _s = _p.shield; var _profile = _s.profiles[_s.equipped];
    if (_s.state == SHIELD_STATE.BROKEN) return;
    if (_pressed && global.combat_clock >= _s.next_parry) {
        _s.parry_started = global.combat_clock; _s.parry_consumed = false;
        _s.next_parry = global.combat_clock + 12;
    }
    var _elapsed = global.combat_clock - _s.parry_started;
    _s.state = (!_s.parry_consumed && _elapsed < _profile.parry_frames ? SHIELD_STATE.PARRY : SHIELD_STATE.BLOCK);
    _p.state = (_s.state == SHIELD_STATE.PARRY ? PLAYER_STATE.PARRY : PLAYER_STATE.BLOCK);
}
function shield_break(_p) {
    var _s = _p.shield; var _profile = _s.profiles[_s.equipped];
    combat_cancel(_p); _s.state = SHIELD_STATE.BROKEN;
    _s.guard = _profile.max_guard; _s.broken_until = global.combat_clock + _profile.break_frames;
    _p.state = PLAYER_STATE.STAGGER; _p.stagger_timer = _profile.break_frames;
    _p.last_defense_result = "GUARDA QUEBRADA";
    combat_fx("guard_break", _p.x, _p.y - 15); camera_shake(3, 8); combat_hitstop(4);
}
function player_receive_damage(_attacker, _p, _d) {
    if (_p.state == PLAYER_STATE.DEAD) return false;
    if (_p.state == PLAYER_STATE.EXECUTION) return false;
    if (_p.rage.active) {
        _p.rage.meter = max(0, _p.rage.meter - _d.damage);
        _p.last_defense_result = "COLERA absorveu impacto";
        combat_fx("fury_hit", _p.x, _p.y); return false;
    }
    if (_p.invulnerable) { _p.last_defense_result = "ESQUIVA: i-frames"; return false; }
    var _s = _p.shield; var _profile = _s.profiles[_s.equipped];
    var _ox = (variable_struct_exists(_d, "origin_x") ? _d.origin_x : _attacker.x);
    var _oy = (variable_struct_exists(_d, "origin_y") ? _d.origin_y : _attacker.y);
    var _incoming = point_direction(_p.x, _p.y, _ox, _oy);
    var _frontal = abs(angle_difference(_incoming, _p.aim_dir)) <= _profile.arc / 2;
    var _unblockable = variable_struct_exists(_d, "unblockable") && _d.unblockable;
    var _break = variable_struct_exists(_d, "guard_break") && _d.guard_break;
    var _parryable = !variable_struct_exists(_d, "parryable") || _d.parryable;
    var _blocking = _s.state == SHIELD_STATE.BLOCK || _s.state == SHIELD_STATE.PARRY;
    if (_frontal && _blocking && !_unblockable) {
        var _elapsed = global.combat_clock - _s.parry_started;
        if (_s.state == SHIELD_STATE.PARRY && !_s.parry_consumed && _parryable && _elapsed < _profile.parry_frames) {
            var _perfect = _elapsed < _profile.perfect_frames;
            _s.parry_consumed = true; _s.state = SHIELD_STATE.BLOCK; _p.state = PLAYER_STATE.BLOCK;
            _s.guard = max(0, _s.guard - (_perfect ? 25 : 12)); _s.reward = min(100, _s.reward + (_perfect ? 30 : 15));
            _p.last_defense_result = (_perfect ? "PERFECT PARRY" : "PARRY");
            if (instance_exists(_attacker) && _attacker.object_index != obj_player) {
                var _counter = {damage: 0, stun: _profile.parry_stun * (_perfect ? 1.5 : 1), stagger: (_perfect ? 25 : 18),
                    knockback: 3, hitstop: 0, shake: 0, element: ELEMENT.NONE, element_amount: 0};
                apply_damage(_p, _attacker, _counter);
            }
            combat_hitstop(_perfect ? 7 : 5); combat_fx("parry", _p.x, _p.y - 16);
            camera_shake(2, 5); combat_sfx("parry"); return false;
        }
        _s.last_hit = global.combat_clock;
        if (_break) { shield_break(_p); return false; }
        var _guard = (variable_struct_exists(_d, "guard_damage") ? _d.guard_damage : _d.damage);
        _s.guard = min(_profile.max_guard, _s.guard + _guard * _profile.guard_scale);
        _p.last_defense_result = "BLOQUEIO FRONTAL";
        combat_fx("block", _p.x, _p.y - 16); combat_sfx("block"); combat_hitstop(2);
        if (_s.guard >= _profile.max_guard) shield_break(_p);
        return false;
    }
    shield_lower(_p); combat_cancel(_p);
    _p.hp = max(0, _p.hp - _d.damage); _p.state = (_p.hp <= 0 ? PLAYER_STATE.DEAD : PLAYER_STATE.STAGGER);
    _p.stagger_timer = _d.stagger;
    _p.knockback_dir = point_direction(_ox, _oy, _p.x, _p.y); _p.knockback_force = _d.knockback;
    _p.last_defense_result = (_unblockable ? "IMBLOQUEAVEL: dano" : (_frontal ? "DANO" : "ATAQUE POR TRAS"));
    combat_hitstop(_d.hitstop); camera_shake(_d.shake, 6); combat_fx("hit", _p.x, _p.y - 16); return true;
}
function draw_player_shield(_p) {
    var _s = _p.shield;
    if (_s.state != SHIELD_STATE.BLOCK && _s.state != SHIELD_STATE.PARRY) return;
    var _dir = _p.aim_dir; var _x = _p.x + lengthdir_x(21, _dir); var _y = _p.y - 16 + lengthdir_y(15, _dir);
    draw_set_color(_s.state == SHIELD_STATE.PARRY ? c_aqua : c_silver);
    draw_circle(_x, _y, 12, false); draw_set_color(c_dkgray); draw_circle(_x, _y, 8, true);
    if (global.debug_combat) {
        var _arc = _s.profiles[_s.equipped].arc;
        draw_line(_p.x, _p.y, _p.x + lengthdir_x(75, _dir - _arc / 2), _p.y + lengthdir_y(75, _dir - _arc / 2));
        draw_line(_p.x, _p.y, _p.x + lengthdir_x(75, _dir + _arc / 2), _p.y + lengthdir_y(75, _dir + _arc / 2));
    }
    draw_set_color(c_white);
}

```

## scripts/scr_shield_test/scr_shield_test.gml

```gml
// ================= TESTE CONTROLADO: BONECOS NAO TEM AI =================
function shield_test_queue(_p, _type, _rear) {
    var _dir = _p.aim_dir + (_rear ? 180 : 0);
    var _source = instance_nearest(_p.x, _p.y, obj_enemy_parent);
    if (!instance_exists(_source)) return;
    array_push(global.test_attacks, {source: _source, x: _p.x + lengthdir_x(100, _dir), y: _p.y + lengthdir_y(100, _dir),
        due: global.combat_clock + 60, kind: _type, rear: _rear});
}
function shield_test_tick() {
    if (!instance_exists(global.player)) return;
    var _p = global.player;
    if (global.debug_combat) {
        if (keyboard_check_pressed(vk_f6)) shield_test_queue(_p, 0, false);
        if (keyboard_check_pressed(vk_f7)) shield_test_queue(_p, 1, false);
        if (keyboard_check_pressed(vk_f8)) shield_test_queue(_p, 2, false);
        if (keyboard_check_pressed(vk_f9)) shield_test_queue(_p, 0, true);
        if (keyboard_check_pressed(vk_f10)) { _p.hp = _p.max_hp; _p.last_defense_result = "Vida restaurada"; }
    }
    for (var _i = array_length(global.test_attacks) - 1; _i >= 0; --_i) {
        var _a = global.test_attacks[_i];
        if (global.combat_clock >= _a.due) {
            if (instance_exists(_a.source) && point_distance(_p.x, _p.y, _a.x, _a.y) <= 170) {
                var _d = {damage: 15, stun: 0, stagger: 18, knockback: 3, hitstop: 3, shake: 2,
                    element: ELEMENT.NONE, element_amount: 0, guard_damage: 40,
                    origin_x: _a.x, origin_y: _a.y, parryable: _a.kind != 2,
                    guard_break: _a.kind == 1, unblockable: _a.kind == 2};
                apply_damage(_a.source, _p, _d);
            } else _p.last_defense_result = "TESTE: fora do alcance";
            array_delete(global.test_attacks, _i, 1);
        }
    }
}
function draw_shield_tests() {
    for (var _i = 0; _i < array_length(global.test_attacks); ++_i) {
        var _a = global.test_attacks[_i];
        draw_set_color(_a.kind == 2 ? c_red : (_a.kind == 1 ? c_yellow : c_aqua));
        draw_circle(_a.x, _a.y - 16, 15, true);
        draw_text(_a.x - 35, _a.y - 50, "TESTE " + string(max(0, _a.due - global.combat_clock)));
    }
    draw_set_color(c_white);
}
function draw_equipment_menu() {
    if (!global.equipment_open || !instance_exists(global.player)) return;
    var _s = global.player.shield; var _index = global.equipment_selection; var _d = _s.profiles[_index];
    draw_set_alpha(0.95); draw_set_color(make_color_rgb(14, 20, 29)); draw_rectangle(170, 210, 790, 510, false);
    draw_set_alpha(1); draw_set_color(c_white);
    draw_text(200, 230, "ESCUDOS — todas as opcoes desbloqueadas");
    draw_text(200, 270, "<  " + _d.name + "  >");
    draw_text(200, 310, "Parry: " + string(_d.parry_frames) + " frames | perfect: " + string(_d.perfect_frames));
    draw_text(200, 340, "Guarda: " + string(_d.max_guard) + " | arco frontal: " + string(_d.arc));
    draw_text(200, 380, "Equipado: " + _s.profiles[_s.equipped].name);
    draw_text(200, 420, "Setas / D-pad: escolher | Enter / A: equipar");
    draw_text(200, 455, "Tab / Back: fechar | combate pausado");
}

```

## scripts/scr_soft_chain/scr_soft_chain.gml

```gml
function SoftChain() constructor {
    nodes = []; initialized = false;
    for (var _i = 0; _i < 26; ++_i) array_push(nodes, {x: 0, y: 0, vx: 0, vy: 0});
}
function soft_chain_tick(_c, _hx, _hy, _bx, _by, _slack, _side, _taut) {
    if (_taut) _slack = 0;
    var _count = array_length(_c.nodes);
    var _dx = _bx - _hx; var _dy = _by - _hy;
    var _dist = max(1, point_distance(_hx, _hy, _bx, _by));
    var _nx = -_dy / _dist; var _ny = _dx / _dist;
    for (var _i = 0; _i < _count; ++_i) {
        var _t = _i / (_count - 1);
        var _envelope = sin(pi * _t);
        var _sag = _slack * min(40, _dist * 0.22);
        var _wave = sin(global.combat_clock * 0.13 - _t * 5) * _sag * 0.18;
        var _tx = lerp(_hx, _bx, _t) + _nx * (_sag * _side + _wave) * _envelope;
        var _ty = lerp(_hy, _by, _t) + _ny * (_sag * _side + _wave) * _envelope + _sag * 0.4 * _envelope;
        if (_i == 0) { _tx = _hx; _ty = _hy; }
        if (_i == _count - 1) { _tx = _bx; _ty = _by; }
        var _n = _c.nodes[_i];
        if (!_c.initialized || _taut || _i == 0 || _i == _count - 1) {
            _n.x = _tx; _n.y = _ty; _n.vx = 0; _n.vy = 0;
        } else {
            // Springs amortecidas: a corrente segue com atraso, sem mover a lamina.
            _n.vx = (_n.vx + (_tx - _n.x) * 0.18) * 0.68;
            _n.vy = (_n.vy + (_ty - _n.y) * 0.18) * 0.68;
            _n.x += _n.vx; _n.y += _n.vy;
        }
    }
    _c.initialized = true;
    if (!_taut) {
        // Limitar alongamento entre pontos evita espigoes ao virar/esquivar.
        var _limit = max(2, _dist / (_count - 1) * (1 + _slack * 0.35));
        for (var _pass = 0; _pass < 6; ++_pass) {
            for (var _i = 0; _i < _count - 1; ++_i) {
                var _a = _c.nodes[_i]; var _b = _c.nodes[_i + 1];
                var _x = _b.x - _a.x; var _y = _b.y - _a.y;
                var _len = point_distance(0, 0, _x, _y);
                if (_len > _limit) {
                    var _ratio = (_len - _limit) / max(0.001, _len);
                    var _wa = (_i == 0 ? 0 : (_i + 1 == _count - 1 ? 1 : 0.5));
                    var _wb = (_i + 1 == _count - 1 ? 0 : (_i == 0 ? 1 : 0.5));
                    _a.x += _x * _ratio * _wa; _a.y += _y * _ratio * _wa;
                    _b.x -= _x * _ratio * _wb; _b.y -= _y * _ratio * _wb;
                }
            }
        }
    }
}
function draw_chain_link(_x, _y, _dir, _flat) {
    var _width = (_flat ? 0.8 : 2.2);
    draw_set_color(_flat ? c_silver : c_gray);
    var _px = _x + lengthdir_x(4, _dir); var _py = _y + lengthdir_y(4, _dir);
    for (var _i = 1; _i <= 8; ++_i) {
        var _q = _i * pi / 4;
        var _lx = _x + lengthdir_x(cos(_q) * 4, _dir) + lengthdir_x(sin(_q) * _width, _dir + 90);
        var _ly = _y + lengthdir_y(cos(_q) * 4, _dir) + lengthdir_y(sin(_q) * _width, _dir + 90);
        draw_line(_px, _py, _lx, _ly); _px = _lx; _py = _ly;
    }
}
function draw_soft_chain(_c) {
    if (!_c.initialized) return;
    var _next = 4; var _travel = 0; var _link = 0;
    for (var _i = 0; _i < array_length(_c.nodes) - 1; ++_i) {
        var _a = _c.nodes[_i]; var _b = _c.nodes[_i + 1];
        var _len = point_distance(_a.x, _a.y, _b.x, _b.y);
        draw_set_color(c_dkgray); draw_line(_a.x, _a.y, _b.x, _b.y);
        while (_next <= _travel + _len && _len > 0.001) {
            var _q = (_next - _travel) / _len;
            draw_chain_link(lerp(_a.x, _b.x, _q), lerp(_a.y, _b.y, _q),
                point_direction(_a.x, _a.y, _b.x, _b.y), _link mod 2 == 0);
            _next += 8; _link += 1;
        }
        _travel += _len;
    }
    draw_set_color(c_white);
}

```

## scripts/scr_spear/scr_spear.gml

```gml
function spear_prune(_p) {
    for (var _i = array_length(_p.spears) - 1; _i >= 0; --_i)
        if (!instance_exists(_p.spears[_i])) array_delete(_p.spears, _i, 1);
}
function spear_throw(_p, _dir, _heavy) {
    if (!instance_exists(_p)) return;
    spear_prune(_p);
    if (array_length(_p.spears) >= _p.max_spears) {
        var _old = _p.spears[0];
        if (instance_exists(_old)) { combat_fx("spear_fade", _old.x, _old.y); instance_destroy(_old); }
        array_delete(_p.spears, 0, 1);
    }
    var _s = instance_create_layer(_p.x, _p.y, "Actors", obj_spear_projectile);
    _s.owner = _p; _s.fly_dir = _dir; _s.heavy_throw = _heavy;
    _s.fly_speed = (_heavy ? 17 : 22);
    _s.impact_data.damage = (_heavy ? 32 : 20);
    array_push(_p.spears, _s); combat_sfx("throw");
}
function spear_detonate_all(_p) {
    spear_prune(_p);
    var _index = 0;
    for (var _i = 0; _i < array_length(_p.spears); ++_i) {
        var _s = _p.spears[_i];
        if (_s.state == SPEAR_PROJECTILE_STATE.STUCK && _s.detonate_at < 0) {
            _s.detonate_at = global.combat_clock + _index * 2; _index += 1;
        }
    }
    if (_index > 0) combat_sfx("detonate");
}
function spear_stick(_s, _target) {
    _s.state = SPEAR_PROJECTILE_STATE.STUCK; _s.stuck_target = _target;
    if (instance_exists(_target)) {
        _s.offset_x = _s.x - _target.x; _s.offset_y = _s.y - _target.y;
    }
    combat_fx("spear_stick", _s.x, _s.y);
}
function spear_explode(_s) {
    if (_s.state == SPEAR_PROJECTILE_STATE.DETONATING || !instance_exists(_s.owner)) return;
    _s.state = SPEAR_PROJECTILE_STATE.DETONATING;
    _s.explosion_data.origin_x = _s.x; _s.explosion_data.origin_y = _s.y;
    combat_fx("spear_explosion", _s.x, _s.y); camera_shake(4, 10); combat_sfx("explosion");
    // Uma consulta por alvo em cada explosao; explosoes diferentes podem acumular dano.
    for (var _i = 0; _i < instance_number(obj_enemy_parent); ++_i) {
        var _t = instance_find(obj_enemy_parent, _i);
        if (instance_exists(_t) && point_distance(_s.x, _s.y, _t.x, _t.y) <= _s.explosion_radius + _t.body_radius
            && !segment_wall_blocked(_s.x, _s.y, _t.x, _t.y)) apply_damage(_s.owner, _t, _s.explosion_data);
    }
    for (var _i = 0; _i < array_length(_s.owner.spears); ++_i) {
        var _other = _s.owner.spears[_i];
        if (instance_exists(_other) && _other != _s && _other.state == SPEAR_PROJECTILE_STATE.STUCK
            && point_distance(_s.x, _s.y, _other.x, _other.y) <= _s.explosion_radius
            && !segment_wall_blocked(_s.x, _s.y, _other.x, _other.y)) {
            var _next = global.combat_clock + 2;
            if (_other.detonate_at < 0) _other.detonate_at = _next;
            else _other.detonate_at = min(_other.detonate_at, _next);
        }
    }
    instance_destroy(_s);
}
function spear_projectile_tick(_s) {
    if (!instance_exists(_s.owner)) { instance_destroy(_s); return; }
    if (_s.state == SPEAR_PROJECTILE_STATE.STUCK) {
        if (instance_exists(_s.stuck_target)) {
            _s.x = _s.stuck_target.x + _s.offset_x; _s.y = _s.stuck_target.y + _s.offset_y;
        }
        if (_s.detonate_at >= 0 && global.combat_clock >= _s.detonate_at) { spear_explode(_s); return; }
    } else if (_s.state == SPEAR_PROJECTILE_STATE.FLYING) {
        var _steps = max(1, ceil(_s.fly_speed / 4));
        for (var _step = 0; _step < _steps; ++_step) {
            var _nx = _s.x + lengthdir_x(_s.fly_speed / _steps, _s.fly_dir);
            var _ny = _s.y + lengthdir_y(_s.fly_speed / _steps, _s.fly_dir);
            if (segment_wall_blocked(_s.x, _s.y, _nx, _ny) || _nx < 40 || _ny < 40
                || _nx > room_width - 40 || _ny > room_height - 40) { spear_stick(_s, noone); break; }
            _s.x = _nx; _s.y = _ny;
            var _hit = false;
            for (var _i = 0; _i < instance_number(obj_enemy_parent); ++_i) {
                var _t = instance_find(obj_enemy_parent, _i);
                if (!instance_exists(_t) || _t.state == ENEMY_STATE.DEAD) continue;
                if (point_distance(_s.x, _s.y, _t.x, _t.y) <= _t.body_radius + 5) {
                    if (apply_damage(_s.owner, _t, _s.impact_data)) { spear_stick(_s, _t); _hit = true; break; }
                }
            }
            if (_hit) break;
        }
        if (_s.state == SPEAR_PROJECTILE_STATE.FLYING) {
            _s.fly_distance += _s.fly_speed;
            if (_s.fly_distance >= 750) spear_stick(_s, noone);
        }
    }
    _s.depth = -_s.y - 1;
}
function spear_held_tick(_s) {
    if (!instance_exists(_s.owner)) { instance_destroy(_s); return; }
    var _p = _s.owner;
    _s.state = SPEAR_STATE.HAND; _s.facing = _p.aim_dir;
    var _reach = 26;
    if (_p.weapons.current_weapon == WEAPON.SPEAR && _p.state == PLAYER_STATE.ATTACK) {
        _s.facing = _p.locked_aim_dir; _s.state = SPEAR_STATE.MELEE;
        if (!_p.attack.is_throw) {
            var _q = clamp((_p.attack_timer - _p.attack.startup) / max(1, _p.attack.active), 0, 1);
            _reach += sin(pi * _q) * 65;
        }
    }
    _s.x = _p.x + lengthdir_x(_reach, _s.facing); _s.y = _p.y + lengthdir_y(_reach, _s.facing);
    _s.depth = -_p.y - 1;
}
function draw_spear_shape(_x, _y, _dir, _size) {
    draw_set_color(make_color_rgb(205, 171, 91));
    draw_line_width(_x - lengthdir_x(28 * _size, _dir), _y - lengthdir_y(28 * _size, _dir),
        _x + lengthdir_x(22 * _size, _dir), _y + lengthdir_y(22 * _size, _dir), 3);
    var _hx = _x + lengthdir_x(22 * _size, _dir); var _hy = _y + lengthdir_y(22 * _size, _dir);
    draw_set_color(c_white);
    draw_triangle(_hx + lengthdir_x(12 * _size, _dir), _hy + lengthdir_y(12 * _size, _dir),
        _hx + lengthdir_x(5 * _size, _dir + 90), _hy + lengthdir_y(5 * _size, _dir + 90),
        _hx + lengthdir_x(5 * _size, _dir - 90), _hy + lengthdir_y(5 * _size, _dir - 90), false);
}

```

## scripts/scr_types/scr_types.gml

```gml
enum WEAPON { AXE, BLADES, SPEAR, FISTS }
enum PLAYER_STATE { FREE, ATTACK, AIM, DODGE, BLOCK, PARRY, STAGGER, EXECUTION, DEAD, EXECUTION_APPROACH }
enum ATTACK_PHASE { STARTUP, ACTIVE, RECOVERY }
enum ENEMY_STATE { IDLE, CHASE, ATTACK, RECOVERY, STAGGER, STUNNED, KNOCKBACK, DEAD, EXECUTION }
enum ELEMENT { NONE, FROST, BURN }
enum AXE_STATE { HAND, MELEE, FLYING, STUCK, RETURNING }
enum BLADE_STATE { IDLE, LIGHT_COMBO, HEAVY_COMBO, GRAPPLE, SPIN }
enum SPEAR_STATE { HAND, MELEE, THROWN }
enum SPEAR_PROJECTILE_STATE { FLYING, STUCK, DETONATING }
enum SHIELD_STATE { NONE, BLOCK, PARRY, BROKEN }

```

## scripts/scr_weapon_manager/scr_weapon_manager.gml

```gml
function WeaponManager() constructor {
    current_weapon = WEAPON.AXE; previous_weapon = WEAPON.AXE;
    axe_state = AXE_STATE.HAND; outside_hand = false;
    switch_cooldown = 0;
}
function weapon_switch(_p, _weapon) {
    if (_p.rage.active || _p.state == PLAYER_STATE.EXECUTION) return false;
    if (_weapon < 0 || _weapon > WEAPON.FISTS || _p.weapons.switch_cooldown > 0) return false;
    if (_p.state != PLAYER_STATE.FREE && _p.state != PLAYER_STATE.AIM && _p.state != PLAYER_STATE.BLOCK && _p.state != PLAYER_STATE.PARRY
        && !(_p.state == PLAYER_STATE.ATTACK && _p.attack_timer >= _p.attack.weapon_cancel_start)) return false;
    _p.weapons.previous_weapon = _p.weapons.current_weapon;
    _p.weapons.current_weapon = _weapon; _p.weapons.switch_cooldown = 8;
    combat_cancel(_p);
    shield_lower(_p);
    if (_p.weapons.previous_weapon == WEAPON.BLADES && _weapon == WEAPON.AXE
        && _p.weapons.outside_hand && instance_exists(_p.my_axe)) axe_recall(_p.my_axe);
    return true;
}

```

