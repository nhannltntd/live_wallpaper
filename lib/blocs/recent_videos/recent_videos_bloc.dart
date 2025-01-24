import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_wallpaper/services/recent_video_service.dart';
import 'recent_videos_event.dart';
import 'recent_videos_state.dart';

class RecentVideosBloc extends Bloc<RecentVideosEvent, RecentVideosState> {
  RecentVideosBloc() : super(RecentVideosInitial()) {
    on<LoadRecentVideos>(_onLoadRecentVideos);
    on<AddRecentVideo>(_onAddRecentVideo);
  }

  Future<void> _onLoadRecentVideos(
    LoadRecentVideos event,
    Emitter<RecentVideosState> emit,
  ) async {
    emit(RecentVideosLoading());
    try {
      final videos = await RecentVideoService.getRecentVideos();
      emit(RecentVideosLoaded(videos.map((v) => v.assetPath).toList()));
    } catch (e) {
      emit(RecentVideosError(e.toString()));
    }
  }

  Future<void> _onAddRecentVideo(
    AddRecentVideo event,
    Emitter<RecentVideosState> emit,
  ) async {
    try {
      await RecentVideoService.addRecentVideo(event.videoPath);
      final videos = await RecentVideoService.getRecentVideos();
      emit(RecentVideosLoaded(videos.map((v) => v.assetPath).toList()));
    } catch (e) {
      emit(RecentVideosError(e.toString()));
    }
  }
}
