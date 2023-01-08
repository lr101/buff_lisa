import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveHandler<K, T> {
  late Box<T> box;


  Future<void> init(String boxName) async  {
    box = await Hive.openBox(boxName);
  }

  put(T value, {K? key}) async {
    if (key != null) {
      await box.put(key, value);
    } else {
      await box.add(value);
    }
  }

  deleteByKey(K key) async {
    await box.delete(key);
  }

  deleteByValue(T value) async {
    for (int i = 0; i < box.values.length; i++) {
      if (box.values.elementAt(i) == value) {
        await box.deleteAt(i);
      }
    }
  }

  clear() async {
    await box.clear();
  }

  Future<T?> get(String key) async => box.get(key);
  List<T> values() => box.values.toList();
  Future<List<K>> keys() async => box.keys.map((e) => e as K).toList();

}