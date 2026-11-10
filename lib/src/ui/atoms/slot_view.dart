import 'dart:math';

import 'package:flutter/material.dart';

import 'colors.dart';

/// An empty place on the table: the stock when it has dealt everything, or a
/// nest waiting for a complete sequence.
class SlotView extends StatelessWidget {
  const SlotView.stock({super.key}) : isNest = false;
  const SlotView.nest({super.key}) : isNest = true;

  final bool isNest;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const CustomPaint(painter: _SlotPainter()),
      if (isNest)
        Align(
          alignment: const Alignment(0, .3),
          child: FractionallySizedBox(
            widthFactor: .84,
            child: Opacity(
              opacity: .92,
              child: Image.asset(
                'assets/slots/nest.png',
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
    ],
  );
}

class _SlotPainter extends CustomPainter {
  const _SlotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(1),
      Radius.circular(size.width * .07),
    );
    canvas.drawRRect(shape, Paint()..color = const Color(0x24000000));
    canvas.drawRRect(
      shape,
      Paint()
        ..color = PsitoColors.feltLight.withValues(alpha: .7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.2, size.width * .014),
    );
  }

  @override
  bool shouldRepaint(_SlotPainter old) => false;
}
