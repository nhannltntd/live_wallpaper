import 'package:flutter/material.dart';
import 'package:live_wallpaper/models/category.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              category.iconAsset,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
