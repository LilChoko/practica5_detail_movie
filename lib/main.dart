import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart';
import 'movie_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final favoritesProvider = FavoritesProvider();
            favoritesProvider.loadFavorites(); // Cargar favoritos al iniciar
            return favoritesProvider;
          },
        ),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación de Películas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black, // Color principal
        scaffoldBackgroundColor: Colors.black, // Fondo de las pantallas
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // Fondo del AppBar
          iconTheme: IconThemeData(color: Colors.white), // Íconos del AppBar
          titleTextStyle:
              TextStyle(color: Colors.white, fontSize: 20), // Texto del AppBar
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Texto principal
          bodyMedium: TextStyle(color: Colors.white70), // Texto secundario
        ),
      ),

      home: MovieListScreen(), // Pantalla inicial
    );
  }
}
