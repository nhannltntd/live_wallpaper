import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecentVideo {
  final String assetPath;
  final DateTime timestamp;

  RecentVideo({
    required this.assetPath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'assetPath': assetPath,
        'timestamp': timestamp.toIso8601String(),
      };

  factory RecentVideo.fromJson(Map<String, dynamic> json) => RecentVideo(
        assetPath: json['assetPath'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class RecentVideoService {
  static const String _key = 'recent_videos';

  static Future<List<RecentVideo>> getRecentVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => RecentVideo.fromJson(json)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<void> addRecentVideo(String assetPath) async {
    final prefs = await SharedPreferences.getInstance();
    final recentVideos = await getRecentVideos();

    // Remove if already exists
    recentVideos.removeWhere((video) => video.assetPath == assetPath);

    // Add to beginning
    recentVideos.insert(
        0,
        RecentVideo(
          assetPath: assetPath,
          timestamp: DateTime.now(),
        ));

    // Keep only last 20 videos
    if (recentVideos.length > 20) {
      recentVideos.removeLast();
    }

    await prefs.setString(
        _key,
        json.encode(
          recentVideos.map((video) => video.toJson()).toList(),
        ));
  }
}
