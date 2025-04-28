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
              // 找到可能的连接目标
              connectionTarget = block;
            }
          }
        }
      }
    }
    return connectionTarget;
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

  /// 找到連接鏈中的頭部方塊
  static BlockData _findHeadBlock(BlockData block) {
    BlockData current = block;
    bool foundPrevious = true;
    
    // 循環向前尋找，直到找不到上一個方塊為止
    while (foundPrevious) {
      foundPrevious = false;
      // 尋找連接到previous類型連接點的方塊
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

  /// 調整整個連接鏈的位置對齊
  static void adjustConnectedChain(BlockData startBlock) {
    // 找到連接鏈的頭部方塊
    BlockData headBlock = _findHeadBlock(startBlock);
    
    // 從頭部方塊開始調整整個連接鏈
    _adjustBlockChainFromHead(headBlock);
  }

  /// 從頭部方塊開始調整整個連接鏈
  static void _adjustBlockChainFromHead(BlockData headBlock) {
    // 當前處理的方塊
    BlockData current = headBlock;
    
    // 持續處理，直到找不到下一個方塊為止
    while (true) {
      BlockData? nextBlock = null;
      ConnectionPoint? nextCp = null;
      
      // 尋找當前方塊的next連接點
      for (var cp in current.connectionPoints) {
        if (cp.type == ConnectionType.next && cp.connectedBlock != null) {
          nextBlock = cp.connectedBlock;
          nextCp = cp;
          break;
        }
      }
      
      // 如果沒有下一個方塊，就結束循環
      if (nextBlock == null || nextCp == null) break;
      
      // 找到下一個方塊中連接到當前方塊的連接點
      ConnectionPoint? prevCp = null;
      for (var cp in nextBlock.connectionPoints) {
        if (cp.type == ConnectionType.previous && cp.connectedBlock == current) {
          prevCp = cp;
          break;
        }
      }
      
      // 如果找不到對應的連接點，就結束循環
      if (prevCp == null) break;
      
      // 精確調整下一個方塊的位置
      // 使next和previous連接點完美對齊
      Offset idealNextPosition = current.position + (nextCp.relativeOffset - prevCp.relativeOffset);
      
      // 根據方塊類型添加特定的修正值
      double xCorrection = 0;
      double yCorrection = 0;
      
      // 根據方塊形狀組合進行特定的調整
      if (current.blockShape == Shape.action && nextBlock.blockShape == Shape.virtual) {
        // 動作方塊後接虛擬方塊的情況
        xCorrection = 0;
        yCorrection = 0.5;
      } else if (current.blockShape == Shape.virtual && nextBlock.blockShape == Shape.action) {
        // 虛擬方塊後接動作方塊的情況
        xCorrection = 0;
        yCorrection = -0.5;
      } else if (current.blockShape == Shape.event1 || current.blockShape == Shape.event2) {
        // 事件方塊的特殊處理
        if (nextBlock.blockShape == Shape.virtual || nextBlock.blockShape == Shape.action) {
          xCorrection = 0;
          yCorrection = 0.5;
        }
      } else if (current.blockShape == Shape.variable1 || current.blockShape == Shape.variable2) {
        // 變量方塊的特殊處理
        if (nextBlock.blockShape != Shape.variable1 && nextBlock.blockShape != Shape.variable2) {
          xCorrection = 0;
          yCorrection = 0.5;
        }
      } else if (current.blockShape == Shape.control) {
        // 控制方塊的特殊處理
        xCorrection = 0;
        yCorrection = 0.5;
      } else if (current.blockShape == Shape.sound) {
        // 聲音方塊的特殊處理
        xCorrection = 0;
        yCorrection = 0.5;
      }
      
      // 應用位置調整和微調修正
      nextBlock.position = Offset(
        idealNextPosition.dx + xCorrection,
        idealNextPosition.dy + yCorrection
      );
      
      // 處理下一個方塊
      current = nextBlock;
    }
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
            
            // 基本的位置調整
            blockB.position = blockA.position + (cpA.relativeOffset - cpB.relativeOffset);
            
            // 連接點類型特定的位置微調
            // 針對next/previous連接類型提供更精確的對齊
            if (cpA.type == ConnectionType.next && cpB.type == ConnectionType.previous) {
              // 根據方塊類型組合進行特定調整
              if (blockA.blockShape == Shape.action && blockB.blockShape == Shape.virtual) {
                blockB.position = Offset(
                  blockB.position.dx,
                  blockB.position.dy + 0.5  // 微調 y 坐標
                );
              } else if (blockA.blockShape == Shape.virtual && blockB.blockShape == Shape.action) {
                blockB.position = Offset(
                  blockB.position.dx,
                  blockB.position.dy - 0.5  // 微調 y 坐標
                );
              } else if (blockA.blockShape == Shape.event1 || blockA.blockShape == Shape.event2) {
                // 事件方塊的特殊處理
                if (blockB.blockShape == Shape.virtual || blockB.blockShape == Shape.action) {
                  blockB.position = Offset(
                    blockB.position.dx,
                    blockB.position.dy + 0.5
                  );
                }
              } else if (blockA.blockShape == Shape.variable1 || blockA.blockShape == Shape.variable2) {
                // 變量方塊的特殊處理
                if (blockB.blockShape != Shape.variable1 && blockB.blockShape != Shape.variable2) {
                  blockB.position = Offset(
                    blockB.position.dx,
                    blockB.position.dy + 0.5
                  );
                }
              }
            } else if (cpA.type == ConnectionType.previous && cpB.type == ConnectionType.next) {
              // 相反方向的連接，對 blockA 進行調整
              if (blockB.blockShape == Shape.action && blockA.blockShape == Shape.virtual) {
                blockA.position = Offset(
                  blockA.position.dx,
                  blockA.position.dy + 0.5
                );
              } else if (blockB.blockShape == Shape.virtual && blockA.blockShape == Shape.action) {
                blockA.position = Offset(
                  blockA.position.dx,
                  blockA.position.dy - 0.5
                );
              } else if (blockB.blockShape == Shape.event1 || blockB.blockShape == Shape.event2) {
                // 事件方塊的特殊處理
                if (blockA.blockShape == Shape.virtual || blockA.blockShape == Shape.action) {
                  blockA.position = Offset(
                    blockA.position.dx,
                    blockA.position.dy + 0.5
                  );
                }
              }
            }
            
            // 連接完成後，對整個連接鏈進行調整
            // 這確保了多個連接的方塊都能正確對齊
            adjustConnectedChain(blockA);
            
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
        (typeA == ConnectionType.previous && typeB == ConnectionType.next)) {
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
