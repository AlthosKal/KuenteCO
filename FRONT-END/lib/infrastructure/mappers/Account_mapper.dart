import 'package:kuenteco/domain/entities/account.dart';
import 'package:kuenteco/infrastructure/models/account_model.dart';

extension AccountModelMapper on AccountModel {
  Account toEntity() {
    return Account(
      id: id.toInt(),
      name: name,
      description: description,
      image: image,
    );
  }
}

extension AccountEntityMapper on Account {
  AccountModel toModel() {
    return AccountModel(
      id: id.toInt(),
      name: name,
      description: description,
      image: image,
    );
  }
}
