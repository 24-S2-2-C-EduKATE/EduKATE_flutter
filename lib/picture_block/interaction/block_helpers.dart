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
      throw Exception('Invalid ConnectionType');
  }

    // Check distance for potential connection
    return (position1 - position2).distance <= threshold;
  }

static void establishConnection(BlockData block1, BlockData block2, ConnectionType connectionType) {
  // Update connection relationship
  block1.connections[connectionType] = Connection(type: connectionType, connectedBlock: block2);
  block2.connections[getOppositeConnectionType(connectionType)] = Connection(
    type: getOppositeConnectionType(connectionType),
    connectedBlock: block1,
  );

  // Align the position of the block
  switch (connectionType) {
    case ConnectionType.left:
      block2.position = Offset(
        block1.position.dx - blockWidth,
        block1.position.dy, // Align vertical position
      );
      break;
    case ConnectionType.right:
      block2.position = Offset(
        block1.position.dx + blockWidth,
        block1.position.dy, // Align vertical position
      );
      break;
  }

  // If Block2 has blocks connected on the right side, recursively align their positions
  var nextBlock = block2.connections[ConnectionType.right]?.connectedBlock;
  if (nextBlock != null) {
    establishConnection(block2, nextBlock, ConnectionType.right);
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

static void checkAndDisconnect(BlockData block) {
  for (var connectionType in block.connections.keys.toList()) {
    var connectedBlock = block.connections[connectionType]?.connectedBlock;
    if (connectedBlock != null) {
      // Check if the distance exceeds the threshold
      if (!canConnect(block, connectedBlock, connectionType)) {
        // If it exceeds the range, disconnect the connection
        block.connections.remove(connectionType);
        connectedBlock.connections.remove(getOppositeConnectionType(connectionType));
        print('Disconnected Block ${block.id} from Block ${connectedBlock.id} due to distance');
      }
    }
  }
}

static List<BlockData> getRightConnectedBlocks(BlockData block, [Set<BlockData>? visited]) {
  visited ??= <BlockData>{};
  visited.add(block);

  // Get the block connected on the right side
  var rightBlock = block.connections[ConnectionType.right]?.connectedBlock;
  if (rightBlock != null && !visited.contains(rightBlock)) {
    // Check if the distance is within the range
    if (canConnect(block, rightBlock, ConnectionType.right)) {
      getRightConnectedBlocks(rightBlock, visited); // Recursively obtain the block connected to the right side
    } else {
      // If it exceeds the range, disconnect the connection
      block.connections.remove(ConnectionType.right);
      rightBlock.connections.remove(ConnectionType.left);
      print('Disconnected Block ${block.id} from Block ${rightBlock.id} due to distance');
    }
  }

  return visited.toList();
}
}
