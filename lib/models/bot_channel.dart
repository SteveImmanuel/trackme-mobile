class BotChannel {
  String id;
  String type;
  String photoUrl;
  String displayName;

  BotChannel(this.id, this.type, this.photoUrl, this.displayName);

  BotChannel.fromJson(Map<String, dynamic> data)
      : id = data['id'],
        type = data['type'],
        photoUrl = data['photo_url'],
        displayName = data['display_name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'photo_url': photoUrl,
        'display_name': displayName
      };
}
