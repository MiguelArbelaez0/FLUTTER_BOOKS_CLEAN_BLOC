import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/book.dart';
import '../models/book_model.dart';

class BookLocalDataSource {
  BookLocalDataSource(this._preferences);
  final SharedPreferences _preferences;
  static const _key = 'bookish_favorites_v1';

  List<Book> readFavorites() {
    final stored = _preferences.get(_key);
    if (stored is! String) return [];
    try {
      final decoded = jsonDecode(stored);
      if (decoded is! List) return [];
      final seen = <String>{};
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(BookModel.fromJson)
          .map((model) => model.toEntity())
          .where((book) => book.id.isNotEmpty && seen.add(book.id))
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> saveFavorites(List<Book> books) async {
    try {
      final saved = await _preferences.setString(
        _key,
        jsonEncode(
          books.map((book) => BookModel.fromEntity(book).toJson()).toList(),
        ),
      );
      if (!saved) throw StateError('Favorites write failed');
    } catch (_) {
      // Reload the plugin cache after a rejected write; never report false success.
      try {
        await _preferences.reload();
      } catch (_) {
        /* Preserve original failure. */
      }
      rethrow;
    }
  }
}
