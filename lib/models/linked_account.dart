class LinkedAccount {
  String id;
  String photoUrl;
  String displayName;
  String platform;

  LinkedAccount(
      this.id,
      this.photoUrl,
      this.displayName,
      this.platform,
      );

  LinkedAccount.fromJson(Map<String, dynamic> data)
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
