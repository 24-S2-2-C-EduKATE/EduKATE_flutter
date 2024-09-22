import 'block_base.dart';
import 'package:flutter/material.dart';

class InteractionBlock extends BlockBase {
  // 交互块可能需要一个变量
  dynamic variable;

  InteractionBlock({
    required String imagePath,
    required Offset position,
    this.variable,
  }) : super(
          imagePath: imagePath,
          position: position,
          blockType: BlockType.interaction,
          connectionPoints: {
            BlockSide.left: ConnectionPoint(type: ConnectionType.female, side: BlockSide.left),
            BlockSide.right: ConnectionPoint(type: ConnectionType.male, side: BlockSide.right),
          },
        );

  @override
  Future<void> execute() async {
    print('Interaction Block executed with variable: $variable');

    // 执行右侧连接的积木块
    var nextBlock = connectionPoints[BlockSide.right]?.connectedBlock;
    if (nextBlock != null) {
      await nextBlock.execute();
    }
  }
}