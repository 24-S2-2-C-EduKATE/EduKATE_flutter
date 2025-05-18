## About the Project

EduKATE is a cross-platform visual programming education platform built with Flutter. Its goal is to help young girls and programming beginners develop computational thinking and master basic programming skills through both graphical and textual programming interfaces.

The project adopts a modular, layered architecture and supports multiple platforms.

---

## Prerequisites (with VS Code)

### What are Flutter and Dart?

**Flutter SDK:** A cross-platform development toolkit from Google that lets you build Android, iOS, Web, and desktop apps from a single codebase. It includes tools for UI building, compilation, debugging, and deployment.

**Dart Language:** The programming language used by Flutter to define UI logic, user interactions, animations, etc. Dart is installed automatically with the Flutter SDK.

### 1. Install Flutter SDK

Install from: https://flutter.dev/docs/get-started/install

After installation, open your terminal and run:

```bash
flutter doctor
```

This command checks your system for:

- Flutter SDK
- Dart
- Android SDK or Xcode
- VS Code extensions

If any red crosses appear, follow the suggestions to complete the setup.

### 2. Install VS Code and Extensions

Note:
- The Flutter SDK provides core tools to build and run apps.
- The VS Code extensions add Flutter support to the editor (auto-complete, error highlighting, debugging, etc.)

Steps:

1. Download VS Code: https://code.visualstudio.com/
2. Open VS Code → Click the Extensions icon (on the sidebar)
3. Install:
   - Flutter
   - Dart

These extensions allow you to:

- Get real-time code suggestions
- Run and debug your app directly from the editor
- Detect dependency changes in pubspec.yaml

### 3. Install Git (for downloading the code)

Git is used to download and manage the project code.

Download: https://git-scm.com/

Verify installation:

```bash
git --version
```

---

## Installation and Setup

### Step 1: Clone the Project Repository

To download the EduKATE project using VS Code:

1. Open VS Code
2. Click the Source Control icon on the left
3. Select Clone Repository
4. Paste the following URL:

```
https://github.com/24-S2-2-C-EduKATE/EduKATE_flutter.git
```

5. Choose a folder → Click "Open" when prompted

### Step 2: Install Dependencies

Once the project opens, VS Code will show a blue popup:

"Run 'flutter pub get'?"

Click “Get packages” or “Yes” to automatically install all required packages.

If it doesn’t appear, open the terminal and run:

```bash
flutter pub get
```

### Step 3: Run the Project

1. Click the Run and Debug icon on the left sidebar (or use Cmd + Shift + D / Ctrl + Shift + D)
2. In the top input bar, type and select:

```
> Flutter: Select Device
```

3. Choose your target device: Chrome (to run in browser)
4. Click the blue "Run and Debug" button to launch the app

### Troubleshooting

- **Flutter SDK not found:**
  - Open Command Palette (Cmd/Ctrl + Shift + P)
  - Search `Flutter: Change SDK`
  - Select the Flutter SDK path (e.g., `/Users/yourname/flutter`)

---

## Main Features & Modules

### 1. Multi-Page Navigation & Global State Management

- Entry Point: `lib/main.dart`

- State Management:
  - Uses Provider for global state
  - `MyAppState` manages general app state
  - `VirtualController` handles virtual character behavior and level logic

- Navigation:
  - `MyHomePage` contains a `NavigationRail` (side navigation bar)
  - Switches between four main functional pages:
    - HomePage
    - Picture Block (Graphical Programming)
    - Word Block (Word-based Programming)
    - Text Coding (Text-based Programming)

### 2. Picture Block Module (Graphical Programming)

- Directory: `lib/picture_block/`
  - Subdivided into `models/`, `interaction/`, and `ui/`

- Key Features:
  - Drag-and-drop block-based programming with support for:
    - Events
    - Actions
    - Loops
    - Conditionals
    - Variables
    - Sounds
  - Blocks can be nested and sequenced to form complex logic
  - Virtual character and level-based challenges

- Core Files:
  - `models/`:
    - Defines block types like `BlockData`, `ActionBlock`, `EventBlock`, `RepeatBlock`, `IfElseBlock`
    - Includes connection point and shape data
    - Contains level-related models
  - `interaction/`:
    - Implements block drag & drop, snapping logic, and sequence management
    - `BlockSequence`: manages ordered block chains
    - `VirtualController`: manages character movement, command execution, and level switching
  - `ui/`:
    - Implements UI components like:
      - Sidebar
      - CategoryButtons
      - CommandManager
      - DraggableBlock and RepeatBlockWidget
      - ActionButtons (Run, Stop, Upload)
  - `pictureblock.dart`:
    - Acts as the main entry for this module
    - Manages placed blocks and execution flow

### 3. Word Block & Text Coding Modules (This module is under development)

- Files:
  - `lib/wordblock.dart`
  - `lib/textblock.dart`

- Features:
  - Word Block:
    - Uses natural-language-like blocks for beginner-friendly programming
  - Text Coding:
    - Provides a raw code editor interface (Python-like syntax)

- UI Structure:
  - Toggleable sidebar with tool selections
  - Central editor area for block or code composition

---

## Technical Architecture Details

### 1. Layered Structure

- Global State Layer:
  - Injected via Provider in `main.dart`
  - Shared by all modules and UI pages

- Navigation & Page Layer:
  - Handled by `MyHomePage` and `NavigationRail`
  - Each page is independent and feature-specific

- Feature Module Layer:
  - Each functional module (PictureBlock, WordBlock, TextBlock) has clear separation between:
    - Data models
    - Interaction logic
    - UI rendering

### 2. Block Data Model (for Picture Block)

- `BlockData` (Abstract Class):
  - Shared properties for all block types:
    - `id`, `name`, `shape`, `imagePath`, `position`, `connectionPoints`
  - Serialization method: `toCommand`

- Concrete Block Types:
  - `ActionBlock`
  - `EventBlock`
  - `VisualBlock`
  - `RepeatBlock`
  - `IfElseBlock`

- `BlockSequence`:
  - Maintains the order of blocks
  - Supports add, remove, reordering, and command generation

- Connection Logic:
  - `ConnectionPoint` and `ConnectionType` are used to define how blocks snap and nest

### 3. Interaction & Control Logic

- `BlockHelpers`:
  - Static utility methods for:
    - Aligning blocks
    - Establishing and removing connections
    - Auto-layout of block chains

- `VirtualController`:
  - Orchestrates block execution and level management
  - Moves virtual character on tile map
  - Supports level switching and execution interruption

- `Level` & `VirtualTile`:
  - Level data defines the map, character start/goal positions
  - Used for gamified task progression

### 4. UI & User Interaction

- Sidebar / CategoryButtons:
  - Block categories with visual grouping

- CommandManager:
  - Maintains placed block states and relationships

- DraggableBlock / RepeatBlockWidget:
  - Fully interactive drag-and-drop experience
  - Highlighting, nesting, reordering supported

- ActionButtons:
  - Run, Stop, Upload functions
  - Communicates with `VirtualController` for execution

---

## Documentation & References

- Flutter Docs: https://flutter.dev/docs
- For additional technical breakdowns and class relationships, please refer to:
  - `doc/structure_diagram_explaination.md`
  - `doc/class_diagram_explaination.md`
