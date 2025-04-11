import 'package:kuenteco/domain/dto/Account_type.dart';

class AccountDetailDTO {
  final String name;
  final AccountType type;
  final int id;

  AccountDetailDTO({
    required this.name,
    required this.type,
    required this.id,
  });

  factory AccountDetailDTO.fromJson(Map<String, dynamic> json) {
    return AccountDetailDTO(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      type: AccountType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => AccountType.PERSONAL,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'id': id,
    };
  }
}
