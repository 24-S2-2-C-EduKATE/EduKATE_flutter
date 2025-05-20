// picture_block/ui/repeat_block_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/repeat_block.dart';
import '../models/block_data.dart';
import '../interaction/block_helpers.dart';
import 'package:flutter_application_1/picture_block/models/block_shape.dart';

class RepeatBlockWidget extends StatefulWidget {
  final RepeatBlock data;
  // Add a callback for when the size might change due to nested blocks
  final VoidCallback? onSizeChanged;

  const RepeatBlockWidget({
    required this.data,
    this.onSizeChanged,
    Key? key
  }) : super(key: key);

  @override
  _RepeatBlockWidgetState createState() => _RepeatBlockWidgetState();
}

class _RepeatBlockWidgetState extends State<RepeatBlockWidget> {
  final GlobalKey _key = GlobalKey();
  late TextEditingController _repeatCountController;

  @override
  void initState() {
    super.initState();
    _repeatCountController = TextEditingController(text: widget.data.repeatCount.toString());
  }

  @override
  void didUpdateWidget(covariant RepeatBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.repeatCount.toString() != _repeatCountController.text) {
      _repeatCountController.text = widget.data.repeatCount.toString();
    }
    // If the number of nested blocks changed, the width might have changed.
    if (widget.data.nestedSequence.length != oldWidget.data.nestedSequence.length) {
       widget.data.nestedSequenceChanged(); // Notify model to update connection points
       WidgetsBinding.instance.addPostFrameCallback((_) {
         widget.onSizeChanged?.call();
       });
    }
  }

  void _removeChild(BlockData child, Offset globalPos) {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final local = renderBox.globalToLocal(globalPos);
    if (!(Offset.zero & renderBox.size).contains(local)) {
      setState(() {
        widget.data.nestedSequence.removeBlock(child);
        widget.data.nestedSequenceChanged(); // Update connections as width changes
         WidgetsBinding.instance.addPostFrameCallback((_) {
           widget.onSizeChanged?.call();
         });
      });
    }
  }
  
  @override
  void dispose() {
    _repeatCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double nestedBlocksContentAreaWidth = widget.data.nestedSequence.blocks.isNotEmpty
        ? widget.data.nestedSequence.length * 65.0
        : RepeatBlock.minNestedAreaWidth;

    return Positioned(
      left: widget.data.position.dx,
      top: widget.data.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            widget.data.position += details.delta;
            widget.onSizeChanged?.call(); // Position changed, might affect connections with other blocks
          });
        },
        child: DragTarget<BlockData>(
          onWillAccept: (data) {
            // Allow dropping any block, removing the previous ID check.
            // Prevent dropping the repeat block into itself.
            if (data?.id == widget.data.id) return false;
            return true;
          },
          onAccept: (blockData) {
            BlockHelpers.disconnectPreviousConnection(blockData);
            setState(() {
              widget.data.nestedSequence.addBlock(blockData);
              widget.data.nestedSequenceChanged(); // Update connections as width changes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                 widget.onSizeChanged?.call();
              });
            });
          },
          builder: (context, candidateData, rejectedData) {
            return SizedBox(
              width: widget.data.getWidth(),
              height: widget.data.getHeight(),
              child: CustomPaint(
                key: _key,
                painter: PuzzlePainter(color: const Color.fromARGB(255, 247, 139, 146)),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: RepeatBlock.leftArmWidth,
                    top: RepeatBlock.armThickness,
                    right: RepeatBlock.rightArmWidth,
                    bottom: RepeatBlock.armThickness,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: nestedBlocksContentAreaWidth,
                        height: RepeatBlock.blockContentHeight,
                        decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.3),
                        ),
                        child: widget.data.nestedSequence.blocks.isEmpty && candidateData.isEmpty
                            ? Center(child: Text('Drop here', style: TextStyle(fontSize: 10, color: Colors.grey[700])))
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: widget.data.nestedSequence.blocks.map((child) {
                                    return Draggable<BlockData>(
                                      data: child,
                                      feedback: _buildChildWidget(child, opacity: 0.7),
                                      childWhenDragging: Opacity(opacity:0.3, child: _buildChildWidget(child)),
                                      onDragEnd: (details) => _removeChild(child, details.offset),
                                      child: _buildChildWidget(child),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                      Container(
                        width: RepeatBlock.repeatCountFieldWidth,
                        height: RepeatBlock.blockContentHeight,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: SizedBox(
                          width: RepeatBlock.repeatCountFieldWidth - 8,
                          height: 30,
                          child: TextField(
                            controller: _repeatCountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(color: Colors.grey[400]!)
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(color: Colors.grey[400]!)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(color: Colors.blue, width: 1.5)
                              ),
                              isCollapsed: true,
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            onChanged: (v) {
                              final t = int.tryParse(v);
                              if (t != null && t > 0) {
                                setState(() {
                                  widget.data.repeatCount = t;
                                });
                              } else if (v.isEmpty) {
                                // Allow clearing field, maybe default to 1 later
                              }
                            },
                            onSubmitted: (v) {
                               final t = int.tryParse(v);
                               if (t == null || t <= 0) {
                                 _repeatCountController.text = "1";
                                 setState(() {
                                   widget.data.repeatCount = 1;
                                 });
                               }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChildWidget(BlockData child, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: 65,
        height: 65,
        child: CustomPaint(
          painter: BlockShapePainter(child),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                child.imagePath,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}