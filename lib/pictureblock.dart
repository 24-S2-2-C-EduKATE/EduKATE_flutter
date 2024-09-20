import 'package:flutter/material.dart';
import 'sidebar.dart'; // Import the Sidebar


class PictureBlockPage extends StatefulWidget {
  @override
  _PictureBlockPageState createState() => _PictureBlockPageState();
}

class _PictureBlockPageState extends State<PictureBlockPage> {
  List<String> commandImages = [];
  List<String> arrangedCommands = [];
  String selectedCategory = 'General'; // 默认类别
  bool isSidebarOpen = false; // 控制侧边栏的状态

  @override
  void initState() {
    super.initState();
    updateCommands(selectedCategory); // 初始加载命令图片
  }

  void updateCommands(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'General') {
        commandImages = [
          'assets/images/follow.jpg',
          'assets/images/lift_leg.jpg',
          'assets/images/noseButton.jpg',
          'assets/images/sound.jpg',
          'assets/images/start.jpg',
          'assets/images/wait.jpg',
          'assets/images/cry.jpg',
          'assets/images/right.jpg',
        ];
      } else if (category == 'Category 1') {
        commandImages = [
          'assets/images/follow.jpg', // 示例图片
        ];
      } else if (category == 'Category 2') {
        commandImages = [
          'assets/images/lift_leg.jpg', // 示例图片
        ];
      }
      // 可以添加更多类别
    });
  }

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture Block Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_double_arrow_right_outlined),
            onPressed: toggleSidebar,
          ),
        ],
      ),

      body: Row(
        // 总的
        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // 顶部类别按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => updateCommands('General'),
                      child: const Text('General'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => updateCommands('Category 1'),
                      child: const Text('Category 1'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => updateCommands('Category 2'),
                      child: const Text('Category 2'),
                    ),
                    // 可以添加更多类别按钮
                  ],
                ),
                const SizedBox(height: 10),
                // 图片按钮区域
                Container(
                  height: 85, // 设置固定高度
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8, // 
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 85, // 每个单元格的高度
                    ),
                    itemCount: commandImages.length,
                    itemBuilder: (context, index) {
                      return Draggable<String>(
                        data: commandImages[index],
                        feedback: Material(
                          child: SizedBox(
                            height: 85,
                            child: Image.asset(
                              commandImages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          child: Image.asset(
                            commandImages[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // 用户排列区域
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/picGround.jpg'), // 背景图
                        fit: BoxFit.cover, // 填充方式
                      ),
                    ),
                    child: DragTarget<String>(
                      onAccept: (data) {
                        setState(() {
                          arrangedCommands.add(data);
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 10.0,
                            mainAxisExtent: 85,
                          ),
                          itemCount: arrangedCommands.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 85,
                              child: Image.asset(
                                arrangedCommands[index],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 侧边栏
          Sidebar(isOpen: isSidebarOpen), // 使用Sidebar.dart
        ],
      ),
    );
  }
}