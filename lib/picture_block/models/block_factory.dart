// lib/factories/block_factory.dart
import 'package:flutter/material.dart';
import 'block_data.dart';
import 'action_block.dart';
import 'event_block.dart';
import 'visual_block.dart';
import 'connection_point.dart';
import 'package:flutter_application_1/picture_block/models/block_with_image.dart';
import 'repeat_block.dart';
import 'package:flutter_application_1/picture_block/interaction/block_sequence.dart';

// Create a specific [BlockData] instance based on the given [BlockWithImage],
// and use the provided position as the initial placement.
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
      );case Shape.control2:
      return RepeatBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position, 
        repeatCount: 1,
        nestedSequence: BlockSequence()
      );
    case Shape.sound:
      return SoundBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
      );
    default:
      print('Warning: Unhandled shape type ${data.shape}');
      // If there is no corresponding type, return a default ActionBlock
      return ActionBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
      );
  }
}

// Virtual block class
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
            // Connection points of the variable block – precisely positioned
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32.5)),
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
          ],
        );

  @override
  String toCommand() {
    return "VIRTUAL:$name";
  }
}

// Variable block class
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
            // Connection points of the variable block – precisely positioned
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32.5)),
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
          ],
        );

  @override
  String toCommand() {
    return "VARIABLE:$name";
  }
}

// Control block class
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
             // Connection points of the variable block – precisely positioned
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32.5)),
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
            // Control blocks may require an additional input connection for nested content
            ConnectionPoint(type: ConnectionType.input, relativeOffset: Offset(32.5, 65)),
          ],
        );

  @override
  String toCommand() {
    return "CONTROL:$name";
  }
}

// Sound block class
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
            // Connection points of the sound block – precisely positioned
            ConnectionPoint(type: ConnectionType.previous, relativeOffset: Offset(0, 32.5)),
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
          ],
        );

  @override
  String toCommand() {
    return "SOUND:$name";
  }
}
