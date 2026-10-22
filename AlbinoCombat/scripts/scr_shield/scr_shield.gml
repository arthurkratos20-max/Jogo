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
