import 'package:KuenteCO/dto/transaction/bancolombia/response/extra/thirdParty_extra.dart';

class Data {
  final ThirdParty thirdParty;
  final String fileUrl;

  Data({
    required this.thirdParty,
    required this.fileUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      thirdParty: ThirdParty.fromJson(json['thirdParty']),
      fileUrl: json['fileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thirdParty': thirdParty.toJson(),
      'fileUrl': fileUrl,
    };
  }
}
