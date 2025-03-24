import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/picture_block/models/block_data.dart';
import 'dart:async';

import 'package:flutter_application_1/picture_block/interaction/block_sequence.dart';
import 'package:provider/provider.dart';
import '../models/level.dart';
import '../models/virtual_tile.dart';


class VirtualController extends ChangeNotifier {
  List<Level> levels = []; // List of levels in the game
  int currentLevelIndex = 0; // Index of the currently active level
  Level? currentLevel; // The current level object
  int babyX = 0; // X-coordinate of the baby's position
  int babyY = 0; // Y-coordinate of the baby's position
  List<VirtualTile> activeGrid = []; // The grid of tiles currently active
  bool isLoading = true; // Loading state indicator
  BlockSequence blockSequence = BlockSequence(); // Block sequence manager
  String outcomeMessage = '';
  bool isRunning = true;

  VirtualController() {
    _initializeLevels(); // Initialize levels on controller creation
  }

  Future<void> _initializeLevels() async {
    try {
      // Create and initialize levels asynchronously
      levels = await Future.wait([
        Level.create(1, 0, 1),
        Level.create(2, 0, 2),
        Level.create(3, 0, 0),
        Level.create(4, 0, 0),
      ]);

      currentLevel = levels[currentLevelIndex]; // Set the current level
      _resetLevel(); // Reset the current level state
      isLoading = false; // Set loading to false after levels are initialized
      notifyListeners(); // Notify listeners about the state change
    } catch (error) {
      // Handle errors during level initialization
      print('Error initializing levels: $error');
      isLoading = false; // Set loading to false on error
      notifyListeners(); // Notify listeners about the state change
    }
  }

  Future<void> playSound(String soundFilePath) async {
  final AudioPlayer audioPlayer = AudioPlayer(); 
  await audioPlayer.play(DeviceFileSource(soundFilePath)); 
}

  void _resetLevel() {
    if (currentLevel == null) return; // Return if there's no current level

    // Set initial position for the baby based on the level's starting position
    babyX = currentLevel!.dollStartX;
    babyY = currentLevel!.dollStartY;

    // Validate the starting position
    if (babyX < 0 || babyX >= currentLevel!.gridN || babyY < 0 || babyY >= currentLevel!.gridN) {
      print('Invalid start position for level ${currentLevel!.id}: ($babyX, $babyY)');
      babyX = 0; // Reset to default if invalid
      babyY = 0;
    }

    activeGrid = List.from(currentLevel!.grid); // Initialize the active grid
    _drawBaby(); // Draw the baby on the grid
    outcomeMessage = 'Level ${currentLevel!.id} started.';
    notifyListeners(); // Notify listeners about the state change

    print('Reset level ${currentLevel!.id}. Baby should go position: ($babyX, $babyY)');
  }

  void _drawBaby() {
    if (currentLevel == null) return; // Return if there's no current level

    // Calculate the index for the baby's current position
    int curIndex = babyY * currentLevel!.gridN + babyX;
    if (curIndex >= 0 && curIndex < currentLevel!.grid.length) {
      // Replace existing tile with the baby tile
      for (int i = 0; i < currentLevel!.grid.length; i++) {
        if (activeGrid[i].tileType == 'the_doll') {
          activeGrid[i] = currentLevel!.grid[i]; // Replace with the original tile
        }
      }
      activeGrid[curIndex] = VirtualTile(curIndex, 'the_doll'); // Draw baby tile at the current position
      notifyListeners(); // Notify listeners about the state change
      print('Baby actual draw position: ($babyX, $babyY)');
    } else {
      print('Invalid baby position: ($babyX, $babyY) for grid size ${currentLevel!.gridN}');
    }
  }

  Future<void> endOfLevel() async {
    outcomeMessage = 'Level Complete!';
    await playSound('assets/sounds/level_complete.wav'); 
    nextLevel(); 
    notifyListeners(); 
  }

