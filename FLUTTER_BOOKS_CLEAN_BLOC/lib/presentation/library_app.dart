import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/book.dart';
import 'library_cubit.dart';

const _green = Color(0xFF426B52);
const _paper = Color(0xFFF6F4EE);

class BookishApp extends StatefulWidget {
  const BookishApp({super.key});
  @override
  State<BookishApp> createState() => _BookishAppState();
}

class _BookishAppState extends State<BookishApp> {
  ThemeMode _mode = ThemeMode.light;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Libris · Biblioteca digital',
    debugShowCheckedModeBanner: false,
    themeMode: _mode,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    home: LibraryShell(
      onThemeChanged: (dark) =>
          setState(() => _mode = dark ? ThemeMode.dark : ThemeMode.light),
    ),
  );
}

ThemeData _theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: _green,
    brightness: brightness,
    surface: dark ? const Color(0xFF151B17) : _paper,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: dark ? const Color(0xFF202923) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    textTheme: ThemeData(brightness: brightness).textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
  );
}

class LibraryShell extends StatefulWidget {
  const LibraryShell({required this.onThemeChanged, super.key});
  final ValueChanged<bool> onThemeChanged;
  @override
  State<LibraryShell> createState() => _LibraryShellState();
}

class _LibraryShellState extends State<LibraryShell> {
  int _index = 0;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  static const categories = [
    ('Ficción', 'fiction'),
    ('Fantasía', 'fantasy'),
    ('Romance', 'romance'),
    ('Misterio', 'mystery'),
    ('Ciencia ficción', 'science fiction'),
    ('Historia', 'history'),
    ('Tecnología', 'technology'),
    ('Biografías', 'biography'),
    ('Terror', 'horror'),
    ('Aventura', 'adventure'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 480) {
        context.read<LibraryCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _pickCategory(String label, String query) {
    setState(() => _index = 1);
    _searchController.text = label;
    context.read<LibraryCubit>().search(query);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(
        index: _index,
        children: [_home(), _searchPage(), _favoritesPage(), _settingsPage()],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.auto_stories_outlined),
          selectedIcon: Icon(Icons.auto_stories),
          label: 'Inicio',
        ),
        NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        NavigationDestination(icon: Icon(Icons.tune), label: 'Ajustes'),
      ],
    ),
  );

  Widget _home() => BlocBuilder<LibraryCubit, LibraryState>(
    builder: (context, state) {
      final width = MediaQuery.sizeOf(context).width;
      return RefreshIndicator(
        onRefresh: context.read<LibraryCubit>().loadHome,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            width > 700 ? 48 : 22,
            22,
            width > 700 ? 48 : 22,
            36,
          ),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LIBRIS  /  BIBLIOTECA DIGITAL',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w700,
                          color: _green,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Descubre tu\npróxima historia',
                        style: TextStyle(
                          fontSize: 38,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.menu_book_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Explora miles de libros y encuentra tu próxima lectura.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _searchBox(),
            const SizedBox(height: 30),
            _sectionTitle('Explora por categoría', 'VER TODAS'),
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 9),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(categories[i].$1),
                  onPressed: () =>
                      _pickCategory(categories[i].$1, categories[i].$2),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            if (state.loading && state.sections.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state.error != null && state.sections.isEmpty)
              _error(
                state.error!,
                () => context.read<LibraryCubit>().loadHome(),
              ),
            for (final entry in state.sections.entries) ...[
              const SizedBox(height: 30),
              _sectionTitle(entry.key, 'EXPLORAR'),
              const SizedBox(height: 14),
              _carousel(entry.value),
            ],
            const SizedBox(height: 30),
            _sectionTitle('Más para descubrir', 'OPEN LIBRARY'),
            const SizedBox(height: 14),
            _bookGrid(state.results),
            if (!state.loading && state.results.isEmpty && state.error == null)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Aún no hay libros para mostrar. Desliza hacia abajo para volver a intentar.',
                ),
              ),
            if (state.loadingMore)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state.error != null)
              _error(
                state.error!,
                () => context.read<LibraryCubit>().loadMore(),
              ),
          ],
        ),
      );
    },
  );

  Widget _searchBox() => TextField(
    controller: _searchController,
    textInputAction: TextInputAction.search,
    onTap: () => setState(() => _index = 1),
    onChanged: (value) {
      setState(() {});
      _debounce?.cancel();
      _debounce = Timer(
        const Duration(milliseconds: 450),
        () => context.read<LibraryCubit>().search(value),
      );
    },
    decoration: InputDecoration(
      hintText: '¿Qué quieres leer hoy?',
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: _searchController.text.isEmpty
          ? const Icon(Icons.tune_rounded)
          : IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                context.read<LibraryCubit>().search('');
                setState(() {});
              },
            ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _searchPage() => BlocBuilder<LibraryCubit, LibraryState>(
    builder: (context, state) => CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'El catálogo',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Busca por título, autor o tema.'),
                const SizedBox(height: 22),
                _searchBox(),
                const SizedBox(height: 20),
                if (state.query.isEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories
                        .take(8)
                        .map(
                          (category) => ActionChip(
                            label: Text(category.$1),
                            onPressed: () =>
                                _pickCategory(category.$1, category.$2),
                          ),
                        )
                        .toList(),
                  ),
                if (state.query.isNotEmpty)
                  Text(
                    '${state.results.length} resultados para “${state.query}”',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                if (state.loading) const LinearProgressIndicator(),
                if (state.error != null)
                  _error(
                    state.error!,
                    () => context.read<LibraryCubit>().search(state.query),
                  ),
                if (!state.loading &&
                    state.query.isNotEmpty &&
                    state.results.isEmpty &&
                    state.error == null)
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'No encontramos libros. Prueba con otro título o autor.',
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          sliver: SliverToBoxAdapter(child: _bookGrid(state.results)),
        ),
        if (state.loadingMore)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _favoritesPage() => BlocBuilder<LibraryCubit, LibraryState>(
    builder: (context, state) => ListView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 36),
      children: [
        const Text(
          'Mis favoritos',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${state.favorites.length} ${state.favorites.length == 1 ? 'libro guardado' : 'libros guardados'}',
        ),
        const SizedBox(height: 24),
        if (state.favorites.isEmpty)
          _empty(
            'Tu biblioteca está esperando nuevas historias.',
            'Explora el catálogo y guarda los libros que quieras leer.',
            Icons.bookmark_add_outlined,
            'Explorar libros',
            () => setState(() => _index = 0),
          )
        else
          _bookGrid(state.favorites),
      ],
    ),
  );

  Widget _settingsPage() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const Text(
        'Ajustes',
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 20),
      Card(
        child: SwitchListTile(
          title: const Text('Modo oscuro'),
          subtitle: const Text('Elige una apariencia cómoda para leer'),
          secondary: const Icon(Icons.dark_mode_outlined),
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: widget.onThemeChanged,
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Libris utiliza el catálogo abierto de Open Library para buscar libros y mostrar sus portadas.',
      ),
      const SizedBox(height: 8),
      const Text('Los favoritos se guardan en este dispositivo.'),
    ],
  );

  Widget _sectionTitle(String title, String trailing) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -.4,
          ),
        ),
      ),
      Text(
        trailing,
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w700,
          color: _green,
        ),
      ),
    ],
  );

  Widget _carousel(List<Book> books) => SizedBox(
    height: 278,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (context, index) => SizedBox(
        width: 142,
        child: _BookTile(book: books[index], compact: true),
      ),
    ),
  );

  Widget _bookGrid(List<Book> books) {
    if (books.isEmpty) return const SizedBox.shrink();
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 1100
        ? 6
        : width > 760
        ? 4
        : width > 520
        ? 3
        : 2;
    return GridView.builder(
      itemCount: books.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: .51,
        crossAxisSpacing: 14,
        mainAxisSpacing: 18,
      ),
      itemBuilder: (context, index) => _BookTile(book: books[index]),
    );
  }

  Widget _error(String message, VoidCallback retry) => Card(
    child: ListTile(
      leading: const Icon(Icons.wifi_off_outlined),
      title: Text(message),
      trailing: TextButton(onPressed: retry, child: const Text('Reintentar')),
    ),
  );

  Widget _empty(
    String title,
    String body,
    IconData icon,
    String action,
    VoidCallback onPressed,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Column(
      children: [
        Icon(icon, size: 52, color: _green),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(body, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        FilledButton(onPressed: onPressed, child: Text(action)),
      ],
    ),
  );
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book, this.compact = false});
  final Book book;
  final bool compact;
  @override
  Widget build(BuildContext context) => BlocBuilder<LibraryCubit, LibraryState>(
    builder: (context, state) {
      final favorite = state.favorites.any((item) => item.id == book.id);
      return InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => BookDetailsPage(book: book)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'cover-${book.id}',
                    child: _Cover(book: book),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Material(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: .92),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: favorite
                            ? 'Quitar de favoritos'
                            : 'Añadir a favoritos',
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          await context.read<LibraryCubit>().toggleFavorite(
                            book,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                favorite
                                    ? 'Libro eliminado de favoritos'
                                    : 'Libro añadido a favoritos',
                              ),
                              action: SnackBarAction(
                                label: 'Deshacer',
                                onPressed: () => context
                                    .read<LibraryCubit>()
                                    .toggleFavorite(book),
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          color: favorite ? const Color(0xFFC34F52) : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, height: 1.15),
            ),
            const SizedBox(height: 4),
            Text(
              book.authorLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (!compact && book.firstPublishYear != null)
              Text(
                '${book.firstPublishYear}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
      );
    },
  );
}

