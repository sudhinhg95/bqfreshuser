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
  const LatestItemView({Key? key, required this.isFood, required this.isShop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isEcommerce = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: GetBuilder<ItemController>(builder: (itemController) {
        List? itemList = itemController.latestItemList;

        return (itemList != null)
            ? itemList.isNotEmpty
                ? Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                        child: TitleWidget(
                          title: isShop ? 'Latest Products'.tr : 'Latest Items'.tr,
                          image: Images.mostPopularIcon,
                          onTap: () => Get.toNamed(RouteHelper.getLatestItemRoute()),
                        ),
                      ),

                      SizedBox(
                        height: 285,
                        width: Get.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                          itemCount: itemList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
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
                  )
                : const SizedBox()
            : const ItemShimmerView(isPopularItem: true);
      }),
    );
  }
}
