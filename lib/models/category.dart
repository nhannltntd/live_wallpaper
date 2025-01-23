class Category {
  final String name;
  final String iconAsset;
  final List<String> videoAssets;

  const Category({
    required this.name,
    required this.iconAsset,
    required this.videoAssets,
  });
}

final List<Category> categories = [
  const Category(
    name: 'Funnky Smile',
    iconAsset: 'assets/images/ca1.png',
    videoAssets: [
      'assets/video1.mp4',
      'assets/video2.mp4',
      'assets/video3.mp4',
      'assets/video4.mp4',
    ],
  ),
  const Category(
    name: 'Evil Smile',
    iconAsset: 'assets/images/ca2.png',
    videoAssets: [
      'assets/video5.mp4',
      'assets/video6.mp4',
      'assets/video7.mp4',
    ],
  ),
  const Category(
    name: 'Silly Smile',
    iconAsset: 'assets/images/ca3.png',
    videoAssets: [
      'assets/video8.mp4',
      'assets/video9.mp4',
      'assets/video10.mp4',
      'assets/video11.mp4',
    ],
  ),
];
