import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveHandler<K, T> {
  late Box<T> box;

  static Future<HiveHandler<K,T>> fromInit<K,T>(String boxName) async {
    HiveHandler<K,T> box = HiveHandler<K,T>();
    await box.init(boxName);
    return box;
  }


  Future<void> init(String boxName) async  {
    box = await Hive.openBox(boxName);
  }

  Future<void> put(T value, {K? key}) async {
    if (key != null) {
      await box.put(key, value);
    } else {
      await box.add(value);
    }
  }

  Future<void> deleteByKey(K key) async {
    await box.delete(key);
  }

  Future<void> deleteByValue(T value) async {
    for (int i = 0; i < box.values.length; i++) {
      if (box.values.elementAt(i) == value) {
        await box.deleteAt(i);
      }
    }
  }

  Future<void> clear() async {
    await box.clear();
  }

  T? get(String key) => box.get(key);
  List<T> values() => box.values.toList();
  Future<List<K>> keys() async => box.keys.map((e) => e as K).toList();

}