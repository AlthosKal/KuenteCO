import 'package:kuenteco/domain/entities/Account.dart';
import 'package:kuenteco/infrastructure/models/Account_model.dart';

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
