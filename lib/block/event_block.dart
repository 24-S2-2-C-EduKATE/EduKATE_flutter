import 'package:flutter/material.dart';
import 'block_base.dart';

class EventBlock extends BlockBase {
  EventBlock({
    required String imagePath,
    required Offset position,
  }) : super(
          imagePath: imagePath,
          position: position,
          blockType: BlockType.event,
          connectionPoints: {
            BlockSide.left: ConnectionPoint(type: ConnectionType.none, side: BlockSide.left),
            BlockSide.right: ConnectionPoint(type: ConnectionType.male, side: BlockSide.right),
          },
        );

  @override
  Future<void> execute() async {
    print('Event Block executed');

    // 执行右侧连接的积木块
    var nextBlock = connectionPoints[BlockSide.right]?.connectedBlock;
    if (nextBlock != null) {
      await nextBlock.execute();
    }
  }
}