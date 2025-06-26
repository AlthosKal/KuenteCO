import '../api_client.dart';

class ProfileService {
  final _api = ApiClient();

  Future<void> getAllProfiles()async{
  await _api.getApp('')}

  Future<void> createProfile(String userId) async {
    await _api.postApp('/register/$userId',dto.toJson());}

    Future<void> updateProfile(String userId) async {
      await _api.putApp('//$userId');}

  Future<void> deleteProfile(String userId) async {
    await _api.deleteApp('/$userId');}
}

