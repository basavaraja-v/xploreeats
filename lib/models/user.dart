class GUser {
  final String uid;
  final String displayName;
  final String username;
  final String email;
  final String photoURL;
  final bool isVegetarian;
  final bool isNonVegetarian;
  num? postsCount = 0;
  num? followersCount = 0;
  num? followingCount = 0;
  List<String>? followingList = [];

  GUser({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.email,
    required this.photoURL,
    required this.isVegetarian,
    required this.isNonVegetarian,
    this.postsCount,
    this.followersCount,
    this.followingCount,
    this.followingList,
  });
}
