import 'package:flutter/material.dart';

class BotChannelListItem extends StatelessWidget {
  const BotChannelListItem(
      {Key? key,
      required this.name,
      required this.type,
      required this.photo_url,
      required this.platform,
      required this.idx})
      : super(key: key);
  final String name;
  final String type;
  final String platform;
  final String photo_url;
  final int idx;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.circle),
        title: Text(name),
        subtitle: Row(
          children: [
            Icon(Icons.person),
            Text(type),
          ],
        ),
        trailing: const Icon(Icons.delete),
        onTap: () {},
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
  final List<int> _listData = [1, 2, 3, 4, 5];

  void _insertItem() {
    _listData.insert(_listData.length, 1);
    listKey.currentState?.insertItem(
      _listData.length - 1,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _itemBuilder(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    int item = _listData[index];

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
          name: 'Channel $item',
          photo_url: 'www.asd.asda',
          platform: 'line',
          type: 'User',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedList(
        key: listKey,
        initialItemCount: _listData.length,
        itemBuilder: _itemBuilder,
      ),
    );
    ;
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
            'Give the token to people or groups that wants to track you and ask them to send /register <token> to the TrackMe bot.'),
        const SizedBox(height: 20),
        const Text(
          'List of Authorized Channels',
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
