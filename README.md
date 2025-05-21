# EduKate

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
