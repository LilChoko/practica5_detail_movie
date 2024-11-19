import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  final List<int> _favoriteMovieIds = [];

  List<int> get favoriteMovieIds => _favoriteMovieIds;

  // Verificar si una película está en favoritos
  bool isFavorite(int movieId) {
    return _favoriteMovieIds.contains(movieId);
  }

  // Agregar o eliminar una película de favoritos
  void toggleFavorite(int movieId) async {
    if (_favoriteMovieIds.contains(movieId)) {
      _favoriteMovieIds.remove(movieId);
    } else {
      _favoriteMovieIds.add(movieId);
    }
    await _saveToPreferences(); // Guarda cambios en SharedPreferences
    notifyListeners();
  }

  // Cargar favoritos desde SharedPreferences
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favoriteMovieIds') ?? [];
    _favoriteMovieIds.clear();
    _favoriteMovieIds.addAll(favoriteIds.map((id) => int.parse(id)));
    notifyListeners();
  }

  // Guardar favoritos en SharedPreferences
  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = _favoriteMovieIds.map((id) => id.toString()).toList();
    await prefs.setStringList('favoriteMovieIds', favoriteIds);
  }
}
