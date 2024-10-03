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
      padding: EdgeInsets.only(right: 10,bottom: 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Drawer(
          child: isOpen
              ? Consumer<VirtualController>(
                  builder: (context, virtualController, child) {
                    return Column(
                      children: [
                        SizedBox(height: 16), 
                        Expanded(
                          child: Column(
                            children: [
                              Flexible(
                                flex: 5, // adjust the height of yellow background
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.yellow[100],
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Current Level: ${virtualController.currentLevel?.id ?? 'N/A'}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: virtualController.isLoading
                                              ? Center(child: CircularProgressIndicator())
                                              : Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: AspectRatio(
                                                    aspectRatio: 1,
                                                    child: GridView.builder(
                                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: virtualController.currentLevel!.gridN,
                                                        childAspectRatio: 1,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(flex: 1), // the position of the previous and next
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: ElevatedButton(
                                          onPressed: virtualController.previousLevel,
                                          child: const Text('Previous level', style: TextStyle(fontSize: 14)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 231, 152, 178),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: ElevatedButton(
                                          onPressed: virtualController.nextLevel,
                                          child: const Text('Next level', style: TextStyle(fontSize: 14)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 231, 152, 178),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30), // height to the buttom
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )
              : null,
        ),
        ),
    );
  }
}