// lib/factories/block_factory.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/models/repeat_block.dart';
import 'block_data.dart';
import 'action_block.dart';
import 'event_block.dart';
import 'package:flutter_application_1/picture_block/models/block_with_image.dart';

/// 根據傳入的 [BlockWithImage] 建立具體的 [BlockData] 實例，並使用給定的位置作為初始位置。
BlockData createBlockFromData(BlockWithImage data, Offset position) {
  switch (data.shape) {
    case Shape.event1:
    case Shape.event2:
      return EventBlock(
        name: data.name, // 你可以根據需求設定事件類型（這裡以名稱作示範）
        imagePath: data.imagePath,
        position: position,
      );
    case Shape.action:
      return ActionBlock(  
        name: data.name, // 以區塊的名稱或其它屬性作為 action 參數
        imagePath: data.imagePath,
        position: position,
      );
    case Shape.repeat:
      return RepeatBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
        repeatCount: 1,
        
      );
    // 可根據需要增加其他類型
    default:
      // 如果沒有對應類型，就回傳一個預設的 ActionBlock
      return ActionBlock(
        name: data.name,
        imagePath: data.imagePath,
        position: position,
      );
  }
}