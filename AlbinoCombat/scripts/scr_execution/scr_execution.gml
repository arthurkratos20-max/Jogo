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
