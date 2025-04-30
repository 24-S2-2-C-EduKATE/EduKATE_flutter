import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/models/block_data.dart';
import 'package:flutter_application_1/picture_block/models/block_shape.dart';
import 'package:flutter_application_1/picture_block/models/block_with_image.dart';
import 'package:flutter_application_1/picture_block/models/visual_block.dart';
import 'package:audioplayers/audioplayers.dart'; // add audio player

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
  String? selectedBlockId; // selected block id
  String? hoveringBlockId; // hover block id
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // initial load player
    preloadSound(); // preload
  }

  Future<void> preloadSound() async {
    try {
      await _audioPlayer.setSourceAsset('sounds/click.wav');
    } catch (e) {
      print('play sound fail: $e');
    }
  }

  Future<void> playSound() async {
    try {
      await _audioPlayer.resume(); // play sound
    } catch (e) {
      print('play sound fail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          selectedBlockId = null;
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
                      onTapDown: (_) async {
                        setState(() {
                          selectedBlockId = block.imagePath;
                        });
                        await playSound(); // play click sound
                      },
                      child: Draggable<BlockWithImage>(
                        data: block,
                        feedback: Material(
                          color: Colors.transparent,
                          child: _buildBlock(block, isSelected, isHovering),
                        ),
                        child: _buildBlock(block, isSelected, isHovering),
                        onDragEnd: (_) {
                          setState(() {
                            selectedBlockId = null;
                          });
                        },
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

  Widget _buildBlock(BlockWithImage block, bool isSelected, bool isHovering) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 6,
                )
              ]
            : isHovering
                ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
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
                VisualBlock(
                  name: block.imagePath,
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
