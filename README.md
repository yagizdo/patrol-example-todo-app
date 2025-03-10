# Patrol Example Todo App

A Flutter Todo application demonstrating the use of Patrol for integration testing.

## 📱 App Overview

This is a simple Todo application built with Flutter that allows users to:
- View a list of todos
- Add new todos
- Mark todos as completed
- Delete todos

The app serves as an example of how to implement Patrol for integration testing in a Flutter application with a clean architecture approach.

## 🏗️ Architecture

The application follows a clean architecture pattern with the following structure:

```
lib/
├── constants/       # App-wide constants
├── core/
│   ├── bl/          # Business logic
│   │   └── repositories/ # Repository implementations
│   └── locator/     # Dependency injection setup
├── features/        # Feature modules
│   ├── add_todo/    # Add todo feature
│   │   ├── cubit/   # State management
│   │   └── view/    # UI components
│   └── home/        # Home feature
│       ├── cubit/   # State management
│       └── view/    # UI components
├── models/          # Data models
└── main.dart        # App entry point
```

### State Management
- Uses **BLoC/Cubit** pattern for state management
- Each feature has its own Cubit for managing state

### Dependency Injection
- Uses **GetIt** for service locator pattern
- Services and repositories are registered in the AppLocator

## 🧪 Testing

The app includes integration tests using Patrol:

```
integration_test/
├── add_todo_test.dart    # Tests for adding todos
├── example_test.dart     # Example tests
└── test_bundle.dart      # Test bundle configuration
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.6.0)
- Dart SDK (^3.6.0)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS development)

### Clone the Repository

```bash
git clone https://github.com/yourusername/patrol_example_todo.git
cd patrol_example_todo
```

### Install Dependencies

```bash
flutter pub get
```

### Setting Up Patrol CLI

1. Install the Patrol CLI globally:

```bash
dart pub global activate patrol_cli
```

2. Make sure the Patrol CLI is in your PATH. If not, add the following to your shell profile:

```bash
# For bash (~/.bashrc) or zsh (~/.zshrc)
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

3. Verify the installation:

```bash
patrol --version
```

### Run the App

```bash
flutter run
```

### Run Integration Tests

```bash
patrol test
```

### Code Coverage

The project includes a script to generate and view code coverage reports:

```bash
# Run the coverage check script
./scripts/coverage_check.sh
```

This script:
- Runs all tests with coverage
- Filters out generated files and UI components
- Focuses on business logic files (stores, models, cubits, etc.)
- Generates an HTML report in the `coverage/html` directory
- Automatically opens the report in your default browser

To generate the report without opening it:

```bash
./scripts/coverage_check.sh --no-open
```

## 📦 Dependencies

### Main Dependencies
- **flutter_bloc**: ^9.0.0 - State management
- **dio**: ^5.8.0+1 - HTTP client
- **get_it**: ^8.0.3 - Dependency injection
- **freezed**: ^2.5.8 - Code generation for immutable classes
- **equatable**: ^2.0.7 - Equality comparisons

### Dev Dependencies
- **patrol**: ^3.14.1 - Integration testing
- **mocktail**: ^1.0.4 - Mocking for tests
- **flutter_lints**: ^5.0.0 - Linting rules

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Patrol Documentation](https://patrol.leancode.co/)
- [Flutter Bloc Documentation](https://bloclibrary.dev/)
