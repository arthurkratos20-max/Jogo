function SoftChain() constructor {
    nodes = []; initialized = false;
    for (var _i = 0; _i < 26; ++_i) array_push(nodes, {x: 0, y: 0, vx: 0, vy: 0});
}
function soft_chain_tick(_c, _hx, _hy, _bx, _by, _slack, _side, _taut) {
    if (_taut) _slack = 0;
    var _count = array_length(_c.nodes);
    var _dx = _bx - _hx; var _dy = _by - _hy;
    var _dist = max(1, point_distance(_hx, _hy, _bx, _by));
    var _nx = -_dy / _dist; var _ny = _dx / _dist;
    for (var _i = 0; _i < _count; ++_i) {
        var _t = _i / (_count - 1);
        var _envelope = sin(pi * _t);
        var _sag = _slack * min(40, _dist * 0.22);
        var _wave = sin(global.combat_clock * 0.13 - _t * 5) * _sag * 0.18;
        var _tx = lerp(_hx, _bx, _t) + _nx * (_sag * _side + _wave) * _envelope;
        var _ty = lerp(_hy, _by, _t) + _ny * (_sag * _side + _wave) * _envelope + _sag * 0.4 * _envelope;
        if (_i == 0) { _tx = _hx; _ty = _hy; }
        if (_i == _count - 1) { _tx = _bx; _ty = _by; }
        var _n = _c.nodes[_i];
        if (!_c.initialized || _taut || _i == 0 || _i == _count - 1) {
            _n.x = _tx; _n.y = _ty; _n.vx = 0; _n.vy = 0;
        } else {
            // Springs amortecidas: a corrente segue com atraso, sem mover a lamina.
            _n.vx = (_n.vx + (_tx - _n.x) * 0.18) * 0.68;
            _n.vy = (_n.vy + (_ty - _n.y) * 0.18) * 0.68;
            _n.x += _n.vx; _n.y += _n.vy;
        }
    }
    _c.initialized = true;
    if (!_taut) {
        // Limitar alongamento entre pontos evita espigoes ao virar/esquivar.
        var _limit = max(2, _dist / (_count - 1) * (1 + _slack * 0.35));
        for (var _pass = 0; _pass < 6; ++_pass) {
            for (var _i = 0; _i < _count - 1; ++_i) {
                var _a = _c.nodes[_i]; var _b = _c.nodes[_i + 1];
                var _x = _b.x - _a.x; var _y = _b.y - _a.y;
                var _len = point_distance(0, 0, _x, _y);
                if (_len > _limit) {
                    var _ratio = (_len - _limit) / max(0.001, _len);
                    var _wa = (_i == 0 ? 0 : (_i + 1 == _count - 1 ? 1 : 0.5));
                    var _wb = (_i + 1 == _count - 1 ? 0 : (_i == 0 ? 1 : 0.5));
                    _a.x += _x * _ratio * _wa; _a.y += _y * _ratio * _wa;
                    _b.x -= _x * _ratio * _wb; _b.y -= _y * _ratio * _wb;
                }
            }
        }
    }
}
function draw_chain_link(_x, _y, _dir, _flat) {
    var _width = (_flat ? 0.8 : 2.2);
    draw_set_color(_flat ? c_silver : c_gray);
    var _px = _x + lengthdir_x(4, _dir); var _py = _y + lengthdir_y(4, _dir);
    for (var _i = 1; _i <= 8; ++_i) {
        var _q = _i * pi / 4;
        var _lx = _x + lengthdir_x(cos(_q) * 4, _dir) + lengthdir_x(sin(_q) * _width, _dir + 90);
        var _ly = _y + lengthdir_y(cos(_q) * 4, _dir) + lengthdir_y(sin(_q) * _width, _dir + 90);
        draw_line(_px, _py, _lx, _ly); _px = _lx; _py = _ly;
    }
}
function draw_soft_chain(_c) {
    if (!_c.initialized) return;
    var _next = 4; var _travel = 0; var _link = 0;
    for (var _i = 0; _i < array_length(_c.nodes) - 1; ++_i) {
        var _a = _c.nodes[_i]; var _b = _c.nodes[_i + 1];
        var _len = point_distance(_a.x, _a.y, _b.x, _b.y);
        draw_set_color(c_dkgray); draw_line(_a.x, _a.y, _b.x, _b.y);
        while (_next <= _travel + _len && _len > 0.001) {
            var _q = (_next - _travel) / _len;
            draw_chain_link(lerp(_a.x, _b.x, _q), lerp(_a.y, _b.y, _q),
                point_direction(_a.x, _a.y, _b.x, _b.y), _link mod 2 == 0);
            _next += 8; _link += 1;
        }
        _travel += _len;
    }
    draw_set_color(c_white);
}
