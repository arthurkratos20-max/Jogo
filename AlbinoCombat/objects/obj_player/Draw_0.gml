draw_actor(x, y, state == PLAYER_STATE.ATTACK ? locked_aim_dir : aim_dir, c_white, true);
if (global.debug_combat) {
    draw_set_color(invulnerable ? c_aqua : c_white); draw_circle(x, y, body_radius, true);
    draw_set_color(c_aqua); draw_line(x, y, x + lengthdir_x(65, aim_dir), y + lengthdir_y(65, aim_dir));
    draw_attack_arc(id);
}
if (instance_exists(lock_target)) {
    draw_set_color(c_yellow); draw_circle(lock_target.x, lock_target.y - 20, 26, true);
}
draw_set_color(c_white);

draw_player_shield(id);

draw_fists(id); draw_execution_indicators(id);
