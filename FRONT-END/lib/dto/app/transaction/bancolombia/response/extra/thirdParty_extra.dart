import 'identification_extra.dart';

class ThirdParty {
  final Identification identification;

  ThirdParty({
    required this.identification,
  });

  factory ThirdParty.fromJson(Map<String, dynamic> json) {
    return ThirdParty(
      identification: Identification.fromJson(json['identification']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identification': identification.toJson(),
    };
  }
}
