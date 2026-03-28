// lib/widgets/game_grid/generator_tile.dart
//
// All implemented generator effects:
//  ✅ 21 – Tap squash (Y 0.82 / X 1.10 snap-back)
//  ✅ 22 – Internal wobble (random rotation jiggle every 3–5 s)
//     23 – Ejection arc handled externally in game_grid_screen
//  ✅ 25 – Cooldown dim (28% dark overlay)
//  ✅ 26 – Recharge glow (green breathe when < 25% cooldown left)
//  ✅ 27 – "!" bubble bounces above when newly ready
//  ✅ 29 – Sparkle overlay on overlayNumber > 0 generators
//  ✅ 30 – Haptic thud on every production tap
//
// Plus previously shipped:
//  ✅  1 – Breathe scale (idle, 1.0 → 1.05)
//  ✅  1b– Diagonal glint sweep every 5 s
//  ✅  3 – Red glow ring + Zzz particles (exhausted)
//  ✅  4 – Radial wake-up burst + double-hop
//     5 – Lightning bolt badge (removed)

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../models/tile_data.dart';

Widget buildTileContentGen(String p, {BoxFit fit = BoxFit.contain, double size = 30}) {
  if (p.contains('/')) {
    return Image.asset(p, fit: fit,
        errorBuilder: (_, __, ___) => Icon(Icons.error_outline, size: size * 0.8, color: Colors.red));
  }
  return Center(child: Text(p, style: TextStyle(fontSize: size)));
}

// ── Particle data ─────────────────────────────────────────────────────────────
class _Spark {
  Offset pos, vel;
  Color color;
  double life;
  _Spark({required this.pos, required this.vel, required this.color}) : life = 1.0;
}

class _Zzz {
  Offset pos;
  double opacity, size;
  _Zzz({required this.pos, required this.size}) : opacity = 0.85;
}

class _Sparkle {
  Offset pos;
  double life; // oscillates 0→1→0
  double phase;
  _Sparkle({required this.pos, required this.phase}) : life = 0.0;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Widget
// ─────────────────────────────────────────────────────────────────────────────

class GeneratorTile extends StatefulWidget {
  final TileData tile;
  final Color bgColor;
  final VoidCallback onTap;

  const GeneratorTile({
    super.key,
    required this.tile,
    required this.bgColor,
    required this.onTap,
  });

