import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';
import 'package:trackme_mobile/models/user.dart';
import 'package:trackme_mobile/models/bot_channel.dart';

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
              Text('${type[0].toUpperCase()}${type.substring(1)}'),
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
              onTap: () => onDeleteTapped(context, idx),
            ),
          ),
        ),
        onTap: null,
      ),
    );
  }
}

class BotChannelList extends StatefulWidget {
  const BotChannelList({Key? key}) : super(key: key);

  @override
  _BotChannelListState createState() => _BotChannelListState();
}

class _BotChannelListState extends State<BotChannelList> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  late List<BotChannel> _listData = [];

  // void _reloadList() {
  //   _listData.insert(_listData.length, 1);
  //   listKey.currentState?.insertItem(
  //     _listData.length - 1,
  //     duration: const Duration(milliseconds: 300),
  //   );
  // }

  void _onConfirmDelete(BuildContext context, int idx) {
    // TODO: call api delete
    Navigator.pop(context);
  }

  void _onDeclineDelete(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _onDeleteTapped(BuildContext context, int idx) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Bot Channel'),
          content: const Text('Are you sure you want to delete bot channel X?'),
          actions: [
            TextButton(
              child: const Text('Yes'),
              onPressed: () => _onConfirmDelete(context, idx),
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () => _onDeclineDelete(context),
            )
          ],
        );
      },
    );
  }

  Widget _itemBuilder(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    BotChannel channel = _listData[index];

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: const Offset(0, 0),
      ).animate(animation),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        )),
        child: BotChannelListItem(
          idx: index,
          name: channel.displayName,
          photoUrl: channel.photoUrl,
          platform: channel.platform,
          type: 'User',
          onDeleteTapped: _onDeleteTapped,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) {
        if (!user.isReady) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator()],
          );
        }

        _listData = user.botChannels;

        return Expanded(
          child: AnimatedList(
            key: listKey,
            initialItemCount: _listData.length,
            itemBuilder: _itemBuilder,
          ),
        );
      },
    );
  }
}

class BotChannels extends StatefulWidget {
  const BotChannels({Key? key}) : super(key: key);

  @override
  _BotChannelsState createState() => _BotChannelsState();
}

class _BotChannelsState extends State<BotChannels> {
  String _token = '1234';
  bool _isGeneratingToken = false;

  Future<void> _generateNewToken() async {
    setState(() {
      _isGeneratingToken = true;
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isGeneratingToken = false;
      _token = (num.parse(_token) + 5).toString();
    });
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
                  child: CircularProgressIndicator(),
                  height: 15,
                  width: 15,
                )
              : const Icon(Icons.refresh),
        ),
        const Text(
            'Give this token to people or groups that want to track you and ask them to send /register <token> to the TrackMe bot.'),
        const SizedBox(height: 20),
        const Text(
          'Authorized Channels',
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 5),
        const BotChannelList(),
      ],
    );
  }
}
