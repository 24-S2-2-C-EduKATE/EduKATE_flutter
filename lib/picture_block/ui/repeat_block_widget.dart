import 'package:flutter/material.dart';
import '../models/repeat_block.dart';
import '../models/block_data.dart';
import '../interaction/block_helpers.dart';
import 'package:flutter_application_1/picture_block/models/block_shape.dart';

/// RepeatBlockWidget: UI for RepeatBlock
/// - 支持将其他积木拖入到槽中
/// - 支持将已嵌套的积木拖出以移除
class RepeatBlockWidget extends StatefulWidget {
  final RepeatBlock data;
  const RepeatBlockWidget({required this.data, Key? key}) : super(key: key);

  @override
  _RepeatBlockWidgetState createState() => _RepeatBlockWidgetState();
}

class _RepeatBlockWidgetState extends State<RepeatBlockWidget> {
  // GlobalKey 用于获取区域大小，以检测拖出
  final GlobalKey _key = GlobalKey();

  /// 如果子积木被拖到区域外，则移除
  void _removeChild(BlockData child, Offset globalPos) {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final local = renderBox.globalToLocal(globalPos);
    if (!(Offset.zero & renderBox.size).contains(local)) {
      setState(() {
        widget.data.nestedBlocks.remove(child);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.data.position.dx,
      top: widget.data.position.dy,
      child: GestureDetector(
        // 整体拖动 RepeatBlock
        onPanUpdate: (details) {
          setState(() {
            widget.data.position += details.delta;
          });
        },
        child: DragTarget<BlockData>(
          // 接收外部拖入的积木
          onAccept: (blockData) {
            setState(() {
              widget.data.nestedBlocks.add(blockData);
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              key: _key,
              child: CustomPaint(
                painter: PuzzlePainter(color: Colors.orange),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 顶部留空
                      const SizedBox(height: 40, width: 70),
                      // 嵌套积木水平滚动区
                      Container(
                        height: 100,
                        color: Colors.white,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: widget.data.nestedBlocks.map((child) {
                              // 将子积木作为 Draggable
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
                      // 重复次数输入框
                      SizedBox(
                        width: 60,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.only(left: 5, top: 3),
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

  /// 构建子积木的渲染
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