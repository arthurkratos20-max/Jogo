draw_actor(x, y, 270, state == ENEMY_STATE.DEAD ? c_dkgray : make_color_rgb(194, 151, 99), false);
draw_set_color(c_dkgray); draw_rectangle(x - 30, y - 55, x + 30, y - 50, false);
draw_set_color(c_red); draw_rectangle(x - 30, y - 55, x - 30 + 60 * hp / max_hp, y - 50, false);
draw_set_color(c_yellow); draw_rectangle(x - 30, y - 48, x - 30 + 60 * stun / max_stun, y - 45, false);
if (global.debug_combat) {
    draw_set_color(c_white); draw_circle(x, y, body_radius, true);
    draw_text(x - 42, y + 12, "HP " + string(hp) + " hits " + string(hit_count));
    draw_text(x - 42, y + 28, "stun " + string(stun) + " dano " + string(last_damage));
draw_set_color(c_orange);
    draw_text(x - 42, y + 60, "burn " + string(floor(burn_amount)) + " DOT " + string(burn_timer));
    draw_set_color(c_aqua);
    draw_text(x - 42, y + 44, "gelo " + string(floor(frost_amount)) + " freeze " + string(frozen_timer));
    draw_set_color(c_white);
}

if (is_elite) draw_text(x - 18, y - 94, "ELITE");
if (state == ENEMY_STATE.STUNNED) { draw_set_color(c_yellow); draw_text(x - 30, y - 74, "STUNNED"); }
draw_set_color(c_white);

enemy_ai_draw(id);
