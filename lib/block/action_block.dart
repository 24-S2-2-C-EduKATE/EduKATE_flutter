import 'block_base.dart';
import 'package:flutter/material.dart';

class ActionBlock extends BlockBase {
  // 可以添加特定的属性，例如动作类型、参数等

  ActionBlock({
    required String imagePath,
    required Offset position,
  }) : super(
          imagePath: imagePath,
          position: position,
          blockType: BlockType.action,
          connectionPoints: {
            BlockSide.left: ConnectionPoint(type: ConnectionType.female, side: BlockSide.left),
            BlockSide.right: ConnectionPoint(type: ConnectionType.male, side: BlockSide.right),
          },
        );

  @override
  Future<void> execute() async {
    print('Action Block executed');

    // 执行右侧连接的积木块
    var nextBlock = connectionPoints[BlockSide.right]?.connectedBlock;
    if (nextBlock != null) {
      await nextBlock.execute();
    }
  }
}