  @override
  State<GeneratorTile> createState() => _GeneratorTileState();
}

class _GeneratorTileState extends State<GeneratorTile>
    with TickerProviderStateMixin {

  // Breathe (idle)
  late AnimationController _breathCtrl;

  // Glint
  late AnimationController _glintCtrl;
  Timer? _glintTimer;

  // Squash (#21)
  late AnimationController _squashCtrl;

  // Wobble (#22) — random jiggle
  late AnimationController _wobbleCtrl;
  Timer? _wobbleTimer;
  double _wobbleAngle = 0;

  // Tap sparks
  final List<_Spark> _sparks = [];
  late Ticker _sparkTicker;
  Duration? _lastSparkTick;

  // Exhausted glow
  late AnimationController _glowCtrl;

  // Zzz particles
  final List<_Zzz> _zzzList = [];
  Timer? _zzzTimer;

  // Recharge glow (#26) — green when < 25% cooldown left
  late AnimationController _rechargeCtrl;

  // Wake-up burst (#4 / #27)
  late AnimationController _wakeCtrl;
  late AnimationController _hopCtrl;
  bool _showWake = false;
  bool _showExclam = false; // "!" bubble
  late AnimationController _exclamCtrl;
  Timer? _exclamTimer;

  // Sparkles (#29)
  final List<_Sparkle> _sparkles = [];
  late AnimationController _sparkleCtrl;

  bool _prevReady = true;
  final _rng = math.Random();

  static const _sparkColors = [
    Color(0xFFFFD700), Color(0xFFFF8C00), Color(0xFFFFFFAA), Color(0xFFFFCC44),
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _prevReady = widget.tile.isReady;

    _breathCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true)..addListener(_mark);

    _glintCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))
      ..addListener(_mark);
    _scheduleGlint();

    _squashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))
      ..addListener(_mark);

    // #22 Wobble
    _wobbleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))
      ..addListener(_mark)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _wobbleCtrl.reverse();
        } else if (s == AnimationStatus.dismissed) {
          _wobbleAngle = 0;
          _scheduleWobble();
        }
      });
    _scheduleWobble();

    _sparkTicker = createTicker(_onSparkTick);

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..addListener(_mark);
    if (!widget.tile.isReady) {
      _glowCtrl.repeat(reverse: true);
      _scheduleZzz();
    }

    // #26 Recharge glow
    _rechargeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..addListener(_mark);

    _wakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(_mark)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) setState(() => _showWake = false);
      });
    _hopCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..addListener(_mark);

    // #27 "!" exclamation bubble
    _exclamCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))
      ..addListener(_mark);

    // #29 Sparkles for premium generators
    if ((widget.tile.overlayNumber) > 0) {
      _initSparkles();
      _sparkleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
        ..repeat()..addListener(_onSparkleTick);
    } else {
      _sparkleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1));
    }

    _startRechargePulseIfNeeded();
  }

  void _initSparkles() {
    _sparkles.clear();
    for (int i = 0; i < 5; i++) {
      _sparkles.add(_Sparkle(
        pos: Offset(5 + _rng.nextDouble() * 38, 5 + _rng.nextDouble() * 38),
        phase: _rng.nextDouble() * 2 * math.pi,
      ));
    }
  }

  void _onSparkleTick() {
    final t = _sparkleCtrl.value * 2 * math.pi;
    for (final s in _sparkles) {
      s.life = (math.sin(t + s.phase) + 1) / 2;
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(GeneratorTile old) {
    super.didUpdateWidget(old);
    final wasReady = _prevReady;
    final isReady  = widget.tile.isReady;
    _prevReady = isReady;

    if (isReady && !wasReady) {
      _glowCtrl.stop(); _glowCtrl.value = 0;
      _rechargeCtrl.stop(); _rechargeCtrl.value = 0;
      _zzzTimer?.cancel(); _zzzList.clear();
      _triggerWakeUp();
    } else if (!isReady && wasReady) {
      _glowCtrl.repeat(reverse: true);
      _scheduleZzz();
    }
    _startRechargePulseIfNeeded();
  }

  void _startRechargePulseIfNeeded() {
    if (!widget.tile.isReady) {
      final remaining = widget.tile.remainingCooldown.inMilliseconds;
      final total     = widget.tile.cooldownDuration.inMilliseconds;
      final fraction  = total > 0 ? remaining / total : 1.0;
      if (fraction < 0.25) {
        if (!_rechargeCtrl.isAnimating) _rechargeCtrl.repeat(reverse: true);
      } else {
        _rechargeCtrl.stop(); _rechargeCtrl.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _glintCtrl.dispose();
    _glintTimer?.cancel();
    _squashCtrl.dispose();
    _wobbleCtrl.dispose();
    _wobbleTimer?.cancel();
    _sparkTicker.dispose();
    _glowCtrl.dispose();
    _rechargeCtrl.dispose();
    _zzzTimer?.cancel();
    _wakeCtrl.dispose();
    _hopCtrl.dispose();
    _exclamCtrl.dispose();
    _exclamTimer?.cancel();
    _sparkleCtrl.dispose();
    super.dispose();
  }

  void _mark() => setState(() {});

  // ── Scheduling helpers ────────────────────────────────────────────────────

  void _scheduleGlint() {
    _glintTimer?.cancel();
    _glintTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && widget.tile.isReady) {
        _glintCtrl.forward(from: 0).then((_) => _scheduleGlint());
      } else {
        _scheduleGlint();
      }
    });
  }

  void _scheduleWobble() {
    _wobbleTimer?.cancel();
    final delay = 3000 + _rng.nextInt(2000); // 3–5 s
    _wobbleTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted || !widget.tile.isReady) { _scheduleWobble(); return; }
      _wobbleAngle = (_rng.nextBool() ? 1 : -1) * (2.5 + _rng.nextDouble() * 2.5) * math.pi / 180;
      _wobbleCtrl.forward(from: 0);
    });
  }

  void _scheduleZzz() {
    _zzzTimer?.cancel();
    _zzzTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (!mounted || widget.tile.isReady) return;
      setState(() {
        _zzzList.add(_Zzz(pos: Offset(18 + _rng.nextDouble() * 12, 8.0), size: 9 + _rng.nextDouble() * 4));
      });
      if (!_sparkTicker.isActive) { _lastSparkTick = null; _sparkTicker.start(); }
    });
  }

  // ── Wake-up + "!" ─────────────────────────────────────────────────────────

  void _triggerWakeUp() {
    setState(() { _showWake = true; _showExclam = true; });
    _wakeCtrl.forward(from: 0);
    _hopCtrl.forward(from: 0).then((_) => _hopCtrl.reverse()).then((_) {
      _hopCtrl.forward(from: 0).then((_) => _hopCtrl.reverse());
    });
    _exclamCtrl.repeat(reverse: true);
    HapticFeedback.lightImpact();
    // Auto-hide "!" after 4 s
    _exclamTimer?.cancel();
    _exclamTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) { _exclamCtrl.stop(); setState(() => _showExclam = false); }
    });
  }

  // ── Tap ───────────────────────────────────────────────────────────────────

  void _onTap() {
    if (!widget.tile.isReady) return;
    _squashCtrl.forward(from: 0).then((_) => _squashCtrl.reverse());
    // Dismiss "!" on tap
    if (_showExclam) { _exclamCtrl.stop(); setState(() => _showExclam = false); }
    // Tap sparks
    for (int i = 0; i < 8; i++) {
      final angle = math.pi + _rng.nextDouble() * math.pi;
      final speed = 60.0 + _rng.nextDouble() * 80.0;
      _sparks.add(_Spark(
        pos: const Offset(25, 44),
        vel: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: _sparkColors[_rng.nextInt(_sparkColors.length)],
      ));
    }
    if (!_sparkTicker.isActive) { _lastSparkTick = null; _sparkTicker.start(); }
    HapticFeedback.mediumImpact(); // #30 haptic thud
    widget.onTap();
  }

  // ── Spark + Zzz ticker ────────────────────────────────────────────────────

  void _onSparkTick(Duration elapsed) {
    final dt = _lastSparkTick == null
        ? 0.016 : (elapsed - _lastSparkTick!).inMilliseconds / 1000.0;
    _lastSparkTick = elapsed;
    const g = 300.0;
    for (final s in _sparks) {
      s.pos += s.vel * dt;
      s.vel  = Offset(s.vel.dx * 0.95, s.vel.dy + g * dt);
      s.life -= dt * 2.5;
    }
    _sparks.removeWhere((s) => s.life <= 0);
    for (final z in _zzzList) {
      z.pos     = z.pos.translate(_rng.nextDouble() * 1.5 - 0.75, -18 * dt);
      z.opacity -= dt * 0.45;
    }
    _zzzList.removeWhere((z) => z.opacity <= 0);
    if (_sparks.isEmpty && _zzzList.isEmpty) { _sparkTicker.stop(); _lastSparkTick = null; }
    setState(() {});
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isReady = widget.tile.isReady;

    // Breathe scale
    final breathScale = isReady
        ? 1.0 + Tween<double>(begin: 0.0, end: 0.05)
            .animate(CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut)).value
        : 1.0;

    // Squash
    final sq = _squashCtrl.value;
    final sqFwd = sq < 0.5 ? sq * 2 : 1.0;
    final sqBck = sq >= 0.5 ? (sq - 0.5) * 2 : 0.0;
    final scaleX = 1.0 + sqFwd * 0.10 - sqBck * 0.05;
    final scaleY = 1.0 - sqFwd * 0.18 + sqBck * 0.09;

    // Wobble angle
    final wobble = _wobbleAngle * _wobbleCtrl.value;

    // Hop offset
    final hopY = -math.sin(_hopCtrl.value * math.pi) * 5.0;

    // Recharge glow (green, when almost recharged)
    final rechargeGlow = _rechargeCtrl.value;
    final isRecharging = _rechargeCtrl.isAnimating;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // #27 "!" bubble ABOVE tile (Clip.none lets it overflow)
        if (_showExclam)
          Positioned(
            top: -18,
            left: 0, right: 0,
            child: Center(
              child: Transform.translate(
                offset: Offset(0, -math.sin(_exclamCtrl.value * math.pi) * 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.6), blurRadius: 6)],
                  ),
                  child: const Text('!', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),

        // Main tile body
        GestureDetector(
          onTap: _onTap,
          child: Transform.translate(
            offset: Offset(0, hopY),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scale(breathScale * scaleX, breathScale * scaleY)
                ..rotateZ(wobble),
              child: SizedBox(
                width: 50, height: 50,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Base container
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: widget.bgColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isRecharging
                                ? Colors.greenAccent.withOpacity(0.4 + rechargeGlow * 0.5)
                                : isReady
                                    ? Colors.amber.withOpacity(0.35 + _breathCtrl.value * 0.25)
                                    : Colors.red.withOpacity(0.2 + _glowCtrl.value * 0.35),
                            width: isRecharging ? 2.0 : 1.5,
                          ),
                          boxShadow: isRecharging
                              ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.15 + rechargeGlow * 0.25), blurRadius: 10, spreadRadius: 2)]
                              : isReady
                                  ? [BoxShadow(color: Colors.amber.withOpacity(0.08 + _breathCtrl.value * 0.12), blurRadius: 8, spreadRadius: 2)]
                                  : null,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: [
                            // Generator emoji
                            buildTileContentGen(widget.tile.baseImagePath, size: 28),

                            // #29 Sparkle overlay (high-level generators)
                            if (widget.tile.overlayNumber > 0)
                              ..._sparkles.map((s) => Positioned(
                                left: s.pos.dx,
                                top:  s.pos.dy,
                                child: Opacity(
                                  opacity: s.life * 0.9,
                                  child: Text('✨', style: TextStyle(fontSize: 8 + s.life * 6)),
                                ),
                              )),

                            // Exhausted dim overlay (#25)
                            if (!isReady)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.black.withOpacity(0.28),
                                  ),
                                ),
                              ),

                            // Recharge green glow ring (#26)
                            if (isRecharging)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.greenAccent.withOpacity(0.2 + rechargeGlow * 0.6),
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              ),

                            // Exhausted red glow ring
                            if (!isReady && !isRecharging)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.15 + _glowCtrl.value * 0.45),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),

                            // Cooldown countdown
                            if (!isReady)
                              Positioned.fill(child: _CooldownText(tile: widget.tile)),
                          ],
                        ),
                      ),
                    ),

                    // Glint sweep
                    if (isReady && _glintCtrl.value > 0)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CustomPaint(painter: _GlintPainter(_glintCtrl.value)),
                        ),
                      ),

                    // Wake-up radial shine
                    if (_showWake)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: _WakePainter(_wakeCtrl.value)),
                        ),
                      ),

                    // Tap sparks
                    ..._sparks.map((s) => Positioned(
                      left: s.pos.dx - 3, top: s.pos.dy - 3,
                      child: Opacity(
                        opacity: s.life.clamp(0.0, 1.0),
                        child: Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                        ),
                      ),
                    )),

                    // Zzz labels
                    ..._zzzList.map((z) => Positioned(
                      left: z.pos.dx, top: z.pos.dy,
                      child: Opacity(
                        opacity: z.opacity.clamp(0.0, 1.0),
                        child: Text('z', style: TextStyle(
                          fontSize: z.size, color: Colors.blueGrey.shade200,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets & painters ────────────────────────────────────────────────────

class _CooldownText extends StatefulWidget {
  final TileData tile;
  const _CooldownText({required this.tile});
  @override
  State<_CooldownText> createState() => _CooldownTextState();
}
class _CooldownTextState extends State<_CooldownText> {
  Timer? _t;
  @override void initState() { super.initState(); _t = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); }); }
  @override void dispose() { _t?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final secs = widget.tile.remainingCooldown.inSeconds + 1;
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(3)),
      child: Center(child: Text('${secs}s', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
    );
  }
}

class _GlintPainter extends CustomPainter {
  final double t;
  const _GlintPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final x = (t * (size.width + size.height)) - size.height;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Colors.transparent, Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.35), Colors.white.withOpacity(0.0), Colors.transparent],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(x - 20, 0, 40, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }
  @override bool shouldRepaint(_GlintPainter o) => o.t != t;
}

class _WakePainter extends CustomPainter {
  final double t;
  const _WakePainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4 + t * size.width * 1.2;
    final opacity = (1.0 - t).clamp(0.0, 1.0) * 0.7;
    canvas.drawCircle(center, radius,
      Paint()..shader = RadialGradient(colors: [
        Colors.amber.withOpacity(opacity),
        Colors.yellow.withOpacity(opacity * 0.5),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(center: center, radius: radius)));
  }
  @override bool shouldRepaint(_WakePainter o) => o.t != t;
}
