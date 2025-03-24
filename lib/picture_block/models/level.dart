import 'package:flutter/services.dart' show rootBundle;
import 'virtual_tile.dart';

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

    for (int y = 0; y < gridN; y++) {
      List<String> tiles = lines[y].trim().split(' ');
      for (int x = 0; x < gridN; x++) {
        grid.add(VirtualTile(y * gridN + x, tiles[x]));
      }
    }

    return Level(id, gridN, grid, startX, startY);
  }
}