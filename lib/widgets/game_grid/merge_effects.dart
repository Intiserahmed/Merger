// lib/widgets/game_grid/merge_effects.dart
//
// All 10 merge dopamine effects:
//  1. Implosion        – source items shrink to 0 before result appears
//  2. White Flash      – brief white burst on the merge cell
//  3. Impact Bloom     – soft radial glow expands and fades
//  4. Particle Fountain– sparks shoot upward with gravity
//  5. Ring Shockwave   – hollow circle expands and thins out
//  6. Screen Shake     – communicated via [MergeEffectsController.onShake]
//  7. New Item Pop     – communicated via [MergeEffectsController.onPop]
//  8. Confetti Burst   – coloured squares on rare / new-discovery merges
//  9. Sound            – handled externally (MergeAudio)
// 10. Text Float       – "+XP" / "NEW!" rises and fades

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _Spark {
  Offset pos;
  Offset vel;
  Color color;
  double size;
  double life; // 1 → 0

  _Spark({required this.pos, required this.vel, required this.color, required this.size})
      : life = 1.0;
}

class _Confetto {
  Offset pos;
  Offset vel;
  Color color;
  double size;
  double angle;
  double spin;
  double life;

  _Confetto({
    required this.pos,
    required this.vel,
    required this.color,
    required this.size,
    required this.angle,
    required this.spin,
  }) : life = 1.0;
}

class _FloatLabel {
  final String text;
  final Color color;
  Offset pos;
  double opacity;

  _FloatLabel({required this.text, required this.color, required this.pos})
      : opacity = 1.0;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Controller – imperative API consumed by GameGridScreen
// ─────────────────────────────────────────────────────────────────────────────

class MergeEffectsController {
  _MergeEffectsState? _state;
  void _attach(_MergeEffectsState s) => _state = s;
  void _detach() => _state = null;

  /// Called by grid screen so the overlay can request a screen-shake.
  VoidCallback? onShake;

  /// Called when the blast phase begins → grid screen should pop the new item.
  VoidCallback? onPop;

