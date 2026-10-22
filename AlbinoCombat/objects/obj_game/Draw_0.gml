draw_clear(make_color_rgb(24, 29, 36));
draw_set_color(make_color_rgb(39, 46, 54));
for (var _x = 40; _x < room_width; _x += 64) draw_line(_x, 40, _x, room_height - 40);
for (var _y = 40; _y < room_height; _y += 64) draw_line(40, _y, room_width - 40, _y);
draw_set_color(make_color_rgb(81, 91, 105));
draw_rectangle(0, 0, room_width, 40, false);
draw_rectangle(0, room_height - 40, room_width, room_height, false);
draw_rectangle(0, 0, 40, room_height, false);
draw_rectangle(room_width - 40, 0, room_width, room_height, false);
for (var _i = 0; _i < array_length(global.walls); ++_i) {
    var _w = global.walls[_i]; draw_rectangle(_w.x1, _w.y1, _w.x2, _w.y2, false);
}
draw_set_color(c_white);
