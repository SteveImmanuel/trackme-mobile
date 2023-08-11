import 'package:flutter/material.dart';
import 'package:trackme/utilities/custom_callback_types.dart';
import 'package:trackme/models/bot_channel.dart';
import 'package:trackme/models/user.dart';
import 'package:trackme/widgets/custom_list.dart';
import 'package:trackme/widgets/token_generator.dart';
import 'package:trackme/utilities/api.dart';
import 'package:trackme/utilities/snackbar_factory.dart';

class BotChannelListItem extends StatefulWidget {
  final int idx;
  final String name;
  final String type;
  final String platform;
  final String photoUrl;
  final DeleteListItem onDeleteTapped;
  final bool indirectMentionNotif;
  final UpdateIndirectNotif onUpdateIndirectNotif;

  const BotChannelListItem({
    Key? key,
    required this.idx,
    required this.name,
    required this.type,
    required this.photoUrl,
    required this.platform,
    required this.onDeleteTapped,
    required this.indirectMentionNotif,
    required this.onUpdateIndirectNotif,
  }) : super(key: key);

  @override
  State<BotChannelListItem> createState() => _BotChannelListItemState();
}

class _BotChannelListItemState extends State<BotChannelListItem> {
  late bool isNotifOn = widget.indirectMentionNotif;

  void _toggleIndirectNotif(BuildContext context, bool value) {
    widget.onUpdateIndirectNotif(context, widget.idx, value);
    setState(() {
      isNotifOn = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    String icon = 'line_icon.png';
    if (widget.platform == 'telegram') {
      icon = 'telegram_icon.png';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 12, 0),
              child: CircleAvatar(
                radius: 23,
                backgroundImage: NetworkImage(widget.photoUrl),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: Image.asset(
                            'assets/images/$icon',
                            scale: 5.5,
                          ),
                          height: 25,
                          width: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(widget.type),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: widget.type == 'Group',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Switch(
                            onChanged: (bool value) => {
                              _toggleIndirectNotif(context, value),
                            },
                            value: isNotifOn,
                          ),
                          height: 25,
                          width: 30,
                        ),
                        const SizedBox(width: 10),
                        const Text('Mention Notification'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ClipOval(
                child: Material(
                  child: InkWell(
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.delete,
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () => widget.onDeleteTapped(
                      context,
                      widget.idx,
                      widget.name,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BotChannelList extends CustomList {
  const BotChannelList({Key? key, required reloadUserData})
      : super(key: key, type: 'Bot Channel', reloadUserData: reloadUserData);

  @override
  _BotChannelListState createState() => _BotChannelListState();
}

class _BotChannelListState extends CustomListState<BotChannelList> {
  Future<void> _updateIndirectNotif(
      BuildContext context, int idx, bool value) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.create(
      duration: 3000000,
      type: SnackBarType.loading,
      content: 'Updating ${widget.type}',
    ));

    List<Map<String, dynamic>> updateData = (listData as List<BotChannel>)
        .map((channel) => channel.toJson())
        .toList();
    updateData[idx]['indirect_mention_notif'] = value;

    Map<String, dynamic> updateResult = await updateUser({
      'bot_channels': updateData,
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (updateResult['code'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.create(
        duration: 1000,
        type: SnackBarType.success,
        content: 'Update ${widget.type} Success',
      ));
    } else if (updateResult['code'] != 401) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.create(
        duration: 1000,
        type: SnackBarType.failed,
        content: 'Update ${widget.type} Failed',
      ));
    }
    widget.reloadUserData();
  }

  @override
  Future<void> onConfirmDelete(BuildContext context, int idx) async {
    super.onConfirmDelete(context, idx);

    List<Map<String, dynamic>> updateData = (listData as List<BotChannel>)
        .map((channel) => channel.toJson())
        .toList();

    Map<String, dynamic> updateResult = await updateUser({
      'bot_channels': [
        ...updateData.sublist(0, idx),
        ...updateData.sublist(idx + 1)
      ]
    });

    afterDelete(context, updateResult['code']);
  }

  @override
  List getListData(User user) {
    return user.botChannels;
  }

  @override
  Widget createItem(int index) {
    BotChannel channel = listData[index] as BotChannel;
    return BotChannelListItem(
      idx: index,
      name: channel.displayName,
      photoUrl: channel.photoUrl,
      platform: channel.platform,
      type: channel.type,
      indirectMentionNotif: channel.indirectMentionNotif,
      onDeleteTapped: onDeleteTapped,
      onUpdateIndirectNotif: _updateIndirectNotif,
    );
  }
}

class BotChannels extends StatefulWidget {
  final VoidCallback reloadUserData;

  const BotChannels({Key? key, required this.reloadUserData}) : super(key: key);

  @override
  _BotChannelsState createState() => _BotChannelsState();
}

class _BotChannelsState extends State<BotChannels> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const TokenGenerator(
          generateToken: generateChannelToken,
          tokenType: 'Channel',
        ),
        RichText(
          text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              text:
                  'Give this token to people or groups that want to track you and ask them to send ',
              children: const [
                TextSpan(
                  text: '/register <token>',
                  style: TextStyle(
                      fontFamily: 'RobotoMono',
                      backgroundColor: Colors.black12),
                ),
                TextSpan(text: ' to the TrackMe bot.')
              ]),
        ),
        const SizedBox(height: 20),
        const Text(
          'Authorized Channels',
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 5),
        BotChannelList(reloadUserData: widget.reloadUserData),
      ],
    );
  }
}
