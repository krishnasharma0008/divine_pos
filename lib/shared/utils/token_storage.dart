import 'package:hive/hive.dart';

class TokenStorage {
  static const _boxName = 'authBox';
  static const _authKey = 'user';

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_authKey, user);
  }

  static Future<dynamic> getUser() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_authKey);
  }

  static Future<void> clearUser() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_authKey);
  }
}
