## Features

Simple state management solution that uses streams.

## Usage

dependencies:
simple_box: ^1.0.0

```dart
import 'package:flutter/material.dart';
import 'package:simple_box/simple_box.dart';

void main() {
  runApp(LoginScreen());
}

class LoginScreen extends StatelessWidget {
  // Make instance of your Simple box
  final LoginBox loginBox = LoginBox();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SimpleBoxWidget(
          listener: (SimpleBoxState state) {
            // Do Anything here like dialogs ,routing...
          },
          builder:
              (SimpleBoxState state) =>
              SafeArea(
                child: Column(
                  children: [
                    Text('Simple Box Example !'),
                    if (state is LoadingState)
                      Center(child: CircularProgressIndicator()),
                    ElevatedButton(
                      onPressed: () => loginBox.mockLogin(),
                      child: Text(
                        state is LoadingDialogState
                            ? 'Loading...'
                            : 'Mock Login',
                      ),
                    ),
                  ],
                ),
              ),
          simpleBox: loginBox,
        ),
      ),
    );
  }
}

//create a class and extend SimpleBox
class LoginBox extends SimpleBox {
  void mockLogin() async {
    //sending loading state to the UI
    updateState(LoadingState());
    //mocking login operation
    await Future.delayed(Duration(seconds: 2));
    //sending success state to the UI
    updateState(SuccessState());
  }
}

```


