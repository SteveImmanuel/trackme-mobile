import 'package:flutter/material.dart';
import 'package:trackme/utilities/api.dart';
import 'package:trackme/widgets/token_generator.dart';

class Account extends StatefulWidget {
  final VoidCallback reloadUserData;

  const Account({Key? key, required this.reloadUserData}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const TokenGenerator(
          generateToken: generateUserToken,
          tokenType: 'User',
        ),
        RichText(
          text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              text:
                  'Don\'t share this token to anyone! This token is used to link your account to TrackMe mobile app. Send ',
              children: const [
                TextSpan(
                  text: '/me <token>',
                  style: TextStyle(
                      fontFamily: 'RobotoMono',
                      backgroundColor: Colors.black12),
                ),
                TextSpan(text: ' to the TrackMe bot.')
              ]),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
