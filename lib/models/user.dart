class GUser {
  final String uid;
  final String displayName;
  final String username;
  final String email;
  final String photoURL;
  final String? location;
  final bool isVegetarian;
  final bool isNonVegetarian;
  final double? latitude;
  final double? longitude;
  double? postsCount = 0;
  double? followersCount = 0;
  double? followingCount = 0;

  GUser(
      {required this.uid,
      required this.displayName,
      required this.username,
      required this.email,
      required this.photoURL,
      required this.location,
      required this.isVegetarian,
      required this.isNonVegetarian,
      this.latitude,
      this.longitude,
      this.postsCount,
      this.followersCount,
      this.followingCount});
}
