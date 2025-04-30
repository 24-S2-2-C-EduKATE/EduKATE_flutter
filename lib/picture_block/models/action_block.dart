// lib/blocks/action_block.dart
import 'package:flutter/material.dart';
import 'block_data.dart';
import 'connection_point.dart';

class ActionBlock extends BlockData {

  BlockData? customization;

  ActionBlock({
    required String name,
    required String imagePath,
    required Offset position,
    
  }) : super(
          name: name, 
          blockShape: Shape.action, 
          imagePath: imagePath, 
          position: position,
          connectionPoints: [
            // 假設左側為上一個區塊連接點 - 精確定位
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32.5)),
            // 假設右側為下一個區塊連接點 - 精確定位
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
          ],
        );

  @override
  String toCommand() {
    return "ACTION:$name" + (customization != null ? "(${customization!.toCommand()})" : "");
  }
}