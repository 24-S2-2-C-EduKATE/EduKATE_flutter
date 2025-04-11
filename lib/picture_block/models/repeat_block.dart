import 'package:flutter/material.dart';
import 'block_data.dart';
import 'connection_point.dart';
import '../interaction/block_sequence.dart';

class RepeatBlock extends BlockData {
  final int repeatCount;
  final BlockSequence nestedSequence;

  RepeatBlock({
    required this.repeatCount,
    required String name,
    required String imagePath,
    required Offset position,
    required this.nestedSequence,
  })  : assert(repeatCount > 0, "repeatCount 必須大於 0"),
        super(
          name: name,
          blockShape: Shape.action,
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
}