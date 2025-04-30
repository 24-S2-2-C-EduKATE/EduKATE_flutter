// lib/helpers/block_helpers.dart

import 'package:flutter/material.dart';
import '../models/block_data.dart';
import '../models/connection_point.dart';
import 'dart:collection';

class BlockHelpers {
  static double snapThreshold = 20.0; // 距离阈值

  // 获取局部坐标位置
  static Offset getLocalPosition(GlobalKey stackKey, Offset globalPosition) {
    final RenderBox stackRenderBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    return stackRenderBox.globalToLocal(globalPosition);
  }

  // 检查是否有可能连接的方块
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

  // 尝试连接两个块
  static bool tryConnect(BlockData blockA, BlockData blockB) {
    for (var cpA in blockA.connectionPoints) {
      for (var cpB in blockB.connectionPoints) {
        if (_compatible(cpA.type, cpB.type)) {
          Offset globalA = cpA.getGlobalPosition(blockA.position);
          Offset globalB = cpB.getGlobalPosition(blockB.position);
          if ((globalA - globalB).distance < snapThreshold) {
            cpA.connectedBlock = blockB;
            cpB.connectedBlock = blockA;

            // 位置对齐（让连接点重叠）
            blockB.position = blockA.position + (cpA.relativeOffset - cpB.relativeOffset);

            adjustConnectedChain(blockA); // 保持链式对齐
            return true;
          }
        }
      }
    }
    return false;
  }

  // 断开指定块的所有连接（新版 connectionPoints）
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

  // 如果连接超出距离，就断开连接
    static void checkAndDisconnect(BlockData block) {
      for (var cp in block.connectionPoints) {
        var connectedBlock = cp.connectedBlock;
        if (connectedBlock != null) {
          for (var otherCp in connectedBlock.connectionPoints) {
            if (otherCp.connectedBlock == block) {
              Offset globalA = cp.getGlobalPosition(block.position);
              Offset globalB = otherCp.getGlobalPosition(connectedBlock.position);

              if ((globalA - globalB).distance > snapThreshold) {
                // 超出就断开
                cp.connectedBlock = null;
                otherCp.connectedBlock = null;
                print('Disconnected Block ${block.id} from Block ${connectedBlock.id} due to distance');
              }
            }
          }
        }
      }
    }



  // 获取右边连接的所有块
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




  // 根据链头开始调整一整个链条
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

  // 判断两个连接点类型是否兼容
  static bool _compatible(ConnectionType typeA, ConnectionType typeB) {
    return (typeA == ConnectionType.next && typeB == ConnectionType.previous) ||
           (typeA == ConnectionType.previous && typeB == ConnectionType.next);
  }
  
}
