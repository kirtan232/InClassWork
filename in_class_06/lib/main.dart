// In-Class Activity 06 — Drawing with Flutter
// Student: Kirtan Patel
// Date: September 26, 2026

import 'dart:math' show pi;

import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

/// Level 3: named face variations instead of duplicating the painter.
enum FaceStyle { classic, sleepy, surprised }

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Drawing "state" — changing these + setState() triggers shouldRepaint
  double mood = 0.8; // 0.0 sad → 1.0 happy
  double eyeSize = 0.12; // eye radius as a fraction of the face radius
  double eyeGap = 0.35; // eye distance from center as a fraction of the face radius
  bool showBlush = true;
  bool showHat = false;
  bool winking = false;
  FaceStyle faceStyle = FaceStyle.classic;

  String get moodLabel {
    if (mood < 0.35) return 'Sad';
    if (mood <= 0.7) return 'Neutral';
    return 'Happy';
  }

  // Level 4: gesture callbacks live in the widget; they only update state.
  void _onDrag(DragUpdateDetails details) {
    setState(() => mood = (mood - details.delta.dy / 200).clamp(0.0, 1.0));
  }

  void _reset() {
    setState(() {
      mood = 0.8;
      eyeSize = 0.12;
      eyeGap = 0.35;
      showBlush = true;
      showHat = false;
      winking = false;
      faceStyle = FaceStyle.classic;
    });
  }

  Widget _buildCanvas() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => winking = !winking),
        onLongPress: () => setState(() => showHat = !showHat),
        onVerticalDragUpdate: _onDrag,
        child: AspectRatio(
          aspectRatio: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, maxHeight: 320),
            child: CustomPaint(
              painter: SmileyPainter(
                mood: mood,
                eyeSize: eyeSize,
                eyeGap: eyeGap,
                showBlush: showBlush,
                showHat: showHat,
                winking: winking,
                faceStyle: faceStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 12),
        SegmentedButton<FaceStyle>(
          segments: const [
            ButtonSegment(value: FaceStyle.classic, label: Text('Classic')),
            ButtonSegment(value: FaceStyle.sleepy, label: Text('Sleepy')),
            ButtonSegment(value: FaceStyle.surprised, label: Text('Surprised')),
          ],
          selected: {faceStyle},
          onSelectionChanged: (s) => setState(() => faceStyle = s.first),
        ),
        const SizedBox(height: 12),
        Text('Mood: ${mood.toStringAsFixed(2)} ($moodLabel)'),
        Slider(
          value: mood,
          onChanged: (double v) => setState(() => mood = v),
        ),
        Text('Eye size: ${eyeSize.toStringAsFixed(2)}'),
        Slider(
          value: eyeSize,
          min: 0.06,
          max: 0.2,
          onChanged: (double v) => setState(() => eyeSize = v),
        ),
        Text('Eye gap: ${eyeGap.toStringAsFixed(2)}'),
        Slider(
          value: eyeGap,
          min: 0.2,
          max: 0.5,
          onChanged: (double v) => setState(() => eyeGap = v),
        ),
        SwitchListTile(
          title: const Text('Blush'),
          value: showBlush,
          onChanged: (v) => setState(() => showBlush = v),
        ),
        SwitchListTile(
          title: const Text('Hat'),
          value: showHat,
          onChanged: (v) => setState(() => showHat = v),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildCanvas(),
                    ),
                  ),
                  Expanded(child: _buildControls()),
                ],
              );
            }
            return Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildCanvas(),
                  ),
                ),
                Expanded(flex: 6, child: _buildControls()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    this.eyeSize = 0.12,
    this.eyeGap = 0.35,
    this.showBlush = true,
    this.showHat = false,
    this.winking = false,
    this.faceStyle = FaceStyle.classic,
  });

  final double mood;
  final double eyeSize;
  final double eyeGap;
  final bool showBlush;
  final bool showHat;
  final bool winking;
  final FaceStyle faceStyle;

  // Level 2: mood bands drive the face color.
  Color get faceColor {
    if (mood < 0.35) return Colors.lightBlue.shade200;
    if (mood <= 0.7) return Colors.yellow.shade600;
    return Colors.orange.shade400;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * (showHat ? 0.34 : 0.40);
    // Shift the face down a little when the hat is on so the hat fits.
    final center = showHat ? c + Offset(0, r * 0.25) : c;

    final ink = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04
      ..strokeCap = StrokeCap.round;

    // 1) Face fill
    canvas.drawCircle(center, r, Paint()..color = faceColor);

    // 2) Face border
    canvas.drawCircle(center, r, ink);

    // 3) Blush (drawOval)
    if (showBlush) _drawBlush(canvas, center, r);

    // 4) Eyes
    _drawEyes(canvas, center, r, ink);

    // 5) Mouth
    _drawMouth(canvas, center, r, ink);

    // 6) Accessories last so they sit on top
    if (showHat) _drawHat(canvas, center, r);
  }

  void _drawBlush(Canvas canvas, Offset c, double r) {
    final blush = Paint()..color = Colors.pinkAccent.withValues(alpha: 0.35);
    final y = c.dy + r * 0.2;
    final dx = r * 0.70;
    for (final x in [c.dx - dx, c.dx + dx]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: r * 0.3, height: r * 0.16),
        blush,
      );
    }
  }

  void _drawEyes(Canvas canvas, Offset c, double r, Paint ink) {
    final eyePaint = Paint()..color = Colors.black87;
    final eyeY = c.dy - r * 0.18;
    final dx = r * eyeGap;
    final eyeR = r * eyeSize;
    final left = Offset(c.dx - dx, eyeY);
    final right = Offset(c.dx + dx, eyeY);

    switch (faceStyle) {
      case FaceStyle.classic:
        canvas.drawCircle(left, eyeR, eyePaint);
        if (winking) {
          _drawClosedEye(canvas, right, eyeR, ink);
        } else {
          canvas.drawCircle(right, eyeR, eyePaint);
        }
      case FaceStyle.sleepy:
        _drawClosedEye(canvas, left, eyeR, ink);
        _drawClosedEye(canvas, right, eyeR, ink);
        _drawZzz(canvas, c, r);
      case FaceStyle.surprised:
        final bigR = eyeR * 1.3;
        final white = Paint()..color = Colors.white;
        for (final eye in [left, right]) {
          canvas.drawCircle(eye, bigR, white);
          canvas.drawCircle(eye, bigR, ink);
          canvas.drawCircle(eye, bigR * 0.5, eyePaint);
        }
        // Raised brows (drawLine)
        final browY = eyeY - bigR - r * 0.12;
        canvas.drawLine(
          Offset(left.dx - bigR, browY + r * 0.03),
          Offset(left.dx + bigR, browY - r * 0.03),
          ink,
        );
        canvas.drawLine(
          Offset(right.dx - bigR, browY - r * 0.03),
          Offset(right.dx + bigR, browY + r * 0.03),
          ink,
        );
    }
  }

  // A closed eye is a small downward-curving arc.
  void _drawClosedEye(Canvas canvas, Offset eye, double eyeR, Paint ink) {
    final rect = Rect.fromCenter(center: eye, width: eyeR * 2.4, height: eyeR * 1.6);
    canvas.drawArc(rect, 0.1 * pi, 0.8 * pi, false, ink);
  }

  void _drawZzz(Canvas canvas, Offset c, double r) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'z Z',
        style: TextStyle(
          color: Colors.indigo,
          fontSize: r * 0.28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx + r * 0.6, c.dy - r * 1.1));
  }

  void _drawMouth(Canvas canvas, Offset c, double r, Paint ink) {
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.05
      ..strokeCap = StrokeCap.round;

    if (faceStyle == FaceStyle.surprised) {
      // "O" mouth — opens wider as mood rises.
      final o = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.42),
        width: r * 0.3,
        height: r * (0.3 + mood * 0.2),
      );
      canvas.drawOval(o, Paint()..color = Colors.brown.shade800);
      canvas.drawOval(o, mouthPaint);
      return;
    }

    if (mood < 0.35) {
      // Frown: top half of an oval, deeper the sadder the mood.
      final depth = (0.35 - mood) / 0.35; // 0..1
      final frownRect = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.6),
        width: r * 0.9,
        height: r * (0.2 + depth * 0.4),
      );
      canvas.drawArc(frownRect, 1.15 * pi, 0.70 * pi, false, mouthPaint);

    } else if (mood <= 0.7) {
      // Neutral / soft smile.
      final t = (mood - 0.35) / 0.35; // 0..1
      final smileRect = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.25),
        width: r * 0.9,
        height: r * (0.1 + t * 0.5),
      );
      canvas.drawArc(smileRect, 0.15 * pi, 0.70 * pi, false, mouthPaint);

    } else {
      // Big open smile: a filled half-oval with an outline.
      final t = (mood - 0.7) / 0.3; // 0..1
      final bigRect = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.15),
        width: r * 1.0,
        height: r * (0.6 + t * 0.4),
      );
      canvas.drawArc(bigRect, 0, pi, false, Paint()..color = Colors.red.shade900);
      canvas.drawArc(bigRect, 0, pi, true, mouthPaint);
    }
  }

  void _drawHat(Canvas canvas, Offset c, double r) {
    final hatPaint = Paint()..color = Colors.grey.shade900;
    final bandPaint = Paint()..color = Colors.redAccent;
    final brimY = c.dy - r * 0.8;

    // Crown (drawRect) then brim (drawRRect) on top.
    final crown = Rect.fromLTWH(c.dx - r * 0.45, brimY - r * 0.75, r * 0.9, r * 0.75);
    canvas.drawRect(crown, hatPaint);
    canvas.drawRect(
      Rect.fromLTWH(crown.left, brimY - r * 0.22, crown.width, r * 0.12),
      bandPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(c.dx, brimY), width: r * 1.5, height: r * 0.14),
        Radius.circular(r * 0.07),
      ),
      hatPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.eyeSize != eyeSize ||
        oldDelegate.eyeGap != eyeGap ||
        oldDelegate.showBlush != showBlush ||
        oldDelegate.showHat != showHat ||
        oldDelegate.winking != winking ||
        oldDelegate.faceStyle != faceStyle;
  }
}
