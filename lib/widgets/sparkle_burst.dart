import 'dart:math' as math;

import 'package:flutter/material.dart';

const sparkleBurstKey = Key('sparkle-burst');

/// ボタンの中央から、短いキラッとした光を出す。
void showSparkleBurst(BuildContext context) {
  if (!context.mounted || MediaQuery.disableAnimationsOf(context)) {
    return;
  }
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) {
    return;
  }
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    return;
  }

  final origin = box.localToGlobal(box.size.center(Offset.zero));
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return _SparkleLayer(
        key: sparkleBurstKey,
        origin: origin,
        onFinished: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      );
    },
  );
  overlay.insert(entry);
}

class _SparkleLayer extends StatefulWidget {
  const _SparkleLayer({
    super.key,
    required this.origin,
    required this.onFinished,
  });

  final Offset origin;
  final VoidCallback onFinished;

  @override
  State<_SparkleLayer> createState() => _SparkleLayerState();
}

class _SparkleLayerState extends State<_SparkleLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _controller.forward().whenComplete(_finish);
  }

  void _finish() {
    if (_finished) {
      return;
    }
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final sparkleT = (t / 0.6).clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: Colors.black.withValues(alpha: _scrimOpacity(t)),
              ),
              CustomPaint(
                painter: _SparklePainter(origin: widget.origin, t: sparkleT),
              ),
              Center(
                child: Opacity(
                  opacity: _doneOpacity(t),
                  child: Transform.scale(
                    scale: _doneScale(t),
                    child: const _DoneBadge(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

double _scrimOpacity(double t) {
  const peak = 0.32;
  if (t < 0.12) {
    return peak * (t / 0.12);
  }
  if (t < 0.62) {
    return peak;
  }
  return peak * (1 - (t - 0.62) / 0.38).clamp(0.0, 1.0);
}

double _doneOpacity(double t) {
  if (t < 0.08) {
    return t / 0.08;
  }
  if (t < 0.68) {
    return 1;
  }
  return (1 - (t - 0.68) / 0.32).clamp(0.0, 1.0);
}

double _doneScale(double t) {
  if (t < 0.22) {
    final scale = Curves.easeOutBack.transform(t / 0.22);
    if (scale < 0) {
      return 0;
    }
    return scale;
  }
  return 1;
}

class _DoneBadge extends StatelessWidget {
  const _DoneBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'できた',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFE07A5F),
              size: 36,
            ),
            SizedBox(height: 8),
            Text(
              'Done!',
              style: TextStyle(
                color: Color(0xFF3A2E29),
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Spark {
  const _Spark({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.delay,
    this.dot = false,
  });

  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double delay;
  final bool dot;
}

const _sparks = [
  _Spark(
    angle: -1.57,
    distance: 54,
    size: 7.5,
    color: Color(0xFFFFD56A),
    delay: 0.02,
  ),
  _Spark(
    angle: -2.25,
    distance: 40,
    size: 5.5,
    color: Color(0xFFFFFFFF),
    delay: 0.05,
  ),
  _Spark(
    angle: -0.85,
    distance: 44,
    size: 6,
    color: Color(0xFFFFE3D6),
    delay: 0.04,
  ),
  _Spark(
    angle: 3.14,
    distance: 30,
    size: 4.2,
    color: Color(0xFFFFD56A),
    delay: 0.08,
  ),
  _Spark(
    angle: 0.05,
    distance: 32,
    size: 4.4,
    color: Color(0xFFFFFFFF),
    delay: 0.07,
  ),
  _Spark(
    angle: -1.15,
    distance: 28,
    size: 3.2,
    color: Color(0xFFFFF6E8),
    delay: 0.12,
    dot: true,
  ),
  _Spark(
    angle: -2.0,
    distance: 26,
    size: 2.8,
    color: Color(0xFFFFD56A),
    delay: 0.14,
    dot: true,
  ),
  _Spark(
    angle: -0.4,
    distance: 24,
    size: 2.6,
    color: Color(0xFFFFFFFF),
    delay: 0.1,
    dot: true,
  ),
];

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.origin, required this.t});

  final Offset origin;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = (1 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);
    canvas.drawCircle(
      origin,
      16 + 30 * Curves.easeOut.transform(t),
      Paint()
        ..color = const Color(0xFFFFE08A).withValues(alpha: 0.38 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    _drawGlint(canvas);
    for (final spark in _sparks) {
      _drawSpark(canvas, spark);
    }
    _drawFlash(canvas, origin, 18, t, 0);
    _drawTwinkle(canvas);
  }

  void _drawGlint(Canvas canvas) {
    if (t > 0.42) {
      return;
    }
    final local = t / 0.42;
    final opacity = math.sin(local * math.pi);
    final length = 8 + 34 * Curves.easeOut.transform(local);
    final angle = -0.65;
    final delta = Offset(math.cos(angle), math.sin(angle)) * length;
    canvas.drawLine(
      origin - delta * 0.3,
      origin + delta,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.95 * opacity)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawSpark(Canvas canvas, _Spark spark) {
    if (t <= spark.delay) {
      return;
    }
    final local = ((t - spark.delay) / (1 - spark.delay)).clamp(0.0, 1.0);
    final move = Curves.easeOutCubic.transform(local);
    final fade = (1 - Curves.easeIn.transform(local)).clamp(0.0, 1.0);
    final pos =
        origin +
        Offset(math.cos(spark.angle), math.sin(spark.angle)) *
            spark.distance *
            move;
    final radius = spark.size * math.sin(local * math.pi).clamp(0.35, 1);
    final color = spark.color.withValues(alpha: fade);
    if (spark.dot) {
      canvas.drawCircle(pos, radius, Paint()..color = color);
      return;
    }
    _drawStar(canvas, pos, radius, color, local * 0.8);
  }

  void _drawFlash(
    Canvas canvas,
    Offset at,
    double radius,
    double progress,
    double delay,
  ) {
    if (progress <= delay) {
      return;
    }
    final local = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
    final pop =
        local < 0.18
            ? Curves.easeOutBack.transform(local / 0.18)
            : 1 + (1 - (local - 0.18) / 0.82) * 0.12;
    final opacity =
        local < 0.12
            ? local / 0.12
            : (1 - (local - 0.12) / 0.88).clamp(0.0, 1.0);
    _drawStar(
      canvas,
      at,
      radius * pop,
      const Color(0xFFFFD56A).withValues(alpha: opacity),
      0,
    );
    _drawStar(
      canvas,
      at,
      radius * 0.62 * pop,
      Colors.white.withValues(alpha: opacity),
      math.pi / 4,
    );
  }

  void _drawTwinkle(Canvas canvas) {
    _drawFlash(canvas, origin + const Offset(20, -24), 9, t, 0.28);
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double rotation,
  ) {
    if (radius <= 0 || color.a == 0) {
      return;
    }
    final path = Path();
    const spikes = 4;
    final inner = radius * 0.18;
    for (var i = 0; i < spikes * 2; i++) {
      final angle = rotation - math.pi / 2 + i * math.pi / spikes;
      final reach = i.isEven ? radius : inner;
      final point = Offset(
        center.dx + math.cos(angle) * reach,
        center.dy + math.sin(angle) * reach,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.origin != origin;
  }
}
