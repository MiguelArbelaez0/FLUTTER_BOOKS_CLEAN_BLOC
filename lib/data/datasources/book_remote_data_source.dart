import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/book.dart';
import '../models/book_model.dart';

class BookRemoteDataSource {
  BookRemoteDataSource({
    required http.Client client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client;
  final http.Client _client;
  final Duration timeout;

  Future<List<Book>> search(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    if (page < 1 || limit < 1 || limit > 100) {
      throw ArgumentError('Invalid pagination');
    }
    if (query.trim().isEmpty) return [];
    final uri = Uri.https('openlibrary.org', '/search.json', {
      'q': query.trim(),
      'page': '$page',
      'limit': '$limit',
      'fields':
          'key,title,author_name,cover_i,first_publish_year,edition_count,isbn,subject',
    });
    final response = await _client.get(uri).timeout(timeout);
    if (response.statusCode != 200) {
      throw BookApiException('No se pudo conectar con Open Library.');
    }
    try {
      final decoded =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final docs = decoded['docs'];
      if (docs is! List) throw const FormatException('Missing docs');
      return docs
          .whereType<Map<String, dynamic>>()
          .map(BookModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    } on FormatException {
      throw BookApiException('La respuesta del catálogo no se pudo leer.');
    } on TypeError {
      throw BookApiException(
        'La respuesta del catálogo no tiene el formato esperado.',
      );
    }
  }
}

class BookApiException implements Exception {
  const BookApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
