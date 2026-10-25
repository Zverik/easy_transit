import 'package:easy_transit/models/bookmark.dart';
import 'package:easy_transit/models/destination.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

final databaseProvider = FutureProvider<Database>((_) => DatabaseHelper._().database);

class DatabaseHelper {
  static const _kDatabaseName = 'every_door.db';

  DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await createDatabase();
    return _db!;
  }

  Future<Database> createDatabase() async {
    return await openDatabase(_kDatabaseName, version: 2, onCreate: initDatabase, onUpgrade: upgradeDatabase);
  }

  void initDatabase(Database database, int version) async {
    await database.execute("create table ${Bookmark.kTableName} (${Bookmark.kTableColumns.join(',')})");
    if (version >= 2) createTablesV2(database);
  }

  void upgradeDatabase(Database database, int oldVersion, int newVersion) async {
    if (newVersion >= 2 && oldVersion < 2) {
      createTablesV2(database);
    }
  }

  Future<void> createTablesV2(Database database) async {
    await database.execute("create table ${StoredDestination.kTableName} (${StoredDestination.kTableColumns.join(',')})");
  }
}
