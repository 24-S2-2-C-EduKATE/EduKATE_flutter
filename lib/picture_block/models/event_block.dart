// lib/blocks/event_block.dart
import 'package:flutter/material.dart';
import 'block_data.dart';
import 'package:flutter_application_1/picture_block/interaction/block_sequence.dart';
import 'connection_point.dart';

class EventBlock extends BlockData {
  // Used to store child blocks inside the container, similar to embedded block areas in Blockly or Scratch
  BlockSequence? innerSequence;

  EventBlock({
    required String name,
    required String imagePath,
    required Offset position,
  }) : super(
          name: name,
          blockShape: Shape.event2, // Choose shape based on design
          imagePath: imagePath,
          position: position,
          connectionPoints: [
            // If connection to other event blocks is needed, define a next connection point (e.g., on the right side)
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32.5)),
            // Optionally define an input connection point as a drop area for nested child blocks
            ConnectionPoint(type: ConnectionType.input, relativeOffset: Offset(10, 70)),
          ],
        );

  @override
  String toCommand() {
    return "EVENT:$name" +
        (innerSequence != null ? " -> [${innerSequence!.toCommand()}]" : "");
  }
}