class _Cover extends StatelessWidget {
  const _Cover({required this.book});
  final Book book;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: book.coverUrl == null
          ? _coverPlaceholder(context)
          : Image.network(
              book.coverUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _coverPlaceholder(context),
              errorBuilder: (_, _, _) => _coverPlaceholder(context),
            ),
    ),
  );
  Widget _coverPlaceholder(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 34,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({required this.book, super.key});
  final Book book;
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LibraryCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del libro'),
        actions: [
          BlocBuilder<LibraryCubit, LibraryState>(
            builder: (context, state) {
              final favorite = state.favorites.any(
                (item) => item.id == book.id,
              );
              return IconButton(
                tooltip: favorite
                    ? 'Quitar de favoritos'
                    : 'Añadir a favoritos',
                onPressed: () => cubit.toggleFavorite(book),
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
        children: [
          Center(
            child: SizedBox(
              height: 330,
              width: 220,
              child: Hero(
                tag: 'cover-${book.id}',
                child: _Cover(book: book),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            book.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -.7,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.authorLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              if (book.firstPublishYear != null)
                _meta(context, 'Primera edición', '${book.firstPublishYear}'),
              if (book.editionCount != null)
                _meta(context, 'Ediciones', '${book.editionCount}'),
              if (book.isbn.isNotEmpty) _meta(context, 'ISBN', book.isbn.first),
            ],
          ),
          if (book.subjects.isNotEmpty) ...[
            const SizedBox(height: 30),
            const Text(
              'Temas',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: book.subjects
                  .take(12)
                  .map(
                    (subject) => Chip(
                      label: Text(
                        subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 30),
          const Text(
            'Datos del catálogo',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text('Registro Open Library: ${book.id}'),
        ],
      ),
    );
  }

  Widget _meta(BuildContext context, String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
