import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/picture_block/block_data.dart';
import 'dart:async';

import 'package:flutter_application_1/picture_block/block_sequence.dart';

// Class representing a virtual tile on the grid
class VirtualTile {
  final int index; // Index of the tile in the grid
  final String tileType; // Type of the tile

  VirtualTile(this.index, this.tileType); // Constructor
}

// Class representing a level in the game
class Level {
  final int id; // Level ID
  final int gridN; // Size of the grid (NxN)
  final List<VirtualTile> grid; // List of tiles in the grid
  final int dollStartX; // Starting X position of the doll
  final int dollStartY; // Starting Y position of the doll

  Level(this.id, this.gridN, this.grid, this.dollStartX, this.dollStartY);

  // Static method to create a level from a file
  static Future<Level> create(int id, int startX, int startY) async {
    // Load level data from a text file
    String content = await rootBundle.loadString('assets/levels/level_$id.txt');
    List<String> lines = content.trim().split('\n');
    int gridN = lines.length; // Get grid size
    List<VirtualTile> grid = [];

    // Populate the grid with tiles based on the loaded data
    for (int y = 0; y < gridN; y++) {
      List<String> tiles = lines[y].trim().split(' ');
      for (int x = 0; x < gridN; x++) {
        grid.add(VirtualTile(y * gridN + x, tiles[x]));
      }
    }

    return Level(id, gridN, grid, startX, startY);
  }
}

// Widget to control the virtual doll in the game
class VirtualController extends StatefulWidget {
  // This public method will be used to control the baby externally
  const VirtualController({Key? key}) : super(key: key);

  @override
  VirtualControllerState createState() => VirtualControllerState();
}

// State class for the VirtualController widget
class VirtualControllerState extends State<VirtualController> {
  List<Level> levels = []; // List of levels in the game
  int currentLevelIndex = 0; // Index of the current level
  Level? currentLevel; // Current level object
  int babyX = 0; // Current X position of the baby
  int babyY = 0; // Current Y position of the baby
  List<VirtualTile> activeGrid = []; // Active grid with the current state
  bool isLoading = true; // Loading state indicator
  BlockSequence blockSequence = BlockSequence(); // Block sequence object

  @override
  void initState() {
    super.initState();
    _initializeLevels(); // Initialize levels when the widget is created
  }

  // Method to initialize levels
  Future<void> _initializeLevels() async {
    try {
      levels = await Future.wait([
        Level.create(1, 0, 1), // Load level 1
        Level.create(2, 0, 2), // Load level 2
        Level.create(3, 0, 0), // Load level 3
        Level.create(4, 0, 0), // Load level 4
      ]);

      setState(() {
        currentLevel = levels[currentLevelIndex]; // Set the current level
        _resetLevel(); // Reset the level to start state
        isLoading = false; // Mark loading as complete
      });
    } catch (error) {
      print('Error initializing levels: $error');
      setState(() {
        isLoading = false; // Mark loading as complete in case of error
      });
    }
  }

  // Method to reset the current level
  void _resetLevel() {
    if (currentLevel == null) return; // Check if current level is not null

    babyX = currentLevel!.dollStartX; // Set baby's starting X position
    babyY = currentLevel!.dollStartY; // Set baby's starting Y position

    // Validate starting position
    if (babyX < 0 || babyX >= currentLevel!.gridN || babyY < 0 || babyY >= currentLevel!.gridN) {
      print('Invalid start position for level ${currentLevel!.id}: ($babyX, $babyY)');
      babyX = 0; // Reset to valid position
      babyY = 0; // Reset to valid position
    }

    activeGrid = List.from(currentLevel!.grid); // Copy current grid state
    _drawBaby(); // Draw baby on the grid

    print('Reset level ${currentLevel!.id}. Baby should go position: ($babyX, $babyY)');
  }

  // Method to draw the baby on the grid
  void _drawBaby() {
    if (currentLevel == null) return; // Check if current level is not null

    int curIndex = babyY * currentLevel!.gridN + babyX; // Calculate the current index
    if (curIndex >= 0 && curIndex < currentLevel!.grid.length) {
      setState(() {
        // Update the active grid with the baby's position
        for (int i = 0; i < currentLevel!.grid.length; i++) {
          if (activeGrid[i].tileType == 'the_doll') {
            activeGrid[i] = currentLevel!.grid[i]; // Remove old baby position
          }
        }
        activeGrid[curIndex] = VirtualTile(curIndex, 'the_doll'); // Set new baby position
        print('Baby actual draw position: ($babyX, $babyY)');
      });
    } else {
      print('Invalid baby position: ($babyX, $babyY) for grid size ${currentLevel!.gridN}');
    }
  }

