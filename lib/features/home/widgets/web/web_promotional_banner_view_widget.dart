import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/util/dimensions.dart';

class WebPromotionalBannerView extends StatelessWidget {
  const WebPromotionalBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    // Bottom promotional banner (web) is hidden as per requirement.
    return const SizedBox();
  }
}

class WebPromotionalBannerShimmerView extends StatelessWidget {
  const WebPromotionalBannerShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        height: 235, width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
      ),
    );
  }
}
