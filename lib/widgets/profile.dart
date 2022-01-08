import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackme_mobile/models/user.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final List<bool> _isActive = [false];
  final List<int> _postIntervalList = [2, 5, 10, 15, 30, 60];
  int postInterval = 10;

  void _onSwitched(int idx) {
    setState(() {
      _isActive[idx] = !_isActive[idx];
    });
  }

  void _onIntervalChanged(int? value) {
    setState(() {
      postInterval = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 1),
        Consumer<User>(
          builder: (context, user, child) {
            Widget child = Container();
            if (user.isReady) {
              child = AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Hello, ${user.username.toUpperCase()}',
                    textStyle: const TextStyle(
                      fontSize: 35,
                    ),
                    speed: const Duration(milliseconds: 200),
                  ),
                ],
                totalRepeatCount: 1,
              );
            }
            return SizedBox(
              child: child,
              height: 40,
            );
          },
        ),
        const Divider(
          thickness: 1,
        ),
        const Spacer(flex: 5),
        Text(
          _isActive[0] ? 'ON' : 'OFF',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w100,
          ),
        ),
        ToggleButtons(
          children: const [
            Icon(
              Icons.power_settings_new,
              size: 200,
            )
          ],
          onPressed: _onSwitched,
          isSelected: _isActive,
          borderRadius: BorderRadius.circular(100),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Post location every:',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: DropdownButton(
                value: postInterval,
                icon: const Icon(Icons.arrow_downward),
                items: _postIntervalList.map((int value) {
                  return DropdownMenuItem(
                    child: Text(value.toString()),
                    value: value,
                  );
                }).toList(),
                onChanged: _onIntervalChanged,
                underline: Container(height: 0.5, color: Colors.black),
              ),
            ),
            const Text('minutes'),
          ],
        ),
        const Spacer(flex: 5),
      ],
    );
  }
}
