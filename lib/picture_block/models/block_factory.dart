// lib/factories/block_factory.dart
import 'package:flutter/material.dart';
import 'block_data.dart';
import 'action_block.dart';
import 'event_block.dart';
import 'visual_block.dart';
import 'connection_point.dart';
import 'package:flutter_application_1/picture_block/models/block_with_image.dart';

/// 根據傳入的 [BlockWithImage] 建立具體的 [BlockData] 實例，並使用給定的位置作為初始位置。
BlockData createBlockFromData(BlockWithImage data, Offset position) {
  switch (data.shape) {
    case Shape.event1:
      return EventBlock(
        
        name: data.name,
        imagePath: data.imagePath,
        position: position,
      );
    case Shape.event2:
      return EventBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
      );
    case Shape.action:
      return ActionBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
      );
    case Shape.virtual:
      return VirtualBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
      );
    case Shape.variable1:
      return VariableBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
        isVariable2: false,
      );
    case Shape.variable2:
      return VariableBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
        isVariable2: true,
      );
    case Shape.control:
      return ControlBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
      );
    case Shape.sound:
      return SoundBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
      );
    default:
      print('警告：未处理的形状类型 ${data.shape}');
      // 如果沒有對應類型，就回傳一個預設的 ActionBlock
      return ActionBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
      );
  }
}

/// 虚拟方块类
class VirtualBlock extends BlockData {
  VirtualBlock({
    required String name,
    required String imagePath,
    required Offset position,
  }) : super(
          name: name,
          blockShape: Shape.virtual,
          imagePath: imagePath,
          position: position,
          connectionPoints: [
            // 虚拟方块的连接点 - 精确定位
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32.5)),
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
          ],
        );

  @override
  String toCommand() {
    return "VIRTUAL:$name";
  }
}

/// 变量方块类
class VariableBlock extends BlockData {
  final bool isVariable2;

  VariableBlock({
    required String name,
    required String imagePath,
    required Offset position,
    required this.isVariable2,
  }) : super(
          name: name,
          blockShape: isVariable2 ? Shape.variable2 : Shape.variable1,
          imagePath: imagePath,
          position: position,
          connectionPoints: [
            // 变量方块的连接点 - 精确定位
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32.5)),
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
          ],
        );

  @override
  String toCommand() {
    return "VARIABLE:$name";
  }
}

/// 控制方块类
class ControlBlock extends BlockData {
  ControlBlock({
    required String name,
    required String imagePath,
    required Offset position,
  }) : super(
          name: name,
          blockShape: Shape.control,
          imagePath: imagePath,
          position: position,
          connectionPoints: [
            // 控制方块的连接点 - 精确定位
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32.5)),
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
            // 控制方块可能需要额外的input连接点用于嵌套内容
            ConnectionPoint(type: ConnectionType.input, relativeOffset: Offset(32.5, 65)),
          ],
        );

  @override
  String toCommand() {
    return "CONTROL:$name";
  }
}

/// 声音方块类
class SoundBlock extends BlockData {
  SoundBlock({
    required String name,
    required String imagePath,
    required Offset position,
  }) : super(
          name: name,
          blockShape: Shape.sound,
          imagePath: imagePath,
          position: position,
          connectionPoints: [
            // 声音方块的连接点 - 精确定位
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32.5)),
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
          ],
        );

  @override
  String toCommand() {
    return "SOUND:$name";
  }
}
