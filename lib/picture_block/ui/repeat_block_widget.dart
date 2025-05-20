import 'package:flutter/material.dart';
import '../models/repeat_block.dart';
import '../models/block_data.dart';
import '../interaction/block_helpers.dart';
import 'package:flutter_application_1/picture_block/models/block_shape.dart';

/// RepeatBlockWidget: UI for RepeatBlock
/// - Supports dragging other blocks into the slot
/// - Supports removing nested blocks by dragging them out
class RepeatBlockWidget extends StatefulWidget {
  final RepeatBlock data;
  const RepeatBlockWidget({required this.data, Key? key}) : super(key: key);

  @override
  _RepeatBlockWidgetState createState() => _RepeatBlockWidgetState();
}

class _RepeatBlockWidgetState extends State<RepeatBlockWidget> {
  // GlobalKey used to obtain the area size for drag-out detection
  final GlobalKey _key = GlobalKey();

  /// Remove the child block if it is dragged outside the container area
  void _removeChild(BlockData child, Offset globalPos) {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final local = renderBox.globalToLocal(globalPos);
    if (!(Offset.zero & renderBox.size).contains(local)) {
      setState(() {
        widget.data.nestedSequence.removeBlock(child);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.data.position.dx,
      top: widget.data.position.dy,
      child: GestureDetector(
        // Drag the entire RepeatBlock
        onPanUpdate: (details) {
          setState(() {
            widget.data.position += details.delta;
          });
        },
        child: DragTarget<BlockData>(
          // Accept blocks dragged in from outside
          onAccept: (blockData) {
            setState(() {
              widget.data.nestedSequence.addBlock(blockData);
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  key: _key,
                  child: CustomPaint(
                    painter: PuzzlePainter(color: Colors.orange),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Leave space at the top
                          const SizedBox(height: 40, width: 70),
                          // Horizontal scroll area for nested blocks
                          Container(
                            height: 100,
                            color: Colors.white,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: widget.data.nestedSequence.blocks.map((child) {
                                  // Render each nested block as a Draggable
                                  return Draggable<BlockData>(
                                    data: child,
                                    feedback: _buildChildWidget(child, opacity: 0.7),
                                    childWhenDragging: Container(),
                                    onDragEnd: (details) => _removeChild(child, details.offset),
                                    child: _buildChildWidget(child),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                // Position the number input field in the top-right corner
                Positioned(
                  top: -2,
                  right: -2,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.only(top: 4),
                        hintText: widget.data.repeatCount.toString(),
                      ),
                      onChanged: (v) {
                        final t = int.tryParse(v);
                        if (t != null) {
                          setState(() {
                            widget.data.repeatCount = t;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build the visual rendering for a child block
  Widget _buildChildWidget(BlockData child, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: 65,
        height: 65,
        child: CustomPaint(
          painter: BlockShapePainter(child),
          child: Stack(
            children: [
              Positioned(
                left: 16,
                top: 13,
                child: Image.asset(
                  child.imagePath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
