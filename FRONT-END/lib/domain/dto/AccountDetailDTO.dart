
import 'package:kuenteco/domain/dto/New_Account_DTO.dart';

class AccountDetailDTO {
  final String name;
  final AccountType type;

  AccountDetailDTO({
    required this.name,
    required this.type,
  });

  factory AccountDetailDTO.fromJson(Map<String, dynamic> json) {
    return AccountDetailDTO(
      name: json['name'] ?? '',
      type: AccountType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => AccountType.PERSONAL, // Fallback seguro
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
    };
  }
}
