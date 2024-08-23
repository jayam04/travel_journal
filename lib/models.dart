class User {
  String id;
  String email;
  String name;
  String? profilePicture;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePicture,
  });
}
