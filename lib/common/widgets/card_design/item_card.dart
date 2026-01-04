import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/add_favourite_view.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/hover/on_hover.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/organic_tag.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final bool isPopularItem;
  final bool isFood;
  final bool isShop;
  final bool isPopularItemCart;
  final int? index;
  const ItemCard({super.key, required this.item, this.isPopularItem = false, required this.isFood, required this.isShop, this.isPopularItemCart = false, this.index});

  @override
  Widget build(BuildContext context) {
    double? discount = item.storeDiscount == 0 ? item.discount : item.storeDiscount;
    String? discountType = item.storeDiscount == 0 ? item.discountType : 'percent';

    return OnHover(
      isItem: true,
      child: Stack(children: [
        Container(
          // Slightly smaller width so home cards look more compact.
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            color: Theme.of(context).cardColor,
          ),
          child: CustomInkWell(
            onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
            radius: Dimensions.radiusLarge,
            child: TextHover(
                builder: (isHovered) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // Image section – fixed height similar to listing `ItemWidget` image.
                    Padding(
                      padding: EdgeInsets.only(
                        top: isPopularItem ? Dimensions.paddingSizeExtraSmall : 0,
                        left: isPopularItem ? Dimensions.paddingSizeExtraSmall : 0,
                        right: isPopularItem ? Dimensions.paddingSizeExtraSmall : 0,
                      ),
                      child: Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(Dimensions.radiusLarge),
                            topRight: const Radius.circular(Dimensions.radiusLarge),
                            bottomLeft: Radius.circular(isPopularItem ? Dimensions.radiusLarge : 0),
                            bottomRight: Radius.circular(isPopularItem ? Dimensions.radiusLarge : 0),
                          ),
                          child: CustomImage(
                            isHovered: isHovered,
                            placeholder: Images.placeholder,
                            image: '${item.imageFullUrl}',
                            // Match listing cards: same fit and similar height
                            fit: BoxFit.cover,
                            width: double.infinity,
                            // Align with listing card image height on mobile
                            height: 120,
                          ),
                        ),

                        AddFavouriteView(item: item),

                        item.isStoreHalalActive! && item.isHalalItem! ? const Positioned(
                          top: 40, right: 15,
                          child: CustomAssetImageWidget(
                            Images.halalTag,
                            height: 20, width: 20,
                          ),
                        ) : const SizedBox(),

                        DiscountTag(
                          discount: discount,
                          discountType: discountType,
                          freeDelivery: false,
                        ),

                        OrganicTag(item: item, placeInImage: false),

                        // Availability badge if item is not available.
                        Get.find<ItemController>().isAvailable(item)
                            ? const SizedBox()
                            : NotAvailableWidget(radius: Dimensions.radiusLarge, isAllSideRound: isPopularItem),
                      ]),
                    ),

                    Padding(
                      padding: EdgeInsets.only(
                        left: Dimensions.paddingSizeSmall,
                        right: Dimensions.paddingSizeSmall,
                        top: Dimensions.paddingSizeSmall,
                        // smaller bottom padding to reduce vertical height
                        bottom: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Item name
                          Text(
                            item.name ?? '',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Single-line description below name (same as listing card)
                          if (item.description != null && item.description!.isNotEmpty)
                            Text(
                              item.description!,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: 6),

                          Row(children: [
                            // Price section: show current (discounted) price and, if discounted,
                            // the original price struck through underneath.
                            Expanded(
                              child: Builder(builder: (_) {
                                final String fullPrice = PriceConverter.convertPrice(
                                  item.price,
                                  discount: discount,
                                  discountType: discountType,
                                );
                                final bool isRightSide = Get.find<SplashController>()
                                        .configModel!
                                        .currencySymbolDirection ==
                                    'right';

                                String currencyPart = '';
                                String amountPart = fullPrice;
                                final parts = fullPrice.split(' ');
                                if (parts.length >= 2) {
                                  if (isRightSide) {
                                    currencyPart = parts.last;
                                    amountPart = fullPrice
                                        .substring(0, fullPrice.length - currencyPart.length)
                                        .trimRight();
                                  } else {
                                    currencyPart = parts.first;
                                    amountPart = fullPrice
                                        .substring(currencyPart.length)
                                        .trimLeft();
                                  }
                                }

                                final bool hasDiscount = (discount ?? 0) > 0;
                                final String originalPriceText = hasDiscount
                                    ? PriceConverter.convertPrice(item.price)
                                    : '';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Current (discounted or base) price
                                    RichText(
                                      textDirection: TextDirection.ltr,
                                      text: TextSpan(
                                        children: [
                                          if (currencyPart.isNotEmpty)
                                            TextSpan(
                                              text: '$currencyPart ',
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeExtraSmall,
                                                color: Theme.of(context)
                                                    .disabledColor,
                                              ),
                                            ),
                                          TextSpan(
                                            text: amountPart,
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Original price (struck through) when discounted
                                    if (hasDiscount && originalPriceText.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          originalPriceText,
                                          style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                            color:
                                                Theme.of(context).disabledColor,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }),
                            ),

                            CartCountView(item: item, index: index),
                          ]),
                        ],
                      ),
                    ),
                  ]);
                }
            ),
          ),
        ),
      ]),
    );
  }

  // Widget? showUnitOrRattings(BuildContext context) {
  //   if(isFood || isShop) {
  //     if(item.ratingCount! > 0) {
  //       return Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
  //         Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
  //         const SizedBox(width: Dimensions.paddingSizeExtraSmall),
  //
  //         Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
  //         const SizedBox(width: Dimensions.paddingSizeExtraSmall),
  //
  //         Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
  //
  //       ]);
  //     }
  //   } else if(Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) {
  //     return Text(
  //       '(${ item.unitType ?? ''})',
  //       style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
  //     );
  //   }
  // }

}