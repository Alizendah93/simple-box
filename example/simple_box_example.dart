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
              (SimpleBoxState state) => SafeArea(
                child: Column(
                  children: [
                    Text('Simple Box Example !'),
                    if (state is LoadingState)
                      Center(child: CircularProgressIndicator()),
                    ElevatedButton(
                      onPressed: () => loginBox.mockLogin(),
                      child: Text(
                        state is LoadingState ? 'Loading...' : 'Mock Login',
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

  // Use pre defined states like loading, error, success, and more
  //And also you can define your own like follows

  // class MyDefinedState extends SimpleBoxState  {}
}
