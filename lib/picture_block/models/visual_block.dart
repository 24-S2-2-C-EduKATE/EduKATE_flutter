// lib/blocks/visual_block.dart
import 'package:flutter/material.dart';
import 'block_data.dart';
import 'connection_point.dart';

class VisualBlock extends BlockData {
  VisualBlock({
    required String name,
    required Shape blockShape,
    required String imagePath,
    required Offset position,
    List<ConnectionPoint>? connectionPoints,
  }) : super(
          name: name,
          blockShape: blockShape,
          imagePath: imagePath,
          position: position,
          connectionPoints: connectionPoints ?? [],
        );

  @override
  String toCommand() {

    return "$name command";
  }
}