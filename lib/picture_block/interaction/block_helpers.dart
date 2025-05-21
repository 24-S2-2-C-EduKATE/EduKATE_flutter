// lib/helpers/block_helpers.dart

import 'package:flutter/material.dart';
import '../models/block_data.dart';
import '../models/connection_point.dart';
import 'dart:collection';

class BlockHelpers {
  static double snapThreshold = 20.0; // Distance threshold

  // Get the local coordinate position
  static Offset getLocalPosition(GlobalKey stackKey, Offset globalPosition) {
    final RenderBox stackRenderBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    return stackRenderBox.globalToLocal(globalPosition);
  }

  // Check for possible blocks to connect
  static BlockData? checkPossibleConnection(BlockData movedBlock, List<BlockData> others) {
    BlockData? connectionTarget;
    for (var block in others) {
      if (block.id == movedBlock.id) continue;
      for (var cpA in block.connectionPoints) {
        for (var cpB in movedBlock.connectionPoints) {
          if (_compatible(cpA.type, cpB.type)) {
            Offset globalA = cpA.getGlobalPosition(block.position);
            Offset globalB = cpB.getGlobalPosition(movedBlock.position);
            double distance = (globalA - globalB).distance;
            if (distance < snapThreshold) {
              connectionTarget = block;
            }
          }
        }
      }
    }
    return connectionTarget;
  }

  // Attempt to connect two blocks
  static bool tryConnect(BlockData blockA, BlockData blockB) {
    for (var cpA in blockA.connectionPoints) {
      for (var cpB in blockB.connectionPoints) {
        if (_compatible(cpA.type, cpB.type)) {
          Offset globalA = cpA.getGlobalPosition(blockA.position);
          Offset globalB = cpB.getGlobalPosition(blockB.position);
          if ((globalA - globalB).distance < snapThreshold) {
            cpA.connectedBlock = blockB;
            cpB.connectedBlock = blockA;

            // Align positions (make connection points overlap)
            blockB.position = blockA.position + (cpA.relativeOffset - cpB.relativeOffset);

            adjustConnectedChain(blockA);  // Maintain chain alignment
            return true;
          }
        }
      }
    }
    return false;
  }

  // Disconnect all connections of the specified block (new connectionPoints implementation)
  static void disconnect(BlockData block) {
    for (var cp in block.connectionPoints) {
      if (cp.connectedBlock != null) {
        for (var other in cp.connectedBlock!.connectionPoints) {
          if (other.connectedBlock == block) {
            other.connectedBlock = null;
          }
        }
        cp.connectedBlock = null;
      }
    }
  }

  // If a connection exceeds the distance threshold, disconnect it
    static void checkAndDisconnect(BlockData block) {
      int snapThreshold = 10;
      for (var cp in block.connectionPoints) {
        var connectedBlock = cp.connectedBlock;
        if (connectedBlock != null) {
          for (var otherCp in connectedBlock.connectionPoints) {
            if (otherCp.connectedBlock == block) {
              Offset globalA = cp.getGlobalPosition(block.position);
              Offset globalB = otherCp.getGlobalPosition(connectedBlock.position);

              if ((globalA - globalB).distance > snapThreshold) {
                // Disconnect when threshold exceeded
                cp.connectedBlock = null;
                otherCp.connectedBlock = null;
                print('Disconnected Block ${block.id} from Block ${connectedBlock.id} due to distance');
              }
            }
          }
        }
      }
    }



  // Get all blocks connected to the right
    static List<BlockData> getRightConnectedBlocks(BlockData block, [Set<BlockData>? visited]) {
      visited ??= <BlockData>{};
      visited.add(block);

      ConnectionPoint? nextCp;
      try {
        nextCp = block.connectionPoints.firstWhere((cp) => cp.type == ConnectionType.next);
      } catch (e) {
        nextCp = null;
      }

      var rightBlock = nextCp?.connectedBlock;

      if (rightBlock != null && !visited.contains(rightBlock)) {
        if (nextCp != null && nextCp.connectedBlock != null) {
          getRightConnectedBlocks(rightBlock, visited);
        }
      }

      return visited.toList();
    }




  // Adjust the entire chain starting from the head of the chain
  static void adjustConnectedChain(BlockData startBlock) {
    BlockData headBlock = _findHeadBlock(startBlock);
    _adjustBlockChainFromHead(headBlock);
  }

  static BlockData _findHeadBlock(BlockData block) {
    BlockData current = block;
    bool foundPrevious = true;
    while (foundPrevious) {
      foundPrevious = false;
      for (var cp in current.connectionPoints) {
        if (cp.type == ConnectionType.previous && cp.connectedBlock != null) {
          current = cp.connectedBlock!;
          foundPrevious = true;
          break;
        }
      }
    }
    return current;
  }

  static void _adjustBlockChainFromHead(BlockData headBlock) {
    BlockData current = headBlock;
    while (true) {
      BlockData? nextBlock;
      ConnectionPoint? nextCp;
      for (var cp in current.connectionPoints) {
        if (cp.type == ConnectionType.next && cp.connectedBlock != null) {
          nextBlock = cp.connectedBlock;
          nextCp = cp;
          break;
        }
      }
      if (nextBlock == null || nextCp == null) break;

      ConnectionPoint? prevCp;
      for (var cp in nextBlock.connectionPoints) {
        if (cp.type == ConnectionType.previous && cp.connectedBlock == current) {
          prevCp = cp;
          break;
        }
      }
      if (prevCp == null) break;

      Offset idealNextPosition = current.position + (nextCp.relativeOffset - prevCp.relativeOffset);
      nextBlock.position = idealNextPosition;

      current = nextBlock;
    }
  }

  // Determine if two connection point types are compatible
  static bool _compatible(ConnectionType typeA, ConnectionType typeB) {
    return (typeA == ConnectionType.next && typeB == ConnectionType.previous) ||
           (typeA == ConnectionType.previous && typeB == ConnectionType.next);
  }

    // Disconnect only the block's "previous" connection, preserving its subsequent chain
  static void disconnectPreviousConnection(BlockData block) {
    // 1. Find the block's previous connection point (if connected)
    ConnectionPoint? prevCP;
    for (var cp in block.connectionPoints) {
      if (cp.type == ConnectionType.previous && cp.connectedBlock != null) {
        prevCP = cp;
        break;
      }
    }
    if (prevCP == null) return;

    // 2. Get the "previous" block it was connected to
    final parent = prevCP.connectedBlock!;

    // 3. On the parent block, find the corresponding next connection point and disconnect it
    for (var cp in parent.connectionPoints) {
      if (cp.type == ConnectionType.next && cp.connectedBlock == block) {
        cp.connectedBlock = null;
        break;
      }
    }

    // 4. 最後把自己的 previous 也斷掉
    prevCP.connectedBlock = null;
  }
}
