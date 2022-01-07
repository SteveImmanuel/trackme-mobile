import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';
import 'package:trackme_mobile/models/user.dart';
import 'package:trackme_mobile/models/location.dart';

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
  late List<Location> _listData = [];

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

  // void _insertItem() {
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
    Location location = _listData[index];

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
            name: location.name,
            latitude: location.latitude,
            longitude: location.longitude,
            alertOnArrive: location.alertOnArrive,
            alertOnLeave: location.alertOnLeave,
            onDeleteTapped: _onDeleteTapped,
          )),
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

        _listData = user.locations;

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
