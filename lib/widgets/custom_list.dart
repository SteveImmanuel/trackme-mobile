import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackme/models/user.dart';
import 'package:trackme/utilities/custom_callback_types.dart';
import 'package:trackme/utilities/snackbar_factory.dart';

class CustomList extends StatefulWidget {
  final ReloadUserData reloadUserData;
  final String type;
  final String emptyListMessage;

  const CustomList({
    Key? key,
    required this.type,
    required this.reloadUserData,
    this.emptyListMessage = '',
  }) : super(key: key);

  @override
  CustomListState createState() => CustomListState();
}

class CustomListState<T extends CustomList> extends State<T> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  late List listData = [];

  Future<void> onConfirmDelete(BuildContext context, int idx) async {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.create(
      duration: 3000000,
      type: SnackBarType.loading,
      content: 'Deleting ${widget.type}',
    ));
  }

  void afterDelete(BuildContext context, int resultCode) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (resultCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.create(
        duration: 1000,
        type: SnackBarType.success,
        content: 'Delete ${widget.type} Success',
      ));
    } else if (resultCode != 401) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.create(
        duration: 1000,
        type: SnackBarType.failed,
        content: 'Delete ${widget.type} Failed',
      ));
    }
    widget.reloadUserData();
  }

  void onDeclineDelete(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> onDeleteTapped(
      BuildContext parentContext, int idx, String name) {
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
              onPressed: () => onConfirmDelete(parentContext, idx),
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

  List getListData(User user) {
    throw UnimplementedError();
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

        listData = getListData(user);
        String emptyListMessage =
            'Once you add ${widget.type.toLowerCase()}, it will be shown here';
        if (widget.emptyListMessage != '') {
          emptyListMessage = widget.emptyListMessage;
        }

        Widget child = ListView(
          children: [
            Container(
              child: Text(emptyListMessage),
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
