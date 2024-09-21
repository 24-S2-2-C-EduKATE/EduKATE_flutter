import 'package:flutter/material.dart';

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
  String imagePath;
  Offset position;
  Map<ConnectionType, Connection> connections = {};

  BlockData({
    required this.imagePath,
    required this.position,
  });
}