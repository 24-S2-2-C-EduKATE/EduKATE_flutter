// sensing_block.dart
import 'package:flutter/material.dart';
import 'block_base.dart';

class SensingBlock extends BlockBase {
  // 可以添加特定的属性，例如传感器类型、条件等

  SensingBlock({
    required String imagePath,
    required Offset position,
  }) : super(
          imagePath: imagePath,
          position: position,
          blockType: BlockType.sensing,
          connectionPoints: {
            BlockSide.left: ConnectionPoint(type: ConnectionType.female, side: BlockSide.left),
            BlockSide.right: ConnectionPoint(type: ConnectionType.male, side: BlockSide.right),
          },
        );

  @override
  Future<void> execute() async {
    print('Sensing Block executed');

    // 执行右侧连接的积木块
    var nextBlock = connectionPoints[BlockSide.right]?.connectedBlock;
    if (nextBlock != null) {
      await nextBlock.execute();
    }
  }
}