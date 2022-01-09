import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackme_mobile/models/user.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';

class CustomList extends StatefulWidget {
  const CustomList({
    Key? key,
    required this.type,
    required this.reloadUserData,
  }) : super(key: key);
  final ReloadUserData reloadUserData;
  final String type;

  @override
  CustomListState createState() => CustomListState();
}

class CustomListState<T extends CustomList> extends State<T> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  late List listData = [];

  Future<void> onConfirmDelete(BuildContext context, int idx) async {
    Navigator.pop(context);
    widget.reloadUserData();
  }

  void onDeclineDelete(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> onDeleteTapped(BuildContext context, int idx, String name) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${widget.type}'),
          content: Text(
              'Are you sure you want to delete ${widget.type.toLowerCase()} $name?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () => onDeclineDelete(context),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () => onConfirmDelete(context, idx),
            ),
          ],
        );
      },
    );
  }

  Widget createItem(int index) {
    return Container();
  }

  Widget itemBuilder(
    BuildContext context,
    int index,
  ) {
    return createItem(index);
  }

  Future<void> _onRefresh(BuildContext context) async {
    return widget.reloadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) {
        if (!user.isReady) {
          return Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [CircularProgressIndicator()],
            ),
            padding: const EdgeInsets.only(top: 15),
          );
        }
        listData = user.getListPropertyByString(widget.type);

        Widget child = ListView(
          children: [
            Container(
              child: Text(
                  'Once you add ${widget.type.toLowerCase()}, it will be shown here'),
              alignment: Alignment.center,
            )
          ],
          physics: const AlwaysScrollableScrollPhysics(),
        );
        if (listData.isNotEmpty) {
          child = ListView.builder(
            itemBuilder: itemBuilder,
            itemCount: listData.length,
            physics: const AlwaysScrollableScrollPhysics(),
          );
        }

        return Expanded(
          child: RefreshIndicator(
            displacement: 10,
            child: child,
            onRefresh: () => _onRefresh(context),
          ),
        );
      },
    );
  }
}
