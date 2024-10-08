import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/block_shape.dart';
import 'block_data.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';

class DraggableBlock extends StatefulWidget {
  final BlockData blockData; // Data associated with the block
  final Function(BlockData) onUpdate; // Callback function to update the block data
  final VirtualController virtualController;
  final List<BlockData> arrangedCommands;

  DraggableBlock({
    required this.blockData, // Required block data parameter
    required this.onUpdate,   // Required update callback
    required this.virtualController,
    required this.arrangedCommands,
  });

  @override
  _DraggableBlockState createState() => _DraggableBlockState();
}

class _DraggableBlockState extends State<DraggableBlock> {
  Offset _offset = Offset.zero; // Initial offset for the block's position

  @override
  void initState() {
    super.initState();
    _offset = widget.blockData.position; // Set initial position from block data
  }

  @override
  void didUpdateWidget(covariant DraggableBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the position has changed
    if (widget.blockData.position != _offset) {
      setState(() {
        _offset = widget.blockData.position; // Update offset if position has changed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx, // Set horizontal position
      top: _offset.dy,  // Set vertical position
      child: GestureDetector(
        onTap: () {
        // Find the index of the current block
        int currentIndex = widget.arrangedCommands.indexOf(widget.blockData);
        // Get all blocks starting from the current block
        List<BlockData> remainingBlocks = widget.arrangedCommands.sublist(currentIndex);
        // Pass remaining blocks to the executeMoves method
        widget.virtualController.executeMoves(remainingBlocks);

       },
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta; // Update offset based on drag movement
            widget.blockData.position = _offset; // Update block data position
          });
          widget.onUpdate(widget.blockData); // Call the update function with the current block data
        },
        onPanEnd: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox; // Get the current render box
          final size = renderBox.size; // Get size of the render box

          // Check if the block is out of bounds of the working area
          if (_offset.dx < 0 || _offset.dx > size.width || 
              _offset.dy < 0 || _offset.dy > size.height) {
            // Trigger delete operation, can pass null or perform other actions
            widget.onUpdate(widget.blockData); // Or call a deletion function
          }
        },
        child: SizedBox(
          width: 65,  // Block size
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
            width: 40,  // Set image width
            height: 40, // Set image height
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
