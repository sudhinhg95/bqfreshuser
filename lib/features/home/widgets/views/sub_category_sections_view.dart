import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_medicine_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

/// Shows a list of horizontal product sections, one for each
/// featured sub-category, directly under Latest Items.
class SubCategorySectionsView extends StatelessWidget {
  final bool isFood;
  final bool isShop;

  const SubCategorySectionsView({super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      final ItemModel? featured = itemController.featuredCategoriesItem;

      if (featured == null || featured.categories == null || featured.items == null) {
        return const SizedBox();
      }

      final List<Categories> categories = featured.categories!;
      final List<Item> items = featured.items!;

      if (categories.isEmpty || items.isEmpty) {
        return const SizedBox();
      }

      return Column(
        children: categories.map((category) {
          // Collect products that belong to this category (id match in
          // categoryIds list, or fall back to single categoryId).
          final List<Item> categoryItems = items.where((item) {
            final bool matchesByList = (item.categoryIds != null && item.categoryIds!.isNotEmpty)
                ? item.categoryIds!.any((cid) => cid.id == category.id)
                : false;
            final bool matchesBySingle = item.categoryId == category.id;
            return matchesByList || matchesBySingle;
          }).toList();

          if (categoryItems.isEmpty) {
            return const SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Container(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeExtraSmall,
                      left: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                    ),
                    child: TitleWidget(
                      title: category.name ?? '',
                      onTap: () => Get.toNamed(
                        RouteHelper.getCategoryItemRoute(category.id, category.name ?? ''),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 246,
                    width: Get.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                      itemCount: categoryItems.length,
                      itemBuilder: (context, index) {
                        final Item item = categoryItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeSmall,
                            right: Dimensions.paddingSizeSmall,
                            bottom: Dimensions.paddingSizeSmall,
                          ),
                          child: ItemCard(
                            isPopularItem: !isShop,
                            isPopularItemCart: true,
                            item: item,
                            isShop: isShop,
                            isFood: isFood,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
