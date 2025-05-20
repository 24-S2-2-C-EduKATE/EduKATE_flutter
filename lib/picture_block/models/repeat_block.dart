// picture_block/models/repeat_block.dart
import 'package:flutter/material.dart';
import 'block_data.dart';
import 'connection_point.dart';
import '../interaction/block_sequence.dart';

class RepeatBlock extends BlockData {
  // Define fixed geometric properties of the repeat block's appearance
  static const double leftArmWidth = 25.0;
  static const double rightArmWidth = 25.0;
  static const double repeatCountFieldWidth = 45.0;
  static const double minNestedAreaWidth = 50.0;
  static const double blockContentHeight = 80.0; // Height for the nested blocks + text field row
  static const double armThickness = 25.0; // Thickness of top/bottom C-arms

  int repeatCount; // Modifiable
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
          connectionPoints: [], // Initialize empty, will be set below
        ) {
    // Dynamically set connection points
    _updateConnectionPoints();
  }

  // Helper to update connection points, useful if dimensions could ever change post-construction
  void _updateConnectionPoints() {
    double currentWidth = getWidth();
    double currentHeight = getHeight();
    double connectionY = currentHeight / 2; // Vertically centered

    connectionPoints = [
      ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, connectionY)),
      ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(currentWidth, connectionY)),
      // Input connection point for the nested area (conceptually)
      ConnectionPoint(
        type: ConnectionType.input,
        relativeOffset: Offset(leftArmWidth + (currentWidth - leftArmWidth - rightArmWidth - repeatCountFieldWidth) / 2, connectionY)
      ),
    ];
  }

  @override
  String toCommand() {
    return "REPEAT:$repeatCount[${nestedSequence.toCommand()}]";
  }

  // Calculate the total width of the repeat block
  @override
  double getWidth() {
    double nestedBlockContentWidth = nestedSequence.blocks.isNotEmpty
        ? nestedSequence.length * 65.0 // Standard width of a block
        : minNestedAreaWidth;
    return leftArmWidth + nestedBlockContentWidth + repeatCountFieldWidth + rightArmWidth;
  }

  // Define the total height of the repeat block
  double getHeight() {
    return armThickness + blockContentHeight + armThickness; // Top arm + content area + bottom arm
  }

  // Call this if nestedSequence changes, to update connection points if width changes
  void nestedSequenceChanged() {
    _updateConnectionPoints();
  }
}

// CustomPainter for puzzle-shaped block background (RepeatBlock)
class PuzzlePainter extends CustomPainter {
  final Color color;

  PuzzlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    const double cornerRadius = 15.0;

    // Path logic for C-shape (simplified for brevity, use robust logic from previous step if needed)
    // This simplified version just draws a rounded rect;
    // For the actual C-shape, the complex path generation is required.
    // Assuming the complex path from the prior step is implicitly here for the C-shape.

    // Outer C-shape structure
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0); // Top-left outer

    // Top edge of left arm
    path.lineTo(RepeatBlock.leftArmWidth - cornerRadius, 0);
    path.quadraticBezierTo(RepeatBlock.leftArmWidth, 0, RepeatBlock.leftArmWidth, cornerRadius); // Curve into inner top of left arm
    path.lineTo(RepeatBlock.leftArmWidth, RepeatBlock.armThickness - cornerRadius); // Inner side of top-left arm
    path.quadraticBezierTo(RepeatBlock.leftArmWidth, RepeatBlock.armThickness, RepeatBlock.leftArmWidth + cornerRadius, RepeatBlock.armThickness); // Curve to mouth top

    // Mouth top edge
    double mouthRightX = size.width - RepeatBlock.rightArmWidth;
    path.lineTo(mouthRightX - cornerRadius, RepeatBlock.armThickness);
    path.quadraticBezierTo(mouthRightX, RepeatBlock.armThickness, mouthRightX, RepeatBlock.armThickness + cornerRadius); // Curve to inner top of right arm
    path.lineTo(mouthRightX, cornerRadius); // Inner side of top-right arm
    path.quadraticBezierTo(mouthRightX, 0, mouthRightX + cornerRadius, 0); // Curve to top edge of right arm

    path.lineTo(size.width - cornerRadius, 0); // Top edge
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius); // Top-right outer
    path.lineTo(size.width, size.height - cornerRadius); // Right edge
    path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height); // Bottom-right outer

    // Bottom edge of right arm
    path.lineTo(mouthRightX + cornerRadius, size.height);
    path.quadraticBezierTo(mouthRightX, size.height, mouthRightX, size.height - cornerRadius); // Curve into inner bottom of right arm
    path.lineTo(mouthRightX, size.height - RepeatBlock.armThickness + cornerRadius); // Inner side of bottom-right arm
    path.quadraticBezierTo(mouthRightX, size.height - RepeatBlock.armThickness, mouthRightX - cornerRadius, size.height - RepeatBlock.armThickness); // Curve to mouth bottom

    // Mouth bottom edge
    path.lineTo(RepeatBlock.leftArmWidth + cornerRadius, size.height - RepeatBlock.armThickness);
    path.quadraticBezierTo(RepeatBlock.leftArmWidth, size.height - RepeatBlock.armThickness, RepeatBlock.leftArmWidth, size.height - RepeatBlock.armThickness - cornerRadius); // Curve to inner bottom of left arm
    path.lineTo(RepeatBlock.leftArmWidth, size.height - cornerRadius); // Inner side of bottom-left arm
    path.quadraticBezierTo(RepeatBlock.leftArmWidth, size.height, RepeatBlock.leftArmWidth - cornerRadius, size.height); // Curve to bottom edge of left arm

    path.lineTo(cornerRadius, size.height); // Bottom edge
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius); // Bottom-left outer
    path.close(); // Close path

    canvas.drawPath(path, paint);

    // Right protrusion (visual part of right arm connection)
    final double notchRectH = size.height * 0.25; // Example, adjust as needed
    final double notchTop = (size.height - notchRectH) / 2;
    final double notchOvalW = 13;
    final double notchOvalH = notchRectH + 5;

    Paint protrusionPaint = Paint()..color = paint.color;
    canvas.drawRect(Rect.fromLTWH(size.width, notchTop, 6, notchRectH), protrusionPaint);
    canvas.drawOval(
      Rect.fromLTWH(size.width + 3.55, notchTop - 2.5, notchOvalW, notchOvalH),
      protrusionPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}