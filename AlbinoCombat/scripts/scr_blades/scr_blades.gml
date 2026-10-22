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
