import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _key = 'favorite_videos';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_key) ?? [];
    return favorites;
  }

  static Future<bool> toggleFavorite(String videoPath) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_key) ?? [];

    bool isFavorite = false;
    if (favorites.contains(videoPath)) {
      favorites.remove(videoPath);
    } else {
      favorites.add(videoPath);
      isFavorite = true;
    }

    await prefs.setStringList(_key, favorites);
    return isFavorite;
  }

  static Future<bool> isFavorite(String videoPath) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_key) ?? [];
    return favorites.contains(videoPath);
  }
}
