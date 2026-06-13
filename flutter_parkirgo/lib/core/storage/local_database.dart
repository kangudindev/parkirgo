import 'package:hive_flutter/hive_flutter.dart';

class LocalDatabase {
  LocalDatabase._();

  static const String appBoxName = 'parkirgo_app';
  static const String syncBoxName = 'parkirgo_sync';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(appBoxName);
    await Hive.openBox(syncBoxName);
  }
}
