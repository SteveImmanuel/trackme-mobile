import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackme_mobile/models/user.dart';

class CustomAnimatedList extends StatefulWidget {
  const CustomAnimatedList({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  CustomAnimatedListState createState() => CustomAnimatedListState();
}

class CustomAnimatedListState<T extends CustomAnimatedList> extends State<T> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  late List listData = [];

  void onConfirmDelete(BuildContext context, int idx) {
    Navigator.pop(context);
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

  Widget baseItemBuilder(
    BuildContext context,
    int index,
    Animation<double> animation,
    Widget child,
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
          child: child),
    );
  }

  Widget itemBuilder(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    return Container();
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

        if (listData.length > 0) {
          return Expanded(
            child: AnimatedList(
              key: listKey,
              initialItemCount: listData.length,
              itemBuilder: itemBuilder,
            ),
          );
        }

        return Expanded(child:Text('Once you add ${widget.type.toLowerCase()}, it will be shown here'));

      },
    );
  }
}