  /// Called when implosion completes → grid state should update now.
  void trigger({
    required Offset mergeGlobal,   // centre of the target cell (global coords)
    required Offset src1Global,    // centre of source cell 1
    required Offset src2Global,    // centre of source cell 2
    required String sourceEmoji,
    required int xpGain,
    required bool isRare,          // triggers confetti + stronger effects
    required VoidCallback onImplosionDone, // execute the actual merge
  }) {
    _state?._trigger(
      mergeGlobal: mergeGlobal,
      src1Global: src1Global,
      src2Global: src2Global,
      sourceEmoji: sourceEmoji,
      xpGain: xpGain,
      isRare: isRare,
      onImplosionDone: onImplosionDone,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Overlay widget
// ─────────────────────────────────────────────────────────────────────────────

class MergeEffectsOverlay extends StatefulWidget {
  final MergeEffectsController controller;
  const MergeEffectsOverlay({super.key, required this.controller});

  @override
  State<MergeEffectsOverlay> createState() => _MergeEffectsState();
}

enum _Phase { idle, imploding, blasting }

class _MergeEffectsState extends State<MergeEffectsOverlay>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.idle;

  // ── Positions (global coords, converted to local in build) ──────────────
  Offset _mergeG = Offset.zero;
  Offset _src1G  = Offset.zero;
  Offset _src2G  = Offset.zero;
  String _srcEmoji = '';

  // ── Live particle lists ──────────────────────────────────────────────────
  final List<_Spark>      _sparks    = [];
  final List<_Confetto>   _confetti  = [];
  final List<_FloatLabel> _labels    = [];

  // ── Animation controllers ────────────────────────────────────────────────
  late AnimationController _implodeCtrl; // 150 ms: scale 1→0 on source items
  late AnimationController _bloomCtrl;   // 550 ms: bloom + ring
  late AnimationController _flashCtrl;   //  80 ms: white flash
  late Ticker              _tick;

  VoidCallback? _onImplosionDone;
  Duration? _lastTick;
  final _rng = math.Random();

  static const _sparkColors = [
    Color(0xFFFFD700), Color(0xFFFF8C00), Color(0xFFFF3366),
    Color(0xFF00E5FF), Color(0xFF69FF47), Color(0xFFFFFFFF),
  ];
  static const _confettiColors = [
    Color(0xFFFF1744), Color(0xFFFF6D00), Color(0xFFFFD600),
    Color(0xFF00E676), Color(0xFF2979FF), Color(0xFFD500F9),
  ];

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);

    _implodeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )
      ..addListener(_mark)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _onImplosionDone?.call();
          _startBlast();
        }
      });

    _bloomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..addListener(_mark);

    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..addListener(_mark);

    _tick = createTicker(_onTick);
  }

  @override
  void dispose() {
    widget.controller._detach();
    _implodeCtrl.dispose();
    _bloomCtrl.dispose();
    _flashCtrl.dispose();
    _tick.dispose();
    super.dispose();
  }

  void _mark() => setState(() {});

  // ── Trigger from controller ───────────────────────────────────────────────

  void _trigger({
    required Offset mergeGlobal,
    required Offset src1Global,
    required Offset src2Global,
    required String sourceEmoji,
    required int xpGain,
    required bool isRare,
    required VoidCallback onImplosionDone,
  }) {
    _phase      = _Phase.imploding;
    _mergeG     = mergeGlobal;
    _src1G      = src1Global;
    _src2G      = src2Global;
    _srcEmoji   = sourceEmoji;
    _onImplosionDone = onImplosionDone;

    _sparks.clear();
    _confetti.clear();
    _labels.clear();

    // Store for use in _startBlast
    _pendingXp   = xpGain;
    _pendingRare = isRare;

    _implodeCtrl.forward(from: 0);
    _bloomCtrl.stop(); _bloomCtrl.value = 0;
    _flashCtrl.stop(); _flashCtrl.value = 0;
    setState(() {});
  }

  int  _pendingXp   = 0;
  bool _pendingRare = false;

  void _startBlast() {
    _phase = _Phase.blasting;

    // Haptic
    HapticFeedback.mediumImpact();

    // Request screen shake and new-item pop from grid screen
    widget.controller.onShake?.call();
    widget.controller.onPop?.call();

    // Sparks
    final sparkCount = _pendingRare ? 20 : 12;
    for (int i = 0; i < sparkCount; i++) {
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 180.0 + _rng.nextDouble() * 260.0;
      _sparks.add(_Spark(
        pos: _mergeG,
        vel: Offset(math.cos(angle) * speed, math.sin(angle) * speed - 80),
        color: _sparkColors[_rng.nextInt(_sparkColors.length)],
        size: 4.0 + _rng.nextDouble() * 5.0,
      ));
    }

    // Confetti on rare merges
    if (_pendingRare) {
      for (int i = 0; i < 28; i++) {
        final angle = _rng.nextDouble() * 2 * math.pi;
        final speed = 120.0 + _rng.nextDouble() * 220.0;
        _confetti.add(_Confetto(
          pos: _mergeG,
          vel: Offset(math.cos(angle) * speed, math.sin(angle) * speed - 160),
          color: _confettiColors[_rng.nextInt(_confettiColors.length)],
          size: 7.0 + _rng.nextDouble() * 7.0,
          angle: _rng.nextDouble() * 2 * math.pi,
          spin: (_rng.nextDouble() - 0.5) * 12,
        ));
      }
      _labels.add(_FloatLabel(
        text: '✨ NEW!',
        color: Colors.purpleAccent,
        pos: _mergeG + const Offset(-16, -52),
      ));
    }

    // XP label
    _labels.add(_FloatLabel(
      text: '+$_pendingXp XP',
      color: Colors.amber,
      pos: _mergeG + const Offset(-20, -24),
    ));

    _bloomCtrl.forward(from: 0);
    _flashCtrl.forward(from: 0);
    _lastTick = null;
    if (!_tick.isActive) _tick.start();
    setState(() {});
  }

  // ── Particle ticker ───────────────────────────────────────────────────────

  void _onTick(Duration elapsed) {
    if (_phase == _Phase.idle) { _tick.stop(); return; }

    final dt = _lastTick == null
        ? 0.016
        : (elapsed - _lastTick!).inMilliseconds / 1000.0;
    _lastTick = elapsed;
    const g = 480.0;

    for (final s in _sparks) {
      s.pos += s.vel * dt;
      s.vel = Offset(s.vel.dx * 0.97, s.vel.dy + g * dt);
      s.life -= dt * 1.4;
    }
    _sparks.removeWhere((s) => s.life <= 0);

    for (final c in _confetti) {
      c.pos   += c.vel * dt;
      c.vel    = Offset(c.vel.dx * 0.96, c.vel.dy + g * 0.55 * dt);
      c.angle += c.spin * dt;
      c.life  -= dt * 0.75;
    }
    _confetti.removeWhere((c) => c.life <= 0);

    for (final l in _labels) {
      l.pos    = l.pos.translate(0, -75 * dt);
      l.opacity -= dt * 1.1;
    }
    _labels.removeWhere((l) => l.opacity <= 0);

    final allDone = _sparks.isEmpty && _confetti.isEmpty &&
        _labels.isEmpty && (_bloomCtrl.isCompleted || _bloomCtrl.isDismissed);

    if (allDone) {
      _tick.stop();
      _lastTick = null;
      _phase = _Phase.idle;
    }

    setState(() {});
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_phase == _Phase.idle) return const SizedBox.shrink();

    final box = context.findRenderObject() as RenderBox?;
    Offset L(Offset g) => box != null ? box.globalToLocal(g) : g;

    final lMerge = L(_mergeG);
    final lSrc1  = L(_src1G);
    final lSrc2  = L(_src2G);
    final bp     = _bloomCtrl.value;

    return Stack(
      children: [
        // 1 ── Implosion: source items shrink ──────────────────────────────
        if (_phase == _Phase.imploding) ...[
          _implodeItem(lSrc1,  _srcEmoji, _implodeCtrl.value),
          _implodeItem(lSrc2,  _srcEmoji, _implodeCtrl.value),
        ],

        // 3 ── Impact Bloom ────────────────────────────────────────────────
        if (_phase == _Phase.blasting)
          CustomPaint(
            size: Size.infinite,
            painter: _BloomPainter(lMerge, bp),
          ),

        // 5 ── Ring Shockwave ──────────────────────────────────────────────
        if (_phase == _Phase.blasting)
          CustomPaint(
            size: Size.infinite,
            painter: _RingPainter(lMerge, bp),
          ),

        // 4 ── Spark particles ─────────────────────────────────────────────
        ..._sparks.map((s) {
          final lp = L(s.pos);
          return Positioned(
            left: lp.dx - s.size / 2,
            top:  lp.dy - s.size / 2,
            child: Opacity(
              opacity: s.life.clamp(0.0, 1.0),
              child: Container(
                width: s.size, height: s.size,
                decoration: BoxDecoration(
                  color: s.color,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: s.color.withOpacity(0.7), blurRadius: 5)],
                ),
              ),
            ),
          );
        }),

        // 8 ── Confetti ────────────────────────────────────────────────────
        ..._confetti.map((c) {
          final lp = L(c.pos);
          return Positioned(
            left: lp.dx - c.size / 2,
            top:  lp.dy - c.size / 2,
            child: Opacity(
              opacity: c.life.clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: c.angle,
                child: Container(width: c.size, height: c.size, color: c.color),
              ),
            ),
          );
        }),

        // 2 ── White Flash ─────────────────────────────────────────────────
        if (_phase == _Phase.blasting && _flashCtrl.value < 1.0)
          Positioned(
            left: lMerge.dx - 28,
            top:  lMerge.dy - 28,
            child: Opacity(
              opacity: (1.0 - _flashCtrl.value).clamp(0.0, 0.9),
              child: Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white,
                ),
              ),
            ),
          ),

        // 10 ── Float labels ───────────────────────────────────────────────
        ..._labels.map((l) {
          final lp = L(l.pos);
          return Positioned(
            left: lp.dx,
            top:  lp.dy,
            child: Opacity(
              opacity: l.opacity.clamp(0.0, 1.0),
              child: Text(
                l.text,
                style: TextStyle(
                  color: l.color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _implodeItem(Offset localPos, String emoji, double progress) {
    final scale = (1.0 - Curves.easeIn.transform(progress)).clamp(0.0, 1.0);
    return Positioned(
      left: localPos.dx - 24,
      top:  localPos.dy - 24,
      child: Transform.scale(
        scale: scale,
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Custom painters
// ─────────────────────────────────────────────────────────────────────────────

class _BloomPainter extends CustomPainter {
  final Offset center;
  final double t;
  const _BloomPainter(this.center, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final radius  = 15.0 + t * 90.0;
    final opacity = (1.0 - t).clamp(0.0, 1.0) * 0.65;
    final paint   = Paint()
      ..shader = RadialGradient(colors: [
        Colors.amber.withOpacity(opacity),
        Colors.deepOrange.withOpacity(opacity * 0.5),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_BloomPainter o) => o.t != t;
}

class _RingPainter extends CustomPainter {
  final Offset center;
  final double t;
  const _RingPainter(this.center, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final radius  = 8.0 + t * 130.0;
    final stroke  = (9.0 * (1.0 - t)).clamp(0.5, 9.0);
    final opacity = (1.0 - t * 1.1).clamp(0.0, 1.0);
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color      = Colors.white.withOpacity(opacity * 0.85)
        ..strokeWidth = stroke
        ..style       = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.t != t;
}
