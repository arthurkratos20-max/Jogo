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
