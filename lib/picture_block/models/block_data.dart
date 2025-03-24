import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
enum ConnectionType {
  left,
  right,
}

enum Shape {
  virtual,
  event1,
  event2,
  action,
  variable1,
  control,
  sound,
  variable2
  // another shape
}

class Connection {
  ConnectionType type;
  BlockData? connectedBlock;

  Connection({required this.type, this.connectedBlock});
}

class BlockData {
  final Shape blockShape;
  String id; 
  String imagePath;
  Offset position;
  Map<ConnectionType, Connection> connections = {};

  BlockData({
    required this.blockShape,
    required this.imagePath,
    required this.position,
  }): id = Uuid().v4();
}