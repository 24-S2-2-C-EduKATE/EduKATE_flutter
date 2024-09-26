// block_sequence.dart
import 'package:flutter_application_1/picture_block/block_data.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'dart:ui';

class BlockSequence {
  // List to store the order of blocks
  List<BlockData> _blockOrder = [];

  // Constructor that initializes with a default block
  BlockSequence() {
    // Create and add a default BlockData object
    BlockData defaultBlock = BlockData(
      imagePath: 'assets/images/move_up.png', // Default image path
      position: Offset(0, 0), // Default position information
    );
    _blockOrder.add(defaultBlock); // Add the default BlockData to the list
  }

  // Add a block to the order
  void addBlock(BlockData block) {
    // Add the block if it is not already in the list
    if (!_blockOrder.contains(block)) {
      _blockOrder.add(block);
    }
  }

  // Get the current block order
  List<BlockData> getBlockOrder() {
    return List.unmodifiable(_blockOrder); // Return an unmodifiable list
  }

  // Get descriptions of the block order
  List<String> getBlockOrderDescriptions() {
    return _blockOrder.map((block) => 'ID: ${block.id}, Image: ${block.imagePath}').toList();
  }

  // Update the order of blocks based on arranged commands
  void updateOrder(List<BlockData> arrangedCommands) {
    _blockOrder.clear(); // Clear the existing order
    
    // Find the first block
    BlockData? firstBlock = _findFirstBlock(arrangedCommands);
    
    // If a first block is found, recursively add blocks in order
    if (firstBlock != null) {
      _addToOrder(firstBlock);
    }
  }

  // Remove a block by its ID
  void removeBlock(String blockId) {
    _blockOrder.removeWhere((block) => block.id == blockId);
  }

  // Find the first block that is not connected on top or left
  BlockData? _findFirstBlock(List<BlockData> arrangedCommands) {
    for (var block in arrangedCommands) {
      // Ensure that the block's top or left connections are not connected to other blocks
      if (block.connections[ConnectionType.top]?.connectedBlock == null &&
          block.connections[ConnectionType.left]?.connectedBlock == null) {
        return block; // Return the first block found
      }
    }
    return null; // Return null if no block is found
  }

  // Recursively add blocks to the order
  void _addToOrder(BlockData block) {
    addBlock(block); // Add the current block to the order
    // Find the next block connected to the current block
    var nextBlock = block.connections[ConnectionType.bottom]?.connectedBlock ?? 
                    block.connections[ConnectionType.right]?.connectedBlock;
    
    // If there is a next block, recursively add it
    if (nextBlock != null) {
      _addToOrder(nextBlock);
    }
  }

  // Execute moves based on the block order
  void executeMoves(Function(String) moveCallback) async {
    for (var block in _blockOrder) {
      switch (block.imagePath) {
        case 'assets/images/move_up.png':
          moveCallback('up'); // Move up
          break;
        case 'assets/images/move_down.png':
          moveCallback('down'); // Move down
          break;
        case 'assets/images/move_left.png':
          moveCallback('left'); // Move left
          break;
        case 'assets/images/move_right.png':
          moveCallback('right'); // Move right
          break;
      }
      await Future.delayed(Duration(milliseconds: 500)); // Wait for 500 milliseconds before the next move
    }
  }

  // Run the blocks in order
  void runBlocks(VirtualController controller) {
    print('Running blocks...');
    executeMoves((direction) {
      print('Moving baby $direction'); // Print the move direction
    });
  }

  // Print the current block order for debugging
  void printBlockOrder() {
    print('Current Block Order:');
    for (var i = 0; i < _blockOrder.length; i++) {
      print('Block ${i + 1}: ID = ${_blockOrder[i].id}, Image Path = ${_blockOrder[i].imagePath}');
    }
  }
}
