// File: sidebar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

class Sidebar extends StatelessWidget {
// Boolean to control whether the sidebar is open
  final bool isOpen;

// Constructor requiring the isOpen parameter
  Sidebar({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // Using AnimatedContainer for animation effect
      duration: Duration(milliseconds: 300), // Animation duration
      width: isOpen ? 300 : 0, // Width is 300 if open, 0 if closed
      child: Drawer(
        child: isOpen
            ? Column(
                // If sidebar is open, show a Column
                children: [
                  Expanded(
                    child:
                        VirtualController(), // VirtualController fills the available space
                  ),
                ],
              )
            : null, // If sidebar is closed, show nothing
      ),
    );
  }
}

// VirtualTile class represents a virtual tile in the game
class VirtualTile {
  final int index; // Index of the tile in the grid
  final String tileType; // Type of the tile

  VirtualTile(this.index, this.tileType); // Constructor
}

class Level {
  final int id;
  final int gridN;
  final List<VirtualTile> grid;
  final int dollStartX;
  final int dollStartY;

  Level(this.id, this.gridN, this.grid, this.dollStartX, this.dollStartY);

  static Future<Level> create(int id, int startX, int startY) async {
    String content = await rootBundle.loadString('assets/levels/level_$id.txt');
    List<String> lines = content.trim().split('\n');
    int gridN = lines.length; // get gridN
    List<VirtualTile> grid = [];

    for (int y = 0; y < gridN; y++) {
      List<String> tiles = lines[y].trim().split(' ');
      for (int x = 0; x < gridN; x++) {
        grid.add(VirtualTile(y * gridN + x, tiles[x]));
      }
    }

    return Level(id, gridN, grid, startX, startY);
  }
}

// VirtualController class is a stateful widget for controlling game logic
class VirtualController extends StatefulWidget {
  @override
  _VirtualControllerState createState() => _VirtualControllerState();
}

// _VirtualControllerState class contains the main game logic
class _VirtualControllerState extends State<VirtualController> {
  // Stores all levels
  List<Level> levels = [];
  // Index of the current level
  int currentLevelIndex = 0;
  // Current level
  Level? currentLevel;
  // Current X coordinate of the doll
  int babyX = 0;
  int babyY = 0;
  // Currently active grid
  List<VirtualTile> activeGrid = [];
  // Loading state flag
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLevels(); // Initialize levels
  }

// Asynchronous method to initialize all levels
  Future<void> _initializeLevels() async {
    try {
      levels = await Future.wait([
        Level.create(1, 0, 1),
        Level.create(2, 0, 2),
        Level.create(3, 0, 0),
        Level.create(4, 0, 0),
      ]);

      setState(() {
        currentLevel = levels[currentLevelIndex];
        _resetLevel();
        isLoading = false;
      });
    } catch (error) {
      print('Error initializing levels: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

void _resetLevel() {
  if (currentLevel == null) return;

  babyX = currentLevel!.dollStartX;
  babyY = currentLevel!.dollStartY;
  
 
  if (babyX < 0 || babyX >= currentLevel!.gridN || babyY < 0 || babyY >= currentLevel!.gridN) {
    print('Invalid start position for level ${currentLevel!.id}: ($babyX, $babyY)');
    babyX = 0;
    babyY = 0;
  }
  
  activeGrid = List.from(currentLevel!.grid);
  _drawBaby();
  
  // 添加日志
  print('Reset level ${currentLevel!.id}. Baby should go position: ($babyX, $babyY)');
}

  void _drawBaby() {
    if (currentLevel == null) return;

    int curIndex = babyY * currentLevel!.gridN + babyX;
    if (curIndex >= 0 && curIndex < currentLevel!.grid.length) {
      setState(() {
        //清除旧的娃娃位置
        for (int i = 0; i < currentLevel!.grid.length; i++) {
          if (activeGrid[i].tileType == 'the_doll') {
            activeGrid[i] = currentLevel!.grid[i];
          }
        }
        // 设置新的娃娃位置
        activeGrid[curIndex] = VirtualTile(curIndex, 'the_doll');
         print(
          'Baby actual draw position: ($babyX, $babyY)');
      });
    } else {
      print(
          'Invalid baby position: ($babyX, $babyY) for grid size ${currentLevel!.gridN}');
    }
  }

  bool _checkBabyPosition(int x, int y) {
  if (currentLevel == null) return false;
  if (x < 0 || x >= currentLevel!.gridN || y < 0 || y >= currentLevel!.gridN) {
    return false; // 超出网格范围
  }
  int index = y * currentLevel!.gridN + x;
  if (index < 0 || index >= currentLevel!.grid.length) {
    return false;
  }
  String tileType = currentLevel!.grid[index].tileType;
  if (tileType == 'pink') {
    return false; // 不能移动到粉色瓦片
  } else if (tileType == 'start_doll') {
    _endOfLevel(); // 如果到达起始点，结束关卡
    return false;
  }
  return true; // 可以移动到其他类型的瓦片
}

  void _moveBaby(String direction) {
    if (currentLevel == null) return;
    int newX = babyX;
    int newY = babyY;

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

    if (_checkBabyPosition(newX, newY)) {
      setState(() {
        babyX = newX;
        babyY = newY;
        _drawBaby();
        print('After move - Baby now position: ($babyX, $babyY)');
      });
    } else {
      _shakeBaby();
    }
  }


  void _shakeBaby() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cannot move there!'), duration: Duration(seconds: 1)));
  }

  void _endOfLevel() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Level completed!'), duration: Duration(seconds: 2)));
    _nextLevel();
  }

  void _nextLevel() {
    if (currentLevelIndex < levels.length - 1) {
      setState(() {
        currentLevelIndex++;
        currentLevel = levels[currentLevelIndex];
        _resetLevel();
      });
    }
  }

  void _previousLevel() {
    if (currentLevelIndex > 0) {
      setState(() {
        currentLevelIndex--;
        currentLevel = levels[currentLevelIndex];
        _resetLevel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (currentLevel == null) {
      return Center(child: Text('Error loading levels'));
    }

    return Column(
      children: [
        Text('Level ${currentLevel!.id}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Expanded(
          child: AspectRatio(
            // 新添加的 AspectRatio
            aspectRatio: 1, // 保持正方形
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: currentLevel!.gridN,
              ),
              itemCount: activeGrid.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Image.asset(
                    'assets/blocks/${activeGrid[index].tileType}.png',
                    fit: BoxFit.contain, // 使用 contain 以确保图像适应单元格
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
              ElevatedButton(
                onPressed: () => _moveBaby('left'),
                child: Icon(Icons.arrow_left),
              ),
              ElevatedButton(
                onPressed: () => _moveBaby('up'),
                child: Icon(Icons.arrow_upward),
              ),
              ElevatedButton(
                onPressed: () => _moveBaby('down'),
                child: Icon(Icons.arrow_downward),
              ),
              ElevatedButton(
                onPressed: () => _moveBaby('right'),
                child: Icon(Icons.arrow_right),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _previousLevel,
              child: Text('Previous Level'),
            ),
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
