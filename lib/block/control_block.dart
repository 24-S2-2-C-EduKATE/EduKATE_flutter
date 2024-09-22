import 'block_base.dart';
import 'package:flutter/material.dart';

class ControlBlock extends BlockBase {
  // 例如，控制块可能需要一个参数，如重复次数
  int repeatTimes;

  ControlBlock({
    required String imagePath,
    required Offset position,
    this.repeatTimes = 1,
  }) : super(
          imagePath: imagePath,
          position: position,
          blockType: BlockType.control,
          connectionPoints: {
            BlockSide.left: ConnectionPoint(type: ConnectionType.female, side: BlockSide.left),
            BlockSide.right: ConnectionPoint(type: ConnectionType.male, side: BlockSide.right),
          },
        );

  @override
  Future<void> execute() async {
    print('Control Block executed');

    // 重复执行右侧连接的积木块
    var nextBlock = connectionPoints[BlockSide.right]?.connectedBlock;
    if (nextBlock != null) {
      for (int i = 0; i < repeatTimes; i++) {
        await nextBlock.execute();
      }
    }
  }
}