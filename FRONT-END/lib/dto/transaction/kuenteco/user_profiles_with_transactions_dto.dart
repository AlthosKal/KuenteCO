import 'profile_with_transactions_dto.dart';

class UserProfilesWithTransactionsDTO {
  final String username;
  final String email;
  final List<ProfileWithTransactionsDTO> profiles;
  final int totalProfiles;
  final int totalTransactions;

  UserProfilesWithTransactionsDTO({
    required this.username,
    required this.email,
    required this.profiles,
    required this.totalProfiles,
    required this.totalTransactions,
  });

  factory UserProfilesWithTransactionsDTO.fromJson(Map<String, dynamic> json) {
    return UserProfilesWithTransactionsDTO(
      username: json['username'],
      email: json['email'],
      profiles: (json['profiles'] as List)
          .map((item) => ProfileWithTransactionsDTO.fromJson(item))
          .toList(),
      totalProfiles: json['totalProfiles'],
      totalTransactions: json['totalTransactions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'profiles': profiles.map((item) => item.toJson()).toList(),
      'totalProfiles': totalProfiles,
      'totalTransactions': totalTransactions,
    };
  }
}
