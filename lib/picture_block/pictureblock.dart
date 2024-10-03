import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/block_sequence.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'package:provider/provider.dart';
import 'sidebar.dart'; // Import the Sidebar
import 'block_data.dart';
import 'dragable_block.dart';
import 'block_helpers.dart';
import 'command_manager.dart';
import 'category_buttons.dart';
import 'action_buttons.dart';

class PictureBlockPage extends StatefulWidget {
  const PictureBlockPage({Key? key}) : super(key: key);

  @override
  _PictureBlockPageState createState() => _PictureBlockPageState();
}

class _PictureBlockPageState extends State<PictureBlockPage> {
  List<String> commandImages = []; // List to hold the command image paths
  List<BlockData> arrangedCommands = []; // List to hold the arranged blocks
  String selectedCategory = 'Events'; // Default category for command images
  bool isSidebarOpen = false; // State to control sidebar visibility
  BlockSequence blockSequence = BlockSequence(); // Instance of BlockSequence to manage block order

  GlobalKey _stackKey = GlobalKey(); // Key for the stack to get its size and position
  final GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    updateCommands(selectedCategory); // Load command images initially
  }

  void updateCommands(String category) {
    setState(() {
      selectedCategory = category; // Update the selected category
      // Load command images based on the selected category
      if (category == 'Events') {
        commandImages = [
          'assets/images/follow.jpg',
          'assets/images/lift_leg.jpg',
          'assets/images/noseButton.jpg',
          'assets/images/sound.png',
          'assets/images/start.jpg',
          'assets/images/wait.jpg',
          'assets/images/cry.jpg',
          'assets/images/right.jpg',
        ];
      } else if (category == 'Virtual') {
        commandImages = [
          'assets/images/start_virtual.png',
          'assets/images/move_up.png',
          'assets/images/move_down.png',
          'assets/images/move_left.png',
          'assets/images/move_right.png',
        ];
      } else if (category == 'Actions') {
        commandImages = [
          'assets/images/lift_leg.jpg', // Example image
          'assets/images/sound.png',
        ];
      }else if (category == 'Variables') {
        commandImages = [
          'assets/images/lift_leg.jpg', // Example image
          'assets/images/sound.png',
        ];
      }else if (category == 'Control') {
        commandImages = [
          'assets/images/lift_leg.jpg', // Example image
          'assets/images/sound.png',
        ];
      }else if (category == 'Sound') {
        commandImages = [
          'assets/images/lift_leg.jpg', // Example image
          'assets/images/sound.png',
        ];
      }
      // More categories can be added here
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
        if (block != movedBlock) {
          if (BlockHelpers.canConnect(block, movedBlock, ConnectionType.bottom)) {
            BlockHelpers.establishConnection(block, movedBlock, ConnectionType.bottom);
            connected = true;
            break;
          } else if (BlockHelpers.canConnect(movedBlock, block, ConnectionType.bottom)) {
            BlockHelpers.establishConnection(movedBlock, block, ConnectionType.bottom);
            connected = true;
            break;
          } else if (BlockHelpers.canConnect(block, movedBlock, ConnectionType.right)) {
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
                    onUpdateCommands: updateCommands,
                    commandImages: commandImages,
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
                          DragTarget<String>( 
                            onAcceptWithDetails: (details) {
                              final localPosition = _getLocalPosition(details.offset); // Get local position of the dropped block
                              setState(() {
                                arrangedCommands.add(BlockData(
                                  imagePath: details.data, // Path of the dropped image
                                  position: localPosition, // Position to place the block
                                ));
                                // Update the sequence of blocks
                                blockSequence.updateOrder(arrangedCommands);
                                blockSequence.printBlockOrder(); // Print the current order of blocks
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isSidebarOpen
                      ? Icons.arrow_circle_right // Left arrow when sidebar is open
                      : Icons.arrow_circle_left, // Right arrow when sidebar is closed
                    size: 30.0,
                ),
                onPressed: toggleSidebar,
              ),
            ],
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