// lib/helpers/block_connector.dart
import 'package:flutter/material.dart';
import '../models/block_data.dart';
import '../models/connection_point.dart';
import 'dart:collection';

class BlockHelpers {
  static double snapThreshold = 20.0;

  // Get local position within the workspace
  static Offset getLocalPosition(GlobalKey stackKey, Offset globalPosition) {
    final RenderBox stackRenderBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    return stackRenderBox.globalToLocal(globalPosition); // Convert global position to local
  }

  static BlockData? checkPossibleConnection(BlockData movedBlock, List<BlockData> others) {
  BlockData? highlightTarget;
  for (var block in others) {
    if (block.id == movedBlock.id) continue;
    for (var cpA in block.connectionPoints) {
      for (var cpB in movedBlock.connectionPoints) {
        if (_compatible(cpA.type, cpB.type)) {
          Offset globalA = cpA.getGlobalPosition(block.position);
          Offset globalB = cpB.getGlobalPosition(movedBlock.position);
          double distance = (globalA - globalB).distance;
          if (distance < snapThreshold) {
            // 有機會對接，就把 block 視為 highlight 目標
            highlightTarget = block;
          }
        }
      }
    }
  }
  return highlightTarget;
}

  static List<BlockData> getConnectedBlocks(BlockData startBlock) {
  // 這是一個示範，可依據您實際的連接點結構來實作
  // 例如: next <-> previous 連接、或是 input <-> output 連接
  List<BlockData> result = [];
  Queue<BlockData> queue = Queue();
  queue.add(startBlock);

  while (queue.isNotEmpty) {
    BlockData current = queue.removeFirst();
    if (!result.contains(current)) {
      result.add(current);
      // 搜尋與 current 相連的區塊，加入 queue
      for (var cp in current.connectionPoints) {
        if (cp.connectedBlock != null && !result.contains(cp.connectedBlock)) {
          queue.add(cp.connectedBlock!);
        }
      }
    }
  }
  return result;
}


  /// 嘗試連接兩個區塊。如果兩個區塊在相容的連接點上靠得足夠近，就建立連接並自動調整位置。
  static bool tryConnect(BlockData blockA, BlockData blockB) {
    // 依序遍歷 blockA 的所有連接點
    for (var cpA in blockA.connectionPoints) {
      // 在 blockB 中尋找與 cpA 相容的連接點
      for (var cpB in blockB.connectionPoints) {
        if (_compatible(cpA.type, cpB.type)) {
          Offset globalA = cpA.getGlobalPosition(blockA.position);
          Offset globalB = cpB.getGlobalPosition(blockB.position);
          if ((globalA - globalB).distance < snapThreshold) {
            // 建立連接關係
            cpA.connectedBlock = blockB;
            cpB.connectedBlock = blockA;
            // 調整 blockB 的位置，使得兩連接點對齊
            blockB.position = blockA.position + (cpA.relativeOffset - cpB.relativeOffset);
            return true;
          }
        }
      }
    }
    return false;
  }

  /// 判斷兩個連接型別是否相容（例如 previous 與 next 是一對）
  static bool _compatible(ConnectionType typeA, ConnectionType typeB) {
    if ((typeA == ConnectionType.next && typeB == ConnectionType.previous) ||
        (typeA == ConnectionType.previous && typeB == ConnectionType.next) ||
        (typeA == ConnectionType.input && typeB == ConnectionType.previous)) {
      return true;
    }
    // 針對容器區塊可另外定義 input 連接點的相容性（根據需求自訂）
    // 例如：如果 typeA 為 input 且 typeB 為 input，視為不相容，或另外做處理
    return false;
  }

  /// 斷開指定區塊的所有連接
  static void disconnect(BlockData block) {
    for (var cp in block.connectionPoints) {
      if (cp.connectedBlock != null) {
        // 找到對方區塊中連接到此區塊的連接點並清除
        for (var other in cp.connectedBlock!.connectionPoints) {
          if (other.connectedBlock == block) {
            other.connectedBlock = null;
          }
        }
        cp.connectedBlock = null;
      }
    }
  }
}
