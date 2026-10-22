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
