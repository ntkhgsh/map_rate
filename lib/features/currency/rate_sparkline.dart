import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 直近レートの折れ線。一覧用の小さく薄い線と、推移画面用の塗り付きを切り替えられる。
class RateSparkline extends StatelessWidget {
  const RateSparkline({
    super.key,
    required this.values,
    this.width = 56,
    this.height = 28,
    this.filled = false,
    this.showEndDot = false,
    this.strokeWidth = 1.6,
    this.color,
  });

  final List<double> values;
  final double width;
  final double height;

  /// true のとき折れ線の下を薄く塗る（推移画面向け）
  final bool filled;

  /// true のとき最新値に丸印を付ける
  final bool showEndDot;

  final double strokeWidth;

  /// null ならテーマの primary を使う
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? Theme.of(context).colorScheme.primary;
    // シート内など親がサイズを決めるときは LayoutBuilder で広げる
    if (!width.isFinite || !height.isFinite) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(
              width.isFinite ? width : constraints.maxWidth,
              height.isFinite ? height : constraints.maxHeight,
            ),
            painter: _SparklinePainter(
              values: values,
              color: lineColor,
              filled: filled,
              showEndDot: showEndDot,
              strokeWidth: strokeWidth,
            ),
          );
        },
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: lineColor,
          filled: filled,
          showEndDot: showEndDot,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.filled,
    required this.showEndDot,
    required this.strokeWidth,
  });

  final List<double> values;
  final Color color;
  final bool filled;
  final bool showEndDot;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (values.isEmpty || values.length == 1) {
      final y = size.height / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      if (showEndDot && values.length == 1) {
        canvas.drawCircle(
          Offset(size.width, y),
          strokeWidth + 2,
          Paint()..color = color,
        );
      }
      return;
    }

    var minV = values.first;
    var maxV = values.first;
    for (final v in values) {
      if (!v.isFinite) continue;
      minV = math.min(minV, v);
      maxV = math.max(maxV, v);
    }
    final span = (maxV - minV).abs() < 1e-12 ? 1.0 : (maxV - minV);

    // 上下に少し余白を残して線が枠に張り付かないようにする
    final padY = filled ? size.height * 0.08 : 0.0;
    final usableH = (size.height - padY * 2).clamp(1.0, size.height);

    Offset pointAt(int i) {
      final x = size.width * (i / (values.length - 1));
      final norm = (values[i] - minV) / span;
      final y = padY + usableH * (1 - norm);
      return Offset(x, y);
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      final p = pointAt(i);
      path.lineTo(p.dx, p.dy);
    }

    if (filled) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.02),
            ],
          ).createShader(Offset.zero & size),
      );
    }

    canvas.drawPath(path, linePaint);

    if (showEndDot) {
      final end = pointAt(values.length - 1);
      canvas.drawCircle(
        end,
        strokeWidth + 2.5,
        Paint()..color = color,
      );
      canvas.drawCircle(
        end,
        strokeWidth,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.filled != filled ||
        oldDelegate.showEndDot != showEndDot ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
