import 'package:flutter/material.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';
import 'package:trackme_mobile/widgets/custom_animated_list.dart';
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
                    onTap: () => onDeleteTapped(context, idx, name),
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

class LocationList extends CustomAnimatedList {
  const LocationList({Key? key}) : super(key: key, type: 'Location');

  @override
  _LocationListState createState() => _LocationListState();
}

class _LocationListState extends CustomAnimatedListState<LocationList> {
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
    Location location = listData[index] as Location;
    Widget child = LocationListItem(
      idx: index,
      name: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
      alertOnArrive: location.alertOnArrive,
      alertOnLeave: location.alertOnLeave,
      onDeleteTapped: onDeleteTapped,
    );
    return baseItemBuilder(context, index, animation, child);
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
