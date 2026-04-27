import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';

class ShimmerLoading extends StatelessWidget {
  final int itemCount;
  const ShimmerLoading({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: AppColors.bgCard,
            highlightColor: AppColors.bgSurface.withValues(alpha: 0.7),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 60 + (i * 10),
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 240,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        childCount: itemCount,
      ),
    );
  }
}
