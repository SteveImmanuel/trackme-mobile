class ConnectedAccount {
  String id;
  String photoUrl;
  String displayName;
  String platform;

  ConnectedAccount(
      this.id,
      this.photoUrl,
      this.displayName,
      this.platform,
      );

  ConnectedAccount.fromJson(Map<String, dynamic> data)
      : id = data['id'],
        photoUrl = data['photo_url'],
        displayName = data['display_name'],
        platform = data['platform'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo_url': photoUrl,
    'display_name': displayName,
    'platform': platform
  };
}
