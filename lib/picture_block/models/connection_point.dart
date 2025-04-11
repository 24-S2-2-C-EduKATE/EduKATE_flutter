// lib/blocks/connection_point.dart
import 'package:flutter/material.dart';
import 'block_data.dart';

enum ConnectionType {
  previous, // 用於連接前一個區塊
  next,     // 用於連接下一個區塊
  input,    // 容器區塊用以接收內部子區塊
}

class ConnectionPoint {
  final ConnectionType type;
  // 相對於區塊本身的偏移位置（例如連接點在左側、右側或底部）
  final Offset relativeOffset;
  BlockData? connectedBlock;

  ConnectionPoint({
    required this.type,
    required this.relativeOffset,
    this.connectedBlock,
  });

  /// 以區塊的全局位置換算出此連接點的全局位置
  Offset getGlobalPosition(Offset blockPosition) {
    return blockPosition + relativeOffset;
  }
}