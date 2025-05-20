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
            // Assume the left side is the previous block connection point - precisely positioned
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32.5)),
            // Assume the right side is the next block connection point - precisely positioned
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
          ],
        );

  @override
  String toCommand() {
    return "ACTION:$name" + (customization != null ? "(${customization!.toCommand()})" : "");
  }
}