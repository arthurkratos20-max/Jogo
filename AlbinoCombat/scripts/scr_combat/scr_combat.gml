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
