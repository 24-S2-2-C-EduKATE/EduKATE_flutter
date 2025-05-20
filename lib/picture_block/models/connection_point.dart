// lib/blocks/connection_point.dart
import 'package:flutter/material.dart';
import 'block_data.dart';

enum ConnectionType {
  previous, // Used to connect to the previous block
  next,     // Used to connect to the next block
  input,    // Used by container blocks to receive nested child blocks
}

class ConnectionPoint {
  final ConnectionType type;
  
  // Offset relative to the block itself (e.g., connection point on the left, right, or bottom)
  final Offset relativeOffset;
  
  BlockData? connectedBlock;

  ConnectionPoint({
    required this.type,
    required this.relativeOffset,
    this.connectedBlock,
  });

  /// Calculate the global position of this connection point based on the block's global position
  Offset getGlobalPosition(Offset blockPosition) {
    return blockPosition + relativeOffset;
  }
}
