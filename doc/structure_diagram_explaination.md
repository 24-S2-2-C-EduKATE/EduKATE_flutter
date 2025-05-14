# Project Architecture Overview

This document provides a detailed explanation of the code structure for the Flutter application, outlining its main components and how they interact.

---

## 1. App Entry and State Management

**File:** `lib/main.dart`  
**Responsibilities:**

- Initializes the Flutter application.  
- Configures global state using `MultiProvider`, injecting two providers:
  - `MyAppState`: Manages general application settings (e.g., theme, user preferences).  
  - `VirtualController`: Controls the virtual character’s movement and level execution logic.  
- Sets up `MaterialApp` and defines `MyHomePage` as the home screen.

**Collaboration:**  
- Provides state to all child widgets via `Provider.of` or `Consumer`.
- Serves as the root for navigation between feature pages.

---

## 2. Feature Page Navigation

**File:** `lib/main.dart` (continued)  
**Component:** `MyHomePage`  
**Responsibilities:**

- Renders one of four feature pages based on the integer `selectedIndex`:
  1. **HomePage** – Displays welcome content or summary statistics.  
  2. **PictureBlockPage** – The block-based image programming interface.  
  3. **WordBlockPage** – The text-block editing interface.  
  4. **TextBlockPage** – The raw text encoding interface.
- Updates `selectedIndex` when the user interacts with the navigation controls.

**Collaboration:**  
- Switches between child pages dynamically, passing the necessary providers and callbacks.

---

## 3. Picture Block Module (`lib/picture_block`)

The core block-programming feature is implemented under `lib/picture_block`, organized into three subfolders:

### 3.1 Models (`lib/picture_block/models`)

- **`block_data.dart`**  
  Defines the abstract base class `BlockData` and the `Shape` enum. All block types inherit from `BlockData`, implementing:
  - Common properties (e.g., `id`, `name`, `shape`).  
  - `toCommand()` method to serialize into a runnable command string.

- **Concrete Block Classes**  
  - `action_block.dart`: `ActionBlock` with optional nested child blocks.  
  - `event_block.dart`: `EventBlock` containing an `innerSequence`.  
  - `visual_block.dart`: `VisualBlock` providing simple visual commands.  
  - Additional classes in `new_block_data.dart` supporting loops (`RepeatBlock`), conditionals (`IfElseBlock`), and the `BlockSequence` manager.

- **Connection Logic**  
  - `connection_point.dart`: Defines `ConnectionPoint` objects and `ConnectionType` enums for snapping blocks together.

- **Rendering Helpers**  
  - `block_shape.dart`: Contains `BlockShapePainter`, a `CustomPainter` that draws shapes based on `BlockData.shape`.

- **UI Data Transfer**  
  - `block_with_image.dart`: Wraps block metadata with an image path for drag-and-drop menus.

### 3.2 Interaction Logic (`lib/picture_block/interaction`)

- **`block_sequence.dart`**  
  Manages an ordered list of blocks (`List<BlockData>`) and compiles them into a single executable script.

- **`block_helpers.dart`**  
  Utility methods for:
  - Calculating local coordinates.  
  - Checking and enforcing connection rules.  
  - Auto-aligning chains of connected blocks.

- **`virtual_controller.dart`**  
  Executes the generated command sequence by moving a virtual character and updating level state.

### 3.3 UI Components (`lib/picture_block/ui`)

- **`sidebar.dart`**: Displays categories of available commands.  
- **`category_buttons.dart`**: Toggles command categories in the sidebar.  
- **`command_manager.dart`**: Renders draggable block icons based on the current category.  
- **`dragable_block.dart`**: Renders placed blocks, supporting drag, drop, and on-the-fly repositioning.  
- **`repeat_block_widget.dart`**: Specialized widget for loop blocks with an inner drop area.  
- **`action_buttons.dart`**: Provides Run, Stop, and Upload controls, wired to `VirtualController` methods.

### 3.4 `PictureBlockPage` Main Component

**File:** `lib/picture_block/pictureblock.dart`  
**Responsibilities:**

- Initializes command icons via `updateCommands()` in `initState()`.  
- Maintains two key lists:
  - `commandImages`: Available `BlockWithImage` icons for dragging.  
  - `arrangedCommands`: Instantiated `BlockData` objects placed on the canvas.
- Delegates drag-and-drop handling to `BlockHelpers`.  
- Updates the `BlockSequence` instance as blocks are arranged or moved.  
- On Run, compiles and sends the command list to `VirtualController` for execution.


---

## 4. WordBlock and TextBlock Pages

Both pages share a similar layout pattern:

- **Files:** `lib/wordblock.dart`, `lib/textblock.dart`  
- **Structure:**  
  - A toggleable sidebar (via `toggleSidebar()`) for tool selection or navigation.  
  - A main content area for editing text blocks or raw text.  
- **Collaboration:**  
  - Receive `MyAppState` from `Provider` for theme or preferences.  
  - Use internal state to manage sidebar visibility and content updates.

---

### Summary

The architecture cleanly separates concerns into:

1. **Global State** (in `main.dart`)  
2. **Navigation Layer** (`MyHomePage`)  
3. **Feature Modules** (each page under `lib/`)  
4. **Models, Logic, and UI** (within each feature folder)  
