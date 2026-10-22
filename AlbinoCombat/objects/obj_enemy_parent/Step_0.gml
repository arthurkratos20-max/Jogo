if (global.combat_frozen || global.equipment_open) exit;
if (instance_exists(execution_owner)) exit;
if (state == ENEMY_STATE.EXECUTION) { execution_owner = noone; stun = 0; state = ENEMY_STATE.IDLE; }
enemy_stun_tick(id);
frost_tick(id);
burn_tick(id);
if (knockback_force > 0) {
    arena_move(id, lengthdir_x(knockback_force, knockback_dir), lengthdir_y(knockback_force, knockback_dir));
    knockback_force = max(0, knockback_force - knockback_friction);
}
if (state == ENEMY_STATE.STAGGER) {
    stagger_timer -= 1; if (stagger_timer <= 0) state = ENEMY_STATE.IDLE;
}
depth = -y;

enemy_ai_tick(id);
