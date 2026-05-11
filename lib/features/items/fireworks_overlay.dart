import 'dart:math';

import 'package:flutter/material.dart';

import 'package:autism_avc_flutter/core/theme/app_colors.dart';

/// Full-screen fireworks animation overlay.
///
/// Launches several rockets from the bottom of the screen; each one bursts
/// into a gentle shower of coloured particles that fade out.
class FireworksOverlay extends StatefulWidget {
  const FireworksOverlay({super.key});

  @override
  State<FireworksOverlay> createState() => _FireworksOverlayState();
}

class _FireworksOverlayState extends State<FireworksOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_Firework>? _fireworks;
  final _rng = Random();

  static const _colors = [
    AppColors.primaryBlueLighter10,
    AppColors.blossomPinkBase,
    AppColors.brilliantTealBase,
    AppColors.sunshineYellowBase,
    AppColors.blossomPinkLighter10,
    AppColors.primaryBlueBase,
    AppColors.brilliantTealLighter10,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Firework> _generateFireworks(Size size) {
    const count = 7;
    return List.generate(count, (i) {
      final launchX = size.width * (0.12 + _rng.nextDouble() * 0.76);
      final burstX = size.width * (0.15 + _rng.nextDouble() * 0.70);
      final burstY = size.height * (0.12 + _rng.nextDouble() * 0.35);

      return _Firework(
        launchPos: Offset(launchX, size.height),
        burstPos: Offset(burstX, burstY),
        startFraction: i * 0.10,
        color: _colors[i % _colors.length],
        particleCount: 24 + _rng.nextInt(12),
        rng: _rng,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _fireworks ??= _generateFireworks(size);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _FireworksPainter(
                  progress: _controller.value,
                  fireworks: _fireworks!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _Firework {
  final Offset launchPos;
  final Offset burstPos;
  final double startFraction;
  final Color color;
  final List<_Particle> particles;

  _Firework({
    required this.launchPos,
    required this.burstPos,
    required this.startFraction,
    required this.color,
    required int particleCount,
    required Random rng,
  }) : particles = List.generate(particleCount, (_) => _Particle(rng));
}

class _Particle {
  final double angle;
  final double speed;
  final double size;

  _Particle(Random rng)
      : angle = rng.nextDouble() * 2 * pi,
        speed = 0.4 + rng.nextDouble() * 0.6,
        size = 1.5 + rng.nextDouble() * 2.0;
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _FireworksPainter extends CustomPainter {
  final double progress;
  final List<_Firework> fireworks;

  /// Fraction of a firework's lifecycle spent on the launch trail.
  static const _launchPhase = 0.25;

  _FireworksPainter({required this.progress, required this.fireworks});

  @override
  void paint(Canvas canvas, Size size) {
    for (final fw in fireworks) {
      // Each firework occupies the time window [startFraction, 1.0].
      final span = 1.0 - fw.startFraction;
      if (span <= 0) continue;
      final local = ((progress - fw.startFraction) / span).clamp(0.0, 1.0);
      if (local <= 0) continue;

      if (local < _launchPhase) {
        _drawTrail(canvas, fw, local / _launchPhase);
      } else {
        final t = (local - _launchPhase) / (1.0 - _launchPhase);
        _drawBurst(canvas, fw, t);
      }
    }
  }

  void _drawTrail(Canvas canvas, _Firework fw, double t) {
    final current = Offset.lerp(fw.launchPos, fw.burstPos, t)!;
    final trailStart =
        Offset.lerp(fw.launchPos, fw.burstPos, (t - 0.18).clamp(0, 1))!;

    // Thin rocket trail
    final trailPaint = Paint()
      ..color = fw.color.withValues(alpha: 0.8 * (1 - t * 0.3))
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(trailStart, current, trailPaint);

    // Bright head
    final headPaint = Paint()
      ..color = fw.color.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(current, 3, headPaint);
  }

  void _drawBurst(Canvas canvas, _Firework fw, double t) {
    for (final p in fw.particles) {
      final spread = p.speed * t * 90;
      final gravity = t * t * 35; // gentle fall
      final pos = Offset(
        fw.burstPos.dx + cos(p.angle) * spread,
        fw.burstPos.dy + sin(p.angle) * spread + gravity,
      );

      final opacity = (1.0 - t).clamp(0.0, 1.0) * 0.75;
      final radius = p.size * (1.0 - t * 0.4);

      // Core particle
      canvas.drawCircle(
        pos,
        radius,
        Paint()..color = fw.color.withValues(alpha: opacity),
      );

      // Soft glow
      canvas.drawCircle(
        pos,
        radius * 1.6,
        Paint()
          ..color = fw.color.withValues(alpha: opacity * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter old) =>
      old.progress != progress;
}
