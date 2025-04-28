import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/interaction/block_sequence.dart';
import 'package:flutter_application_1/picture_block/interaction/virtual_controller.dart';
import 'package:provider/provider.dart';
import 'ui/sidebar.dart'; // Import the Sidebar
import 'models/block_data.dart';
import 'ui/dragable_block.dart';
import 'interaction/block_helpers.dart';
import 'ui/command_manager.dart';
import 'ui/category_buttons.dart';
import 'ui/action_buttons.dart';
import 'package:flutter_application_1/picture_block/models/block_with_image.dart';

class PictureBlockPage extends StatefulWidget {
  const PictureBlockPage({Key? key}) : super(key: key);

  @override
  _PictureBlockPageState createState() => _PictureBlockPageState();
}

class _PictureBlockPageState extends State<PictureBlockPage> {
  List<BlockWithImage> commandImage = [];
  List<BlockData> arrangedCommands = []; // List to hold the arranged blocks
  String selectedCategory = 'Events'; // Default category for command images
  bool isSidebarOpen = false; // State to control sidebar visibility
  BlockSequence blockSequence = BlockSequence(); // Instance of BlockSequence to manage block order

  GlobalKey _stackKey = GlobalKey(); // Key for the stack to get its size and position
  final GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    updateCommands(selectedCategory);
  }

  // Method to update command images based on selected category
 void updateCommands(String category) {
  setState(() {
    selectedCategory = category;
    commandImage.clear(); // Clear previous command images
    if (category == 'Events') {
      commandImage = [
        BlockWithImage(imagePath: 'assets/images/start_virtual.png', shape: Shape.event1),
        BlockWithImage(imagePath: 'assets/images/start_physical.png', shape: Shape.event2),
        BlockWithImage(imagePath: 'assets/images/back_sensor.png', shape: Shape.event2),
        BlockWithImage(imagePath: 'assets/images/belly_sensor.png', shape: Shape.event2),
        BlockWithImage(imagePath: 'assets/images/nose_sensor.png', shape: Shape.event2),
      ];
    } else if (category == 'Virtual') {
      commandImage = [
        BlockWithImage(imagePath: 'assets/images/move_up.png', shape: Shape.virtual),
        BlockWithImage(imagePath: 'assets/images/move_down.png', shape: Shape.virtual),
        BlockWithImage(imagePath: 'assets/images/move_left.png', shape: Shape.virtual),
        BlockWithImage(imagePath: 'assets/images/move_right.png', shape: Shape.virtual),
      ];
    } else if (category == 'Actions') {
      commandImage = [
        BlockWithImage(imagePath: 'assets/images/sit.png', shape: Shape.action),
        BlockWithImage(imagePath: 'assets/images/lay_down.png', shape: Shape.action),
        BlockWithImage(imagePath: 'assets/images/stand.png', shape: Shape.action),
        BlockWithImage(imagePath: 'assets/images/play_dead.png', shape: Shape.action),
        BlockWithImage(imagePath: 'assets/images/bow.png', shape: Shape.action),
        BlockWithImage(imagePath: 'assets/images/beg.png', shape: Shape.action),
        BlockWithImage(imagePath: 'assets/images/howl.png', shape: Shape.action),
        BlockWithImage(imagePath: 'assets/images/wag_tail.png', shape: Shape.action),
      ];
    } else if (category == 'Variables') {
      commandImage = [
        BlockWithImage(imagePath: 'assets/images/walk.png', shape: Shape.variable1),
        BlockWithImage(imagePath: 'assets/images/turn.png', shape: Shape.variable1),
        BlockWithImage(imagePath: 'assets/images/lift_left.png', shape: Shape.variable1),
        BlockWithImage(imagePath: 'assets/images/eyes.png', shape: Shape.variable1),
        BlockWithImage(imagePath: 'assets/images/mouth.png', shape: Shape.variable1),
        BlockWithImage(imagePath: 'assets/images/forwards.png', shape: Shape.variable2),
        BlockWithImage(imagePath: 'assets/images/backwards.png', shape: Shape.variable2),
        BlockWithImage(imagePath: 'assets/images/right.png', shape: Shape.variable2),
        BlockWithImage(imagePath: 'assets/images/left.png', shape: Shape.variable2),
        BlockWithImage(imagePath: 'assets/images/front_left_leg.png', shape: Shape.variable2),
        BlockWithImage(imagePath: 'assets/images/front_right_leg.png', shape: Shape.variable2),
        BlockWithImage(imagePath: 'assets/images/back_left_leg.png', shape: Shape.variable2),
        BlockWithImage(imagePath: 'assets/images/back_right_leg.png', shape: Shape.variable2),
        BlockWithImage(imagePath: 'assets/images/open.png', shape: Shape.variable2),
        BlockWithImage(imagePath: 'assets/images/closed.png', shape: Shape.variable2),
      ];
    } else if (category == 'Control') {
      commandImage = [
        BlockWithImage(imagePath: 'assets/images/wait.png', shape: Shape.control),
      ];
    }
  });
}

  // Method to update arranged commands from CommandManager
  void _updateArrangedCommands(List<BlockData> commands) {
    setState(() {
      arrangedCommands = commands; // Update the arranged commands
      blockSequence.updateOrder(arrangedCommands); // Update block order
    });
  }

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen; // Toggle the sidebar visibility
    });
  }

  // Get local position within the workspace
  Offset _getLocalPosition(Offset globalPosition) {
    return BlockHelpers.getLocalPosition(_stackKey, globalPosition);
  }

  // Handle the update of block connections
  void _handleBlockUpdate(BlockData movedBlock) {
    setState(() {
      // Check if the block is dragged outside the workspace
      if (movedBlock.position.dx < 0 || movedBlock.position.dx > _stackKey.currentContext!.size!.width ||
          movedBlock.position.dy < 0 || movedBlock.position.dy > _stackKey.currentContext!.size!.height) {
        // Remove block if dragged outside
        arrangedCommands.removeWhere((block) => block.id == movedBlock.id);
        blockSequence.updateOrder(arrangedCommands); // Update block order
        return;
      }
      bool connected = false; // Flag to check if the block is connected

      // Check connections with other blocks
      for (var block in arrangedCommands) {
        if (block != movedBlock){ 
          if (BlockHelpers.canConnect(block, movedBlock, ConnectionType.right)) {
            BlockHelpers.establishConnection(block, movedBlock, ConnectionType.right);
            connected = true;
            break;
          } else if (BlockHelpers.canConnect(movedBlock, block, ConnectionType.right)) {
            BlockHelpers.establishConnection(movedBlock, block, ConnectionType.right);
            connected = true;
            break;
          }
        }
      }

      // If no connection is made, disconnect all
      if (!connected) {
        BlockHelpers.disconnectAll(movedBlock);
      }
      blockSequence.updateOrder(arrangedCommands); // Update block order
      blockSequence.printBlockOrder(); // Print the order of blocks
    });
  }

