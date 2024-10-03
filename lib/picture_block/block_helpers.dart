// block_helpers.dart

import 'package:flutter/material.dart';
import 'block_data.dart'; // 确保 BlockData 和 ConnectionType 被导入

class BlockHelpers {

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
    case ConnectionType.top:
      position1 = block1.position;
      position2 = block2.position + Offset(0, block2.height); // 使用 block2 的高度
      break;
    case ConnectionType.bottom:
      position1 = block1.position + Offset(0, block1.height); // 使用 block1 的高度
      position2 = block2.position;
      break;
    case ConnectionType.left:
      position1 = block1.position;
      position2 = block2.position + Offset(block2.width + 26.5, 0); // 使用 block2 的宽度
      break;
    case ConnectionType.right:
      position1 = block1.position + Offset(block1.width - 26.5, 0); // 使用 block1 的宽度
      position2 = block2.position;
      break;
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
    case ConnectionType.top:
      block2.position = block1.position - Offset(0, block2.height); // 上方对齐
      break;
    case ConnectionType.bottom:
      block2.position = block1.position + Offset(0, block1.height); // 下方对齐
      break;
    case ConnectionType.left:
      block2.position = block1.position - Offset(block2.width + 26.5, 0); // 左侧对齐
      break;
    case ConnectionType.right:
      block2.position = block1.position + Offset(block1.width - 26.5, 0); // 右侧对齐
      break;
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
      case ConnectionType.top:
        return ConnectionType.bottom;
      case ConnectionType.bottom:
        return ConnectionType.top;
      case ConnectionType.left:
        return ConnectionType.right;
      case ConnectionType.right:
        return ConnectionType.left;
      default:
        throw Exception('Invalid ConnectionType');
    }
  }
}