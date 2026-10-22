for (var _i = 0; _i < array_length(global.fx); ++_i) {
    var _f = global.fx[_i]; draw_set_alpha(_f.life / 12); draw_set_color(c_orange);
    var _radius = ((_f.kind == "blade_explosion" || _f.kind == "spear_explosion") ? (12 - _f.life) * 5 : (_f.kind == "blade_impact" ? (12 - _f.life) * 3 : 16 - _f.life));
    draw_circle(_f.x, _f.y, _radius, true);
}
draw_set_alpha(1); draw_set_color(c_white);

draw_shield_tests();
