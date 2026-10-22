function AttackData(_name, _startup, _active, _recovery, _damage, _range, _arc, _stun, _knockback) constructor {
    name = _name;
    startup = _startup; active = _active; recovery = _recovery;
    damage = _damage; range = _range; arc = _arc;
    stun = _stun; stagger = 10; knockback = _knockback;
    is_blade_heavy = false; blade_spin = false; blade_sign = 1; impact_frame = 0; throw_weapon = WEAPON.AXE; is_throw = false; throw_heavy = false; hitstop = 2; element = ELEMENT.NONE; element_amount = 0;
    buffer_start = max(0, startup - 3);
    buffer_end = startup + active + recovery;
    combo_start = startup + active + floor(recovery * 0.65);
    dodge_cancel_start = startup + active + floor(recovery * 0.4);
    weapon_cancel_start = startup + active + floor(recovery * 0.6);
    block_cancel_start = startup + active + floor(recovery * 0.7);
    movement_scale = 0.4;
    shake = 1;
}
function build_attack_database() {
    var _db = [];
    for (var _w = 0; _w < 4; ++_w) {
        var _light = []; var _heavy = [];
        var _names = ["Machado", "Laminas", "Lanca", "Socos"];
        var _range = [92, 115, 125, 52];
        var _damage = [18, 12, 14, 8];
        var _count = [4, 5, 4, 5];
        for (var _i = 0; _i < _count[_w]; ++_i) {
            var _a = new AttackData(_names[_w] + " leve " + string(_i + 1), 7, 4, 15,
                _damage[_w] + _i * 2, _range[_w], 95, (_w == WEAPON.FISTS ? 22 : 10), 3);
            if (_i == _count[_w] - 1) { _a.damage *= 1.5; _a.hitstop = 4; _a.shake = 3; }
            if (_w == WEAPON.AXE) { _a.element = ELEMENT.FROST; _a.element_amount = 18; }
            array_push(_light, _a);
        }
        for (var _j = 0; _j < 3; ++_j) {
            var _h = new AttackData(_names[_w] + " pesado " + string(_j + 1), 17, 5, 25,
                _damage[_w] * 2 + _j * 4, _range[_w] + 20, 110, 25, 7);
            _h.movement_scale = 0.12; _h.hitstop = 5; _h.shake = 4; _h.stagger = 18;
            if (_w == WEAPON.AXE) { _h.element = ELEMENT.FROST; _h.element_amount = 30; }
            array_push(_heavy, _h);
        }
        array_push(_db, {light: _light, heavy: _heavy});
    }
    var _bl = _db[WEAPON.BLADES];
    for (var _i = 0; _i < array_length(_bl.light); ++_i) {
        var _a = _bl.light[_i];
        _a.startup = 6; _a.active = 6; _a.recovery = 14;
        _a.range = 90 + _i * 7; _a.arc = (_i == 3 ? 360 : 145);
        _a.blade_spin = _i == 3; _a.blade_sign = (_i mod 2 == 0 ? 1 : -1);
        _a.element = ELEMENT.BURN; _a.element_amount = 16;
        _a.combo_start = 20; _a.buffer_start = 7; _a.buffer_end = 26;
        _a.dodge_cancel_start = 16; _a.weapon_cancel_start = 18;
        _a.movement_scale = 0.5;
    }
    for (var _j = 0; _j < array_length(_bl.heavy); ++_j) {
        var _a = _bl.heavy[_j];
        _a.startup = 15; _a.active = 5; _a.recovery = 24;
        _a.range = (_j == 2 ? 220 : 185 + _j * 5); _a.arc = 130;
        _a.is_blade_heavy = true; _a.blade_sign = (_j mod 2 == 0 ? 1 : -1);
        _a.impact_frame = _a.startup + 2;
        _a.combo_start = 36; _a.buffer_start = 15; _a.buffer_end = 44;
        _a.dodge_cancel_start = 27; _a.weapon_cancel_start = 31;
        _a.element = ELEMENT.BURN; _a.element_amount = (_j == 2 ? 40 : 28);
        _a.stagger = (_j == 2 ? 25 : 16); _a.shake = (_j == 2 ? 5 : 3);
    }
    for (var _i = 0; _i < array_length(_db[WEAPON.SPEAR].light); ++_i) {
        var _a = _db[WEAPON.SPEAR].light[_i];
        _a.startup = 5; _a.active = 4; _a.recovery = 12; _a.range = 120; _a.arc = 28;
        _a.stagger = 6; _a.stun = 7; _a.hitstop = 2; _a.movement_scale = 0.55;
        _a.combo_start = 16; _a.buffer_start = 5; _a.buffer_end = 21;
        _a.dodge_cancel_start = 13; _a.weapon_cancel_start = 15;
    }
    for (var _i = 0; _i < array_length(_db[WEAPON.SPEAR].heavy); ++_i) {
        var _a = _db[WEAPON.SPEAR].heavy[_i]; _a.arc = 40; _a.range = 145; _a.stagger = 12;
    }
    var _fist_names = ["Jab", "Direto", "Gancho", "Soco forte", "Finalizador"];
    for (var _i = 0; _i < array_length(_db[WEAPON.FISTS].light); ++_i) {
        var _a = _db[WEAPON.FISTS].light[_i]; _a.name = _fist_names[_i];
        _a.startup = 4; _a.active = 4; _a.recovery = 10; _a.range = 55; _a.arc = 90;
        _a.damage = 7 + _i; _a.stun = 22 + _i * 3; _a.stagger = 9; _a.knockback = 1;
        _a.combo_start = 14; _a.buffer_start = 4; _a.buffer_end = 18;
        _a.dodge_cancel_start = 11; _a.weapon_cancel_start = 13; _a.block_cancel_start = 13;
        _a.movement_scale = 0.6;
        if (_i == 4) { _a.knockback = 4; _a.hitstop = 4; _a.stun = 40; }
    }
    return _db;
}
