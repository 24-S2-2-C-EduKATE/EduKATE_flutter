import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Different block categories that help with validation and command generation.
enum BlockCategory {
  event,
  action,
  control,
  variable,
  sound,
}

class BlockSequence {
  final List<BlockData> blocks;
  BlockSequence({this.blocks = const []});

  /// 將序列轉換為命令字串（以 | 分隔，根據需求調整）
  String toCommand() {
    return blocks.map((block) => block.toCommand()).join(" | ");
  }
}

abstract class BlockData {
  final String id;
  final String name;
  final BlockCategory category;
  final String imagePath;
  Offset position;

  BlockData({
    required this.name,
    required this.category,
    required this.imagePath,
    required this.position,
  }) : id = Uuid().v4();

  String toCommand();
}

/// 事件方塊：僅用於開始一個序列，不接受左邊的連接
class EventBlock extends BlockData {
  final String eventType;
  // 右側代表接下來的 block sequence
  BlockSequence? nextSequence;

  EventBlock({
    required this.eventType,
    required String name,
    required String imagePath,
    required Offset position,
  }) : super(name: name, category: BlockCategory.event, imagePath: imagePath, position: position);

  @override
  String toCommand() {
    return "EVENT:$eventType" + (nextSequence != null ? " -> ${nextSequence!.toCommand()}" : "");
  }
}

/// 動作方塊：紀錄類別與名字，並能回傳對應的命令字串
class ActionBlock extends BlockData {
  final String action;

  // 如有需要客製化，可以用一個子序列（例如存放 variable block）
  BlockData? customization;

  ActionBlock({
    required this.action,
    required String name,
    required String imagePath,
    required Offset position,
  }) : super(name: name, category: BlockCategory.action, imagePath: imagePath, position: position);

  @override
  String toCommand() {
    return "ACTION:$action" + (customization != null ? "(${customization!.toCommand()})" : "");
  }
}

/// 控制方塊：例如 RepeatBlock，包含一個內部序列
class RepeatBlock extends BlockData {
  final int repeatCount;
  BlockSequence nestedSequence;

  RepeatBlock({
    required this.repeatCount,
    required String name,
    required String imagePath,
    required Offset position,
    required this.nestedSequence,
  }) : super(name: name, category: BlockCategory.control, imagePath: imagePath, position: position);

  @override
  String toCommand() {
    return "REPEAT:$repeatCount[${nestedSequence.toCommand()}]";
  }
}

class IfElseBlock extends BlockData {
  // 中間的 boolean block 可視需求拆分或直接放入此類別處理
  final bool condition;
  BlockSequence trueSequence;
  BlockSequence falseSequence;

  IfElseBlock({
    required this.condition,
    required String name,
    required String imagePath,
    required Offset position,
    required this.trueSequence,
    required this.falseSequence,
  }) : super(name: name, category: BlockCategory.control, imagePath: imagePath, position: position);

  @override
  String toCommand() {
    return "IF:${condition ? 'TRUE' : 'FALSE'} {${trueSequence.toCommand()}} ELSE {${falseSequence.toCommand()}}";
  }
}