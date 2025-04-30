import 'dart:ui';  
import 'package:flutter/material.dart';  
import 'package:flutter_application_1/picture_block/models/block_data.dart';  

class BlockShapePainter extends CustomPainter {  // CustomPainter class for drawing shapes.
  final BlockData blockData;  

  BlockShapePainter(this.blockData);  

  @override
  void paint(Canvas canvas, Size size) {  // Method to draw the custom shape on the canvas.
    Paint paint = Paint()  // Paint object for filling shapes.
      ..style = PaintingStyle.fill;  // Set to fill the shapes.

    Path path = Path();  // Path object for defining shape outlines.
    double rectHeight = size.height * 1 / 4;  // Define the height of the rectangle inside the shape.
    double topOffset = (size.height - rectHeight) / 2;  // Offset from the top to vertically center the rectangle.
    double ovalWidth = 13;  // Width of the oval shape.
    double ovalHeight = rectHeight + 5;  // Height of the oval shape.
    double cornerRadius = 20.0;  // Corner radius for rounded shapes.

    if (blockData.blockShape == Shape.virtual) {  // Condition for drawing 'virtual' shaped block.
      paint.color = const Color.fromARGB(255, 248, 231, 81);  // Set the color to yellow.
      path.moveTo(0, cornerRadius);  // Start path at the top-left corner with a rounded corner.
      path.quadraticBezierTo(0, 0, cornerRadius, 0);  // Draw top-left rounded corner.
      path.lineTo(size.width - cornerRadius, 0);  // Draw top edge.
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);  // Draw top-right rounded corner.
      path.lineTo(size.width, size.height - cornerRadius);  // Draw right edge.
      path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);  // Draw bottom-right rounded corner.
      path.lineTo(cornerRadius, size.height);  // Draw bottom edge.
      path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);  // Draw bottom-left rounded corner.

      path.lineTo(0, topOffset + rectHeight);  // Draw left vertical line down to rectangle height.
      path.lineTo(6, topOffset + rectHeight);  // Draw small horizontal line.
      path.lineTo(6, topOffset);  // Draw vertical line upwards.
      path.lineTo(0, topOffset);  // Close the left side of the path.
      path.close();

      path.moveTo(6, topOffset + rectHeight);  // Move the path to start drawing the oval inside the shape.
      path.lineTo(6, 32.5);  // Draw vertical line to the start of the oval.

      path.arcTo(  // Draw the oval shape.
        Rect.fromCenter(center: Offset(9.55, 32.5), width: 13, height: ovalHeight),
        2.1418,
        -4.391,
        false,
      );

      path.lineTo(6, topOffset);  // Complete the path for the oval.
      path.close();

      path.addRect(Rect.fromLTWH(size.width, (size.height - size.height * 1 / 4) / 2, 6, size.height * 1 / 4));  // Add additional rectangle on the right.

      path.addOval(Rect.fromLTWH(  // Add an oval on the right side.
        size.width + 3.55,
        topOffset - 2.5,
        ovalWidth,
        ovalHeight
      ));

    } else if (blockData.blockShape == Shape.action) {  // Condition for drawing 'action' shaped block.
      paint.color = const Color.fromARGB(255, 189, 149, 228);  // Set color for 'action' block.
      path.moveTo(0, cornerRadius);  // Start path at the top-left corner with a rounded corner.
      path.quadraticBezierTo(0, 0, cornerRadius, 0);  // Draw top-left rounded corner.
      path.lineTo(size.width - cornerRadius, 0);  // Draw top edge.
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);  // Draw top-right rounded corner.
      path.lineTo(size.width, size.height - cornerRadius);  // Draw right edge.
      path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);  // Draw bottom-right rounded corner.
      path.lineTo(cornerRadius, size.height);  // Draw bottom edge.
      path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);  // Draw bottom-left rounded corner.

      path.lineTo(0, topOffset + rectHeight);  // Draw left vertical line down to rectangle height.
      path.lineTo(6, topOffset + rectHeight);  // Draw small horizontal line.
      path.lineTo(6, topOffset);  // Draw vertical line upwards.
      path.lineTo(0, topOffset);  // Close the left side of the path.
      path.close();

      path.moveTo(6, topOffset + rectHeight);  // Move the path to start drawing the oval inside the shape.
      path.lineTo(6, 32.5);  // Draw vertical line to the start of the oval.

      path.arcTo(  // Draw the oval shape.
        Rect.fromCenter(center: Offset(9.55, 32.5), width: 13, height: ovalHeight),
        2.1418,
        -4.391,
        false,
      );

      path.lineTo(6, topOffset);  // Complete the path for the oval.
      path.close();

      path.addRect(Rect.fromLTWH(size.width, (size.height - size.height * 1 / 4) / 2, 6, size.height * 1 / 4));  // Add additional rectangle on the right.

      path.addOval(Rect.fromLTWH(  // Add an oval on the right side.
        size.width + 3.55,
        topOffset - 2.5,
        ovalWidth,
        ovalHeight
      ));
      
    } else if (blockData.blockShape == Shape.event1) {  // Condition for drawing 'event1' shaped block.
      paint.color = Colors.orange;  // Set color for 'event1' block.

      // Start from the top-left point of the half-circle
      path.moveTo(0, cornerRadius);  // Start at the top-left corner.
      // Draw a complete half-circle on the left side
      path.arcTo(
       Rect.fromCircle(center: Offset(30, size.height / 2), radius: size.height/2),  // Define the bounding box for the half-circle
       -1.5 * 3.14,  // Start the arc from the top (-90 degrees in radians)
       3.14,  // Sweep the arc 180 degrees (half-circle)
       false,  // Don't force moveTo to the arc start point
        );

      path.lineTo(size.width - cornerRadius, 0);  // Draw top edge.
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);  // Draw top-right rounded corner.
      path.lineTo(size.width, size.height - cornerRadius);  // Draw right edge.
      path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);  // Draw bottom-right rounded corner.
      path.lineTo(30, size.height);  // Draw bottom edge.
      path.quadraticBezierTo(15, size.height, 0, size.height - cornerRadius);  // Draw bottom-left rounded corner to complete the path.
      path.close();

      path.addRect(Rect.fromLTWH(size.width, (size.height - size.height * 1 / 4) / 2, 6, size.height * 1 / 4));

      path.addOval(Rect.fromLTWH(
        size.width + 3.55,
        topOffset - 2.5,
        ovalWidth,
        ovalHeight
      ));
      
    } else if (blockData.blockShape == Shape.event2) {  // Condition for drawing 'event2' shaped block.
      paint.color = const Color.fromARGB(255, 249, 123, 165);  // Set color for 'event2' block.
      path.moveTo(0, cornerRadius);  // Start at the top-left corner.
      // Draw a complete half-circle on the left side
      path.arcTo(
       Rect.fromCircle(center: Offset(30, size.height / 2), radius: size.height/2),  // Define the bounding box for the half-circle
       -1.5 * 3.14,  // Start the arc from the top (-90 degrees in radians)
       3.14,  // Sweep the arc 180 degrees (half-circle)
       false,  // Don't force moveTo to the arc start point
        );

      path.lineTo(size.width - cornerRadius, 0);  // Draw top edge.
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);  // Draw top-right rounded corner.
      path.lineTo(size.width, size.height - cornerRadius);  // Draw right edge.
      path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);  // Draw bottom-right rounded corner.
      path.lineTo(30, size.height);  // Draw bottom edge.
      path.quadraticBezierTo(15, size.height, 0, size.height - cornerRadius);  // Draw bottom-left rounded corner to complete the path.
      path.close();

      path.addRect(Rect.fromLTWH(size.width, (size.height - size.height * 1 / 4) / 2, 6, size.height * 1 / 4));

      path.addOval(Rect.fromLTWH(
        size.width + 3.55,
        topOffset - 2.5,
        ovalWidth,
        ovalHeight
      ));
      
    } else if (blockData.blockShape == Shape.variable1) {  // Condition for drawing 'variable1' shaped block.
      paint.color = const Color.fromARGB(255, 137, 232, 175);  // Set color for 'variable1' block.
      path.moveTo(0, cornerRadius);  // Start drawing the block.
      // Shape drawing logic for 'variable1'.
      path.quadraticBezierTo(0, 0, cornerRadius, 0);  // Draw top-left rounded corner.
      path.lineTo(size.width - cornerRadius, 0);  // Draw top edge.
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);  // Draw top-right rounded corner.
      path.lineTo(size.width, size.height - cornerRadius);  // Draw right edge.
      path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);  // Draw bottom-right rounded corner.
      path.lineTo(cornerRadius, size.height);  // Draw bottom edge.
      path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);  // Draw bottom-left rounded corner.

      path.lineTo(0, topOffset + rectHeight);  // Draw left vertical line down to rectangle height.
      path.lineTo(6, topOffset + rectHeight);  // Draw small horizontal line.
      path.lineTo(6, topOffset);  // Draw vertical line upwards.
      path.lineTo(0, topOffset);  // Close the left side of the path.
      path.close();

      path.moveTo(6, topOffset + rectHeight);  // Move the path to start drawing the oval inside the shape.
      path.lineTo(6, 32.5);  // Draw vertical line to the start of the oval.

      path.arcTo(  // Draw the oval shape.
        Rect.fromCenter(center: Offset(9.55, 32.5), width: 13, height: ovalHeight),
        2.1418,
        -4.391,
        false,
      );

      path.lineTo(6, topOffset);  // Complete the path for the oval.
      path.close();

      path.addRect(Rect.fromLTWH(size.width, (size.height - size.height * 1 / 4) / 2, 6, size.height * 1 / 4));  // Add additional rectangle on the right.

      path.addOval(Rect.fromLTWH(  // Add an oval on the right side.
        size.width + 3.55,
        topOffset - 2.5,
        ovalWidth,
        ovalHeight
      ));
      
    } else if (blockData.blockShape == Shape.variable2) {  // Condition for drawing 'variable2' shaped block.
      paint.color = const Color.fromARGB(255, 89, 189, 126);  // Set color for 'variable2' block.
      path.moveTo(0, cornerRadius);
      path.quadraticBezierTo(0, 0, cornerRadius, 0);
      path.lineTo(size.width - cornerRadius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
      path.lineTo(size.width, size.height - cornerRadius);
      path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
      path.lineTo(cornerRadius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
      
    } else if (blockData.blockShape == Shape.control) {  // Condition for drawing 'control' shaped block.
      paint.color = const Color.fromARGB(255, 247, 139, 146);  // Set color for 'control' block.
      path.moveTo(0, cornerRadius);  // Start drawing the block.
      // Shape drawing logic for 'control'.
      path.quadraticBezierTo(0, 0, cornerRadius, 0);  // Draw top-left rounded corner.
      path.lineTo(size.width - cornerRadius, 0);  // Draw top edge.
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);  // Draw top-right rounded corner.
      path.lineTo(size.width, size.height - cornerRadius);  // Draw right edge.
      path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);  // Draw bottom-right rounded corner.
      path.lineTo(cornerRadius, size.height);  // Draw bottom edge.
      path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);  // Draw bottom-left rounded corner.

      path.lineTo(0, topOffset + rectHeight);  // Draw left vertical line down to rectangle height.
      path.lineTo(6, topOffset + rectHeight);  // Draw small horizontal line.
      path.lineTo(6, topOffset);  // Draw vertical line upwards.
      path.lineTo(0, topOffset);  // Close the left side of the path.
      path.close();

      path.moveTo(6, topOffset + rectHeight);  // Move the path to start drawing the oval inside the shape.
      path.lineTo(6, 32.5);  // Draw vertical line to the start of the oval.

      path.arcTo(  // Draw the oval shape.
        Rect.fromCenter(center: Offset(9.55, 32.5), width: 13, height: ovalHeight),
        2.1418,
        -4.391,
        false,
      );

      path.lineTo(6, topOffset);  // Complete the path for the oval.
      path.close();

      path.addRect(Rect.fromLTWH(size.width, (size.height - size.height * 1 / 4) / 2, 6, size.height * 1 / 4));  // Add additional rectangle on the right.

      path.addOval(Rect.fromLTWH(  // Add an oval on the right side.
        size.width + 3.55,
        topOffset - 2.5,
        ovalWidth,
        ovalHeight
      ));
    }else if (blockData.blockShape == Shape.control2) {  // Condition for drawing 'control' shaped block.
      paint.color = const Color.fromARGB(255, 247, 139, 146);  // Set color for 'control' block.
      // 1. 主体：圆角矩形 + 左侧凹槽
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
    // 左侧凹槽
    path.lineTo(0, topOffset + rectHeight);
    path.lineTo(6, topOffset + rectHeight);
    path.lineTo(6, topOffset);
    path.lineTo(0, topOffset);
    path.close();

    // 2. 左侧凹槽内的小椭圆
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

    // 3. 右侧凸台（矩形 + 椭圆）
    path.addRect(Rect.fromLTWH(size.width, topOffset, 6, rectHeight));
    path.addOval(Rect.fromLTWH(
      size.width + 3.55,
      topOffset - 2.5,
      ovalWidth,
      ovalHeight,
    ));
    }
    canvas.drawPath(path, paint);  // Draw the path on the canvas with the selected paint.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {  // Method to determine whether to repaint the shape.
    return false;  // No need to repaint unless the shape data changes.
  }
}
