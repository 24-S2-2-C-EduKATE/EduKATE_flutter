import 'package:flutter/material.dart';
import 'block_data.dart';

class DraggableBlock extends StatefulWidget {
  final BlockData blockData; // BlockData object to hold the block's data
  final Function(BlockData) onUpdate; // Callback function to update block data

  DraggableBlock({
    required this.blockData,
    required this.onUpdate,
  });

  @override
  _DraggableBlockState createState() => _DraggableBlockState(); // Create the state for this widget
}

class _DraggableBlockState extends State<DraggableBlock> {
  Offset _offset = Offset.zero; // Initial offset for the block position

  @override
  void initState() {
    super.initState();
    _offset = widget.blockData.position; // Initialize the offset with the block's position
  }

  @override
  void didUpdateWidget(covariant DraggableBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the offset if the block's position has changed
    if (widget.blockData.position != _offset) {
      setState(() {
        _offset = widget.blockData.position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx, // Set the left position based on the offset
      top: _offset.dy, // Set the top position based on the offset
      child: GestureDetector(
        // Handle drag events
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta; // Update the offset based on drag movement
            widget.blockData.position = _offset; // Update the block's position
          });
          widget.onUpdate(widget.blockData); // Call the onUpdate function to update the block data
        },
        onPanEnd: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox; // Get the render box
          final size = renderBox.size; // Get the size of the box

          // Check if the block goes out of the workspace
          if (_offset.dx < 0 || _offset.dx > size.width || 
              _offset.dy < 0 || _offset.dy > size.height) {
            // Trigger delete operation or handle out-of-bounds logic
            widget.onUpdate(widget.blockData); // Call onUpdate or a delete function
          }
        },
        child: Image.asset(
          widget.blockData.imagePath, // Display the block image
          height: 85, // Set the height of the block
        ),
      ),
    );
  }
}
