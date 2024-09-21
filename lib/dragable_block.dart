import 'package:flutter/material.dart';
import 'block_data.dart';

class DraggableBlock extends StatefulWidget {
  final BlockData blockData;
  final Function(BlockData) onUpdate;

  DraggableBlock({
    required this.blockData,
    required this.onUpdate,
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
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
            widget.blockData.position = _offset;
          });
          widget.onUpdate(widget.blockData);
        },
        child: Image.asset(
          widget.blockData.imagePath,
          height: 85,
        ),
      ),
    );
  }
}