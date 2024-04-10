import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

late Database db;

Future<int> addData(Map<String, Object?> json, String store) async {
  var s = intMapStoreFactory.store(store);
  return await s.add(db, json);
}

Future<void> deleteAllDatabaseData() async {
  File dataFile =
      File(join((await getApplicationDocumentsDirectory()).path, 'data.db'));
  await dataFile.delete();
}

Future<void> deleteData(int id, String store) async {
  var s = intMapStoreFactory.store(store);
  await s.record(id).delete(db);
}

Future<void> initDatabases() async {
  var dir = await getApplicationDocumentsDirectory();
  await dir.create(recursive: true);

  var dbPath = join(dir.path, 'data.db');
  db = await databaseFactoryIo.openDatabase(dbPath);
}

Future<List<RecordSnapshot<int, Map<String, Object?>>>> readAllData(
    String store, SortOrder order, int limit) async {
  var s = intMapStoreFactory.store(store);
  return await s.find(db, finder: Finder(limit: limit));
}

Future<Map<String, Object?>?> readData(int id, String store) async {
  var s = intMapStoreFactory.store(store);
  var data = await s.record(id).get(db);

  return data;
}

Future<void> updateData(Map<String, Object?> json, int id, String store) async {
  var s = intMapStoreFactory.store(store);
  await s.record(id).put(db, json);
}
