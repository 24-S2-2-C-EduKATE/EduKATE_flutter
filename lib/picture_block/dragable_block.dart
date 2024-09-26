import 'package:flutter/material.dart';
import 'block_data.dart';

class DraggableBlock extends StatefulWidget {
  final BlockData blockData;
  final Function(BlockData) onUpdate; // 更新参数类型

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
          widget.onUpdate(widget.blockData); // 确保传递正确的参数
        },
        onPanEnd: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final size = renderBox.size;

          // 检查是否超出工作区
          if (_offset.dx < 0 || _offset.dx > size.width || 
              _offset.dy < 0 || _offset.dy > size.height) {
            // 触发删除操作，可以传递 null 或者执行其他操作
            widget.onUpdate(widget.blockData); // 或者调用删除函数
          }
        },
        child: Image.asset(
          widget.blockData.imagePath,
          height: 85,
        ),
      ),
    );
  }
}
