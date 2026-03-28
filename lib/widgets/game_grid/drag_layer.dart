// lib/widgets/game_grid/drag_layer.dart
//
// Custom drag system with all tactile feel features:
//  1. Selection scale (1.0 → 1.1 on lift)
//  2. Lift offset (item floats above finger)
//  3. Shadow drop (blur grows with speed)
//  4. Drag trail (ghost copies with 50ms delay)
//  5. Tilt on move (velocity-based rotation, max 5°)
//  6. Haptic pick (selectionClick on lift)
//  7. Proximity pulse (both items scale when over valid target)
//  8. Magnetic snap (slams into cell center on valid drop)
//  9. Invalid wobble (5Hz horizontal shake then return)
// 10. Return arc (parabolic bezier flight back to source)

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  Internal types
// ─────────────────────────────────────────────

enum DragPhase { idle, dragging, snapping, wobbling, returning }

class _TrailPoint {
  final Offset pos;
  final DateTime time;
  _TrailPoint(this.pos, this.time);
}

// ─────────────────────────────────────────────
//  Controller (imperative API for parent)
// ─────────────────────────────────────────────

class DragOverlayController {
  _DragOverlayState? _state;

  void _attach(_DragOverlayState s) => _state = s;
  void _detach() => _state = null;

  bool get isActive => _state != null && _state!._phase != DragPhase.idle;
  bool get isDragging => _state?._phase == DragPhase.dragging;

  void startDrag({
    required String emoji,
    required Offset globalPos,
    required double tileSize,
  }) =>
      _state?._startDrag(emoji: emoji, globalPos: globalPos, tileSize: tileSize);

  void updateDrag(Offset globalPos) => _state?._updateDrag(globalPos);

  void setOverValid(bool valid) => _state?._setOverValid(valid);

  /// Item snaps to [targetGlobal]; calls [onComplete] when done.
  void snapTo(Offset targetGlobal, VoidCallback onComplete) =>
      _state?._snapTo(targetGlobal, onComplete);

  /// Item wobbles (invalid) then arcs back to [returnGlobal].
  void wobbleAndReturn(Offset returnGlobal, VoidCallback onComplete) =>
      _state?._wobbleAndReturn(returnGlobal, onComplete);

  void clear() => _state?._clear();
}

// ─────────────────────────────────────────────
//  The overlay widget
// ─────────────────────────────────────────────

class DragOverlay extends StatefulWidget {
  final DragOverlayController controller;
  const DragOverlay({super.key, required this.controller});

  @override
  State<DragOverlay> createState() => _DragOverlayState();
}

class _DragOverlayState extends State<DragOverlay> with TickerProviderStateMixin {
  DragPhase _phase = DragPhase.idle;

  String _emoji = '';
  double _tileSize = 50.0;
  Offset _pos = Offset.zero;

  // Velocity tracking
  Offset _velocity = Offset.zero;
  Offset _prevPos = Offset.zero;
  DateTime _prevTime = DateTime.now();

  // Trail
  final List<_TrailPoint> _trail = [];

  // Proximity state
  bool _isOverValid = false;

  // Lift offset — item floats above touch point
  static const double _liftY = -38.0;

  // ── Animation controllers ──────────────────
  late AnimationController _liftCtrl;   // 1.0 → 1.1 scale on pickup
  late AnimationController _pulseCtrl;  // proximity pulse (repeating)
  late AnimationController _snapCtrl;   // magnetic snap to target
  late AnimationController _wobbleCtrl; // invalid shake
  late AnimationController _returnCtrl; // parabolic return

  Offset _snapStart = Offset.zero;
  Offset _snapEnd   = Offset.zero;
  VoidCallback? _onSnapDone;

  Offset _returnStart = Offset.zero;
  Offset _returnEnd   = Offset.zero;
  VoidCallback? _onReturnDone;

  late Ticker _frameTicker;

