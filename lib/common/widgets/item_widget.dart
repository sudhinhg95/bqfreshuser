import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/corner_banner/banner.dart';
import 'package:sixam_mart/common/widgets/corner_banner/corner_discount_tag.dart';
// removed unused widget imports after layout change
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
// favourite controller not used in new layout
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
// date converter not used in compact layout
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
// removed unused decorators/tags after layout change
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemWidget extends StatelessWidget {
  final Item? item;
  final Store? store;
  final bool isStore;
  final int index;
  final int? length;
  final bool inStore;
  final bool isCampaign;
  final bool isFeatured;
  final bool fromCartSuggestion;
  final double? imageHeight;
  final double? imageWidth;
  final bool? isCornerTag;
  const ItemWidget({super.key, required this.item, required this.isStore, required this.store, required this.index,
    required this.length, this.inStore = false, this.isCampaign = false, this.isFeatured = false,
    this.fromCartSuggestion = false, this.imageHeight, this.imageWidth, this.isCornerTag = false});

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    bool desktop = ResponsiveHelper.isDesktop(context);
    double? discount;
    String? discountType;
  // availability and generic name not used in compact card layout

    if(isStore) {
      discount = store!.discount != null ? store!.discount!.discount : 0;
      discountType = store!.discount != null ? store!.discount!.discountType : 'percent';
    } else {
      discount = (item!.storeDiscount == 0 || isCampaign) ? item!.discount : item!.storeDiscount;
      discountType = (item!.storeDiscount == 0 || isCampaign) ? item!.discountType : 'percent';
    }

    return Stack(
      children: [
        Container(
          // Further reduce bottom margin so rows sit closer together.
          margin: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
          ),
          child: CustomInkWell(
            onTap: () {
              if(isStore) {
                if(store != null) {
                  if(isFeatured && Get.find<SplashController>().moduleList != null) {
                    for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                      if(module.id == store!.moduleId) {
                        Get.find<SplashController>().setModule(module);
                        break;
                      }
                    }
                  }
                  Get.toNamed(
                    RouteHelper.getStoreRoute(id: store!.id, page: isFeatured ? 'module' : 'item'),
                    arguments: StoreScreen(store: store, fromModule: isFeatured),
                  );
                }
              }else {
                if(isFeatured && Get.find<SplashController>().moduleList != null) {
                  for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                    if(module.id == item!.moduleId) {
                      Get.find<SplashController>().setModule(module);
                      break;
                    }
                  }
                }
                Get.find<ItemController>().navigateToItemPage(item, context, inStore: inStore, isCampaign: isCampaign);
              }
            },
            radius: Dimensions.radiusDefault,
            // Remove horizontal padding on mobile so the image can extend
            // fully to the card edges; keep padding on desktop layouts.
            padding: ResponsiveHelper.isDesktop(context)
              ? EdgeInsets.all(fromCartSuggestion ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall)
              : const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
            child: TextHover(
              builder: (hovered) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image on top
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImage(
                        isHovered: hovered,
                        image: '${isStore ? store != null ? store!.logoFullUrl : '' : item!.imageFullUrl}',
                        // Slightly smaller image height to make the card more compact.
                        height: imageHeight ?? (desktop ? 160 : 120),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    // Title and description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          isStore ? store!.name! : item!.name!,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // show short description beneath name
                        (!isStore && item!.description != null && item!.description!.isNotEmpty) ? Text(
                          item!.description!,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ) : const SizedBox(),
                        const SizedBox(height: 6),
                        Row(children: [
                          // Price with smaller currency text (e.g. BHD) and normal-sized amount
                          Expanded(child: Builder(builder: (_) {
                            final String fullPrice = PriceConverter.convertPrice(
                              item!.price,
                              discount: discount,
                              discountType: discountType,
                            );
                            final bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';

                            String currencyPart = '';
                            String amountPart = fullPrice;
                            final parts = fullPrice.split(' ');
                            if (parts.length >= 2) {
                              if (isRightSide) {
                                currencyPart = parts.last;
                                amountPart = fullPrice.substring(0, fullPrice.length - currencyPart.length).trimRight();
                              } else {
                                currencyPart = parts.first;
                                amountPart = fullPrice.substring(currencyPart.length).trimLeft();
                              }
                            }

                            return RichText(
                              textDirection: TextDirection.ltr,
                              text: TextSpan(
                                children: [
                                  if (currencyPart.isNotEmpty)
                                    TextSpan(
                                      text: '$currencyPart ',
                                      style: robotoMedium.copyWith(
                                        // Slightly smaller and same color as description text
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  TextSpan(
                                    text: amountPart,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })),
                          // Plus / add button (fixed width inside CartCountView)
                          CartCountView(item: item!, index: index),
                        ]),
                      ]),
                    ),
                    // Minimal bottom spacer to almost remove extra empty space.
                    const SizedBox(height: 2),
                  ],
                );
              }
            ),
          ),
        ),

        (!isStore && isCornerTag! == false) ? Positioned(
          right: ltr ? 0 : null, left: ltr ? null : 0,
          child: CornerDiscountTag(
            bannerPosition: ltr ? CornerBannerPosition.topRight : CornerBannerPosition.topLeft,
            elevation: 0,
            discount: discount, discountType: discountType,
            freeDelivery: isStore ? store!.freeDelivery : false,
        )) : const SizedBox(),

      ],
    );
  }
}
