if (!instance_exists(owner)) { instance_destroy(); exit; }
if (global.combat_frozen || global.equipment_open) exit;
if (owner.weapons.current_weapon != WEAPON.BLADES || owner.state != PLAYER_STATE.ATTACK) blades_pose_update(owner);
state = BLADE_STATE.IDLE;
if (owner.weapons.current_weapon == WEAPON.BLADES && owner.state == PLAYER_STATE.ATTACK)
    state = (owner.attack_kind == "heavy" ? BLADE_STATE.HEAVY_COMBO : BLADE_STATE.LIGHT_COMBO);
for (var _i = array_length(trail) - 1; _i >= 0; --_i) {
    trail[_i].life -= 1;
    if (trail[_i].life <= 0) array_delete(trail, _i, 1);
}
if (state != BLADE_STATE.IDLE && global.combat_clock mod 2 == 0) {
    var _b = owner.blade_pose;
    array_push(trail, {x: _b.blade_x, y: _b.blade_y, angle: _b.current_angle, life: 8});
    array_push(trail, {x: _b.offblade_x, y: _b.offblade_y, angle: _b.off_angle, life: 8});
}
x = owner.x; y = owner.y; depth = -y - 2;

var _pose = owner.blade_pose;
var _slack = 1; var _taut = false;
if (_pose.attacking) {
    _slack = (owner.attack_phase == ATTACK_PHASE.ACTIVE ? 0.12 : 0.85);
    _taut = owner.attack.is_blade_heavy && _pose.attack_frame == owner.attack.impact_frame;
}
if (owner.weapons.current_weapon != WEAPON.BLADES) { chain_left.initialized = false; chain_right.initialized = false; }
soft_chain_tick(chain_left, _pose.hand_x, _pose.hand_y, _pose.blade_x, _pose.blade_y, _slack, 1, _taut);
soft_chain_tick(chain_right, _pose.offhand_x, _pose.offhand_y, _pose.offblade_x, _pose.offblade_y, _slack, -1, _taut);
