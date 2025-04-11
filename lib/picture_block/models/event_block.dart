// lib/blocks/event_block.dart
import 'package:flutter/material.dart';
import 'block_data.dart';
import 'package:flutter_application_1/picture_block/interaction/block_sequence.dart';
import 'connection_point.dart';

class EventBlock extends BlockData {
  // 用來儲存容器內部的子區塊，類似 Blockly 或 Scratch 的內嵌區塊區域
  BlockSequence? innerSequence;

  EventBlock({
    required String name,
    required String imagePath,
    required Offset position,
  }) : super(
          name: name,
          blockShape: Shape.event2, // 根據設計選擇形狀
          imagePath: imagePath,
          position: position,
          connectionPoints: [
            // 若需要與其他事件區塊連接，可定義 next 連接點（例如右側）
            ConnectionPoint(type: ConnectionType.next, relativeOffset: Offset(65, 32)),
            // 可另外定義一個 input 連接點，作為放置子區塊的 drop 區域
            ConnectionPoint(type: ConnectionType.input, relativeOffset: Offset(10, 70)),
          ],
        );

  @override
  String toCommand() {
    return "EVENT:$name" +
        (innerSequence != null ? " -> [${innerSequence!.toCommand()}]" : "");
  }
}
