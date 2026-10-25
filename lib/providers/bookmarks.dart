import 'package:easy_transit/models/bookmark.dart';
import 'package:easy_transit/providers/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookmarkProvider = NotifierProvider<BookmarksController, List<Bookmark>>(BookmarksController.new);

class BookmarksController extends Notifier<List<Bookmark>> {
  @override
  List<Bookmark> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final db = await ref.read(databaseProvider.future);
    var bookmarks = await db.query(Bookmark.kTableName, orderBy: 'id');
    state = [for (var b in bookmarks) Bookmark.fromJson(b)];
  }

  Future<void> add(Bookmark bookmark) async {
    final db = await ref.read(databaseProvider.future);
    final positions = await db.rawQuery('select max(position) from ${Bookmark.kTableName}');
    bookmark.position = (positions.firstOrNull?.values.firstOrNull as int?) ?? 1;
    bookmark.id = await db.insert(Bookmark.kTableName, bookmark.toJson());
    state = [...state, bookmark];
  }

  Future<void> remove(Bookmark bookmark) async {
    state = state.where((e) => e != bookmark).toList();
    if (bookmark.id != null) {
      final db = await ref.read(databaseProvider.future);
      await db.delete(Bookmark.kTableName, where: 'id = ?', whereArgs: [bookmark.id]);
    }
  }
}
