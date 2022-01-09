import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:trackme_mobile/utilities/gps.dart';
import 'package:trackme_mobile/utilities/api.dart';
import 'package:location/location.dart';
import 'package:trackme_mobile/models/user.dart';
import 'package:trackme_mobile/utilities/snackbar_factory.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final List<bool> _isActive = [false];
  final List<int> _postIntervalList = [2, 5, 10, 15, 30, 60];
  int postInterval = 10;
  bool _isLoading = false;

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

  Future<void> _onSubmitLocation(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    LocationData currentLocation = await getCurrentLocation();
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      Map<String, dynamic> postResult = await postLocation(
        currentLocation.latitude.toString(),
        currentLocation.longitude.toString(),
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      SnackBar snackBar;
      if (postResult['code'] == 200) {
        snackBar = SnackBarFactory.create(
          duration: 1000,
          type: SnackBarType.success,
          content: 'Post Location Success',
        );
      } else {
        snackBar = SnackBarFactory.create(
          duration: 1000,
          type: SnackBarType.failed,
          content: 'Post Location Failed',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      _isLoading = false;
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
        ElevatedButton(
          onPressed: _isLoading ? null : () => _onSubmitLocation(context),
          child: _isLoading
              ? const SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black45,
                  ),
                  height: 15,
                  width: 15,
                )
              : const Text('POST NOW'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(100, 37)),
        ),
        const Spacer(flex: 5),
      ],
    );
  }
}
