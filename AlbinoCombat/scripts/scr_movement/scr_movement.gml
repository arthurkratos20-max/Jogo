function arena_move(_actor, _dx, _dy) {
    // Colisao circular contra retangulos. Subpassos impedem atravessar paredes.
    var _steps = max(1, ceil(max(abs(_dx), abs(_dy)) / 4));
    for (var _s = 0; _s < _steps; ++_s) {
        var _nx = _actor.x + _dx / _steps;
        var _ny = _actor.y + _dy / _steps;
        var _r = _actor.body_radius;
        _nx = clamp(_nx, 40 + _r, room_width - 40 - _r);
        _ny = clamp(_ny, 40 + _r, room_height - 40 - _r);
        for (var _i = 0; _i < array_length(global.walls); ++_i) {
            var _w = global.walls[_i];
            if (_actor.y + _r > _w.y1 && _actor.y - _r < _w.y2) {
                if (_dx > 0 && _actor.x + _r <= _w.x1 && _nx + _r > _w.x1) _nx = _w.x1 - _r;
                if (_dx < 0 && _actor.x - _r >= _w.x2 && _nx - _r < _w.x2) _nx = _w.x2 + _r;
            }
        }
        _actor.x = _nx;
        for (var _i = 0; _i < array_length(global.walls); ++_i) {
            var _w = global.walls[_i];
            if (_actor.x + _r > _w.x1 && _actor.x - _r < _w.x2) {
                if (_dy > 0 && _actor.y + _r <= _w.y1 && _ny + _r > _w.y1) _ny = _w.y1 - _r;
                if (_dy < 0 && _actor.y - _r >= _w.y2 && _ny - _r < _w.y2) _ny = _w.y2 + _r;
            }
        }
        _actor.y = _ny;
    }
}
function segment_wall_blocked(_x1, _y1, _x2, _y2) {
    var _steps = max(1, ceil(point_distance(_x1, _y1, _x2, _y2) / 4));
    for (var _s = 0; _s <= _steps; ++_s) {
        var _x = lerp(_x1, _x2, _s / _steps); var _y = lerp(_y1, _y2, _s / _steps);
        for (var _i = 0; _i < array_length(global.walls); ++_i) {
            var _w = global.walls[_i];
            if (_x >= _w.x1 && _x <= _w.x2 && _y >= _w.y1 && _y <= _w.y2) return true;
        }
    }
    return false;
}