  // Method to check if the baby can move to a new position
  bool _checkBabyPosition(int x, int y) {
    if (currentLevel == null) return false; // Check if current level is not null
    if (x < 0 || x >= currentLevel!.gridN || y < 0 || y >= currentLevel!.gridN) {
      return false; // Out of grid bounds
    }
    int index = y * currentLevel!.gridN + x; // Calculate index for the new position
    if (index < 0 || index >= currentLevel!.grid.length) {
      return false; // Invalid index
    }
    String tileType = currentLevel!.grid[index].tileType; // Get the type of the tile at the new position
    if (tileType == 'pink') {
      return false; // Cannot move to a pink tile
    } else if (tileType == 'start_doll') {
      _endOfLevel(); // If reached start point, end level
      return false;
    }
    return true; // Can move to other tile types
  }

  // Method to move the baby in a specified direction
  void moveBaby(String direction) {
    if (currentLevel == null) return; // Check if current level is not null
    int newX = babyX; // Store new X position
    int newY = babyY; // Store new Y position

    // Determine new position based on direction
    switch (direction) {
      case 'left':
        newX = babyX - 1;
        break;
      case 'right':
        newX = babyX + 1;
        break;
      case 'up':
        newY = babyY - 1;
        break;
      case 'down':
        newY = babyY + 1;
        break;
    }

    // Check if the new position is valid
    if (_checkBabyPosition(newX, newY)) {
      setState(() {
        babyX = newX; // Update X position
        babyY = newY; // Update Y position
        _drawBaby(); // Draw baby at new position
        print('After move - Baby now position: ($babyX, $babyY)');
      });
    } else {
      _shakeBaby(); // Shake if move is not allowed
    }
  }

  // Method to shake the baby (indicate invalid move)
  void _shakeBaby() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cannot move there!'), duration: Duration(seconds: 1))); // Show error message
  }

  // Method to indicate the end of the level
  void _endOfLevel() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Level completed!'), duration: Duration(seconds: 2))); // Show completion message
    _nextLevel(); // Move to the next level
  }

  // Method to load the next level
  void _nextLevel() {
    if (currentLevelIndex < levels.length - 1) {
      setState(() {
        currentLevelIndex++; // Increment level index
        currentLevel = levels[currentLevelIndex]; // Update current level
        _resetLevel(); // Reset to start state
      });
    }
  }

  void _previousLevel() {
    // Check if the current level index is greater than 0 to prevent going out of bounds
    if (currentLevelIndex > 0) {
      setState(() {
        // Decrease the current level index to go to the previous level
        currentLevelIndex--;
        // Update the current level to the new index
        currentLevel = levels[currentLevelIndex];
        // Reset the level to initialize the baby position and grid
        _resetLevel();
      });
    }
  }

  void executeMoves(List<BlockData> blocks) async {
    // Iterate through the list of block data provided
    for (var block in blocks) {
      // Determine the move direction based on the block's image path
      switch (block.imagePath) {
        case 'assets/images/move_up.png':
          moveBaby('up'); // Move the baby up
          break;
        case 'assets/images/move_down.png':
          moveBaby('down'); // Move the baby down
          break;
        case 'assets/images/move_left.png':
          moveBaby('left'); // Move the baby left
          break;
        case 'assets/images/move_right.png':
          moveBaby('right'); // Move the baby right
          break;
      }
      // Wait for half a second before executing the next move
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator while levels are being initialized
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Handle case where current level could not be loaded
    if (currentLevel == null) {
      return Center(child: Text('Error loading levels'));
    }

    return Column(
      children: [
        // Display the current level ID
        Text('Level ${currentLevel!.id}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1, // Maintain a square aspect ratio for the grid
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: currentLevel!.gridN, // Number of columns in the grid
              ),
              itemCount: activeGrid.length, // Number of tiles in the active grid
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(), // Add borders to each tile
                  ),
                  child: Image.asset(
                    'assets/blocks/${activeGrid[index].tileType}.png',
                    fit: BoxFit.contain, // Ensure the image fits within the cell
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Button to move the baby left
              ElevatedButton(
                onPressed: () => moveBaby('left'),
                child: Icon(Icons.arrow_left),
              ),
              // Button to move the baby up
              ElevatedButton(
                onPressed: () => moveBaby('up'),
                child: Icon(Icons.arrow_upward),
              ),
              // Button to move the baby down
              ElevatedButton(
                onPressed: () => moveBaby('down'),
                child: Icon(Icons.arrow_downward),
              ),
              // Button to move the baby right
              ElevatedButton(
                onPressed: () => moveBaby('right'),
                child: Icon(Icons.arrow_right),
              ),
            ],
          ),
        ),
        // Row of buttons for navigating between levels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Button to go to the previous level
            ElevatedButton(
              onPressed: _previousLevel,
              child: Text('Previous Level'),
            ),
            // Button to go to the next level
            ElevatedButton(
              onPressed: _nextLevel,
              child: Text('Next Level'),
            ),
          ],
        ),
      ],
    );
  }
}
