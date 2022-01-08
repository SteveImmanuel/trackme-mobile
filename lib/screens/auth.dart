import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:trackme_mobile/utilities/api.dart';

class Auth extends StatefulWidget {
  static String route = '/auth';

  const Auth({Key? key}) : super(key: key);

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
  bool _isLoading = false;

  void _switchType() {
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

  Future<void> _onSubmit() async {
    Map<String, dynamic> authResult;
    setState(() {
      _isLoading = true;
    });
    if (_index == 0) {
      authResult = await login(_username, _password);
    } else {
      authResult = await register(_username, _password);
    }
    setState(() {
      _isLoading = false;
      if (_index == 1) {
        _index = 0;
      } else {

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                child: Hero(
                  tag: 'trackmeBanner',
                  child: Image.asset(
                    'assets/images/trackme_banner.png',
                    width: MediaQuery.of(context).size.width * 0.7,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
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
                obscureText: true,
                onChanged: _onPasswordChanged,
              ),
              const Spacer(flex: 1),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    child: Padding(
                      child: _isLoading
                          ? const SizedBox(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black45,
                              ),
                              height: 15,
                              width: 15,
                            )
                          : Text(btnText[_index].toUpperCase()),
                      padding: const EdgeInsets.all(15),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).colorScheme.primary),
                    onPressed: _isLoading ? null : _onSubmit,
                  ),
                )
              ]),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(bottomText[_index]),
                  const SizedBox(width: 10),
                  GestureDetector(
                    child: Text(btnText[(_index - 1).abs()]),
                    onTap: _switchType,
                  ),
                ],
              ),
              const Spacer(flex: 15),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
