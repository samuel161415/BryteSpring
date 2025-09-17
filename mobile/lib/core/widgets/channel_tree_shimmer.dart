import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChannelTreeShimmer extends StatelessWidget {
  const ChannelTreeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main folder shimmer
          _buildShimmerItem(0),
          const SizedBox(height: 8),
          
          // Sub-folder shimmers
          _buildShimmerItem(1),
          const SizedBox(height: 8),
          _buildShimmerItem(1),
          const SizedBox(height: 8),
          
          // Sub-sub-folder shimmers
          _buildShimmerItem(2),
          const SizedBox(height: 8),
          _buildShimmerItem(2),
        ],
      ),
    );
  }

  Widget _buildShimmerItem(int level) {
    return Padding(
      padding: EdgeInsets.only(
        left: level > 0 ? 16 + (level * 16) : 0,
        right: 16,
        top: 6,
        bottom: 6,
      ),
      child: Row(
        children: [
          // Prefix for sub-items (=)
          if (level > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 8,
                height: 14,
                color: Colors.white,
              ),
            ),

          // Text shimmer
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
