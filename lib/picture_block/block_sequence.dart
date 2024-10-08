// block_sequence.dart
import 'package:flutter_application_1/picture_block/block_data.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'dart:ui';

class BlockSequence {
  // List to hold the order of blocks
  List<BlockData> _blockOrder = [];

  // Method to add a block to the sequence
  void addBlock(BlockData block) {
    // Only add the block if it is not already in the order
    if (!_blockOrder.contains(block)) {
      _blockOrder.add(block);
    }
  }

  // Method to get the current order of blocks
  List<BlockData> getBlockOrder() {
    return List.unmodifiable(_blockOrder); // Return an unmodifiable list
  }

  // Method to get descriptions of the blocks in order
  List<String> getBlockOrderDescriptions() {
    return _blockOrder.map((block) => 'ID: ${block.id}, Image: ${block.imagePath}').toList();
  }

  // Method to update the order of blocks based on arranged commands
  void updateOrder(List<BlockData> arrangedCommands) {
    _blockOrder.clear(); // Clear the current block order
    
    // Find the first block in the arranged commands
    BlockData? firstBlock = _findFirstBlock(arrangedCommands);
    
    // If a first block exists, recursively add blocks in connection order
    if (firstBlock != null) {
      _addToOrder(firstBlock);
    }
  }

  // Method to remove a block by its ID
  void removeBlock(String blockId) {
    _blockOrder.removeWhere((block) => block.id == blockId);
  }

  // Method to find the first block that is not connected above or to the left
  BlockData? _findFirstBlock(List<BlockData> arrangedCommands) {
    for (var block in arrangedCommands) {
      // Ensure the top or left of the block is not connected to any other blocks
      if (block.connections[ConnectionType.left]?.connectedBlock == null) {
            if (block.imagePath == 'assets/images/start_virtual.png') {
              return block; // Return the first block if it's the virtual start block
            }
            else{
              print("Need start block!");
            }
      }
    }
    return null; // Return null if no unconnected block is found
  }

  // Recursive method to add blocks to the order based on connections
  void _addToOrder(BlockData block) {
    addBlock(block); // Add the current block to the order
    // Find the next connected block either below or to the right
    var nextBlock = block.connections[ConnectionType.right]?.connectedBlock;
    
    // If there is a next block, recursively add it
    if (nextBlock != null) {
      _addToOrder(nextBlock);
    }
  }

  // // Method to execute moves based on the block order
  // void executeMoves(Function(String) moveCallback) async {
  //   for (var block in _blockOrder) {
  //     switch (block.imagePath) {
  //       case 'assets/images/move_up.png':
  //         moveCallback('up'); // Call the move callback with 'up'
  //       case 'assets/images/move_down.png':
  //         moveCallback('down'); // Call the move callback with 'down'
  //       case 'assets/images/move_left.png':
  //         moveCallback('left'); // Call the move callback with 'left'
  //       case 'assets/images/move_right.png':
  //         moveCallback('right'); // Call the move callback with 'right'
  //     }
  //     await Future.delayed(Duration(milliseconds: 500)); // Delay between moves
  //   }
  // }

  // // Method to run the blocks using a VirtualController
  // void runBlocks(VirtualController controller) {
  //   print('Running blocks...'); // Debug message
  //   executeMoves((direction) {
  //     print('Moving baby $direction'); // Print the move direction
  //   });
  // }

  // Method to print the current order of blocks for debugging
  void printBlockOrder() {
    print('Current Block Order:');
    for (var i = 0; i < _blockOrder.length; i++) {
      print('Block ${i + 1}: ID = ${_blockOrder[i].id}, Image Path = ${_blockOrder[i].imagePath}');
    }
  }
}
