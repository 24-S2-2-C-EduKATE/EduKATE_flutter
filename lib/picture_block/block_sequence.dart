// block_sequence.dart
import 'package:flutter_application_1/picture_block/block_data.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'dart:ui';



class BlockSequence {
  // 保存积木顺序的列表
  List<BlockData> _blockOrder = [];

  BlockSequence() {
    // 创建并添加一个默认的BlockData对象
    BlockData defaultBlock = BlockData(
      imagePath: 'assets/images/move_up.png', // 默认的图片路径
      position: Offset(0, 0), // 默认的位置信息
    );
    _blockOrder.add(defaultBlock); // 将默认的BlockData添加到列表中
  }

  // 添加积木到顺序中
  void addBlock(BlockData block) {
    if (!_blockOrder.contains(block)) {
      _blockOrder.add(block);
    }
  }

  // 获取积木顺序
  List<BlockData> getBlockOrder() {
    return List.unmodifiable(_blockOrder); // 返回不可修改的列表
  }

  List<String> getBlockOrderDescriptions() {
  return _blockOrder.map((block) => 'ID: ${block.id}, Image: ${block.imagePath}').toList();
}


  void updateOrder(List<BlockData> arrangedCommands) {
  _blockOrder.clear();
  
  // 找到第一个积木块
  BlockData? firstBlock = _findFirstBlock(arrangedCommands);
  
  // 如果有首积木块，按连接顺序递归添加积木块
  if (firstBlock != null) {
    _addToOrder(firstBlock);
  }
}


  void removeBlock(String blockId) {
    _blockOrder.removeWhere((block) => block.id == blockId);
  }

  // 找到第一个积木
 BlockData? _findFirstBlock(List<BlockData> arrangedCommands) {
  for (var block in arrangedCommands) {
    // 确保该积木块的顶部或左侧没有连接到其他积木
    if (block.connections[ConnectionType.top]?.connectedBlock == null &&
        block.connections[ConnectionType.left]?.connectedBlock == null) {
      return block;
    }
  }
  return null;
}


  // 递归添加积木
  void _addToOrder(BlockData block) {
  addBlock(block); // 添加当前积木块到顺序中
  // 找到与当前积木连接的下一个积木块
  var nextBlock = block.connections[ConnectionType.bottom]?.connectedBlock ?? 
                  block.connections[ConnectionType.right]?.connectedBlock;
  
  // 如果有下一个积木块，则递归添加
  if (nextBlock != null) {
    _addToOrder(nextBlock);
  }
}

void executeMoves(Function(String) moveCallback) async {
    for (var block in _blockOrder) {
      switch (block.imagePath) {
        case 'assets/images/move_up.png':
          moveCallback('up');
          break;
        case 'assets/images/move_down.png':
          moveCallback('down');
          break;
        case 'assets/images/move_left.png':
          moveCallback('left');
          break;
        case 'assets/images/move_right.png':
          moveCallback('right');
          break;
      }
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  void runBlocks(VirtualController controller) {
  print('Running blocks...');
  executeMoves((direction) {
    print('Moving baby $direction');
  });
}

  // 打印积木顺序（调试）
  void printBlockOrder() {
    print('Current Block Order:');
    for (var i = 0; i < _blockOrder.length; i++) {
      print('Block ${i + 1}: ID = ${_blockOrder[i].id}, Image Path = ${_blockOrder[i].imagePath}');
    }
  }
}
