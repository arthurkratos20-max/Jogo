// ================= TESTE CONTROLADO: BONECOS NAO TEM AI =================
function shield_test_queue(_p, _type, _rear) {
    var _dir = _p.aim_dir + (_rear ? 180 : 0);
    var _source = instance_nearest(_p.x, _p.y, obj_enemy_parent);
    if (!instance_exists(_source)) return;
    array_push(global.test_attacks, {source: _source, x: _p.x + lengthdir_x(100, _dir), y: _p.y + lengthdir_y(100, _dir),
        due: global.combat_clock + 60, kind: _type, rear: _rear});
}
function shield_test_tick() {
    if (!instance_exists(global.player)) return;
    var _p = global.player;
    if (global.debug_combat) {
        if (keyboard_check_pressed(vk_f6)) shield_test_queue(_p, 0, false);
        if (keyboard_check_pressed(vk_f7)) shield_test_queue(_p, 1, false);
        if (keyboard_check_pressed(vk_f8)) shield_test_queue(_p, 2, false);
        if (keyboard_check_pressed(vk_f9)) shield_test_queue(_p, 0, true);
        if (keyboard_check_pressed(vk_f10)) { _p.hp = _p.max_hp; _p.last_defense_result = "Vida restaurada"; }
    }
    for (var _i = array_length(global.test_attacks) - 1; _i >= 0; --_i) {
        var _a = global.test_attacks[_i];
        if (global.combat_clock >= _a.due) {
            if (instance_exists(_a.source) && point_distance(_p.x, _p.y, _a.x, _a.y) <= 170) {
                var _d = {damage: 15, stun: 0, stagger: 18, knockback: 3, hitstop: 3, shake: 2,
                    element: ELEMENT.NONE, element_amount: 0, guard_damage: 40,
                    origin_x: _a.x, origin_y: _a.y, parryable: _a.kind != 2,
                    guard_break: _a.kind == 1, unblockable: _a.kind == 2};
                apply_damage(_a.source, _p, _d);
            } else _p.last_defense_result = "TESTE: fora do alcance";
            array_delete(global.test_attacks, _i, 1);
        }
    }
}
function draw_shield_tests() {
    for (var _i = 0; _i < array_length(global.test_attacks); ++_i) {
        var _a = global.test_attacks[_i];
        draw_set_color(_a.kind == 2 ? c_red : (_a.kind == 1 ? c_yellow : c_aqua));
        draw_circle(_a.x, _a.y - 16, 15, true);
        draw_text(_a.x - 35, _a.y - 50, "TESTE " + string(max(0, _a.due - global.combat_clock)));
    }
    draw_set_color(c_white);
}
function draw_equipment_menu() {
    if (!global.equipment_open || !instance_exists(global.player)) return;
    var _s = global.player.shield; var _index = global.equipment_selection; var _d = _s.profiles[_index];
    draw_set_alpha(0.95); draw_set_color(make_color_rgb(14, 20, 29)); draw_rectangle(170, 210, 790, 510, false);
    draw_set_alpha(1); draw_set_color(c_white);
    draw_text(200, 230, "ESCUDOS — todas as opcoes desbloqueadas");
    draw_text(200, 270, "<  " + _d.name + "  >");
    draw_text(200, 310, "Parry: " + string(_d.parry_frames) + " frames | perfect: " + string(_d.perfect_frames));
    draw_text(200, 340, "Guarda: " + string(_d.max_guard) + " | arco frontal: " + string(_d.arc));
    draw_text(200, 380, "Equipado: " + _s.profiles[_s.equipped].name);
    draw_text(200, 420, "Setas / D-pad: escolher | Enter / A: equipar");
    draw_text(200, 455, "Tab / Back: fechar | combate pausado");
}
