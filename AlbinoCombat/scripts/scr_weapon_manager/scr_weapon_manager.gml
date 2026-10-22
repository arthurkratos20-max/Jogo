function WeaponManager() constructor {
    current_weapon = WEAPON.AXE; previous_weapon = WEAPON.AXE;
    axe_state = AXE_STATE.HAND; outside_hand = false;
    switch_cooldown = 0;
}
function weapon_switch(_p, _weapon) {
    if (_p.rage.active || _p.state == PLAYER_STATE.EXECUTION) return false;
    if (_weapon < 0 || _weapon > WEAPON.FISTS || _p.weapons.switch_cooldown > 0) return false;
    if (_p.state != PLAYER_STATE.FREE && _p.state != PLAYER_STATE.AIM && _p.state != PLAYER_STATE.BLOCK && _p.state != PLAYER_STATE.PARRY
        && !(_p.state == PLAYER_STATE.ATTACK && _p.attack_timer >= _p.attack.weapon_cancel_start)) return false;
    _p.weapons.previous_weapon = _p.weapons.current_weapon;
    _p.weapons.current_weapon = _weapon; _p.weapons.switch_cooldown = 8;
    combat_cancel(_p);
    shield_lower(_p);
    if (_p.weapons.previous_weapon == WEAPON.BLADES && _weapon == WEAPON.AXE
        && _p.weapons.outside_hand && instance_exists(_p.my_axe)) axe_recall(_p.my_axe);
    return true;
}
