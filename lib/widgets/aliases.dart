import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';
import 'package:trackme_mobile/models/user.dart';

class AliasListItem extends StatelessWidget {
  const AliasListItem({
    Key? key,
    required this.name,
    required this.idx,
    required this.onDeleteTapped,
  }) : super(key: key);

  final int idx;
  final String name;
  final DeleteListItem onDeleteTapped;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
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
      ),
    );
  }
}

class AliasList extends StatefulWidget {
  const AliasList({Key? key}) : super(key: key);

  @override
  _AliasListState createState() => _AliasListState();
}

class _AliasListState extends State<AliasList> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  late List<String> _listData;

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
          title: const Text('Delete Alias'),
          content: const Text('Are you sure you want to delete alias X?'),
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

  // void _reloadList() {
  //   _listData.insert(_listData.length, tempCounter++);
  //   listKey.currentState?.insertItem(
  //     _listData.length - 1,
  //     duration: const Duration(milliseconds: 300),
  //   );
  // }

  Widget _itemBuilder(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
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
        child: AliasListItem(
          idx: index,
          name: _listData[index],
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

        _listData = user.aliases;

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

class Aliases extends StatelessWidget {
  const Aliases({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(height: 20),
        Text(
          'Your Aliases',
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'TrackMe Bot will recognize these aliases as you if any of them is mentioned in authorized chat channels',
        ),
        SizedBox(height: 5),
        AliasList(),
      ],
    );
  }
}
