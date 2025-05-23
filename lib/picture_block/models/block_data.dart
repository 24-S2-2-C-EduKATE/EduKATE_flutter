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
  control2,
  sound,
  variable2
  // another shape
}

abstract class BlockData {
  final String id; 
  final String name;
  final Shape blockShape;
  final String imagePath;
  Offset position;
  // Each block can define multiple connection points
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