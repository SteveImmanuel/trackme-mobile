import 'package:flutter/material.dart';
import 'package:trackme/utilities/custom_callback_types.dart';
import 'package:trackme/models/linked_account.dart';
import 'package:trackme/models/user.dart';
import 'package:trackme/widgets/custom_list.dart';
import 'package:trackme/widgets/token_generator.dart';
import 'package:trackme/utilities/api.dart';

class LinkedAccountListItem extends StatelessWidget {
  const LinkedAccountListItem({
    Key? key,
    required this.name,
    required this.photoUrl,
    required this.platform,
    required this.idx,
    required this.onDeleteTapped,
  }) : super(key: key);

  final String name;
  final String platform;
  final String photoUrl;
  final int idx;
  final DeleteListItem onDeleteTapped;

  @override
  Widget build(BuildContext context) {
    String icon = 'line_icon.png';
    if (platform == 'telegram') {
      icon = 'telegram_icon.png';
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(photoUrl),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/$icon',
                scale: 5.5,
              ),
              const SizedBox(width: 10),
              Text(name),
            ],
          ),
        ),
        trailing: ClipOval(
          child: Material(
            child: InkWell(
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.delete,
                  color: Colors.black87,
                ),
              ),
              onTap: () => onDeleteTapped(context, idx, name),
            ),
          ),
        ),
        onTap: null,
      ),
    );
  }
}

class LinkedAccountList extends CustomList {
  const LinkedAccountList({Key? key, required reloadUserData})
      : super(key: key, type: 'Linked Account', reloadUserData: reloadUserData);

  @override
  _LinkedAccountListState createState() => _LinkedAccountListState();
}

class _LinkedAccountListState extends CustomListState<LinkedAccountList> {
  @override
  Future<void> onConfirmDelete(BuildContext context, int idx) async {
    super.onConfirmDelete(context, idx);

    List<Map<String, dynamic>> updateData = (listData as List<LinkedAccount>)
        .map((account) => account.toJson())
        .toList();
    Map<String, dynamic> updateResult = await updateUser({
      'linked_accounts': [
        ...updateData.sublist(0, idx),
        ...updateData.sublist(idx + 1)
      ]
    });

    afterDelete(context, updateResult['code']);
  }

  @override
  List getListData(User user) {
    return user.linkedAccounts;
  }

  @override
  Widget createItem(int index) {
    LinkedAccount account = listData[index] as LinkedAccount;
    return LinkedAccountListItem(
      idx: index,
      name: account.displayName,
      photoUrl: account.photoUrl,
      platform: account.platform,
      onDeleteTapped: onDeleteTapped,
    );
  }
}

class Accounts extends StatefulWidget {
  final VoidCallback reloadUserData;

  const Accounts({Key? key, required this.reloadUserData}) : super(key: key);

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
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
        const Text(
          'Linked Accounts',
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        LinkedAccountList(reloadUserData: widget.reloadUserData)
      ],
    );
  }
}
