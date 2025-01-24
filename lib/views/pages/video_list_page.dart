import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_wallpaper/services/favorite_service.dart';
import 'package:live_wallpaper/models/category.dart';
import 'package:live_wallpaper/views/widgets/category_item.dart';
import 'package:live_wallpaper/blocs/recent_videos/recent_videos_bloc.dart';
import 'package:live_wallpaper/blocs/recent_videos/recent_videos_event.dart';
import 'package:live_wallpaper/blocs/recent_videos/recent_videos_state.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _sillySmileVideos = [];
  List<String> _newVideos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCategoryData();
    context.read<RecentVideosBloc>().add(LoadRecentVideos());
  }

  void _loadCategoryData() {
    // Load Silly Smile videos
    final sillySmileCategory =
        categories.firstWhere((cat) => cat.name == 'Silly Smile');
    _sillySmileVideos = sillySmileCategory.videoAssets;

    // Load New videos
    final newCategory = categories.firstWhere((cat) => cat.name == 'New');
    _newVideos = newCategory.videoAssets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Video'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Category",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            _buildCategorySection(),
            const SizedBox(height: 16),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).primaryColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Silly Smile'),
                  Tab(text: 'New'),
                  Tab(text: 'Recent'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVideoGrid(_sillySmileVideos),
                  _buildVideoGrid(_newVideos),
                  BlocBuilder<RecentVideosBloc, RecentVideosState>(
                    builder: (context, state) {
                      if (state is RecentVideosLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is RecentVideosLoaded) {
                        return _buildVideoGrid(state.videos);
                      } else if (state is RecentVideosError) {
                        return Center(child: Text(state.message));
                      }
                      return const Center(child: Text('No recent videos'));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildCategorySection() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 100,
            child: CategoryItem(
              category: categories[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryVideoPage(
                      category: categories[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoGrid(List<String> videos) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 9 / 16,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return VideoPreviewCard(
          assetPath: videos[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewWallpaper(
                  assetPath: videos[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CategoryVideoPage extends StatelessWidget {
  final Category category;

  const CategoryVideoPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 9 / 16,
        ),
        itemCount: category.videoAssets.length,
        itemBuilder: (context, index) {
          return VideoPreviewCard(
            assetPath: category.videoAssets[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewWallpaper(
                    assetPath: category.videoAssets[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VideoPreviewCard extends StatefulWidget {
  final String assetPath;
  final VoidCallback onTap;

  const VideoPreviewCard({
    super.key,
    required this.assetPath,
    required this.onTap,
  });

  @override
  State<VideoPreviewCard> createState() => _VideoPreviewCardState();
}

class _VideoPreviewCardState extends State<VideoPreviewCard> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await FavoriteService.isFavorite(widget.assetPath);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final isFavorite = await FavoriteService.toggleFavorite(widget.assetPath);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    _controller.play();
                    return VideoPlayer(_controller);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ViewWallpaper extends StatefulWidget {
  const ViewWallpaper({super.key, required this.assetPath});
  final String assetPath;

  @override
  State<ViewWallpaper> createState() => _ViewWallpaperState();
}

class _ViewWallpaperState extends State<ViewWallpaper> {
  static const double buttonHeight = 80.0;
  static const String setWallpaperText = 'Cài hình nền';
  static const String errorText = 'Lỗi khi cài đặt hình nền';

  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.asset(widget.assetPath);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  Future<void> setWallpaper() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final directory = await getTemporaryDirectory();
      final String fileName = widget.assetPath.split('/').last;
      final String filePath = '${directory.path}/$fileName';
      final ByteData data = await rootBundle.load(widget.assetPath);
      final List<int> bytes = data.buffer.asUint8List();
      await File(filePath).writeAsBytes(bytes);
      final bool success = await AsyncWallpaper.setLiveWallpaper(
        filePath: filePath,
        goToHome: true,
      );
      await File(filePath).delete();

      if (!success) {
        throw PlatformException(
          code: 'ERROR',
          message: errorText,
        );
      }

      // Update recent videos using BLoC
      context.read<RecentVideosBloc>().add(AddRecentVideo(widget.assetPath));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(setWallpaperText)),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? errorText)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                _controller.play();
                return VideoPlayer(_controller);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: ElevatedButton(
              style: ButtonStyle(
                fixedSize: WidgetStateProperty.all(
                  Size(MediaQuery.of(context).size.width, buttonHeight),
                ),
                backgroundColor: WidgetStateProperty.all(
                  Colors.black.withOpacity(0.8),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              onPressed: setWallpaper,
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text(
                      setWallpaperText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
