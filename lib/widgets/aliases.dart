import 'package:flutter/material.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';
import 'package:trackme_mobile/widgets/custom_animated_list.dart';

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

class AliasList extends CustomAnimatedList {
  const AliasList({Key? key}) : super(key: key, type: 'Alias');

  @override
  _AliasListState createState() => _AliasListState();
}

class _AliasListState extends CustomAnimatedListState<AliasList> {
  @override
  void onConfirmDelete(BuildContext context, int idx) {
    // TODO: implement onConfirmDelete
    super.onConfirmDelete(context, idx);
  }

  @override
  Widget itemBuilder(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    String alias = listData[index] as String;
    Widget child = AliasListItem(
      idx: index,
      name: alias,
      onDeleteTapped: onDeleteTapped,
    );
    return baseItemBuilder(context, index, animation, child);
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
          'TrackMe Bot will recognize these aliases as you if any of them is mentioned in the authorized chat channels',
        ),
        SizedBox(height: 5),
        AliasList(),
      ],
    );
  }
}
