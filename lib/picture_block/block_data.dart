import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
enum ConnectionType {
  top,
  bottom,
  left,
  right,
}

class Connection {
  ConnectionType type;
  BlockData? connectedBlock;

  Connection({required this.type, this.connectedBlock});
}

class BlockData {
  String id; 
  String imagePath;
  Offset position;
  double width;  // 添加宽度
  double height; // 添加高度
  Map<ConnectionType, Connection> connections = {};

  BlockData({
    required this.imagePath,
    required this.position,
    required this.width,  // 添加宽度参数
    required this.height,
  }): id = Uuid().v4();
}