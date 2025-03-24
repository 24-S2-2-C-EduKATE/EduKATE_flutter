import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/models/block_data.dart';
import 'package:flutter_application_1/picture_block/models/block_shape.dart';
import 'package:flutter_application_1/picture_block/models/block_with_image.dart';


class CommandManager extends StatefulWidget {
  final List<BlockWithImage> commandImages; // List to hold command images
  
  const CommandManager({
    Key? key,
    required this.commandImages,
  }) : super(key: key);

  @override
  _CommandManagerState createState() => _CommandManagerState();
}

class _CommandManagerState extends State<CommandManager> {
  List<BlockWithImage> commandImages = []; // List to hold command images
  String selectedCategory = 'Events'; // Default selected category

  @override
 void initState() {
  super.initState();
  // Automatically load the 'Events' category when the widget is initialized
}

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Container(
        height: 100,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 198, 236, 247), // Inner container background color
          borderRadius: BorderRadius.circular(50), // Rounded corners for the inner container
        ),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0), // Padding
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.commandImages.length, // Assuming commandImages is the list of images
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Draggable<BlockWithImage>(
                data: widget.commandImages[index],
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    height: 65,
                    width: 65, // Added width to maintain aspect ratio for shapes
                    child: Stack(
                      children: [
                        // Paint the block shape first
                        CustomPaint(
                          size: Size(65, 65), // Size for each block
                          painter: BlockShapePainter(
                            BlockData(
                              blockShape: widget.commandImages[index].shape, // Provide a valid Shape object here
                              imagePath: widget.commandImages[index].imagePath, // Provide imagePath
                              position: Offset(0, 0), // Provide a default position
                            ),
                          ),
                        ),
                        // Then overlay the image on top of the shape
                        Positioned(
                          left: 16, // Custom left position
                          top: 13,  // Custom top position
                          child: Image.asset(
                            widget.commandImages[index].imagePath,
                            width: 40,  // Custom width
                            height: 40, // Custom height
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 65,
                  width: 65,
                  child: Stack(
                    children: [
                      // Paint the block shape first
                      CustomPaint(
                        size: Size(65, 65), // Size for each block
                        painter: BlockShapePainter(
                          BlockData(
                            blockShape: widget.commandImages[index].shape,  // Provide a valid Shape object here
                            imagePath: widget.commandImages[index].imagePath, // Provide imagePath
                            position: Offset(0, 0), // Provide a default position
                          ),
                        ),
                      ),
                      // Then overlay the image on top of the shape
                      Positioned(
                        left: 16, // Custom left position
                        top: 13,  // Custom top position
                        child: Image.asset(
                          widget.commandImages[index].imagePath,
                          width: 40,  // Custom width
                          height: 40, // Custom height
                          fit: BoxFit.contain,
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
    ],
  );
}
}