import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/models/block_shape.dart';
import '../models/block_data.dart';
import 'package:flutter_application_1/picture_block/interaction/virtual_controller.dart';
import 'package:audioplayers/audioplayers.dart'; // Sound player

class DraggableBlock extends StatefulWidget {
  final BlockData blockData; // Data associated with the block
  final Function(BlockData)
      onUpdate; // Callback function to update the block data
  final VirtualController
      virtualController; // Controller to manage virtual operations
  final List<BlockData> arrangedCommands; // List of arranged commands

  DraggableBlock({
    required this.blockData,
    required this.onUpdate,
    required this.virtualController,
    required this.arrangedCommands,
  });

  @override
  _DraggableBlockState createState() => _DraggableBlockState();
}

class _DraggableBlockState extends State<DraggableBlock> {
  Offset _offset = Offset.zero; // Initial offset for the block's position
  bool isSelected = false; // Whether the block is selected
  bool isHovering = false; // Whether the mouse is hovering over the block
  late final AudioPlayer _audioPlayer; // Sound player instance

  @override
  void initState() {
    super.initState();
    _offset = widget.blockData.position; // Set initial position from block data
    _audioPlayer = AudioPlayer(); // Initialize the audio player
    preloadSound(); // Preload the click sound
  }

  Future<void> preloadSound() async {
    try {
      await _audioPlayer
          .setSourceAsset('sounds/click.wav'); // Preload the sound asset
    } catch (e) {
      print('Failed to preload sound: $e');
    }
  }

  Future<void> playSound() async {
    try {
      await _audioPlayer.resume(); // Play the preloaded sound
    } catch (e) {
      print('Failed to play sound: $e');
    }
  }

  @override
  void didUpdateWidget(covariant DraggableBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blockData.position != _offset) {
      setState(() {
        _offset =
            widget.blockData.position; // Update offset if position changed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx, // Set horizontal position
      top: _offset.dy, // Set vertical position
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovering = true; // Mouse enters, set hovering true
          });
        },
        onExit: (_) {
          setState(() {
            isHovering = false; // Mouse exits, set hovering false
          });
        },
        child: GestureDetector(
          onTapDown: (_) async {
            // When clicked, set selected and play sound
            setState(() {
              isSelected = true;
            });
            await playSound(); // Play sound on tap down
          },
          onPanUpdate: (details) {
            setState(() {
              _offset += details.delta; // Update offset based on drag movement
              widget.blockData.position = _offset; // Update block data position
            });
            widget.onUpdate(widget
                .blockData); // Call the update function with the current block data
          },
          onPanEnd: (details) {
            setState(() {
              isSelected = false; // On release, cancel selected
            });

            final RenderBox renderBox = context.findRenderObject()
                as RenderBox; // Get the current render box
            final size = renderBox.size; // Get size of the render box

            // Check if the block is out of bounds of the working area
            if (_offset.dx < 0 ||
                _offset.dx > size.width ||
                _offset.dy < 0 ||
                _offset.dy > size.height) {
              widget.onUpdate(widget.blockData);
            }
          },
          child: Container(
            width: 65, // Set block width
            height: 65, // Set block height
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
            child: CustomPaint(
              painter: BlockShapePainter(widget.blockData),
              child: Stack(
                children: [
                  Positioned(
                    left: 16, // Image left offset
                    top: 13, // Image top offset
                    child: Image.asset(
                      widget.blockData.imagePath,
                      width: 40, // Set image width
                      height: 40, // Set image height
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
