import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../style/palette.dart';

class TerraGrid extends StatelessWidget {
  final int width;
  final int height;

  const TerraGrid(this.width, this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final lineColor = Colors.grey;

    return Stack(
      fit: StackFit.expand,
      children: [
        // First, "draw" (reveal) the horizontal lines
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _TerraGridPainter(
                width,
                height,
                lineColor: lineColor,
                paintOnly: Axis.horizontal,
              ),
            ),
          ),
          builder: (BuildContext context, double progress, Widget? child) {
            return ShaderMask(
              // BlendMode.dstIn means that opacity of the linear
              // gradient below will be applied to the child (the horizontal
              // lines).
              blendMode: BlendMode.dstIn,
              shaderCallback: (Rect bounds) {
                // A linear gradient that sweeps from
                // "top-slightly-left-off-center" to
                // "bottom-slightly-right-of-center". This achieves the
                // quick "drawing" of the lines.
                return LinearGradient(
                  begin: const Alignment(-0.1, -1),
                  end: const Alignment(0.1, 1),
                  colors: [
                    Colors.black,
                    Colors.white.withOpacity(0),
                  ],
                  stops: [
                    progress,
                    progress + 0.05,
                  ],
                ).createShader(bounds);
              },
              child: child!,
            );
          },
        ),
        // Same as above, but for vertical lines.
        TweenAnimationBuilder(
          // The tween start's with a negative number to achieve
          // a bit of delay before drawing. This is quite dirty, so maybe
          // optimize later?
          tween: Tween<double>(begin: -1, end: 1),
          // Take longer to draw.
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOut,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _TerraGridPainter(
                width,
                height,
                lineColor: lineColor,
                paintOnly: Axis.vertical,
              ),
            ),
          ),
          builder: (BuildContext context, double progress, Widget? child) {
            return ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: const Alignment(-1, -0.1),
                  end: const Alignment(1, 0.1),
                  colors: [
                    Colors.black,
                    Colors.white.withOpacity(0),
                  ],
                  stops: [
                    progress,
                    progress + 0.05,
                  ],
                ).createShader(bounds);
              },
              child: child!,
            );
          },
        ),
      ],
    );
  }
}

//class _TerraGridPainter extends CustomPainter {
//  final int width;
//  final int height;
//
//  final Color lineColor;
//
//  final Axis? paintOnly;
//
//  late final Paint pathPaint = Paint()
//    ..colorFilter = ColorFilter.mode(lineColor, BlendMode.srcIn);
//
//  _TerraGridPainter(
//    this.width,
//    this.height, {
//    this.lineColor = Colors.black,
//    this.paintOnly,
//  });
//
//  @override
//  void paint(Canvas canvas, Size size) {
//    const padding = 0.0;
//    const maxCrossDisplacement = 1.5;
//
//    const gridLineThicknessRatio = .05;
//    final lineThickness =
//        size.longestSide / max(width, height) * gridLineThicknessRatio;
//
//    final widthStep = size.width / width;
//
//    // Draw vertical lines.
//    if (paintOnly == null || paintOnly == Axis.vertical) {
//      for (var i = 0; i <= width; i++) {
//        _terraLine(
//          canvas: canvas,
//          start: Offset(i * widthStep, padding),
//          direction: Axis.vertical,
//          length: size.height - 2 * padding,
//          maxLineThickness: lineThickness,
//          maxCrossAxisDisplacement: maxCrossDisplacement,
//          paint: pathPaint,
//        );
//      }
//    }
//
//    // Draw horizontal lines.
//    final heightStep = size.height / height;
//    if (paintOnly == null || paintOnly == Axis.horizontal) {
//      for (var i = 0; i <= height; i++) {
//        _terraLine(
//          canvas: canvas,
//          start: Offset(padding, i * heightStep),
//          direction: Axis.horizontal,
//          length: size.width - 2 * padding,
//          maxLineThickness: lineThickness,
//          maxCrossAxisDisplacement: maxCrossDisplacement,
//          paint: pathPaint,
//        );
//      }
//    }
//  }
//
//  @override
//  bool shouldRepaint(_TerraGridPainter oldDelegate) {
//    return oldDelegate.width != width ||
//        oldDelegate.height != height ||
//        oldDelegate.paintOnly != paintOnly ||
//        oldDelegate.lineColor != lineColor;
//  }
//
//  static void _terraLine({
//    required Canvas canvas,
//    required Offset start,
//    required Axis direction,
//    required double length,
//    required double maxLineThickness,
//    required double maxCrossAxisDisplacement,
//    required Paint paint,
//  }) {
//    final Offset end = (direction == Axis.horizontal)
//        ? start + Offset(length, 0)
//        : start + Offset(0, length);
//
//    paint.strokeWidth = maxLineThickness;
//    paint.strokeCap = StrokeCap.round;
//
//    canvas.drawLine(start, end, paint);
//  }
//}

class _TerraGridPainter extends CustomPainter {
  final int width;
  final int height;
  final Color lineColor;
  final Axis? paintOnly;

  _TerraGridPainter(this.width, this.height,
      {this.lineColor = Colors.black, this.paintOnly});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0;

    final widthStep = size.width / width;
    final heightStep = size.height / height;

    if (paintOnly == null || paintOnly == Axis.vertical) {
      // Draw vertical lines
      for (var i = 0; i <= width; i++) {
        final x = i * widthStep;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    if (paintOnly == null || paintOnly == Axis.horizontal) {
      // Draw horizontal lines
      for (var i = 0; i <= height; i++) {
        final y = i * heightStep;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_TerraGridPainter oldDelegate) {
    return oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.paintOnly != paintOnly;
  }
}
