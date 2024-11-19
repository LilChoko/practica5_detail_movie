import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'api_service.dart';
import 'favorites_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  MovieDetailScreen({required this.movieId});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Map<String, dynamic>> _movieDetails;
  late Future<List<dynamic>> _actors;

  @override
  void initState() {
    super.initState();
    _movieDetails = ApiService().getMovieDetails(widget.movieId);
    _actors = ApiService().getActors(widget.movieId); // Carga actores
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Película'),
        actions: [
          Hero(
            tag:
                'favorite_button_${widget.movieId}', // Mismo tag que en la lista
            child: IconButton(
              icon: Icon(
                favoritesProvider.isFavorite(widget.movieId)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favoritesProvider.isFavorite(widget.movieId)
                    ? Colors.red
                    : Colors.white,
              ),
              onPressed: () {
                favoritesProvider.toggleFavorite(widget.movieId);
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final movie = snapshot.data!;
            return Stack(
              children: [
                // Fondo difuminado del póster con Hero
                Positioned.fill(
                  child: Hero(
                    tag: 'poster_${widget.movieId}', // Tag único para el Hero
                    flightShuttleBuilder: (flightContext, animation, direction,
                        fromHeroContext, toHeroContext) {
                      return ScaleTransition(
                        scale: animation.drive(
                          Tween<double>(begin: 1.0, end: 1.2).chain(
                            CurveTween(curve: Curves.easeInOut),
                          ),
                        ),
                        child: toHeroContext.widget,
                      );
                    },
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.5),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título de la película
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          movie['title'],
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                      // Reproductor de video (tráiler)
                      TrailerWidget(movieId: widget.movieId),
                      // Descripción
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          movie['overview'],
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      // Rating (estrellas)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'Rating: ',
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(Icons.star, color: Colors.yellow),
                            Text(
                              '${movie['vote_average']}/10',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      // Lista de actores
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Actores:',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      FutureBuilder<List<dynamic>>(
                        future: _actors,
                        builder: (context, actorSnapshot) {
                          if (actorSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (actorSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${actorSnapshot.error}'));
                          } else {
                            final actors = actorSnapshot.data!;
                            return SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: actors.length,
                                itemBuilder: (context, index) {
                                  final actor = actors[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            'https://image.tmdb.org/t/p/w200${actor['profile_path']}',
                                            height: 100,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          actor['name'],
                                          style: TextStyle(color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                      // Información adicional
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Información adicional:',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Fecha de lanzamiento: ${movie['release_date']}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// Widget para el tráiler
class TrailerWidget extends StatefulWidget {
  final int movieId;

  TrailerWidget({required this.movieId});

  @override
  _TrailerWidgetState createState() => _TrailerWidgetState();
}

class _TrailerWidgetState extends State<TrailerWidget> {
  late Future<String?> _trailerUrl;

  @override
  void initState() {
    super.initState();
    _trailerUrl = ApiService().getTrailerUrl(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _trailerUrl,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Tráiler no disponible',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          final url = snapshot.data!;
          return VideoPlayerWidget(videoUrl: url);
        }
      },
    );
  }
}

// VideoPlayerWidget
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {}); // Actualiza la UI una vez que el video está listo
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera los recursos del controlador
    super.dispose();
  }
}
