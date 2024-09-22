import 'package:flutter/material.dart';

enum BlockType {
  event,
  action,
  sensing,
  control,
  interaction,
  variable,
  sound,
  customization,
}

enum ConnectionType {
  male,   // 凸起
  female, // 凹陷
  none,   // 无连接点（如圆角边缘）
}

enum BlockSide {
  left,
  right,
}

class ConnectionPoint {
  ConnectionType type;
  BlockSide side;
  BlockBase? connectedBlock;

  ConnectionPoint({
    required this.type,
    required this.side,
    this.connectedBlock,
  });
}

abstract class BlockBase {
  String imagePath;
  Offset position;
  BlockType blockType;
  Map<BlockSide, ConnectionPoint> connectionPoints;

  BlockBase({
    required this.imagePath,
    required this.position,
    required this.blockType,
    required this.connectionPoints,
  });

  Future<void> execute();

  // 其他通用方法，如渲染、克隆等
}