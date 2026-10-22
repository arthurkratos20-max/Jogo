if (!instance_exists(global.player) || global.equipment_open) exit;
var _p = global.player;
var _tx = clamp(_p.x + lengthdir_x(45, _p.aim_dir) - 480, 0, room_width - 960);
var _ty = clamp(_p.y + lengthdir_y(30, _p.aim_dir) - 270, 0, room_height - 540);
cam_x = lerp(cam_x, _tx, 0.12); cam_y = lerp(cam_y, _ty, 0.12);
var _sx = 0; var _sy = 0;
if (global.shake_remaining > 0) {
    _sx = random_range(-global.shake_strength, global.shake_strength);
    _sy = random_range(-global.shake_strength, global.shake_strength);
    global.shake_remaining -= 1;
    if (global.shake_remaining <= 0) global.shake_strength = 0;
}
camera_set_view_pos(cam, cam_x + _sx, cam_y + _sy);
