// DO NOT USE, NOT READY
// currently there is issue with updating the list because the data came from
// provider and I updated it on build method. However, animated list maintains
// its own internal state, so to update the data I need to update the list state
// as well and that is too much to handle for now. Since this is my first big
// flutter project from complete scratch, I'll leave it as it is for now.
// Might come back in the future if I find new solution.

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:trackme_mobile/models/user.dart';
// import 'package:trackme_mobile/utilities/custom_callback_types.dart';

// class CustomAnimatedList extends StatefulWidget {
//   const CustomAnimatedList({
//     Key? key,
//     required this.type,
//     required this.reloadUserData,
//   }) : super(key: key);
//   final ReloadUserData reloadUserData;
//   final String type;
//
//   @override
//   CustomAnimatedListState createState() => CustomAnimatedListState();
// }
//
// class CustomAnimatedListState<T extends CustomAnimatedList> extends State<T> {
//   final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
//   late List listData = [];
//
//   void onConfirmDelete(BuildContext context, int idx) {
//     // listKey.currentState?.removeItem(
//     //   idx,
//     //   (context, animation) => itemBuilder(context, idx, animation),
//     // );
//     // removeAll(context);
//     Navigator.pop(context);
//     widget.reloadUserData();
//   }
//
//   void onDeclineDelete(BuildContext context) {
//     Navigator.pop(context);
//   }
//
//   Future<void> onDeleteTapped(BuildContext context, int idx, String name) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete ${widget.type}'),
//           content: Text(
//               'Are you sure you want to delete ${widget.type.toLowerCase()} $name?'),
//           actions: [
//             TextButton(
//               child: const Text('No'),
//               onPressed: () => onDeclineDelete(context),
//             ),
//             TextButton(
//               child: const Text('Yes'),
//               onPressed: () => onConfirmDelete(context, idx),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> removeAll(BuildContext context) async {
//     for (int i = 0; i < listData.length; i++) {
//       listKey.currentState?.removeItem(
//         listData.length - i - 1,
//         (context, animation) =>
//             itemBuilder(context, listData.length - i - 1, animation),
//         duration: const Duration(milliseconds: 300),
//       );
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }
//
//   Future<void> insertAll(BuildContext context) async {
//     for (int i = 0; i < listData.length; i++) {
//       listKey.currentState?.insertItem(
//         i,
//         duration: const Duration(milliseconds: 300),
//       );
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }
//
//   Widget baseItemBuilder(
//     BuildContext context,
//     int index,
//     Animation<double> animation,
//     Widget child,
//   ) {
//     return SlideTransition(
//       position: Tween<Offset>(
//         begin: const Offset(-1, 0),
//         end: const Offset(0, 0),
//       ).animate(animation),
//       child: FadeTransition(
//           opacity: Tween<double>(
//             begin: 0,
//             end: 1,
//           ).animate(CurvedAnimation(
//             parent: animation,
//             curve: Curves.easeIn,
//           )),
//           child: child),
//     );
//   }
//
//   Widget itemBuilder(
//     BuildContext context,
//     int index,
//     Animation<double> animation,
//   ) {
//     return Container();
//   }
//
//   Future<void> _onRefresh(BuildContext context) async {
//     print(listData);
//     await removeAll(context);
//     await widget.reloadUserData();
//     await insertAll(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<User>(
//       builder: (context, user, child) {
//         // if (!user.isReady) {
//         //   return Padding(
//         //     child: Row(
//         //       mainAxisAlignment: MainAxisAlignment.center,
//         //       children: const [CircularProgressIndicator()],
//         //     ),
//         //     padding: const EdgeInsets.only(top: 15),
//         //   );
//         // }
//         listData = user.getListPropertyByString(widget.type);
//
//         Widget child = ListView(
//           children: [
//             Container(
//               child: Text(
//                   'Once you add ${widget.type.toLowerCase()}, it will be shown here'),
//               alignment: Alignment.center,
//             )
//           ],
//           physics: const AlwaysScrollableScrollPhysics(),
//         );
//         Widget = ListView.builder(itemBuilder: ,)
//         if (listData.isNotEmpty) {
//           child = AnimatedList(
//             key: listKey,
//             initialItemCount: listData.length,
//             itemBuilder: itemBuilder,
//             physics: const AlwaysScrollableScrollPhysics(),
//           );
//         }
//         // insertAll(context);
//         // print(listData);
//
//         return Expanded(
//           child: RefreshIndicator(
//             displacement: 10,
//             child: child,
//             onRefresh: () => _onRefresh(context),
//           ),
//         );
//       },
//     );
//   }
// }
