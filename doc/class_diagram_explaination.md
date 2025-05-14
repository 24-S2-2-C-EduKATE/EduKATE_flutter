# Application Architecture Documentation

## 1. Application Entry & State Management

### MyApp & MyAppState  
#### MyApp  
- **Inherits from**: `StatelessWidget`  
- **Responsibility**: Serves as the top-level widget of the application.  
- **Dependency**: Relies on `MyAppState`, which holds mutable state (e.g., current word pair) and provides `getNext()` to update it.  

#### MyAppState  
- **Role**: Holds the application’s dynamic data.  
- **Characteristics**: Not a widget itself; acts as the underlying state container used by `MyApp`.  


### MyHomePage & _MyHomePageState  
#### MyHomePage  
- **Inherits from**: `StatefulWidget`  
- **Responsibility**: Represents the main page container.  

#### _MyHomePageState  
- **State**: `selectedIndex` to track the active tab.  
- **Method**: The `build()` method switches between `HomePage`, `PictureBlockPage`, `WordBlockPage`, and `TextBlockPage` based on `selectedIndex`.  


### HomePage  
- **Inherits from**: `StatelessWidget`  
- **Responsibility**: Renders navigation buttons with three callbacks:  
  - `onNavigate`  
  - `onWordBlockNavigate`  
  - `onTextBlockNavigate`  


## 2. Core Data Models (`models/` & `new_block_data.dart`)  

### BlockData (Abstract Base Class)  
#### Properties  
- `id` (String)  
- `name` (String)  
- `blockShape` (Shape enum)  
- `imagePath` (String)  
- `position` (Offset)  
- `connectionPoints` (List<ConnectionPoint>)  

#### Methods  
- `toCommand(): abstract` (Serializes the block to a command string.)  


### Shape (Enum)  
- **Definition**: Defines all available block shapes (e.g., `event1`, `action`, `variable2`, etc.).  


### Concrete Blocks (Subclasses of BlockData)  
- **Includes**: `VirtualBlock`, `VariableBlock`, `ControlBlock`, `SoundBlock`, `EventBlock`, `ActionBlock`, `VisualBlock`  
- **Characteristics**: Each overrides `toCommand()`.  
  - **Example**: `VirtualBlock` returns `"VIRTUAL:$name"`.  
  - `EventBlock` may include an optional `BlockSequence`, appending its commands.  
  - `ActionBlock` can embed a customization block.  


### BlockSequence  
#### Properties  
- `blocks: List<BlockData>`  

#### Methods  
- `toCommand()`: Joins each block’s command with `" | "`.  
- Sequence management methods: `addBlock()`, `removeBlock()`, `getBlockAt()`, `updateOrder()`, `extractSubsequence()`.  


### Advanced Control Structures (`new_block_data.dart`)  
#### RepeatBlock  
- **Properties**: `repeatCount: int`, `nestedSequence: BlockSequence`  
- **Method**: `toCommand()` yields `REPEAT:count[...]`.  

#### IfElseBlock  
- **Properties**: `condition: bool`, `trueSequence` and `falseSequence` (both `BlockSequence`)  
- **Method**: `toCommand()` yields `IF:TRUE {...} ELSE {...}`.  

#### BlockCategory (Enum)  
- **Values**: `event`, `action`, `control`, `variable`, `sound`.  


## 3. Helpers & Rendering Classes  
### ConnectionType (Enum)  
- **Values**: `previous`, `next`, `input`.  

### ConnectionPoint  
#### Properties  
- `type: ConnectionType`  
- `relativeOffset: Offset`  
- `connectedBlock: BlockData?`  

#### Method  
- `getGlobalPosition(blockPosition: Offset)`: Computes the global position.  


### BlockShapePainter  
- **Inherits from**: `CustomPainter`  
- **Responsibility**: Draws each block’s custom shape onto a canvas.  


### BlockHelpers  
- **Type**: Static utility class  
- **Methods**:  
  - `snapThreshold`  
  - Connection management: `tryConnect()`, `disconnect()`, `getRightConnectedBlocks()`  
  - Functions: Manages block snapping, connection updates, chain rearrangement, and disconnection logic.  


