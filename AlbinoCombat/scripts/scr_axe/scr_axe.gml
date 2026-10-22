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
