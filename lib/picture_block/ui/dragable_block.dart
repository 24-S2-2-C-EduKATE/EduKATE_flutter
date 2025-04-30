import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/models/block_shape.dart';
import '../models/block_data.dart';
import 'package:flutter_application_1/picture_block/interaction/block_helpers.dart';
import 'package:flutter_application_1/picture_block/interaction/virtual_controller.dart';
import 'package:audioplayers/audioplayers.dart';

/// Draggable blocks:
/// - Click to execute onTap
/// - Drag (translate) to move the entire connection chain
/// - Long press drag (LongPressDraggable) to drag into RepeatBlockWidget
/// - Mouse hover/select to emit light
/// - Click to play sound effects
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
  bool isSelected = false;
  bool isHovering = false;
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _offset = widget.blockData.position;
    _audioPlayer = AudioPlayer(); 
    preloadSound(); 
  }

  Future<void> preloadSound() async {
    try {
      await _audioPlayer.setSourceAsset('sounds/click.wav');
    } catch (e) {
      print('Failed to preload sound: $e');
    }
  }

  Future<void> playSound() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      print('Failed to play sound: $e');
    }
  }

  @override
  void didUpdateWidget(covariant DraggableBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blockData.position != _offset) {
      setState(() => _offset = widget.blockData.position);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: () {
        // Click to execute, starting from the right side of the current block
          List<BlockData> chainToExecute =
              BlockHelpers.getRightConnectedBlocks(widget.blockData);
          widget.virtualController.executeMoves(chainToExecute);
        },
        onTapDown: (_) async {
          setState(() => isSelected = true);
          await playSound();
        },
        onPanUpdate: (details) {
          setState(() {
            Offset delta = details.delta;
            List<BlockData> connectedChain =
                BlockHelpers.getRightConnectedBlocks(widget.blockData);
            for (var block in connectedChain) {
              block.position += delta;
            }
            for (var block in connectedChain) {
              BlockHelpers.checkAndDisconnect(block);
            }
            _offset += delta;
            widget.blockData.position = _offset;
          });
          widget.onUpdate(widget.blockData);
        },
        onPanEnd: (details) {
          setState(() => isSelected = false);
          final renderBox = context.findRenderObject() as RenderBox;
          final size = renderBox.size;
          if (_offset.dx < 0 ||
              _offset.dx > size.width ||
              _offset.dy < 0 ||
              _offset.dy > size.height) {
            widget.onUpdate(widget.blockData);
          }
        },
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 6,
                    )
                  ]
                : isHovering
                    ? [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 3,
                        )
                      ]
                    : [],
          ),
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

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: LongPressDraggable<BlockData>(
        data: widget.blockData,
        feedback: Opacity(opacity: 0.7, child: content),
        childWhenDragging: Opacity(opacity: 0.3, child: content),
        onDragEnd: (_) {
          // Drag end logic (keep empty implementation to support future expansion)
        },
        child: content,
      ),
    );
  }
}
