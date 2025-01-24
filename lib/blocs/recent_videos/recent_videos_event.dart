abstract class RecentVideosEvent {
  const RecentVideosEvent();
}

class LoadRecentVideos extends RecentVideosEvent {}

class AddRecentVideo extends RecentVideosEvent {
  final String videoPath;

  const AddRecentVideo(this.videoPath);
}
