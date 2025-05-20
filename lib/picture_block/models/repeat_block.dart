import 'package:flutter/material.dart';
import 'block_data.dart';
import 'connection_point.dart';
import '../interaction/block_sequence.dart';

class RepeatBlock extends BlockData {
  late final int repeatCount;
  final BlockSequence nestedSequence;

  RepeatBlock({
    required this.repeatCount,
    required String name,
    required String imagePath,
    required Offset position,
    required this.nestedSequence,
  })  : assert(repeatCount > 0, "repeatCount must be greater than 0"),
        super(
          name: name,
          blockShape: Shape.control2,
          imagePath: imagePath,
          position: position,
          connectionPoints: [
            // Assume the left side is the connection point for the previous block
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32)),
            // Assume the right side is the connection point for the next block
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32)),
            // Assume the lower part is the connection point for nested blocks
            ConnectionPoint(type: ConnectionType.input, relativeOffset: Offset(32, 0)),
          ],
        );

  @override
  String toCommand() {
    return "REPEAT:$repeatCount[${nestedSequence.toCommand()}]";
  }

  // Get the width of the repeat block
  double getWidth() {
    double baseWidth = 65; // Base width
    double nestedBlockWidth = nestedSequence.length * 65; // Total width of nested blocks
    return baseWidth + nestedBlockWidth;
  }
}

// CustomPainter for puzzle-shaped block background (RepeatBlock)
class PuzzlePainter extends CustomPainter {
  final Color color;

  PuzzlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 248, 231, 81)
      ..style = PaintingStyle.fill;
    final path = Path();
    final double rectHeight = size.height / 4;
    final double topOffset = (size.height - rectHeight) / 2;
    final double ovalWidth = 13;
    final double ovalHeight = rectHeight + 5;
    const double cornerRadius = 20.0;

    // 1. Main body: rounded rectangle + left-side notch
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - cornerRadius, size.height);
    path.lineTo(size.width - 2 * cornerRadius, size.height);
    path.lineTo(size.width - 2 * cornerRadius, 1.5 * cornerRadius);
    path.lineTo(cornerRadius, 1.5 * cornerRadius);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    // Left-side notch
    path.lineTo(0, topOffset + rectHeight);
    path.lineTo(6, topOffset + rectHeight);
    path.lineTo(6, topOffset);
    path.lineTo(0, topOffset);
    path.close();

    // 2. Small oval inside the left-side notch
    final double ovalCenterX = 9.55;
    final double ovalCenterY = topOffset + ovalHeight / 2;
    path.moveTo(6, topOffset + rectHeight);
    path.lineTo(6, topOffset);
    path.arcTo(
      Rect.fromCenter(
          center: Offset(ovalCenterX, ovalCenterY),
          width: ovalWidth,
          height: ovalHeight),
      2.1418,
      -4.391,
      false,
    );
    path.close();

    // 3. Right-side protrusion (rectangle + oval)
    path.addRect(Rect.fromLTWH(size.width, topOffset, 6, rectHeight));
    path.addOval(Rect.fromLTWH(
      size.width + 3.55,
      topOffset - 2.5,
      ovalWidth,
      ovalHeight,
    ));

    // Draw
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
