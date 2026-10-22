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
