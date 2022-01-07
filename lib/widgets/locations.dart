import 'package:flutter/material.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';

class LocationListItem extends StatelessWidget {
  const LocationListItem(
      {Key? key,
      required this.name,
      required this.latitude,
      required this.longitude,
      required this.alertOnLeave,
      required this.alertOnArrive,
      required this.idx,
      required this.onDeleteTapped})
      : super(key: key);

  final int idx;
  final String name;
  final String latitude;
  final String longitude;
  final bool alertOnLeave;
  final bool alertOnArrive;
  final DeleteListItem onDeleteTapped;

  String _formatCoordinates(String coordinate) {
    return num.parse(coordinate).toStringAsFixed(3);
  }

  String _boolToString(bool value) {
    return value ? 'Yes' : 'No';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Latitude: ${_formatCoordinates(latitude)}'),
                              Text(
                                  'Longitude: ${_formatCoordinates(longitude)}'),
                            ],
                          ),
                          const VerticalDivider(
                            thickness: 1,
                          ),
                          Column(
                            children: [
                              Text(
                                  'Alert on Leave: ${_boolToString(alertOnLeave)}'),
                              Text(
                                  'Alert on Arrive: ${_boolToString(alertOnArrive)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ClipOval(
                child: Material(
                  child: InkWell(
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.delete),
                    ),
                    onTap: () => onDeleteTapped(context, idx),
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () {},
      ),
    );
  }
}

class LocationList extends StatefulWidget {
  const LocationList({Key? key}) : super(key: key);

  @override
  _LocationListState createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final List<int> _listData = [];
  int tempCounter = 0;
  bool _isLoading = true;

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
          title: const Text('Delete Location'),
          content: const Text('Are you sure you want to delete location X?'),
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

  Future<void> TestSleep() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _isLoading = false;
    });

    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _insertItem();
    }
  }

  @override
  void initState() {
    super.initState();
    TestSleep();
  }

  void _insertItem() {
    _listData.insert(_listData.length, tempCounter++);
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
        child: LocationListItem(
          idx: index,
          name: 'home $item',
          latitude: '123.321231',
          longitude: '90.43434',
          alertOnArrive: true,
          alertOnLeave: true,
          onDeleteTapped: _onDeleteTapped,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [CircularProgressIndicator()],
    );

    if (!_isLoading) {
      result = Expanded(
        child: AnimatedList(
          key: listKey,
          initialItemCount: _listData.length,
          itemBuilder: _itemBuilder,
        ),
      );
    }

    return result;
  }
}

class Locations extends StatelessWidget {
  const Locations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(height: 20),
        Text(
          'Your Highlighted Locations',
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        SizedBox(height: 5),
        LocationList(),
      ],
    );
  }
}
