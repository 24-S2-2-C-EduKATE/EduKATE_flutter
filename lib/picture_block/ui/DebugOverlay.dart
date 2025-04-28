import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/models/block_data.dart';


class ConnectionDotOverlay extends StatelessWidget {
  final List<BlockData> blocks;
  const ConnectionDotOverlay(this.blocks, {super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(   // 讓點不擋到手勢
      child: CustomPaint(
        painter: _DotPainter(blocks),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final List<BlockData> blocks;
  _DotPainter(this.blocks);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = Colors.red..style = PaintingStyle.fill;
    for (final b in blocks) {
      for (final cp in b.connectionPoints) {
        final g = cp.getGlobalPosition(b.position);
        c.drawCircle(Offset(g.dx, g.dy), 4, p);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _DotPainter old) => true;
}