## 4. Levels & Virtual Controller  
### VirtualTile  
- **Properties**:  
  - `index: int`  
  - `tileType: String`  

### Level  
#### Properties  
- `id: int`  
- `gridN: int` (Grid size)  
- `grid: List<VirtualTile>`  
- `dollStartX, dollStartY: int`  

#### Static Method  
- `create(id, startX, startY): Future<Level>`: Asynchronously loads and builds a level.  


### VirtualController  
- **Inherits from**: `ChangeNotifier`  
#### Properties  
- `levels: List<Level>`, `currentLevelIndex: int`  
- `babyX, babyY: int`, `activeGrid: List<VirtualTile>`  
- `isLoading: bool`, `isRunning: bool`  
- `blockSequence: BlockSequence`, `outcomeMessage: String`  

#### Methods  
- Initialization/control: `_initializeLevels()`, `moveBaby()`, `executeMoves()`, `stopExecution()`  
- Level navigation: `nextLevel()`, `previousLevel()`  
- **Responsibility**: Manages game logic and notifies listeners on state changes.  


## 5. UI Layer (`ui/` Directory)  
### CategoryButtons  
- **Inherits from**: `StatelessWidget`  
- **Props**:  
  - `selectedCategory: String`  
  - `onUpdateCommands: Function(String)`  
- **Responsibility**: Renders a row of elevated buttons to filter block categories.  


### ActionButtons  
- **Inherits from**: `StatelessWidget`  
- **Props**: `onUpload`, `onRun`, `onStop: Function()`  
- **Responsibility**: Renders three floating action buttons for upload, run, and stop actions.  


### CommandManager  
- **Inherits from**: `StatefulWidget`  
- **Props**: `commandImages: List<BlockWithImage>`  
- **State**: Holds `selectedCategory`, `selectedBlockId?`, `hoveringBlockId?`, and an `AudioPlayer`.  
- **Responsibility**: Renders a horizontal list view of draggable command images.  


### DraggableBlock  
- **Inherits from**: `StatefulWidget`  
- **Props**:  
  - `blockData: BlockData`, `onUpdate: Function(BlockData)`  
  - `virtualController: VirtualController`, `arrangedCommands: List<BlockData>`  
- **Functionality**:  
  - Handles offset, selection, and hover states.  
  - Supports drag, long-press drag into `RepeatBlockWidget`, and lighting effects on hover/selection.  


### RepeatBlockWidget  
- **Inherits from**: `StatefulWidget`  
- **Prop**: `data: RepeatBlock`  
- **Characteristics**: Uses a `GlobalKey` to measure the drop area.  
- **Responsibility**: Acts as a `DragTarget` to accept or remove child blocks from `data.nestedSequence`.  


### Sidebar  
- **Inherits from**: `StatelessWidget`  
- **Prop**: `isOpen: bool`  
- **Characteristics**: Slides in/out using an `AnimatedContainer`.  
- **Responsibility**: Reads from `VirtualController` via `Consumer` to show current level info, grid view, and "previous/next level" buttons.  


## 6. Relationship Overview  
### Inheritance  
- **Data classes**: `VirtualBlock`, `EventBlock`, etc., extend `BlockData`.  
- **UI widgets**: Extend `StatelessWidget` or `StatefulWidget`.  
- **Others**: `VirtualController` extends `ChangeNotifier`; `BlockShapePainter` extends `CustomPainter`.  


### Dependency  
- **UI → Models**:  
  - `CommandManager` uses `BlockWithImage`, `VisualBlock`.  
  - `DraggableBlock` uses `BlockData`, `VirtualController`.  
  - `Sidebar` uses `VirtualController`.  
- **Controller → Data**: `VirtualController` uses `Level`, `VirtualTile`, `BlockSequence`.  
- **Rendering → Models**: `BlockShapePainter`, `ConnectionPoint` use `BlockData`.  


### Association  
- **Complex blocks**: `EventBlock`, `RepeatBlock`, `IfElseBlock`, etc., hold references to `BlockSequence`.  
- **Customization association**: `ActionBlock` may associate with another `BlockData` for customization.  