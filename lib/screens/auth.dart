import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Auth extends StatefulWidget {
  final String title;

  const Auth({Key? key, required this.title}) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

const List<String> btnText = ['Login', 'Register'];
const List<String> bottomText = [
  'Don\'t have an account?',
  'Already have an account?'
];

class _AuthState extends State<Auth> {
  int _index = 0;
  String _username = '';
  String _password = '';

  void _switchType() {
    print(_username);
    print(_password);
    setState(() {
      _index = (1 - _index).abs();
    });
  }

  void _onUsernameChanged(text) {
    _username = text;
  }

  void _onPasswordChanged(text) {
    _password = text;
  }

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              // padding: const EdgeInsets.all(20),
              // shrinkWrap: true,
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 7),
                // Image.asset('assets/a.jpg',),

                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                  ),
                  onChanged: _onUsernameChanged,
                ),
                const Spacer(flex: 1),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  onChanged: _onPasswordChanged,
                ),
                const Spacer(flex: 1),
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text(btnText[_index]),
                      onPressed: () => {},
                    ),
                  )
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 9),
                    Text(bottomText[_index]),
                    const Spacer(flex: 1),
                    GestureDetector(
                      child: Text(btnText[(_index - 1).abs()]),
                      onTap: _switchType,
                    ),
                    const Spacer(flex: 9),
                  ],
                ),
                const Spacer(flex: 15),
              ],
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
