import 'package:flutter/material.dart';
import 'package:trackme/screens/choose_location.dart';
import 'package:trackme/utilities/custom_callback_types.dart';
import 'package:trackme/utilities/route_arguments.dart';
import 'package:trackme/widgets/custom_list.dart';
import 'package:trackme/models/location.dart';
import 'package:trackme/utilities/api.dart';

class LocationListItem extends StatelessWidget {
  const LocationListItem({
    Key? key,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.alertOnLeave,
    required this.alertOnArrive,
    required this.idx,
    required this.onDeleteTapped,
    required this.onUpdateLocation,
  }) : super(key: key);

  final int idx;
  final String name;
  final String latitude;
  final String longitude;
  final bool alertOnLeave;
  final bool alertOnArrive;
  final DeleteListItem onDeleteTapped;
  final OnUpdateLocation onUpdateLocation;

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
                    onTap: () => onDeleteTapped(context, idx, name),
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () => onUpdateLocation(context, idx),
      ),
    );
  }
}

class LocationList extends CustomList {
  const LocationList({Key? key, required reloadUserData})
      : super(key: key, type: 'Location', reloadUserData: reloadUserData);

  @override
  _LocationListState createState() => _LocationListState();
}

class _LocationListState extends CustomListState<LocationList> {
  void _onUpdateLocation(BuildContext context, int idx) {
    Navigator.pushNamed(context, ChooseLocation.route,
        arguments: LocationArgs(
          callback: widget.reloadUserData,
          currentLocationList: listData as List<Location>,
          currentIndex: idx,
          parentContext: context
        ));
  }

  @override
  Future<void> onConfirmDelete(BuildContext context, int idx) async {
    super.onConfirmDelete(context, idx);

    List<Map<String, dynamic>> updateData = (listData as List<Location>)
        .map((location) => location.toJson())
        .toList();

    Map<String,dynamic> updateResult = await updateUser({
      'locations': [
        ...updateData.sublist(0, idx),
        ...updateData.sublist(idx + 1)
      ]
    });

    afterDelete(context, updateResult['code']);
  }

  @override
  Widget createItem(int index) {
    Location location = listData[index] as Location;
    return LocationListItem(
      idx: index,
      name: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
      alertOnArrive: location.alertOnArrive,
      alertOnLeave: location.alertOnLeave,
      onDeleteTapped: onDeleteTapped,
      onUpdateLocation: _onUpdateLocation,
    );
  }
}

class Locations extends StatelessWidget {
  final VoidCallback reloadUserData;

  const Locations({Key? key, required this.reloadUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Your Highlighted Locations',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LocationList(reloadUserData: reloadUserData),
      ],
    );
  }
}
