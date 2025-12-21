import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getCategoryList(false);

    // Preload latest items so we can show an "All Products"
    // section under the categories grid.
    try {
      Get.find<ItemController>().getAllItemList(false, 'all', false);
    } catch (_) {}

  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'categories'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(child: SingleChildScrollView(
        controller: scrollController, child: FooterView(child: Column(
          children: [
            WebScreenTitleWidget(title: 'categories'.tr),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            SizedBox(
              width: Dimensions.webMaxWidth,
              child: GetBuilder<CategoryController>(builder: (catController) {
                if (catController.categoryList == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (catController.categoryList!.isEmpty) {
                  return NoDataScreen(text: 'no_category_found'.tr);
                }

                // Show categories in a single horizontal row, scrollable,
                // styled similarly to the home page category cards.
                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    // Horizontal padding only so the row height
                    // fits without bottom overflow.
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    itemCount: catController.categoryList!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: InkWell(
                          onTap: () => Get.toNamed(
                            RouteHelper.getCategoryItemRoute(
                              catController.categoryList![index].id,
                              catController.categoryList![index].name!,
                            ),
                          ),
                          child: SizedBox(
                            width: 75,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 75,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    child: CustomImage(
                                      height: 75,
                                      width: 75,
                                      fit: BoxFit.cover,
                                      image:
                                          '${catController.categoryList![index].imageFullUrl}',
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall,
                                ),
                                Text(
                                  catController.categoryList![index].name!,
                                  textAlign: TextAlign.center,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // All Products section below categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Text('all_products'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Search box to filter items in All Products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search'.tr,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // All-items grid using the shared ItemsView layout
          GetBuilder<ItemController>(builder: (itemController) {
            final allItems = itemController.allItemList;
            if (allItems == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (allItems.isEmpty) {
              return const SizedBox();
            }

            // Apply simple client-side filtering by item name
            final query = _searchQuery.trim().toLowerCase();
            final items = query.isEmpty
                ? allItems
                : allItems.where((item) {
                    final name = (item.name ?? '').toLowerCase();
                    return name.contains(query);
                  }).toList();

            if (items.isEmpty) {
              return NoDataScreen(text: 'no_item_available'.tr);
            }

            return ItemsView(
              isStore: false,
              stores: null,
              items: items,
              inStorePage: false,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ),
            );
          }),
          ],
        )))),
    );
  }
}
