abstract class RecentVideosState {
  const RecentVideosState();
}

class RecentVideosInitial extends RecentVideosState {}

class RecentVideosLoading extends RecentVideosState {}

class RecentVideosLoaded extends RecentVideosState {
  final List<String> videos;

  const RecentVideosLoaded(this.videos);
}

class RecentVideosError extends RecentVideosState {
  final String message;

  const RecentVideosError(this.message);
}
