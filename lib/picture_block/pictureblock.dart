import 'package:flutter/material.dart';
import 'package:flutter_application_1/picture_block/block_sequence.dart';
import 'package:flutter_application_1/picture_block/virtual_controller.dart';
import 'sidebar.dart'; // Import the Sidebar
import 'block_data.dart';
import 'dragable_block.dart';

class PictureBlockPage extends StatefulWidget {
  final GlobalKey<VirtualControllerState> virtualControllerKey;

  const PictureBlockPage({Key? key, required this.virtualControllerKey}) : super(key: key);

  @override
  _PictureBlockPageState createState() => _PictureBlockPageState();
}

class _PictureBlockPageState extends State<PictureBlockPage> {
  List<String> commandImages = [];
  List<BlockData> arrangedCommands = [];
  String selectedCategory = 'General'; // 默认类别
  bool isSidebarOpen = false; // 控制侧边栏的状态
  BlockSequence blockSequence = BlockSequence();

  GlobalKey _stackKey = GlobalKey(); // 用于获取工作区的大小和位置

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
          'assets/images/move_up.png',
          'assets/images/move_down.png',
          'assets/images/move_left.png',
          'assets/images/move_right.png',
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

  // 获取工作区内的本地坐标
  Offset _getLocalPosition(Offset globalPosition) {
    final RenderBox stackRenderBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
    return stackRenderBox.globalToLocal(globalPosition);
  }

  // 检测并处理积木块的连接
  void _handleBlockUpdate(BlockData movedBlock) {
  setState(() {
    // 检查是否拖出工作区
      if (movedBlock.position.dx < 0 || movedBlock.position.dx > _stackKey.currentContext!.size!.width ||
          movedBlock.position.dy < 0 || movedBlock.position.dy > _stackKey.currentContext!.size!.height) {
        // 移除被拖出工作区的积木
        arrangedCommands.removeWhere((block) => block.id == movedBlock.id);
        blockSequence.updateOrder(arrangedCommands);
        return;
    }
    bool connected = false;

    for (var block in arrangedCommands) {
      if (block != movedBlock) {
        // 检测顶部连接
        if (_canConnect(block, movedBlock, ConnectionType.bottom)) {
          _establishConnection(block, movedBlock, ConnectionType.bottom);
          connected = true;
          break;
        }
        // 检测底部连接
        else if (_canConnect(movedBlock, block, ConnectionType.bottom)) {
          _establishConnection(movedBlock, block, ConnectionType.bottom);
          connected = true;
          break;
        }
        // 检测左侧连接
        else if (_canConnect(block, movedBlock, ConnectionType.right)) {
          _establishConnection(block, movedBlock, ConnectionType.right);
          connected = true;
          break;
        }
        // 检测右侧连接
        else if (_canConnect(movedBlock, block, ConnectionType.right)) {
          _establishConnection(movedBlock, block, ConnectionType.right);
          connected = true;
          break;
        }
        // 可以添加更多连接类型
      }
    }

    // 如果没有连接，解除所有连接
    if (!connected) {
      _disconnectAll(movedBlock);
    }
    blockSequence.updateOrder(arrangedCommands);
    blockSequence.printBlockOrder();
  });
}

void _establishConnection(BlockData block1, BlockData block2, ConnectionType connectionType) {
  // 更新连接关系
  block1.connections[connectionType] = Connection(type: connectionType, connectedBlock: block2);
  block2.connections[_getOppositeConnectionType(connectionType)] = Connection(
    type: _getOppositeConnectionType(connectionType),
    connectedBlock: block1,
  );

  // 对齐位置
  switch (connectionType) {
    case ConnectionType.top:
      block2.position = block1.position - Offset(0, blockHeight);
    case ConnectionType.bottom:
      block2.position = block1.position + Offset(0, blockHeight);
    case ConnectionType.left:
      block2.position = block1.position - Offset(blockWidth, 0);
    case ConnectionType.right:
      block2.position = block1.position + Offset(blockWidth, 0);
  }
}

void _disconnectAll(BlockData block) {
  for (var connectionType in block.connections.keys.toList()) {
    var connectedBlock = block.connections[connectionType]?.connectedBlock;
    if (connectedBlock != null) {
      connectedBlock.connections.remove(_getOppositeConnectionType(connectionType));
    }
    block.connections.remove(connectionType);
  }
}

ConnectionType _getOppositeConnectionType(ConnectionType type) {
  switch (type) {
    case ConnectionType.top:
      return ConnectionType.bottom;
    case ConnectionType.bottom:
      return ConnectionType.top;
    case ConnectionType.left:
      return ConnectionType.right;
    case ConnectionType.right:
      return ConnectionType.left;
  }
}

