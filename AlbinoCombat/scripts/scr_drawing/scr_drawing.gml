function draw_actor(_x, _y, _dir, _color, _player) {
    draw_set_alpha(0.25); draw_set_color(c_black);
    draw_ellipse(_x - 15, _y - 6, _x + 15, _y + 6, false); draw_set_alpha(1);
    draw_set_color(_color);
    draw_triangle(_x, _y - 29, _x - 14, _y - 3, _x + 14, _y - 3, false);
    draw_circle(_x, _y - 29, 8, false);
    draw_set_color(_player ? make_color_rgb(155, 35, 45) : c_dkgray);
    draw_rectangle(_x - 11, _y - 13, _x + 11, _y - 10, false);
    draw_set_color(c_gray);
    var _front = lengthdir_y(1, _dir) >= 0;
    if (_front) draw_line(_x - 4, _y - 29, _x + 4, _y - 29);
    draw_line_width(_x, _y - 17, _x + lengthdir_x(21, _dir), _y - 17 + lengthdir_y(12, _dir), 3);
    draw_set_color(c_white);
}
function draw_attack_arc(_p) {
    if (_p.state != PLAYER_STATE.ATTACK) return;
    var _a = _p.attack;
    draw_set_color(_p.attack_phase == ATTACK_PHASE.ACTIVE ? c_lime : c_yellow);
    var _start = _p.locked_aim_dir - _a.arc / 2;
    for (var _j = 0; _j < 16; ++_j) {
        var _d1 = _start + _a.arc * _j / 16;
        var _d2 = _start + _a.arc * (_j + 1) / 16;
        draw_line(_p.x + lengthdir_x(_a.range, _d1), _p.y + lengthdir_y(_a.range, _d1),
            _p.x + lengthdir_x(_a.range, _d2), _p.y + lengthdir_y(_a.range, _d2));
    }
    draw_line(_p.x, _p.y, _p.x + lengthdir_x(_a.range, _start), _p.y + lengthdir_y(_a.range, _start));
    draw_line(_p.x, _p.y, _p.x + lengthdir_x(_a.range, _start + _a.arc), _p.y + lengthdir_y(_a.range, _start + _a.arc));
    draw_set_color(c_white);
}
