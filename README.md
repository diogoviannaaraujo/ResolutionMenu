# ResolutionMenu

A simple macOS menubar app that displays all connected displays and their available resolutions.

## Building

### Using Swift Package Manager

```bash
swift build -c release
```

### Using Tuist

1. Install Tuist (if not already installed):
   ```bash
   brew tap tuist/tuist
   brew install --formula tuist
   ```

2. Generate the Xcode project:
   ```bash
   tuist generate
   ```

3. Open the generated project/workspace and run from Xcode.


## Running

```bash
swift run
```

Or run the release build:

```bash
.build/release/ResolutionMenu
```

## Features

- Shows a menubar icon with a display symbol
- Lists all connected displays
- Shows all available resolutions for each display
- Marks the current resolution with a checkmark (✓)
- Displays refresh rates when available
- **Click any resolution to instantly change your display settings**
- Automatically refreshes the menu after resolution changes

## Requirements

- macOS 11.0 or later
- Swift 5.9 or later

## Project Architecture

The project follows a clean architecture pattern with clear separation of concerns:

```
Sources/ResolutionMenu/
├── main.swift              # Application entry point
├── AppDelegate.swift       # Application lifecycle management
├── Models/
│   └── DisplayResolution.swift  # Data models for display and resolution information
└── Services/
    ├── DisplayService.swift     # Handles display queries and resolution retrieval
    └── MenuBuilder.swift        # Builds and configures the status bar menu
```

### Components

#### `main.swift`
- Minimal entry point that initializes the NSApplication and AppDelegate
- Starts the application run loop

#### `AppDelegate.swift`
- Manages the application lifecycle
- Creates and configures the status bar item
- Coordinates between services
- Handles application-level actions (quit)

#### `Models/DisplayResolution.swift`
- `DisplayResolution`: Represents a single resolution with width, height, and refresh rate
- `DisplayInfo`: Encapsulates all information about a display including available resolutions

#### `Services/DisplayService.swift`
- Queries connected displays using Core Graphics APIs
- Retrieves available resolutions for each display
- Filters duplicate resolutions and sorts them by size
- Provides clean abstraction over Core Graphics display APIs

#### `Services/MenuBuilder.swift`
- Constructs the NSMenu with display information
- Formats resolution strings with proper checkmarks and spacing
- Separates menu building logic from application lifecycle

### Design Principles

- **Separation of Concerns**: Each component has a single, well-defined responsibility
- **Testability**: Services are isolated and can be tested independently
- **Maintainability**: Clear structure makes it easy to locate and modify code
- **Dependency Injection**: Services are injected rather than hardcoded
- **Documentation**: All public APIs are documented with Swift documentation comments


