class GUser {
  final String uid;
  final String displayName;
  final String username;
  final String email;
  final String photoURL;
  final bool isVegetarian;
  final bool isNonVegetarian;
  double? postsCount = 0;
  double? followersCount = 0;
  double? followingCount = 0;

  GUser(
      {required this.uid,
      required this.displayName,
      required this.username,
      required this.email,
      required this.photoURL,
      required this.isVegetarian,
      required this.isNonVegetarian,
      this.postsCount,
      this.followersCount,
      this.followingCount});
}
