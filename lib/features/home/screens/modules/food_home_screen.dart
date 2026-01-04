import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/home/widgets/bad_weather_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/latest_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/sub_category_sections_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Container(
        width: MediaQuery.of(context).size.width,
        decoration: Get.find<ThemeController>().darkTheme ? null : const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.foodModuleBannerBg),
            fit: BoxFit.cover,
          ),
        ),
        child: const Column(
          children: [
            BadWeatherWidget(),

            BannerView(isFeatured: false),
            SizedBox(height: 8),
          ],
        ),
      ),

      const SizedBox(height: 4),
      const CategoryView(),
      // isLoggedIn ? const VisitAgainView(fromFood: true) : const SizedBox(),
      const SpecialOfferView(isFood: true, isShop: false),
      const HighlightWidget(),
      const TopOffersNearMe(),
        // Best reviewed items hidden as per requirement
        // const BestStoreNearbyView(),
        // const LatestItemView(),
        const ItemThatYouLoveView(forShop: false),
        const MostPopularItemView(isFood: true, isShop: false),
        const LatestItemView(isFood: true, isShop: false),
        const SubCategorySectionsView(isFood: true, isShop: false),
      const JustForYouView(),
      // const NewOnMartView(isNewStore: true, isPharmacy: false, isShop: false),
    ]);
  }
}
