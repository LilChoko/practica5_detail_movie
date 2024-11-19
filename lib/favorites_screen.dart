import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart';
import 'api_service.dart';
import 'movie_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final favoriteIds = favoritesProvider.favoriteMovieIds;

    return Scaffold(
      appBar: AppBar(title: Text('Favoritos')),
      body: favoriteIds.isEmpty
          ? Center(
              child: Text(
                'No hay películas favoritas.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : FutureBuilder(
              future: ApiService().getMovies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final movies = snapshot.data!.where((movie) {
                    return favoriteIds.contains(movie['id']);
                  }).toList();

                  return ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return ListTile(
                        leading: Hero(
                          tag:
                              'poster_${movie['id']}', // Tag único para el Hero
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(movie['title'],
                            style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailScreen(movieId: movie['id']),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
