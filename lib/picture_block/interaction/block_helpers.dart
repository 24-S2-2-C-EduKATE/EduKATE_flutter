// block_helpers.dart

import 'package:flutter/material.dart';
import '../models/block_data.dart'; 

class BlockHelpers {
  static double blockWidth = 65.0; // Adjust according to actual size
  static double blockHeight = 65.0; // Adjust according to actual size

  // Get local position within the workspace
  static Offset getLocalPosition(GlobalKey stackKey, Offset globalPosition) {
    final RenderBox stackRenderBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    return stackRenderBox.globalToLocal(globalPosition); // Convert global position to local
  }

  // Check if two blocks can connect
  static bool canConnect(BlockData block1, BlockData block2, ConnectionType connectionType) {
    double threshold = 20.0; // Distance threshold for connection

    Offset position1, position2;

    switch (connectionType) {
    case ConnectionType.left:
      position1 = block1.position;
      position2 = block2.position + Offset(blockWidth, 0); 
    case ConnectionType.right:
      position1 = block1.position + Offset(blockWidth, 0); 
      position2 = block2.position;
    default:
      return false;
  }

    // Check distance for potential connection
    if ((position1 - position2).distance <= threshold) {
      // Optionally check alignment
      if (connectionType == ConnectionType.left || connectionType == ConnectionType.right) {
        if ((block1.position.dy - block2.position.dy).abs() <= threshold) {
          return true; // Aligned vertically
        }
      } else {
        if ((block1.position.dx - block2.position.dx).abs() <= threshold) {
          return true; // Aligned horizontally
        }
      }
    }

    return false; // No connection can be established
  }

  // Establish a connection between two blocks
  static void establishConnection(BlockData block1, BlockData block2, ConnectionType connectionType) {
    // Update connection relations
    block1.connections[connectionType] = Connection(type: connectionType, connectedBlock: block2);
    block2.connections[getOppositeConnectionType(connectionType)] = Connection(
      type: getOppositeConnectionType(connectionType),
      connectedBlock: block1,
    );

    // Align positions based on connection type
     switch (connectionType) {
    case ConnectionType.left:
      block2.position = block1.position - Offset(blockWidth, 0);
    case ConnectionType.right:
      block2.position = block1.position + Offset(blockWidth, 0);
  }
  }

  // Disconnect all connections of a block
  static void disconnectAll(BlockData block) {
    for (var connectionType in block.connections.keys.toList()) {
      var connectedBlock = block.connections[connectionType]?.connectedBlock;
      if (connectedBlock != null) {
        connectedBlock.connections.remove(getOppositeConnectionType(connectionType)); // Remove opposite connection
      }
      block.connections.remove(connectionType); // Remove connection
    }
  }

  // Get the opposite connection type
  static ConnectionType getOppositeConnectionType(ConnectionType type) {
    switch (type) {
      case ConnectionType.left:
        return ConnectionType.right;
      case ConnectionType.right:
        return ConnectionType.left;
      default:
        throw Exception('Invalid ConnectionType');
    }
  }
}