  // 定义积木块的尺寸
double blockWidth = 100.0; // 根据实际尺寸调整
double blockHeight = 85.0; // 根据实际尺寸调整

bool _canConnect(BlockData block1, BlockData block2, ConnectionType connectionType) {
  double threshold = 20.0; // 连接距离阈值

  Offset position1, position2;

  switch (connectionType) {
    case ConnectionType.top:
      position1 = block1.position;
      position2 = block2.position + Offset(0, blockHeight);
    case ConnectionType.bottom:
      position1 = block1.position + Offset(0, blockHeight);
      position2 = block2.position;
    case ConnectionType.left:
      position1 = block1.position;
      position2 = block2.position + Offset(blockWidth, 0);
    case ConnectionType.right:
      position1 = block1.position + Offset(blockWidth, 0);
      position2 = block2.position;
  }

  if ((position1 - position2).distance <= threshold) {
    // 判断对齐（可选）
    if (connectionType == ConnectionType.left || connectionType == ConnectionType.right) {
      if ((block1.position.dy - block2.position.dy).abs() <= threshold) {
        return true;
      }
    } else {
      if ((block1.position.dx - block2.position.dx).abs() <= threshold) {
        return true;
      }
    }
  }

  return false;
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
              // 添加 Run 按钮
              ElevatedButton(
                onPressed: () {
                  // 使用 GlobalKey 调用 VirtualController 的 executeMoves
                    if (widget.virtualControllerKey.currentState != null) {
                      setState(() {
                        widget.virtualControllerKey.currentState!.executeMoves(blockSequence.getBlockOrder());
                      });
                    } else {
                      print('VirtualController 未加载');
                    }
                },
                child: const Text('Run'),
              ),
              const SizedBox(height: 10),
              // 图片按钮区域
              SizedBox(
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
                  key: _stackKey,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/picGround.jpg'), // 背景图
                      fit: BoxFit.cover, // 填充方式
                    ),
                  ),
                  child: Stack(
                    key: _stackKey,
                    children: [
                      // 接受新积木块的 DragTarget
                      DragTarget<String>(
                        onAcceptWithDetails: (details) {
                          setState(() {
                            final localPosition = _getLocalPosition(details.offset);
                            arrangedCommands.add(BlockData(
                              imagePath: details.data,
                              position: localPosition,
                            ));
                            // 更新积木顺序
                            blockSequence.updateOrder(arrangedCommands);
                            blockSequence.printBlockOrder();
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.transparent,
                          );
                        },
                      ),
                      // 已放置的积木块
                      ...arrangedCommands.map((block) {
                        return DraggableBlock(
                          blockData: block,
                          onUpdate: _handleBlockUpdate,
                        );
                      }).toList(),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: VirtualController(
                            key: widget.virtualControllerKey, // 使用传入的 GlobalKey
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 侧边栏
        Sidebar(isOpen: isSidebarOpen,virtualControllerKey: widget.virtualControllerKey), // 使用Sidebar.dart
        const SizedBox(height: 5),
      ],
    ),
  );
}
}
