import 'profile_with_transactions_dto.dart';

class UserProfilesWithTransactionsDTO {
  final String? username;
  final String? email;
  final List<ProfileWithTransactionsDTO>? profiles;
  final int? totalProfiles;
  final int? totalTransactions;

  UserProfilesWithTransactionsDTO({
    this.username,
    this.email,
    this.profiles,
    this.totalProfiles,
    this.totalTransactions,
  });

  factory UserProfilesWithTransactionsDTO.fromJson(Map<String, dynamic> json) {
    return UserProfilesWithTransactionsDTO(
      username: json['username'],
      email: json['email'],
      profiles: json['profiles'] != null
          ? (json['profiles'] as List)
              .map((item) => ProfileWithTransactionsDTO.fromJson(item))
              .toList()
          : null,
      totalProfiles: json['totalProfiles'],
      totalTransactions: json['totalTransactions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'profiles': profiles?.map((item) => item.toJson()).toList(),
      'totalProfiles': totalProfiles,
      'totalTransactions': totalTransactions,
    };
  }
}
