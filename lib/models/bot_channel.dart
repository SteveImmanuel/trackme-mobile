class BotChannel {
  String id;
  String type;
  String photoUrl;
  String displayName;
  String platform;
  bool indirectMentionNotif;

  BotChannel(
    this.id,
    this.type,
    this.photoUrl,
    this.displayName,
    this.platform,
    this.indirectMentionNotif,
  );

  BotChannel.fromJson(Map<String, dynamic> data)
      : id = data['id'],
        type = data['type'],
        photoUrl = data['photo_url'],
        displayName = data['display_name'],
        platform = data['platform'],
        indirectMentionNotif = data['indirect_mention_notif'] ?? false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'photo_url': photoUrl,
        'display_name': displayName,
        'platform': platform,
        'indirect_mention_notif': indirectMentionNotif
      };
}
