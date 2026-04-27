import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/core/di/clean_arch_providers.dart';
import 'package:movie_watchlist/features/movies/presentation/widgets/movie_search_filter_bar.dart';
import 'package:movie_watchlist/features/movies/presentation/widgets/movie_search_result_list.dart';

class MovieSearchScreen extends ConsumerStatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  ConsumerState<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends ConsumerState<MovieSearchScreen> {
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (currentScroll >= maxScroll * 0.8) {
      ref.read(movieSearchNotifierProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(
      movieSearchNotifierProvider.select((state) => state.query),
    );

    if (_controller.text != query) {
      _controller.value = _controller.value.copyWith(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
        composing: TextRange.empty,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: ref.read(movieSearchNotifierProvider.notifier).setQuery,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search movies',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surface,
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _controller.clear();
                        ref
                            .read(movieSearchNotifierProvider.notifier)
                            .setQuery('');
                      },
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: <Widget>[
            const MovieSearchFilterBar(),
            const SizedBox(height: 16),
            Expanded(
              child: MovieSearchResultList(scrollController: _scrollController),
            ),
          ],
        ),
      ),
    );
  }
}
