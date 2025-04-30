// lib/helpers/draggable_block.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/models/block_shape.dart';
import '../models/block_data.dart';
import 'package:flutter_application_1/picture_block/interaction/block_helpers.dart';
import 'package:flutter_application_1/picture_block/interaction/virtual_controller.dart';

/// DraggableBlock:
/// - 点击执行 onTap
/// - 拖动（pan）移动整个连接链
/// - 长按拖拽 (LongPressDraggable) 用于拖入 RepeatBlockWidget
class DraggableBlock extends StatefulWidget {
  final BlockData blockData;
  final Function(BlockData) onUpdate;
  final VirtualController virtualController;
  final List<BlockData> arrangedCommands;

  const DraggableBlock({
    Key? key,
    required this.blockData,
    required this.onUpdate,
    required this.virtualController,
    required this.arrangedCommands,
  }) : super(key: key);

  @override
  _DraggableBlockState createState() => _DraggableBlockState();
}

class _DraggableBlockState extends State<DraggableBlock> {
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.blockData.position;
  }

  @override
  void didUpdateWidget(covariant DraggableBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blockData.position != _offset) {
      setState(() => _offset = widget.blockData.position);
    }
  }

  /// 构建积木的视觉内容
  Widget _buildContent() {
    return SizedBox(
      width: 65,
      height: 65,
      child: CustomPaint(
        painter: BlockShapePainter(widget.blockData),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 13,
              child: Image.asset(
                widget.blockData.imagePath,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 基于 GestureDetector 构建交互内容
    Widget content = GestureDetector(
      onTap: () {
        // 点击执行，从当前积木开始的右侧链
        List<BlockData> chainToExecute = BlockHelpers.getRightConnectedBlocks(widget.blockData);
        widget.virtualController.executeMoves(chainToExecute);
      },
      onPanUpdate: (details) {
        setState(() {
          Offset delta = details.delta;
          List<BlockData> connectedChain = BlockHelpers.getRightConnectedBlocks(widget.blockData);
          for (var block in connectedChain) {
            block.position += delta;
          }
          // 实时断开被拖断的连接
          for (var block in connectedChain) {
            BlockHelpers.checkAndDisconnect(block);
          }
          // 更新自身偏移并同步模型
          _offset += delta;
          widget.blockData.position = _offset;
        });
        widget.onUpdate(widget.blockData);
      },
      onPanEnd: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final size = renderBox.size;
        if (_offset.dx < 0 || _offset.dx > size.width || _offset.dy < 0 || _offset.dy > size.height) {
          widget.onUpdate(widget.blockData);
        }
      },
      child: _buildContent(),
    );

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: LongPressDraggable<BlockData>(
        data: widget.blockData,
        feedback: Opacity(opacity: 0.7, child: _buildContent()),
        childWhenDragging: Opacity(opacity: 0.3, child: content),
        onDragEnd: (_) {
          // 可选：拖拽结束回调逻辑
        },
        child: content,
      ),
    );
  }
}
