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
