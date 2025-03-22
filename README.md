# 📦 SimpleBox

[![pub package](https://img.shields.io/pub/v/simple_box.svg)](https://pub.dev/packages/simple_box)

A lightweight, intuitive state management solution for Flutter applications using streams with automatic reference counting. SimpleBox makes state management simple! 🚀

## ✨ Features

- 🔄 Stream-based state management
- 🧩 Simple API with minimal boilerplate
- 🔌 Automatic reference counting and disposal
- 🎯 Type-safe state updates
- 🏗️ Pre-defined common states (Loading, Error, Success)
- 🔄 Easily share state between multiple widgets
- 📱 Perfect for small to medium-sized applications

## 📋 Table of Contents

- [Installation](#-installation)
- [Basic Usage](#-basic-usage)
- [Core Concepts](#-core-concepts)
- [Advanced Usage](#-advanced-usage)
- [Best Practices](#-best-practices)

## 📥 Installation

Add SimpleBox to your `pubspec.yaml` file:

```yaml
dependencies:
  simple_box: ^1.0.3
```

Then run:

```bash
flutter pub get
```

## 🚀 Basic Usage

### 1️⃣ Create a SimpleBox

Create a class that extends `SimpleBox` and define methods to update the state:

```dart
import 'package:simple_box/simple_box.dart';

class LoginBox extends SimpleBox<SimpleBoxState> {
  void mockLogin() async {
    // Send loading state to the UI
    updateState(LoadingState());
    
    // Perform login operation
    await Future.delayed(Duration(seconds: 2));
    
    // Send success state to the UI
    updateState(SuccessState());
  }
  
  void loginWithCredentials(String username, String password) async {
    updateState(LoadingState());
    
    try {
      // Your authentication logic here
      await Future.delayed(Duration(seconds: 1));
      
      if (username == 'admin' && password == 'password') {
        updateState(SuccessState(data: {'user': username}));
      } else {
        updateState(ErrorState(message: 'Invalid credentials'));
      }
    } catch (e) {
      updateState(ErrorState(message: e.toString()));
    }
  }
}
```

### 2️⃣ Use SimpleBoxWidget in your UI

Use the `SimpleBoxWidget` to connect your UI with the SimpleBox:

```dart
import 'package:flutter/material.dart';
import 'package:simple_box/simple_box.dart';

class LoginScreen extends StatelessWidget {
  // Create an instance of your SimpleBox
  final LoginBox loginBox = LoginBox();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SimpleBoxWidget<SimpleBoxState>(
        simpleBox: loginBox,
        listener: (state) {
          // Handle state changes (show dialogs, navigate, etc.)
          if (state is SuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login successful!')),
            );
          } else if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'An error occurred')),
            );
          }
        },
        builder: (state) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('SimpleBox Login Example', 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),
                // Show loading indicator when in loading state
                if (state is LoadingState)
                  CircularProgressIndicator(),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => loginBox.mockLogin(),
                  child: Text(state is LoadingState ? 'Loading...' : 'Login'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

## 🧠 Core Concepts

### SimpleBoxState

The base class for all states in your application. SimpleBox comes with several pre-defined states:

- `InitialState`: The default state when a SimpleBox is created
- `LoadingState`: Indicates a loading operation
- `ErrorState`: Represents an error with an optional message
- `SuccessState`: Indicates a successful operation with optional data
- `LoadingDialogState`, `ErrorDialogState`, `SuccessDialogState`: Specialized states for showing dialogs
- `RebuildScreenState`: A utility state to force UI rebuilds

You can create your own custom states by extending `SimpleBoxState`:

```dart
class UserState extends SimpleBoxState {
  final User user;
  UserState(this.user);
}
```

### SimpleBox

The core class that manages state and provides methods to update it. It uses a broadcast stream to notify listeners of state changes and implements reference counting for automatic disposal.

### SimpleBoxWidget

A StatefulWidget that connects your UI to a SimpleBox. It:

- Automatically manages the SimpleBox's reference count
- Listens to state changes and rebuilds the UI
- Provides optional callbacks for state changes

## 🔄 Advanced Usage

### Sharing State Between Widgets

You can share a SimpleBox instance between multiple widgets to share state:

```dart
// Create a singleton instance
class CounterBox extends SimpleBox<SimpleBoxState> {
  static final CounterBox _instance = CounterBox._internal();
  factory CounterBox() => _instance;
  CounterBox._internal();
  
  int _count = 0;
  
  void increment() {
    _count++;
    updateState(SuccessState(data: _count));
  }
}

// Use the same instance in multiple widgets
final counterBox = CounterBox();

// Widget 1
SimpleBoxWidget<SimpleBoxState>(
  simpleBox: counterBox,
  builder: (state) => Text('Count: ${state is SuccessState ? state.data : 0}'),
)

// Widget 2
SimpleBoxWidget<SimpleBoxState>(
  simpleBox: counterBox,
  builder: (state) => ElevatedButton(
    onPressed: () => counterBox.increment(),
    child: Text('Increment'),
  ),
)
```

### Custom State Types

Create specialized state classes for different screens or features:

```dart
class AuthState extends SimpleBoxState {}

class LoggedInState extends AuthState {
  final User user;
  LoggedInState(this.user);
}

class LoggedOutState extends AuthState {}

class AuthBox extends SimpleBox<AuthState> {
  void login(String username) {
    updateState(LoggedInState(User(username)));
  }
  
  void logout() {
    updateState(LoggedOutState());
  }
}
```

## 🛠️ Best Practices

### Reference Counting

SimpleBox uses reference counting to automatically dispose of resources when they're no longer needed:

- Each `SimpleBoxWidget` automatically increments the reference count when created
- When a `SimpleBoxWidget` is disposed, it decrements the reference count
- When the reference count reaches zero, the SimpleBox is disposed

### Avoid Memory Leaks

To prevent memory leaks:

- Don't keep unnecessary references to SimpleBox instances
- Let the reference counting system handle disposal
- If you manually add references with `addReference()`, ensure you call `removeReference()` when done

### Type Safety

Use generics to ensure type safety:

```dart
class CounterBox extends SimpleBox<CounterState> {
  void increment() {
    if (currentState is CounterState) {
      final current = currentState as CounterState;
      updateState(CounterState(current.count + 1));
    }
  }
}
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/Alizendah93/simple-box/issues).

## 💖 Support

If you find this package helpful, please give it a star on [GitHub](https://github.com/Alizendah93/simple-box)!


