// block_sequence.dart
import 'package:flutter_application_1/picture_block/models/block_data.dart';

class BlockSequence {
  // List to hold the order of blocks
  List<BlockData> blocks = [];
  BlockSequence({List<BlockData>? blocks}) : blocks = blocks ?? [];

  // 將區塊序列轉換為命令字串（使用 "|" 分隔）
  String toCommand() {
    return blocks.map((block) => block.toCommand()).join(" | ");
  }

  void addBlock(BlockData block) {
    blocks.add(block);
  }

  void removeBlock(BlockData block) {
    blocks.remove(block);
  }

  BlockData? getBlockAt(int index) {
    if (index >= 0 && index < blocks.length) {
      return blocks[index];
    }
    return null;
  }

  // Getter for length
  int get length => blocks.length;
  // 更新區塊順序
  
  void updateOrder(List<BlockData> newOrder) {
    blocks
      ..clear()
      ..addAll(newOrder);
  }

  // 取出區塊序列的一部分
  BlockSequence extractSubsequence(int startIndex, int endIndex) {
    List<BlockData> subList = blocks.sublist(startIndex, endIndex);
    return BlockSequence(blocks: subList);
  }
}
