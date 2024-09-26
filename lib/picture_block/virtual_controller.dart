import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/picture_block/block_data.dart';
import 'dart:async';

import 'package:flutter_application_1/picture_block/block_sequence.dart';

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

class VirtualController extends StatefulWidget {
  // This public method will be used to control the baby externally

  const VirtualController({Key? key}) : super(key: key);

 @override
  VirtualControllerState createState() => VirtualControllerState();
}

class VirtualControllerState extends State<VirtualController> {
  List<Level> levels = [];
  int currentLevelIndex = 0;
  Level? currentLevel;
  int babyX = 0;
  int babyY = 0;
  List<VirtualTile> activeGrid = [];
  bool isLoading = true;
  BlockSequence blockSequence = BlockSequence();

  @override
  void initState() {
    super.initState();
    _initializeLevels(); // Initialize levels
  }

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

    print('Reset level ${currentLevel!.id}. Baby should go position: ($babyX, $babyY)');
  }

  void _drawBaby() {
    if (currentLevel == null) return;

    int curIndex = babyY * currentLevel!.gridN + babyX;
    if (curIndex >= 0 && curIndex < currentLevel!.grid.length) {
      setState(() {
        for (int i = 0; i < currentLevel!.grid.length; i++) {
          if (activeGrid[i].tileType == 'the_doll') {
            activeGrid[i] = currentLevel!.grid[i];
          }
        }
        activeGrid[curIndex] = VirtualTile(curIndex, 'the_doll');
        print('Baby actual draw position: ($babyX, $babyY)');
      });
    } else {
      print('Invalid baby position: ($babyX, $babyY) for grid size ${currentLevel!.gridN}');
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

  void moveBaby(String direction) {
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

  void executeMoves(List<BlockData> blocks) async {
    for (var block in blocks) {
      switch (block.imagePath) {
        case 'assets/images/move_up.png':
          moveBaby('up');
          break;
        case 'assets/images/move_down.png':
          moveBaby('down');
          break;
        case 'assets/images/move_left.png':
          moveBaby('left');
          break;
        case 'assets/images/move_right.png':
          moveBaby('right');
          break;
      }
      await Future.delayed(Duration(milliseconds: 500));
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
                onPressed: () => moveBaby('left'),
                child: Icon(Icons.arrow_left),
              ),
              ElevatedButton(
                onPressed: () => moveBaby('up'),
                child: Icon(Icons.arrow_upward),
              ),
              ElevatedButton(
                onPressed: () => moveBaby('down'),
                child: Icon(Icons.arrow_downward),
              ),
              ElevatedButton(
                onPressed: () => moveBaby('right'),
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
