import 'package:kuenteco/domain/dto/Account_type.dart';

class NewAccountDTO {
  final String name;
  final AccountType type;

  NewAccountDTO({
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
    };
  }
}
