import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/book_local_data_source.dart';
import 'data/datasources/book_remote_data_source.dart';
import 'data/repositories/book_repository_impl.dart';
import 'domain/repositories/book_repository.dart';
import 'presentation/library_app.dart';
import 'presentation/library_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final BookRepository repository = BookRepositoryImpl(
    remote: BookRemoteDataSource(client: http.Client()),
    local: BookLocalDataSource(preferences),
  );
  runApp(
    BlocProvider(
      create: (_) => LibraryCubit(repository)..loadHome(),
      child: const BookishApp(),
    ),
  );
}
