class BotChannel {
  String id;
  String type;
  String photoUrl;
  String displayName;
  String platform;

  BotChannel(
    this.id,
    this.type,
    this.photoUrl,
    this.displayName,
    this.platform,
  );

  BotChannel.fromJson(Map<String, dynamic> data)
      : id = data['id'],
        type = data['type'],
        photoUrl = data['photo_url'],
        displayName = data['display_name'],
        platform = data['platform'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'photo_url': photoUrl,
        'display_name': displayName,
        'platform': platform
      };
}
