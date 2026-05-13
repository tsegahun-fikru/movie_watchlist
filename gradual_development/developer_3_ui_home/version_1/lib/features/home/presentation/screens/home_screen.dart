// lib/features/home/presentation/screens/home_screen.dart
// VERSION 1 - Basic UI with hardcoded data. No Riverpod providers.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/widgets/custom_app_bar.dart';
import 'package:movie_watchlist/core/widgets/movie_card.dart';
import 'package:movie_watchlist/core/widgets/tv_show_card.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Simple home screen with hardcoded movie/TV data.
/// TODO v2: Replace with Riverpod providers fetching real data
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Hardcoded mock data
  static final List<Movie> _mockMovies = [
    Movie(
      id: 1,
      title: 'Inception',
      overview: 'A thief who steals corporate secrets.',
      posterPath: '/inception.jpg',
      releaseDate: '2010-07-16',
      voteAverage: 8.8,
      genreIds: const [28, 878],
    ),
    Movie(
      id: 2,
      title: 'The Dark Knight',
      overview: 'Batman faces the Joker.',
      posterPath: '/dark_knight.jpg',
      releaseDate: '2008-07-18',
      voteAverage: 9.0,
      genreIds: const [28, 80],
    ),
    Movie(
      id: 3,
      title: 'Interstellar',
      overview: 'A team of explorers travel through space.',
      posterPath: '/interstellar.jpg',
      releaseDate: '2014-11-07',
      voteAverage: 8.6,
      genreIds: const [12, 18],
    ),
  ];

  static final List<TvShow> _mockTvShows = [
    TvShow(
      id: 100,
      name: 'Breaking Bad',
      overview: 'A chemistry teacher turns to cooking meth.',
      posterPath: '/breaking_bad.jpg',
      firstAirDate: '2008-01-20',
      voteAverage: 9.5,
      genreIds: const [18, 80],
    ),
    TvShow(
      id: 101,
      name: 'Game of Thrones',
      overview: 'Nine noble families fight for control.',
      posterPath: '/got.jpg',
      firstAirDate: '2011-04-17',
      voteAverage: 9.3,
      genreIds: const [18, 10765],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection('Trending Movies', _mockMovies),
          _buildSection('Popular Movies', _mockMovies),
          _buildSection('Top Rated Movies', _mockMovies),
          _buildTvSection('Popular Series', _mockTvShows),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Movie> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: movies.length,
            itemBuilder: (_, i) => MovieCard(movie: movies[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTvSection(String title, List<TvShow> shows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: shows.length,
            itemBuilder: (_, i) => TvShowCard(tvShow: shows[i]),
          ),
        ),
      ],
    );
  }
}
