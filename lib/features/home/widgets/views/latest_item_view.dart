import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';

class LatestItemView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const LatestItemView({super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    bool isEcommerce = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return GetBuilder<ItemController>(builder: (itemController) {
      List? itemList = itemController.latestItemList;
      if (itemList == null || itemList.isEmpty) {
        // No latest items, so don't add any extra spacing
        return const SizedBox();
      }
      return Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
        child: Container(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
              child: TitleWidget(
                title: isShop ? 'Latest Products'.tr : 'Latest Items'.tr,
                image: Images.mostPopularIcon,
                onTap: () => Get.toNamed(RouteHelper.getLatestItemRoute()),
              ),
            ),
            SizedBox(
              height: 246,
              width: Get.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                    child: ItemCard(
                      isPopularItem: isEcommerce ? false : true,
                      isPopularItemCart: true,
                      item: itemList[index],
                      isShop: isShop,
                      isFood: isFood,
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      );
    });
  }
}
