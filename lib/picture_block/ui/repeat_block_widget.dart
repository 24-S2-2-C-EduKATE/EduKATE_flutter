import 'dart:math';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_application_1/picture_block/interaction/block_helpers.dart';
import 'package:flutter_application_1/picture_block/interaction/virtual_controller.dart';
import 'package:flutter_application_1/picture_block/models/block_data.dart';
import 'package:flutter_application_1/picture_block/models/connection_point.dart';
import 'package:flutter_application_1/picture_block/models/repeat_block.dart';
import 'package:flutter_application_1/picture_block/ui/dragable_block.dart';

/// -------------------------------------------------------------------------
/// RepeatBlockWidget  ‑  a visual + interactive wrapper around [RepeatBlock]
/// -------------------------------------------------------------------------
/// * 依照子積木數量動態增高 (可伸縮)
/// * 提供拖曳吸附（沿用 BlockHelpers）
/// * 暫不處理「右側 8 點」；先用基本 C‑shape 外觀
/// -------------------------------------------------------------------------
class RepeatBlockWidget extends StatefulWidget {
  final RepeatBlock blockData;
  final Function(BlockData) onUpdate;
  final VirtualController virtualController;
  final List<BlockData> arrangedCommands;

  const RepeatBlockWidget({
    required this.blockData,
    required this.onUpdate,
    required this.virtualController,
    required this.arrangedCommands,
    Key? key,
  }) : super(key: key);

  @override
  State<RepeatBlockWidget> createState() => _RepeatBlockWidgetState();
}

class _RepeatBlockWidgetState extends State<RepeatBlockWidget> {
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.blockData.position;
  }

  @override
  void didUpdateWidget(covariant RepeatBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _offset = widget.blockData.position;
  }

  /// 將 BlockData 加入 nestedSequence，並立即更新 UI / 連接點
  void _acceptChild(BlockData child) {
    setState(() {
      widget.blockData.nestedSequence.addBlock(child);
      print(widget.blockData.nestedSequence);
      // 確保新加入的子積木不在全域排列重複加入
      if (!widget.arrangedCommands.contains(child)) {
        widget.arrangedCommands.add(child);
      }
    });
    widget.onUpdate(widget.blockData); // 通知父層重新吸附
    debugPrint('nestedSequence size = '
    '${widget.blockData.nestedSequence.blocks.length}');
  }

  @override
  Widget build(BuildContext context) {
    
    // 1. 動態寬度計算
    final chainCount = _measureChainWidth(widget.blockData);
    final double innerWidth = chainCount * 65 + 40;
    const double fixedHeight = 120;
    final Size painterSize = Size(innerWidth, fixedHeight);
    Size test = Size(0, 0);
    print(painterSize);
    debugPrint('DEBUG width = $innerWidth');

    // 2. 更新 connectionPoints
    final centerY = painterSize.height / 2;
    widget.blockData.connectionPoints
        .firstWhere((c) => c.type == ConnectionType.previous)
        .relativeOffset = Offset(0, centerY);
    widget.blockData.connectionPoints
        .firstWhere((c) => c.type == ConnectionType.next)
        .relativeOffset = Offset(painterSize.width + 6, centerY);
    widget.blockData.connectionPoints
        .firstWhere((c) => c.type == ConnectionType.input)
        .relativeOffset = Offset(20, centerY);

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final chain = BlockHelpers.getConnectedBlocks(widget.blockData);
            for (final blk in chain) {
              blk.position += details.delta;
            }
          });
          widget.onUpdate(widget.blockData);
        },
        child: SizedBox(
          width: innerWidth,
          height: fixedHeight,
          child: CustomPaint(
            painter: _RepeatPainter(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 15, 10),
              child: DragTarget<BlockData>(
                onWillAcceptWithDetails: (details) => details.data != widget.blockData,
                onAcceptWithDetails: (details) {             
                  final child = details.data;
                  setState(() {
                    widget.blockData.nestedSequence.addBlock(child);
                    // 依序向右排：32 是 C 槽空白，65 每格寬
                    final idx = widget.blockData.nestedSequence.blocks.length - 1;
                    child.position = widget.blockData.position + Offset(32 + idx * 65, 0);
                  });
                },
                builder: (context, cand, rej) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.blockData.nestedSequence.blocks.map((b) {
                      return SizedBox(
                        width: 65,
                        height: 65,
                        child: DraggableBlock(
                          blockData: b,
                          onUpdate: widget.onUpdate,
                          virtualController: widget.virtualController,
                          arrangedCommands: widget.arrangedCommands,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          )
        ),
      ),
    );
  }
}

/// -------------------------------------------------------------------------
/// Painter: draws the yellow C‑shape + left notch + right protrusion.
/// 暫不畫次數點陣。
/// -------------------------------------------------------------------------
class _RepeatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 248, 231, 81)
      ..style = PaintingStyle.fill;
    final path = Path();
    final double rectHeight = size.height;
    final double topOffset = (size.height - rectHeight) / 2;
    final double ovalWidth = 13;
    final double ovalHeight = rectHeight + 5;
    const double cornerRadius = 20.0;

    // 1. 主体：圆角矩形 + 左侧凹槽
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - cornerRadius, size.height);
    path.lineTo(size.width - 2 * cornerRadius, size.height);
    path.lineTo(size.width - 2 * cornerRadius, 1.5 * cornerRadius);
    path.lineTo(cornerRadius, 1.5 * cornerRadius);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    // 左侧凹槽
    path.lineTo(0, topOffset + rectHeight);
    path.lineTo(6, topOffset + rectHeight);
    path.lineTo(6, topOffset);
    path.lineTo(0, topOffset);
    path.close();

    // 2. 左侧凹槽内的小椭圆
    final double ovalCenterX = 9.55;
    final double ovalCenterY = topOffset + ovalHeight / 2;
    path.moveTo(6, topOffset + rectHeight);
    path.lineTo(6, topOffset);
    path.arcTo(
      Rect.fromCenter(
          center: Offset(ovalCenterX, ovalCenterY),
          width: ovalWidth,
          height: ovalHeight),
      2.1418,
      -4.391,
      false,
    );
    path.close();

    // 3. 右侧凸台（矩形 + 椭圆）
    path.addRect(Rect.fromLTWH(size.width, topOffset, 6, rectHeight));
    path.addOval(Rect.fromLTWH(
      size.width + 3.55,
      topOffset - 2.5,
      ovalWidth,
      ovalHeight,
    ));

    // 绘制
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
int _measureChainWidth(BlockData container) {
  int _dfs(BlockData? node) {
    if (node == null) return 0;
    int n = 1;

    // 子容器遞迴
    final inputBlk = node.connectionPoints
        .firstWhereOrNull((c) => c.type == ConnectionType.input)
        ?.connectedBlock;
    n += _dfs(inputBlk);

    // 下一塊
    final nextBlk = node.connectionPoints
        .firstWhereOrNull((c) => c.type == ConnectionType.next)
        ?.connectedBlock;
    n += _dfs(nextBlk);

    return n;
  }

  final first = container.connectionPoints
      .firstWhereOrNull((c) => c.type == ConnectionType.input)
      ?.connectedBlock;
  return max(_dfs(first), 1);        // 至少留一格
}