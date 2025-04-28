// lib/helpers/draggable_block.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/models/block_shape.dart';
import '../models/block_data.dart';
import 'package:flutter_application_1/picture_block/interaction/block_helpers.dart';
import 'package:flutter_application_1/picture_block/interaction/virtual_controller.dart';

class DraggableBlock extends StatefulWidget {
  final BlockData blockData;
  final Function(BlockData) onUpdate;
  final VirtualController virtualController;
  final List<BlockData> arrangedCommands;

  DraggableBlock({
    required this.blockData,
    required this.onUpdate,
    required this.virtualController,
    required this.arrangedCommands,
  });

  @override
  _DraggableBlockState createState() => _DraggableBlockState();
}

class _DraggableBlockState extends State<DraggableBlock> {
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _offset = widget.blockData.position;
  }

  @override
  void didUpdateWidget(covariant DraggableBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blockData.position != _offset) {
      setState(() {
        _offset = widget.blockData.position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onTap: () {
          int currentIndex = widget.arrangedCommands.indexOf(widget.blockData);
          List<BlockData> remainingBlocks = widget.arrangedCommands.sublist(currentIndex);
          List<BlockData> chainToExecute = BlockHelpers.getRightConnectedBlocks(widget.blockData);
          // ✅ 然后把这条链交给 executeMoves 执行
          widget.virtualController.executeMoves(chainToExecute);
        },
        onPanUpdate: (details) {
          setState(() {
            Offset delta = details.delta;

            List<BlockData> connectedChain = BlockHelpers.getRightConnectedBlocks(widget.blockData);

            for (var block in connectedChain) {
              block.position += delta;
            }

            // 拖动过程中就检查链是否要断
            for (var block in connectedChain) {
              BlockHelpers.checkAndDisconnect(block);
            }

            _offset += delta;
            widget.blockData.position = _offset;
          });

          widget.onUpdate(widget.blockData);
        },

        onPanEnd: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final size = renderBox.size;

          if (_offset.dx < 0 || _offset.dx > size.width ||
              _offset.dy < 0 || _offset.dy > size.height) {
            widget.onUpdate(widget.blockData);
          }
        },
        child: SizedBox(
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
        ),
      ),
    );
  }
}