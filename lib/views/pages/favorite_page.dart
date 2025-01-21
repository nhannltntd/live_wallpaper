import 'package:flutter/material.dart';
import 'package:live_wallpaper/services/favorite_service.dart';
import 'package:live_wallpaper/views/pages/video_list_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoriteService.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = favorites;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
      ),
      body: _favorites.isEmpty
          ? const Center(
              child: Text(
                'Chưa có video yêu thích nào',
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 9 / 16,
              ),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                return VideoPreviewCard(
                  assetPath: _favorites[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewWallpaper(
                          assetPath: _favorites[index],
                        ),
                      ),
                    ).then((_) => _loadFavorites());
                  },
                );
              },
            ),
    );
  }
}
