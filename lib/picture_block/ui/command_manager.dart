import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/models/block_data.dart';
import 'package:flutter_application_1/picture_block/models/block_shape.dart';
import 'package:flutter_application_1/picture_block/models/block_with_image.dart';
import 'package:audioplayers/audioplayers.dart';


class CommandManager extends StatefulWidget {
  final List<BlockWithImage> commandImages;

  const CommandManager({
    Key? key,
    required this.commandImages,
  }) : super(key: key);

  @override
  _CommandManagerState createState() => _CommandManagerState();
}

class _CommandManagerState extends State<CommandManager> {
  List<BlockWithImage> commandImages = [];
  String selectedCategory = 'Events';
  String? selectedBlockId; // 当前被选中的 block id
  String? hoveringBlockId; // 当前悬停的 block id（新增）

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          selectedBlockId = null; // 点击空白处取消选中
        });
      },
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 198, 236, 247),
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.commandImages.length,
              itemBuilder: (context, index) {
                final block = widget.commandImages[index];
                final isSelected = selectedBlockId == block.imagePath;
                final isHovering = hoveringBlockId == block.imagePath;

                return Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        hoveringBlockId = block.imagePath;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        hoveringBlockId = null;
                      });
                    },
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBlockId = block.imagePath;
                        });
                        //AudioPlayer().play(AssetSource('assets/sounds/click.wav')); // play click sound
                      },
                      child: Draggable<BlockWithImage>(
                        data: block,
                        feedback: Material(
                          color: Colors.transparent,
                          child: _buildBlock(block, isSelected, isHovering),
                        ),
                        child: _buildBlock(block, isSelected, isHovering),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 封装生成一个积木的方法，带选中 / 悬停发光
  Widget _buildBlock(BlockWithImage block, bool isSelected, bool isHovering) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.6),  //color for select
                  blurRadius: 12,
                  spreadRadius: 6,
                )
              ]
            : isHovering
                ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),  //color for hover
                      blurRadius: 8,
                      spreadRadius: 3,
                    )
                  ]
                : [],
      ),
      child: SizedBox(
        height: 65,
        width: 65,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(65, 65),
              painter: BlockShapePainter(
                BlockData(
                  blockShape: block.shape,
                  imagePath: block.imagePath,
                  position: Offset(0, 0),
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 13,
              child: Image.asset(
                block.imagePath,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
