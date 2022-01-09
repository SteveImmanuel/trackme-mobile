import 'package:flutter/material.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';
import 'package:trackme_mobile/models/bot_channel.dart';
import 'package:trackme_mobile/widgets/custom_list.dart';
import 'package:trackme_mobile/utilities/api.dart';

class BotChannelListItem extends StatelessWidget {
  const BotChannelListItem({
    Key? key,
    required this.name,
    required this.type,
    required this.photoUrl,
    required this.platform,
    required this.idx,
    required this.onDeleteTapped,
  }) : super(key: key);

  final String name;
  final String type;
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
        title: Text(name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/$icon',
                scale: 5.5,
              ),
              const SizedBox(width: 5),
              Text(type),
            ],
          ),
        ),
        trailing: ClipOval(
          child: Material(
            child: InkWell(
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.delete),
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

class BotChannelList extends CustomList {
  const BotChannelList({Key? key, required reloadUserData})
      : super(key: key, type: 'Bot Channel', reloadUserData: reloadUserData);

  @override
  _BotChannelListState createState() => _BotChannelListState();
}

class _BotChannelListState extends CustomListState<BotChannelList> {
  @override
  void onConfirmDelete(BuildContext context, int idx) {
    // TODO: implement onConfirmDelete
    super.onConfirmDelete(context, idx);
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
      onDeleteTapped: onDeleteTapped,
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
  String _token = '-';
  bool _isGeneratingToken = false;

  Future<void> _generateNewToken() async {
    setState(() {
      _isGeneratingToken = true;
    });
    Map<String, dynamic> tokenResult = await generateBotToken();
    if (tokenResult['code'] == 200) {
      setState(() {
        _isGeneratingToken = false;
        _token = tokenResult['detail']['token'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Your Token',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 25,
          ),
        ),
        Text(
          _token,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 50,
          ),
        ),
        ElevatedButton(
          onPressed: _isGeneratingToken ? null : _generateNewToken,
          child: _isGeneratingToken
              ? const SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black45,
                  ),
                  height: 15,
                  width: 15,
                )
              : const Icon(Icons.refresh),
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
                TextSpan(text: ' to the TrackMe bot')
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