@override
  Widget build(BuildContext context) {
    // Retrieve the VirtualController instance from the Provider
    final virtualController = Provider.of<VirtualController>(context);

    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 88, 144, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 88, 144, 1),
        toolbarHeight: 60,
        actions: [
          // Row to hold the circular buttons
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Align(
              alignment: Alignment.bottomCenter, // Align to the bottom
              child: CategoryButtons(
                selectedCategory: selectedCategory,
                onUpdateCommands: updateCommands, // Pass the update function
              ),
            ),
          ),
          Spacer(),
          // actions Button
          Padding(padding: const EdgeInsets.only(top: 8.0, bottom: 8),
            child:ActionButtons(
              onUpload: () {
                // Handle upload action
              },
              onRun: () {
                virtualController.executeMoves(blockSequence.getBlockOrder());
              },
              onStop: () {
                virtualController.stopExecution();
              },
            ),
          ),
          const SizedBox(width: 90),
        ],
      ),
      body: Row(
        // Main layout using a Row to organize the screen
        children: [
          Expanded(
            child: Column(
              children: [
                // above button categories and image buttons
                Padding(padding: const EdgeInsets.only(left: 15.0), 
                  child:CommandManager(
            commandImages: commandImage,
                  ),
                ),
                
                const SizedBox(height: 10),
                // User's area for arranging blocks
                Expanded(
                  child:Padding(padding: EdgeInsets.only(left: 15),
                    child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      key: _containerKey, // Key to manage the container's state
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Stack(
                        key: _stackKey,
                        children: [
                          // DragTarget for accepting new blocks
                          DragTarget<BlockWithImage>(
                            onAcceptWithDetails: (details) {
                              final localPosition = _getLocalPosition(details.offset);
                              setState(() {
                                arrangedCommands.add(BlockData(
                                  imagePath: details.data.imagePath,
                                  position: localPosition,
                                  blockShape: details.data.shape,
                                ));
                                blockSequence.updateOrder(arrangedCommands);
                                blockSequence.printBlockOrder();
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.transparent, // Transparent area for drag target
                              );
                            },
                          ),
                          // Render the blocks that have been placed
                          ...arrangedCommands.map((block) {
                            return DraggableBlock(
                              blockData: block, // Pass the block data
                              onUpdate: _handleBlockUpdate, // Callback to handle block updates
                              virtualController: virtualController,
                              arrangedCommands: arrangedCommands,
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    ),
                  )
                  
                ),
                Consumer<VirtualController>(
                  builder: (context, virtualController, child) {
                    return Container(
                      width: double.infinity, // Make the container as wide as possible
                      padding: EdgeInsets.only(top:10,bottom: 20,left:15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50), // Make the shape elliptical
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                          child: Text(
                            virtualController.outcomeMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Add a small column for the sidebar toggle button
          SizedBox(
            width: 48,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isSidebarOpen
                        ? Icons.arrow_circle_right // Left arrow when sidebar is open
                        : Icons.arrow_circle_left, // Right arrow when sidebar is closed
                      size: 40.0,
                      color: Colors.black,
                  ),
                  onPressed: toggleSidebar,
                ),
              ],
            ),
          ),
          // Sidebar widget, open/closed based on state
          Sidebar(isOpen: isSidebarOpen), // Uses the Sidebar class
          // Spacer for layout
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}