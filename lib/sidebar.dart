// File: sidebar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

class Sidebar extends StatelessWidget {
  final bool isOpen;

  Sidebar({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: isOpen ? 300 : 0,
      child: Drawer(
        child: isOpen
            ? Column(
                children: [
                  Expanded(
                    child: VirtualController(),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

class VirtualTile {
  final int index;
  final String tileType;

  VirtualTile(this.index, this.tileType);
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
    int gridN = lines.length;
    List<VirtualTile> grid = [];

    for (int y = 0; y < lines.length; y++) {
      List<String> tiles = lines[y].trim().split(' ');
      for (int x = 0; x < tiles.length; x++) {
        grid.add(VirtualTile(y * gridN + x, tiles[x]));
      }
    }

    return Level(id, gridN, grid, startX, startY);
  }
}

class VirtualController extends StatefulWidget {
  @override
  _VirtualControllerState createState() => _VirtualControllerState();
}

class _VirtualControllerState extends State<VirtualController> {
  List<Level> levels = [];
  int currentLevelIndex = 0;
  Level? currentLevel;
  int babyX = 0;
  int babyY = 0;
  List<VirtualTile> activeGrid = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLevels();
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
    activeGrid = List.from(currentLevel!.grid);
    _drawBaby();
  }

  void _drawBaby() {
  if (currentLevel == null) return;
  // Reset the grid before drawing the baby
  activeGrid = List.from(currentLevel!.grid);
  
  int curIndex = babyX + babyY * currentLevel!.gridN;
  if (curIndex >= 0 && curIndex < activeGrid.length) {
    setState(() {
      activeGrid[curIndex] = VirtualTile(curIndex, 'the_doll');
    });
  }
}

  bool _checkBabyPosition(int x, int y) {
    if (currentLevel == null) return false;
    int index = x + y * currentLevel!.gridN;
    String tileType = currentLevel!.grid[index].tileType;
    if (tileType == 'pink') {
      return false;
    } else if (tileType == 'start_doll') {
      _endOfLevel();
      return true;
    }
    return true;
  }

  void _moveBaby(String direction) {
    if (currentLevel == null) return;
    int oldIndex = babyX + babyY * currentLevel!.gridN;
    bool moved = false;

    switch (direction) {
      case 'left':
        if (babyX > 0 && _checkBabyPosition(babyX - 1, babyY)) {
          babyX -= 1;
          moved = true;
        }
        break;
      case 'right':
        if (babyX < currentLevel!.gridN - 1 && _checkBabyPosition(babyX + 1, babyY)) {
          babyX += 1;
          moved = true;
        }
        break;
      case 'up':
        if (babyY > 0 && _checkBabyPosition(babyX, babyY - 1)) {
          babyY -= 1;
          moved = true;
        }
        break;
      case 'down':
        if (babyY < currentLevel!.gridN - 1 && _checkBabyPosition(babyX, babyY + 1)) {
          babyY += 1;
          moved = true;
        }
        break;
    }

    if (moved) {
      setState(() {
        activeGrid[oldIndex] = currentLevel!.grid[oldIndex];
        _drawBaby();
      });
    } else {
      _shakeBaby();
    }
  }

  void _shakeBaby() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cannot move there!'), duration: Duration(seconds: 1))
    );
  }

  void _endOfLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Level completed!'), duration: Duration(seconds: 2))
    );
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
        Text('Level ${currentLevel!.id}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Expanded(
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
                  fit: BoxFit.cover,
                ),
              );
            },
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