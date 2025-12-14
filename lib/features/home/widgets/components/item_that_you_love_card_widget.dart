import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/add_favourite_view.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/hover/on_hover.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';

class ItemThatYouLoveCard extends StatelessWidget {
  final Item item;
  final int? index;
  const ItemThatYouLoveCard({super.key, required this.item, this.index});

  @override
  Widget build(BuildContext context) {
    double? discount = item.storeDiscount == 0 ? item.discount : item.storeDiscount;
    String? discountType = item.storeDiscount == 0 ? item.discountType : 'percent';
    return OnHover(
      isItem: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: ResponsiveHelper.isMobile(context) ? [BoxShadow(color: Colors.grey.withOpacity( 0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))] : null,
        ),
        child: CustomInkWell(
          onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
          radius: Dimensions.radiusDefault,
          child: TextHover(
            builder: (hovered) {
              return Column(children: [

                Expanded(
                  flex: 7,
                  child: Stack(clipBehavior: Clip.none, children: [

                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImage(
                          isHovered: hovered,
                          image: '${item.imageFullUrl}',
                          fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                        ),
                      ),
                    ),

                    DiscountTag(
                      discount: discount,
                      discountType: discountType,
                      freeDelivery: false,
                    ),

                    item.isStoreHalalActive! && item.isHalalItem! ? const Positioned(
                      top: 40, right: 15,
                      child: CustomAssetImageWidget(
                        Images.halalTag,
                        height: 20, width: 20,
                      ),
                    ) : const SizedBox(),

                    AddFavouriteView(
                      item: item,
                    ),

                    Get.find<ItemController>().isAvailable(item) ? const SizedBox() : const NotAvailableWidget(),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Expanded(
                  flex: Get.find<LocalizationController>().isLtr ? 3 : 4,
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Item name (match Most Popular style)
                        Text(
                          item.name ?? '',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Single-line description under name, similar to ItemCard
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
                          // Price styling same as Most Popular / ItemCard (small currency, normal amount)
                          // Use the same base price as listing cards so values match.
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

                              return RichText(
                                textDirection: TextDirection.ltr,
                                text: TextSpan(
                                  children: [
                                    if (currencyPart.isNotEmpty)
                                      TextSpan(
                                        text: '$currencyPart ',
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeExtraSmall,
                                          color: Theme.of(context).disabledColor,
                                        ),
                                      ),
                                    TextSpan(
                                      text: amountPart,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),

                          CartCountView(item: item, index: index),
                        ]),
                      ],
                    ),
                  ),
                ),
              ]);
            }
          ),
        ),
      ),
    );
  }
}