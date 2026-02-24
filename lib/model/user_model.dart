class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;
  final String provider;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
    required this.provider,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      provider: data['provider'] ?? '',
    );
  }
}