import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'connection_point.dart';

enum Shape {
  virtual,
  event1,
  event2,
  action,
  variable1,
  control,
  sound,
  variable2,
  repeat
  // another shape
}

abstract class BlockData {
  final String id; 
  final String name;
  final Shape blockShape;
  final String imagePath;
  Offset position;
  // 每個區塊可定義多個連接點
  List<ConnectionPoint> connectionPoints;

  BlockData({
    required this.name,
    required this.blockShape,
    required this.imagePath,
    required this.position,
    required this.connectionPoints,
  }): id = Uuid().v4();

  String toCommand();
}