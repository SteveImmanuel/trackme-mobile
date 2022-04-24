import 'package:flutter/material.dart';
import 'package:trackme/models/bot_channel.dart';
import 'package:trackme/models/linked_account.dart';
import 'package:trackme/models/location.dart';

class User extends ChangeNotifier {
  String username;
  List<String> aliases;
  List<Location> locations;
  List<BotChannel> botChannels;
  List<LinkedAccount> linkedAccounts;
  bool isReady;

  User()
      : isReady = false,
        username = '',
        aliases = [],
        locations = [],
        botChannels = [],
        linkedAccounts = [];

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

    List linkedAccountList = data['linked_accounts'] as List;
    linkedAccounts = linkedAccountList
        .map((account) => LinkedAccount.fromJson(account))
        .toList();

    isReady = true;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'aliases': aliases,
        'locations': locations.map((location) => location.toJson()).toList(),
        'bot_channels': botChannels.map((channel) => channel.toJson()).toList(),
      };
}
