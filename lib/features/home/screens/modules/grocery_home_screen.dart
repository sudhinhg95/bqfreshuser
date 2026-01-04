import 'package:flutter/material.dart';
import 'package:sixam_mart/features/flash_sale/widgets/flash_sale_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/bad_weather_widget.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promo_code_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/latest_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/sub_category_sections_view.dart';
import 'package:sixam_mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/helper/auth_helper.dart';


class GroceryHomeScreen extends StatelessWidget {
  const GroceryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).disabledColor.withOpacity( 0.1),
        child:  const Column(
          children: [
            BadWeatherWidget(),

            BannerView(isFeatured: false),
            SizedBox(height: 8),
          ],
        ),
      ),

      const SizedBox(height: 4),
      const CategoryView(),
      // isLoggedIn ? const VisitAgainView() : const SizedBox(),
      const SpecialOfferView(isFood: false, isShop: false),
      const HighlightWidget(),
      const FlashSaleViewWidget(),
      // const BestStoreNearbyView(),
      // const LatestItemView(),
        // Home item sections order: Today's Special -> Most Popular -> Latest
        const ItemThatYouLoveView(forShop: false),
        const MostPopularItemView(isFood: false, isShop: false),
        const LatestItemView(isFood: false, isShop: false),
        const SubCategorySectionsView(isFood: false, isShop: false),
        const MiddleSectionBannerView(),
      // Best reviewed items hidden as per requirement
      const JustForYouView(),
      const TopOffersNearMe(),
      // Coupon code banner hidden by request
      // Removed extra spacing to make section separation uniform
      // const NewOnMartView(isPharmacy: false, isShop: false),
      const PromotionalBannerView(),
    ]);
  }
}
