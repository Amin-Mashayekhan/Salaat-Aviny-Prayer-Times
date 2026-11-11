import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colours of the compass drawing (taken from the theme by the page).
@immutable
class CompassColors {
  /// Creates the colours.
  const CompassColors({
    required this.face,
    required this.ring,
    required this.tick,
    required this.label,
    required this.north,
    required this.qibla,
    required this.sun,
  });

  /// Background disc.
  final Color face;

  /// Outer ring.
  final Color ring;

  /// Tick marks.
  final Color tick;

  /// N, E, S, W letters.
  final Color label;

  /// North marker.
  final Color north;

  /// Qibla line and Kaaba marker.
  final Color qibla;

  /// Sun marker.
  final Color sun;

  @override
  bool operator ==(Object other) =>
      other is CompassColors &&
      other.face == face &&
      other.ring == ring &&
      other.tick == tick &&
      other.label == label &&
      other.north == north &&
      other.qibla == qibla &&
      other.sun == sun;

  @override
  int get hashCode => Object.hash(face, ring, tick, label, north, qibla, sun);
}

/// Draws the compass rose: ticks every 5 degrees, the four cardinal points
/// in the current language, a line to the qibla bearing ending in a Kaaba
/// marker, and the sun at its azimuth (only while it is above the horizon).
///
/// North is always at the top: a PC has no compass, so the drawing is
/// relative to true north.
class QiblaCompassPainter extends CustomPainter {
  /// Creates the painter.
  ///
  /// [cardinals] are the labels of north, east, south and west, in that
  /// order. [sunAzimuth] is null when the sun is below the horizon.
  QiblaCompassPainter({
    required this.qiblaBearing,
    required this.sunAzimuth,
    required this.cardinals,
    required this.colors,
    required this.textDirection,
    required this.textScaler,
    this.fontFamily,
  }) : assert(cardinals.length == 4, 'north, east, south, west');

  /// Qibla bearing, degrees clockwise from north.
  final double qiblaBearing;

  /// Sun azimuth in degrees, or null when the sun is not shown.
  final double? sunAzimuth;

  /// Labels of N, E, S, W.
  final List<String> cardinals;

  /// Colours.
  final CompassColors colors;

  /// Direction used to lay out the letters.
  final TextDirection textDirection;

  /// Text scale of the surrounding UI.
  final TextScaler textScaler;

  /// Font of the letters.
  final String? fontFamily;

  static Offset _point(Offset center, double radius, double bearing) {
    final angle = bearing * math.pi / 180;
    return Offset(
      center.dx + radius * math.sin(angle),
      center.dy - radius * math.cos(angle),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 4;
    if (radius <= 0) return;

    canvas
      ..drawCircle(center, radius, Paint()..color = colors.face)
      ..drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = colors.ring,
      );

    // Ticks every 5 degrees; longer every 15 and 45.
    final tick = Paint()
      ..strokeCap = StrokeCap.round
      ..color = colors.tick;
    for (var degrees = 0; degrees < 360; degrees += 5) {
      final length = degrees % 45 == 0
          ? radius * 0.09
          : degrees % 15 == 0
          ? radius * 0.06
          : radius * 0.03;
      tick.strokeWidth = degrees % 45 == 0 ? 2.4 : 1.2;
      canvas.drawLine(
        _point(center, radius - 2, degrees.toDouble()),
        _point(center, radius - 2 - length, degrees.toDouble()),
        tick,
      );
    }

    // North marker: a small triangle on the ring.
    final north = Path()
      ..moveTo(center.dx, center.dy - radius - 2)
      ..lineTo(center.dx - radius * 0.045, center.dy - radius + radius * 0.08)
      ..lineTo(center.dx + radius * 0.045, center.dy - radius + radius * 0.08)
      ..close();
    canvas.drawPath(north, Paint()..color = colors.north);

    // Cardinal letters.
    final fontSize = math.min(textScaler.scale(15), radius * 0.15);
    for (var i = 0; i < 4; i++) {
      _text(
        canvas,
        cardinals[i],
        _point(center, radius * 0.76, i * 90.0),
        TextStyle(
          color: i == 0 ? colors.north : colors.label,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
        ),
      );
    }

    // The sun, on a ring inside the letters, with short rays.
    final sun = sunAzimuth;
    if (sun != null) {
      final at = _point(center, radius * 0.56, sun);
      final body = radius * 0.05;
      final ray = Paint()
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = colors.sun;
      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        canvas.drawLine(
          at + Offset(math.cos(angle), math.sin(angle)) * (body * 1.5),
          at + Offset(math.cos(angle), math.sin(angle)) * (body * 2.3),
          ray,
        );
      }
      canvas.drawCircle(at, body, Paint()..color = colors.sun);
    }

    // The qibla: a thick line from the centre to the ring, an arrow head
    // and the Kaaba (a dark square with a gold band) at the tip.
    final line = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = colors.qibla;
    final tip = _point(center, radius * 0.86, qiblaBearing);
    canvas.drawLine(center, tip, line);
    final kaaba = Rect.fromCenter(
      center: _point(center, radius * 0.92, qiblaBearing),
      width: radius * 0.14,
      height: radius * 0.14,
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(kaaba, Radius.circular(radius * 0.02)),
        Paint()..color = colors.qibla,
      )
      ..drawRect(
        Rect.fromLTWH(
          kaaba.left,
          kaaba.top + kaaba.height * 0.25,
          kaaba.width,
          kaaba.height * 0.18,
        ),
        Paint()..color = colors.face,
      )
      ..drawCircle(center, radius * 0.04, Paint()..color = colors.qibla);
  }

  void _text(Canvas canvas, String text, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: 1,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
    painter.dispose();
  }

  @override
  bool shouldRepaint(QiblaCompassPainter old) =>
      old.qiblaBearing != qiblaBearing ||
      old.sunAzimuth != sunAzimuth ||
      old.colors != colors ||
      old.textDirection != textDirection ||
      old.textScaler != textScaler ||
      old.fontFamily != fontFamily ||
      old.cardinals.join('|') != cardinals.join('|');
}