  // ── Lifecycle ─────────────────────────────

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);

    _liftCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    )..addListener(_mark);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..addListener(_mark);

    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )
      ..addListener(_onSnapTick)
      ..addStatusListener(_onSnapStatus);

    _wobbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )
      ..addListener(_mark)
      ..addStatusListener(_onWobbleStatus);

    _returnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )
      ..addListener(_onReturnTick)
      ..addStatusListener(_onReturnStatus);

    // Trail ticker — prune stale points each frame
    _frameTicker = createTicker((_) {
      if (_phase == DragPhase.dragging) {
        _pruneTrail();
        setState(() {});
      }
    });
    _frameTicker.start();
  }

  @override
  void dispose() {
    widget.controller._detach();
    _liftCtrl.dispose();
    _pulseCtrl.dispose();
    _snapCtrl.dispose();
    _wobbleCtrl.dispose();
    _returnCtrl.dispose();
    _frameTicker.dispose();
    super.dispose();
  }

  void _mark() => setState(() {});

  // ── Snap tick / status ────────────────────

  void _onSnapTick() {
    final t = CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutBack).value;
    setState(() => _pos = Offset.lerp(_snapStart, _snapEnd, t)!);
  }

  void _onSnapStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      _onSnapDone?.call();
      _phase = DragPhase.idle;
      setState(() {});
    }
  }

  // ── Return tick / status ──────────────────

  void _onReturnTick() {
    final t = CurvedAnimation(parent: _returnCtrl, curve: Curves.easeInOut).value;
    // Quadratic bezier: arc upward between start and end
    final ctrl = Offset(
      (_returnStart.dx + _returnEnd.dx) / 2,
      math.min(_returnStart.dy, _returnEnd.dy) - 90,
    );
    setState(() => _pos = _bezier(_returnStart, ctrl, _returnEnd, t));
  }

  void _onReturnStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      _onReturnDone?.call();
      _phase = DragPhase.idle;
      setState(() {});
    }
  }

  // ── Wobble status ─────────────────────────

  void _onWobbleStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      _phase = DragPhase.returning;
      _returnStart = _pos;
      _returnCtrl.forward(from: 0);
    }
  }

  // ── Public API ────────────────────────────

  void _startDrag({
    required String emoji,
    required Offset globalPos,
    required double tileSize,
  }) {
    _emoji = emoji;
    _tileSize = tileSize;
    _pos = globalPos;
    _prevPos = globalPos;
    _prevTime = DateTime.now();
    _velocity = Offset.zero;
    _trail.clear();
    _isOverValid = false;
    _phase = DragPhase.dragging;

    HapticFeedback.selectionClick();

    _liftCtrl.forward(from: 0);
    _pulseCtrl.stop();
    _pulseCtrl.value = 0;
    _snapCtrl.stop();
    _wobbleCtrl.stop();
    _wobbleCtrl.value = 0;
    _returnCtrl.stop();

    setState(() {});
  }

  void _updateDrag(Offset globalPos) {
    if (_phase != DragPhase.dragging) return;

    final now = DateTime.now();
    final dt = now.difference(_prevTime).inMilliseconds / 1000.0;
    if (dt > 0.004) {
      final raw = (globalPos - _prevPos) / dt;
      _velocity = _velocity * 0.65 + raw * 0.35; // smoothed EMA
    }

    // Don't accumulate trail ghosts when locked onto a valid target
    if (!_isOverValid) {
      _trail.add(_TrailPoint(_pos, DateTime.now()));
    } else {
      _trail.clear(); // wipe trail so it doesn't look like charging particles
    }
    _pruneTrail();

    _prevPos = _pos;
    _prevTime = now;
    _pos = globalPos;
    setState(() {});
  }

  void _setOverValid(bool valid) {
    if (valid == _isOverValid) return;
    _isOverValid = valid;
    if (valid) {
      _trail.clear(); // clear ghost trail immediately on target lock
      _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0;
    }
    setState(() {});
  }

  void _snapTo(Offset targetGlobal, VoidCallback onComplete) {
    if (_phase == DragPhase.idle) return;
    _phase = DragPhase.snapping;
    _snapStart = _pos;
    _snapEnd = targetGlobal;
    _onSnapDone = onComplete;
    _pulseCtrl.stop();
    _pulseCtrl.value = 0;
    _trail.clear();
    _snapCtrl.forward(from: 0);
    setState(() {});
  }

  void _wobbleAndReturn(Offset returnGlobal, VoidCallback onComplete) {
    if (_phase == DragPhase.idle) return;
    _phase = DragPhase.wobbling;
    _returnEnd = returnGlobal;
    _onReturnDone = onComplete;
    _trail.clear();
    _pulseCtrl.stop();
    _pulseCtrl.value = 0;
    _wobbleCtrl.forward(from: 0);
    setState(() {});
  }

  void _clear() {
    _phase = DragPhase.idle;
    _trail.clear();
    _isOverValid = false;
    for (final c in [_liftCtrl, _pulseCtrl, _snapCtrl, _wobbleCtrl, _returnCtrl]) {
      c.stop();
    }
    setState(() {});
  }

  // ── Helpers ───────────────────────────────

  void _pruneTrail() {
    final cutoff = DateTime.now().subtract(const Duration(milliseconds: 220));
    _trail.removeWhere((t) => t.time.isBefore(cutoff));
    if (_trail.length > 7) _trail.removeRange(0, _trail.length - 7);
  }

  static Offset _bezier(Offset p0, Offset p1, Offset p2, double t) {
    final mt = 1 - t;
    return p0 * (mt * mt) + p1 * (2 * mt * t) + p2 * (t * t);
  }

  // ── Build ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_phase == DragPhase.idle) return const SizedBox.shrink();

    final half = _tileSize / 2;

    // Lift scale: 1.0 → 1.1 on pickup
    final liftScale = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _liftCtrl, curve: Curves.easeOut))
        .value;

    // Proximity pulse scale
    final pulseScale = _isOverValid
        ? Tween<double>(begin: 1.0, end: 1.14)
            .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut))
            .value
        : 1.0;

    // Velocity-based tilt: max ±5°
    final speed = _velocity.distance.clamp(0.0, 1400.0);
    final tiltAngle =
        (_phase == DragPhase.dragging) ? (_velocity.dx / 1400.0) * (5 * math.pi / 180) : 0.0;

    // Shadow blur grows with speed
    final shadowBlur = 10.0 + (speed / 1400.0) * 22.0;
    final shadowOffset = Offset(0, shadowBlur * 0.35);

    // Wobble X offset: damped sin at ~5 Hz
    double wobbleX = 0;
    if (_phase == DragPhase.wobbling) {
      final v = _wobbleCtrl.value;
      wobbleX = math.sin(v * 5 * 2 * math.pi) * 9.0 * (1 - v);
    }

    // Convert global screen coords → local coords within this overlay widget.
    // The overlay is Positioned.fill inside the grid Stack, so its origin
    // is at the top-left of the grid, not the screen.
    final box = context.findRenderObject() as RenderBox?;
    Offset toLocal(Offset global) =>
        box != null ? box.globalToLocal(global) : global;

    final localPos = toLocal(_pos);
    final displayPos = Offset(
      localPos.dx + wobbleX,
      localPos.dy + _liftY,
    );

    return Stack(
      children: [
        // ── Trail ghosts ──────────────────────
        if (_phase == DragPhase.dragging)
          ..._trail.asMap().entries.map((e) {
            final idx = e.key;
            final tp = e.value;
            final age = DateTime.now().difference(tp.time).inMilliseconds.clamp(0, 220);
            final ageFrac = 1.0 - age / 220.0;
            final idxFrac = (idx + 1) / _trail.length;
            final opacity = (ageFrac * idxFrac * 0.45).clamp(0.0, 0.45);
            final s = 0.45 + idxFrac * 0.4;
            final lp = toLocal(tp.pos);
            return Positioned(
              left: lp.dx - half * s,
              top: lp.dy - half * s + _liftY,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: s,
                  child: Text(
                    _emoji,
                    style: TextStyle(fontSize: _tileSize * 0.62),
                  ),
                ),
              ),
            );
          }),

        // ── Main dragged item ─────────────────
        Positioned(
          left: displayPos.dx - half,
          top: displayPos.dy - half,
          child: Transform.rotate(
            angle: tiltAngle,
            child: Transform.scale(
              scale: liftScale * pulseScale,
              child: Container(
                width: _tileSize,
                height: _tileSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.50),
                      blurRadius: shadowBlur,
                      offset: shadowOffset,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _emoji,
                    style: TextStyle(fontSize: _tileSize * 0.62),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
