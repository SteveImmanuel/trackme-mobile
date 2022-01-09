import 'package:flutter/material.dart';
import 'package:trackme_mobile/models/bot_channel.dart';
import 'package:trackme_mobile/models/location.dart';

class User extends ChangeNotifier {
  String username;
  List<String> aliases;
  List<Location> locations;
  List<BotChannel> botChannels;
  bool isReady;

  User()
      : isReady = false,
        username = '',
        aliases = [],
        locations = [],
        botChannels = [];

  Future<void> setData(Map<String, dynamic> data) async {
    username = data['username'];

    List aliasList = data['aliases'] as List;
    aliases = aliasList.map((alias) => alias as String).toList();

    List locationList = data['locations'] as List;
    locations =
        locationList.map((location) => Location.fromJson(location)).toList();

    List botChannelList = data['bot_channels'] as List;
    botChannels =
        botChannelList.map((channel) => BotChannel.fromJson(channel)).toList();

    isReady = true;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'aliases': aliases,
        'locations': locations.map((location) => location.toJson()).toList(),
        'bot_channels': botChannels.map((channel) => channel.toJson()).toList(),
      };

  List getListPropertyByString(String property) {
    switch(property){
      case 'Bot Channel':
        return botChannels;
      case 'Location':
        return locations;
      case 'Alias':
        return aliases;
      default:
        return [];
    }
  }
}
