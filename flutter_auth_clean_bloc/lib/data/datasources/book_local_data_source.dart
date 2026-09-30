import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/book.dart';

class BookLocalDataSource {
  BookLocalDataSource(this._preferences);
  final SharedPreferences _preferences;
  static const _key = 'bookish_favorites_v1';

  List<Book> readFavorites() {
    final stored = _preferences.getString(_key);
    if (stored == null) return [];
    try {
      return (jsonDecode(stored) as List)
          .whereType<Map<String, dynamic>>()
          .map(Book.fromJson)
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> saveFavorites(List<Book> books) => _preferences.setString(
    _key,
    jsonEncode(books.map((book) => book.toJson()).toList()),
  );
}
