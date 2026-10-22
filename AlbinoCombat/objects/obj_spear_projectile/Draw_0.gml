draw_spear_shape(x, y - 10, fly_dir, 0.65);
if (global.debug_combat) {
    draw_set_color(c_yellow); draw_circle(x, y, 5, true);
    if (detonate_at >= 0) draw_circle(x, y, explosion_radius, true);
}
draw_set_color(c_white);
