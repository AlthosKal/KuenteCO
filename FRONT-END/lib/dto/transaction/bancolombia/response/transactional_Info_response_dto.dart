import 'extra/data_extra.dart';
import 'extra/meta_extra.dart';

class TransactionalInfoResponse {
  final Meta meta;
  final Data data;

  TransactionalInfoResponse({
    required this.meta,
    required this.data,
  });

  factory TransactionalInfoResponse.fromJson(Map<String, dynamic> json) {
    return TransactionalInfoResponse(
      meta: Meta.fromJson(json['meta']),
      data: Data.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'data': data.toJson(),
    };
  }
}
