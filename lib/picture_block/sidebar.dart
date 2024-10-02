import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatelessWidget {
  final bool isOpen;
  
  Sidebar({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: isOpen ? 300 : 0,
      child: Drawer(
        child: isOpen
            ? Consumer<VirtualController>(
                builder: (context, virtualController, child) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Current Level: ${virtualController.currentLevel?.id ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: virtualController.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Column(
                                children: [
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: virtualController.currentLevel!.gridN,
                                        ),
                                        itemCount: virtualController.activeGrid.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: const Color.fromARGB(255, 238, 213, 113)),
                                            ),
                                            child: Image.asset(
                                              'assets/blocks/${virtualController.activeGrid[index].tileType}.png',
                                              fit: BoxFit.fill,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      SizedBox(height: 50), // Negative space to move buttons up
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 40,
                              width: 125,
                              child: ElevatedButton(
                                onPressed: virtualController.previousLevel,
                                child: const Text('Previous Level', style: TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 231, 152, 178),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              width: 125, 
                              child: ElevatedButton(
                                onPressed: virtualController.nextLevel,
                                child: const Text('Next Level', style: TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 231, 152, 178),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              )
            : null,
      ),
    );
  }
}