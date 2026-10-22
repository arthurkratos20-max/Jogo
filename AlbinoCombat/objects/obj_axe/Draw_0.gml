if (!instance_exists(owner)) exit;
if ((state == AXE_STATE.HAND || state == AXE_STATE.MELEE) && owner.weapons.current_weapon != WEAPON.AXE) exit;
for (var _i = 0; _i < array_length(trail); ++_i) {
    var _t = trail[_i]; draw_set_color(c_aqua); draw_set_alpha(_t.life / 20);
    draw_circle(_t.x, _t.y, 4, false);
}
draw_set_alpha(1); draw_axe_shape(x, y - 12, spin_angle, 1);
if (global.debug_combat) {
    draw_set_color(c_aqua); draw_circle(x, y, 6, true);
    draw_text(x + 10, y - 30, "axe " + string(state));
}
draw_set_color(c_white);
