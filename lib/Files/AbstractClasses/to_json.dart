abstract class ToJson {
  ToJson.fromJson(Map<String, dynamic> map);
  Future<Map<String, dynamic>> toJson();
}