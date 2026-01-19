import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBase extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBase({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2D2D2D),
      highlightColor: const Color(0xFF3D3D3D),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class CharacterCardSkeleton extends StatelessWidget {
  const CharacterCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: SkeletonBase(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: const Color(0xFF1E1E1E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBase(width: 80, height: 14),
                  SizedBox(height: 8),
                  SkeletonBase(width: 50, height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EpisodeCardSkeleton extends StatelessWidget {
  const EpisodeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          SkeletonBase(width: 60, height: 60, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBase(width: 40, height: 12),
                SizedBox(height: 8),
                SkeletonBase(width: 150, height: 16),
                SizedBox(height: 8),
                SkeletonBase(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationCardSkeleton extends StatelessWidget {
  const LocationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          SkeletonBase(width: 50, height: 50, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBase(width: 120, height: 16),
                SizedBox(height: 8),
                SkeletonBase(width: 180, height: 12),
                SizedBox(height: 8),
                SkeletonBase(width: 80, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
