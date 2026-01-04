import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';

class SpecialOfferView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const SpecialOfferView({super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    bool isEcommerce = Get.find<SplashController>().module != null
        && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? discountedItemList = itemController.discountedItemList;
      
        return discountedItemList != null
          ? discountedItemList.isNotEmpty
            ? Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Container(
              // Match LatestItemView background styling
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(children: [
                    Padding(
                      // Match LatestItemView title padding (add small top padding)
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeExtraSmall,
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault,
                      ),
                      child: TitleWidget(
                        title: 'special_offer'.tr,
                        image: Images.discountOfferIcon,
                        onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(false, true)),
                      ),
                    ),

                    SizedBox(
                      height: 246,
                      width: Get.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                        itemCount: discountedItemList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeSmall,
                              right: Dimensions.paddingSizeSmall,
                              bottom: Dimensions.paddingSizeSmall,
                            ),
                            child: ItemCard(
                              item: discountedItemList[index],
                              // Use same card style as LatestItemView
                              isPopularItem: isEcommerce ? false : true,
                              isPopularItemCart: true,
                              isFood: isFood,
                              isShop: isShop,
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                ))
              : const SizedBox()
          : const ItemShimmerView(isPopularItem: false);
    });
  }
}

class ItemShimmerView extends StatelessWidget {
  final bool isPopularItem;
  const ItemShimmerView({super.key, required this.isPopularItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Match the non-shimmer view: only bottom external padding.
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Container(
        color: Theme.of(context).disabledColor.withOpacity( 0.1),
        child: Column(children: [

          Padding(
            padding: const EdgeInsets.only(
              top: Dimensions.paddingSizeExtraSmall,
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
            ),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            // Keep shimmer height consistent with actual Special Offer cards.
            height: 246, width: Get.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
                  child: Shimmer(
                    duration: const Duration(seconds: 2),
                    enabled: true,
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      // Slightly shorter card to reflect smaller Special Offer items.
                      height: 250, width: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                      child: Column(children: [

                        Container(
                          // Match image height of real item cards (approximate).
                          height: 110, width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Column(children: [

                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              height: 15, width: 100,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              height: 20, width: 200,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              height: 15, width: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
