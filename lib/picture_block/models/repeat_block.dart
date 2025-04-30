import 'package:flutter/material.dart';
import 'block_data.dart';
import 'connection_point.dart';
import '../interaction/block_sequence.dart';

class RepeatBlock extends BlockData {
  late final int repeatCount;
  final BlockSequence nestedSequence;
  List<BlockData> nestedBlocks = [];

  RepeatBlock({
    required this.repeatCount,
    required String name,
    required String imagePath,
    required Offset position,
    required this.nestedSequence,
  })  : assert(repeatCount > 0, "repeatCount 必須大於 0"),
        super(
          name: name,
          blockShape: Shape.control2,
          imagePath: imagePath,
          position: position,
          connectionPoints: [
            // 假設左側為上一個區塊連接點
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32)),
            // 假設右側為下一個區塊連接點
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32)),
            // 假設下半部為子區塊連接點
            ConnectionPoint(type: ConnectionType.input, relativeOffset: Offset(32, 0)),
          ],
        );

  @override
  String toCommand() {
    return "REPEAT:$repeatCount[${nestedSequence.toCommand()}]";
  }

  // 添加子积木
  void addNestedBlock(BlockData block) {
    nestedBlocks.add(block);
  }

  // 移除子积木
  void removeNestedBlock(BlockData block) {
    nestedBlocks.remove(block);
  }

  // 获取 repeat 积木的宽度
  double getWidth() {
    double baseWidth = 65; // 基础宽度
    double nestedBlockWidth = nestedBlocks.length * 65; // 子积木总宽度
    return baseWidth + nestedBlockWidth;
  }
}

// 拼图形状的 CustomPainter（RepeatBlock 背景）
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

    // 绘制
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}