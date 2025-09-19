class User {
  final String fullName;
  final String email;
  final String password;
  final String? profileImagePath;
  final bool isAdmin;

  User({
    required this.fullName,
    required this.email,
    required this.password,
    this.profileImagePath,
    this.isAdmin = false, // Default to false
  });

  User copyWith({
    String? fullName,
    String? email,
    String? password,
    String? profileImagePath,
    bool? isAdmin,
  }) {
    return User(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}