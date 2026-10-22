draw_set_color(c_white);
draw_text(16, 12, "ALBINO COMBAT | FASE 6 | F1 debug | F5 reiniciar");
draw_text(16, 34, "WASD / LS mover | mouse / RS mirar | LMB / RB leve | RMB / RT pesado");
draw_text(16, 56, "Space / A esquiva (2 toques: roll) | Ctrl / LT mira | MMB / RS lock");
draw_text(16, 78, "1-4 / D-pad armas de TESTE | Shift / LS correr | R / Y recall ou detonar | Q / LB escudo | Tab / Back menu");
if (instance_exists(global.player)) {
    var _p = global.player;
    var _names = ["Machado", "Laminas", "Lanca", "Socos"];
    draw_text(16, 112, "Arma: " + _names[_p.weapons.current_weapon] + " | estado: " + string(_p.state) + " | fora da mao: " + string(_p.weapons.outside_hand) + " | lancas: " + string(array_length(_p.spears)) + "/5");
    if (global.debug_combat) {
        draw_text(16, 134, "Combo: " + string(_p.combo_step + 1) + " | timer: " + string(_p.attack_timer)
            + " | fase: " + string(_p.attack_phase) + " | hitstop: " + string(global.hitstop_remaining));
        draw_text(16, 156, "Buffer: " + _p.combo_buffer.action + " | throw fila: " + _p.queued_throw + " | i-frames: " + string(_p.invulnerable)
            + " | direcao 8: " + string(_p.facing8));
        draw_text(16, 178, "FREE=0 ATTACK=1 AIM=2 DODGE=3 | STARTUP=0 ACTIVE=1 RECOVERY=2");
    }
}

if (instance_exists(global.player)) {
    var _p = global.player; var _s = _p.shield; var _d = _s.profiles[_s.equipped];
    draw_text(16, 200, "HP " + string(_p.hp) + "/100 | " + _d.name + " | guarda " + string(round(_s.guard)) + "/" + string(_d.max_guard));
    draw_text(16, 222, "Defesa: " + _p.last_defense_result);
    if (global.debug_combat) draw_text(16, 244, "F6 normal | F7 quebra | F8 imbloqueavel | F9 tras | F10 cura (teste em 60 frames)");
}
draw_equipment_menu();

if (instance_exists(global.player)) {
    var _p = global.player; draw_text(16, 270, "Colera " + string(round(_p.rage.meter)) + "/100 | Shift+MMB / LS+RS: ativar | MMB/RS: executar alvo stunned");
}

if (!global.equipment_open) { draw_set_color(c_white); draw_text(24, 224, "Fase 7: F11 ativa/pausa os inimigos | F5 reinicia a arena"); }
