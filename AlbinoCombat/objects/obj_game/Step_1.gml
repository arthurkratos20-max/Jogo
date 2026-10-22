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
