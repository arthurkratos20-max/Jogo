function InputState() constructor {
    move_x = 0; move_y = 0; aim_x = 0; aim_y = 0;
    execute = false; rage = false; rage_chord_last = false; recall = false; light = false; heavy = false; dodge = false; lock = false;
    block_pressed = false; last_block = false; menu = false; menu_left = false; menu_right = false; menu_confirm = false; aim_pressed = false; last_aim = false; aim = false; block = false; sprint = false;
    weapon = -1; pad = -1; use_pad = false;
    mouse_last_x = mouse_x; mouse_last_y = mouse_y;
}
function read_input(_i) {
    _i.move_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    _i.move_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
    _i.recall = keyboard_check_pressed(ord("R"));
    _i.light = mouse_check_button_pressed(mb_left);
    _i.heavy = mouse_check_button_pressed(mb_right);
    _i.dodge = keyboard_check_pressed(vk_space);
    _i.execute = mouse_check_button_pressed(mb_middle);
    _i.rage = _i.execute && keyboard_check(vk_shift);
    _i.lock = _i.execute && !_i.rage;
    if (_i.rage) _i.execute = false;
    _i.aim = keyboard_check(vk_control);
    _i.block = keyboard_check(ord("Q"));
    _i.menu = keyboard_check_pressed(vk_tab);
    _i.menu_left = keyboard_check_pressed(vk_left);
    _i.menu_right = keyboard_check_pressed(vk_right);
    _i.menu_confirm = keyboard_check_pressed(vk_enter);
    _i.sprint = keyboard_check(vk_shift);
    _i.weapon = -1; _i.aim_x = 0; _i.aim_y = 0;
    for (var _k = 0; _k < 4; ++_k)
        if (keyboard_check_pressed(ord("1") + _k)) _i.weapon = _k;
    if (_i.move_x != 0 || _i.move_y != 0 || _i.light || _i.heavy || _i.dodge
        || _i.rage || _i.execute || _i.recall || _i.aim || mouse_x != _i.mouse_last_x || mouse_y != _i.mouse_last_y) _i.use_pad = false;
    _i.mouse_last_x = mouse_x; _i.mouse_last_y = mouse_y;
    _i.pad = -1;
    for (var _p = 0; _p < 12; ++_p) {
        if (gamepad_is_connected(_p)) { _i.pad = _p; break; }
    }
    if (_i.pad >= 0) {
        var _p = _i.pad;
        var _mx = gamepad_axis_value(_p, gp_axislh);
        var _my = gamepad_axis_value(_p, gp_axislv);
        var _ax = gamepad_axis_value(_p, gp_axisrh);
        var _ay = gamepad_axis_value(_p, gp_axisrv);
        var _ml = point_distance(0, 0, _mx, _my);
        var _al = point_distance(0, 0, _ax, _ay);
        var _l = gamepad_button_check_pressed(_p, gp_shoulderr);
        var _h = gamepad_button_check_pressed(_p, gp_shoulderrb);
        var _d = gamepad_button_check_pressed(_p, gp_face1);
        var _lock = gamepad_button_check_pressed(_p, gp_stickr);
        var _recall = gamepad_button_check_pressed(_p, gp_face4);
        var _rage_chord = gamepad_button_check(_p, gp_stickl) && gamepad_button_check(_p, gp_stickr);
        var _rage = _rage_chord && !_i.rage_chord_last;
        _i.rage_chord_last = _rage_chord;
        var _menu = gamepad_button_check_pressed(_p, gp_select);
        var _w = -1;
        if (gamepad_button_check_pressed(_p, gp_padl)) _w = WEAPON.BLADES;
        if (gamepad_button_check_pressed(_p, gp_padr)) _w = WEAPON.AXE;
        if (gamepad_button_check_pressed(_p, gp_padd)) _w = WEAPON.SPEAR;
        if (gamepad_button_check_pressed(_p, gp_padu)) _w = WEAPON.FISTS;
        if (_ml > 0.2 || _al > 0.2 || _l || _h || _d || _lock || _rage || _menu || _recall || gamepad_button_check(_p, gp_shoulderlb) || _w >= 0
            || gamepad_button_check(_p, gp_shoulderl)) _i.use_pad = true;
        if (_i.use_pad) {
            _i.move_x = (_ml > 0.2 ? _mx : 0); _i.move_y = (_ml > 0.2 ? _my : 0);
            _i.aim_x = (_al > 0.2 ? _ax : 0); _i.aim_y = (_al > 0.2 ? _ay : 0);
            _i.execute = _lock && !_rage_chord; _i.rage = _rage; _i.lock = _lock && !_rage_chord;
            _i.recall = _recall; _i.light = _l; _i.heavy = _h; _i.dodge = _d;
            _i.aim = gamepad_button_check(_p, gp_shoulderlb);
            _i.block = gamepad_button_check(_p, gp_shoulderl);
            _i.menu = _menu; _i.menu_left = gamepad_button_check_pressed(_p, gp_padl);
            _i.menu_right = gamepad_button_check_pressed(_p, gp_padr);
            _i.menu_confirm = gamepad_button_check_pressed(_p, gp_face1);
            _i.sprint = gamepad_button_check(_p, gp_stickl); _i.weapon = _w;
        }
    }
    _i.block_pressed = _i.block && !_i.last_block;
    _i.last_block = _i.block;
    _i.aim_pressed = _i.aim && !_i.last_aim;
    _i.last_aim = _i.aim;
    var _len = point_distance(0, 0, _i.move_x, _i.move_y);
    if (_len > 1) { _i.move_x /= _len; _i.move_y /= _len; }
}
function InputBuffer() constructor { action = ""; expires = -1; }
function buffer_push(_b, _action) { _b.action = _action; _b.expires = global.combat_clock + 10; }
function buffer_clear(_b) { _b.action = ""; _b.expires = -1; }
function buffer_valid(_b) { return _b.action != "" && global.combat_clock <= _b.expires; }