   Future<bool> _checkBabyPosition(int x, int y) async {
    if (currentLevel == null) return false; // Return false if there's no current level
    // Check if the new position is within the grid bounds
    if (x < 0 || x >= currentLevel!.gridN || y < 0 || y >= currentLevel!.gridN) {
      outcomeMessage = 'Cannot move outside the grid!';
      notifyListeners();
      return false; // Out of grid range
    }
    int index = y * currentLevel!.gridN + x; // Calculate index based on x, y
    if (index < 0 || index >= currentLevel!.grid.length) {
      outcomeMessage = 'Invalid position!';
      notifyListeners();
      return false; // Invalid index
    }
    String tileType = currentLevel!.grid[index].tileType; // Get the tile type at the position
    if (tileType == 'pink') {
      outcomeMessage = 'Cannot move to pink tile!';
      notifyListeners();
      return false; // Cannot move to pink tile
    } else if (tileType == 'start_doll') {
      await endOfLevel();
      return false;
    }
    return true; // Can move to other types of tiles
  }

  Future<void> moveBaby(String direction) async {
    if (currentLevel == null) return; // Return if there's no current level
    int newX = babyX; // Initialize new X position
    int newY = babyY; // Initialize new Y position

    // Update the new position based on the direction
    switch (direction) {
      case 'left':
        newX = babyX - 1;
      case 'right':
        newX = babyX + 1;
      case 'up':
        newY = babyY - 1;
      case 'down':
        newY = babyY + 1;
    }

    // Check if the new position is valid and update the position if so
    if (await _checkBabyPosition(newX, newY)) {
      babyX = newX;
      babyY = newY;
      _drawBaby(); // Redraw the baby at the new position
      outcomeMessage = 'Moved $direction';
      notifyListeners(); // Notify listeners about the state change
      print('After move - Baby now position: ($babyX, $babyY)');
    } else {
      _shakeBaby(); // Call shake method if movement is invalid
    }
  }

  void _shakeBaby() {
    // Notify listeners is not needed as it doesn't affect UI
    // Just show Snackbar or error message
    // outcomeMessage = 'Cannot move there!'; // Error message
    notifyListeners(); // Notify listeners about the state change
  }

void nextLevel() {
    if (currentLevelIndex < levels.length - 1) {
      currentLevelIndex++; // Increment level index
      currentLevel = levels[currentLevelIndex]; // Set new current level
      _resetLevel(); // Reset the new level
      outcomeMessage = 'Moved to Level ${currentLevel!.id}'; 
      notifyListeners(); // Notify listeners about the state change
    } else {
      outcomeMessage = 'You have completed all levels!'; 
      notifyListeners();
    }
  }

  void previousLevel() {
    if (currentLevelIndex > 0) {
      currentLevelIndex--; // Decrement level index
      currentLevel = levels[currentLevelIndex]; // Set new current level
      _resetLevel(); // Reset the new level
      outcomeMessage = 'Moved to Level ${currentLevel!.id}';
      notifyListeners(); // Notify listeners about the state change
    }else {
      outcomeMessage = 'This is the first level!'; 
      notifyListeners();
    }
  }

  void executeMoves(List<BlockData> blocks) async {
    if (blocks.isEmpty) {
      outcomeMessage = 'Please add virtual start block!';
      notifyListeners();
      return;
    }

    isRunning = true;

    // Execute a sequence of moves based on the provided block data
    for (var block in blocks) {
      if (!isRunning) {
        break;  
      }
      switch (block.imagePath) {
        case 'assets/images/move_up.png':
          await moveBaby('up'); // Move up
        case 'assets/images/move_down.png':
          await moveBaby('down'); // Move down
        case 'assets/images/move_left.png':
          await moveBaby('left'); // Move left
        case 'assets/images/move_right.png':
          await moveBaby('right'); // Move right
        case 'assets/images/sound.png': 
          await playSound('assets/sounds/bark.wav'); 
          outcomeMessage = 'Played sound!';
          notifyListeners();
        case 'assets/images/virtual_start.png':  // Virtual start block
          print('Start running...'); // Print start message
      }
      
      await Future.delayed(Duration(milliseconds: 500)); // Delay between moves
    }
  }

  // Method to stop the block execution
  void stopExecution() {
    isRunning = false;  
    outcomeMessage = "Stop!";
    notifyListeners();
  }
}
