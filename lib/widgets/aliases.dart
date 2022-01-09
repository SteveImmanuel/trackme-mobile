import 'package:flutter/material.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';
import 'package:trackme_mobile/widgets/custom_list.dart';
import 'package:trackme_mobile/utilities/api.dart';

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
              onTap: () => onDeleteTapped(context, idx, name),
            ),
          ),
        ),
      ),
    );
  }
}

class AliasList extends CustomList {
  const AliasList({Key? key, required reloadUserData})
      : super(key: key, type: 'Alias', reloadUserData: reloadUserData);

  @override
  _AliasListState createState() => _AliasListState();
}

class _AliasListState extends CustomListState<AliasList> {
  @override
  Future<void> onConfirmDelete(BuildContext context, int idx) async {
    await updateAlias({
      'aliases': [...listData.sublist(0, idx), ...listData.sublist(idx + 1)],
    });
    super.onConfirmDelete(context, idx);
  }

  @override
  Widget createItem(int index) {
    String alias = listData[index] as String;

    return AliasListItem(
      idx: index,
      name: alias,
      onDeleteTapped: onDeleteTapped,
    );
  }
}

class Aliases extends StatelessWidget {
  final VoidCallback reloadUserData;

  const Aliases({Key? key, required this.reloadUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Your Aliases',
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'TrackMe Bot will recognize these aliases as you if any of them is mentioned in the authorized chat channels',
        ),
        const SizedBox(height: 5),
        AliasList(reloadUserData: reloadUserData),
      ],
    );
  }
}
