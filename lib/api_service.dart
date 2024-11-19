import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '085a79b6240c12d0a641e61a12563013';

  // Obtener lista de películas
  Future<List<dynamic>> getMovies() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Error al cargar las películas');
    }
  }

  // Obtener detalles de una película
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar detalles');
    }
  }

  // Obtener actores
  Future<List<dynamic>> getActors(int movieId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['cast'];
    } else {
      throw Exception('Error al cargar actores');
    }
  }

// Obtener URL del tráiler
  Future<String?> getTrailerUrl(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final videos = json.decode(response.body)['results'];
      if (videos.isNotEmpty) {
        final trailer = videos.firstWhere(
          (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
          orElse: () => null,
        );
        if (trailer != null) {
          final key = trailer['key'];
          return 'https://www.youtube.com/watch?v=$key';
        }
      }
      return null; // No se encontró tráiler
    } else {
      throw Exception('Error al cargar tráiler: ${response.body}');
    }
  }

  Future<void> toggleFavorite(int movieId, bool isFavorite) async {
    const String accountId = 'YOUR_ACCOUNT_ID'; // Reemplaza con tu ID de cuenta
    const String sessionId =
        'YOUR_SESSION_ID'; // Reemplaza con tu token de sesión

    final String url =
        '$_baseUrl/account/$accountId/favorite?api_key=$_apiKey&session_id=$sessionId';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'media_type': 'movie',
        'media_id': movieId,
        'favorite': isFavorite,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al marcar como favorito: ${response.body}');
    }
  }
}
