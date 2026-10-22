if (!instance_exists(owner) || owner.weapons.current_weapon != WEAPON.BLADES) exit;
var _b = owner.blade_pose;
for (var _i = 0; _i < array_length(trail); ++_i) {
    var _t = trail[_i]; draw_blade_shape(_t.x, _t.y, _t.angle, _t.life / 20);
}
draw_soft_chain(chain_left);
draw_soft_chain(chain_right);
draw_blade_shape(_b.blade_x, _b.blade_y, _b.current_angle, 1);
draw_blade_shape(_b.offblade_x, _b.offblade_y, _b.off_angle, 1);
if (global.debug_combat && _b.attacking) {
    draw_set_color(c_orange); draw_circle(_b.blade_x, _b.blade_y, 5, true);
    draw_text(_b.blade_x + 10, _b.blade_y + 10, "corrente " + string(round(_b.chain_length)));
}
draw_set_color(c_white);
