import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';

class ItemShimmer extends StatelessWidget {
  final bool isEnabled;
  final bool isStore;
  final bool hasDivider;
  const ItemShimmer({super.key, required this.isEnabled, required this.hasDivider, this.isStore = false});

  @override
  Widget build(BuildContext context) {
    bool desktop = ResponsiveHelper.isDesktop(context);
    // For item lists (non-store), show a vertical card-style skeleton
    // that matches the current grid card layout used by ItemWidget.
    if (!isStore) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder on top
            Container(
              height: desktop ? 160 : 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).shadowColor,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title line
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      color: Theme.of(context).shadowColor,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle / description line
                  Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      color: Theme.of(context).shadowColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price + small badge line
                  Row(children: [
                    Container(
                      height: 12,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 10,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Fallback layout for store shimmers keeps the previous
    // row-style skeleton used in store lists.
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
              child: Row(children: [

                Container(
                  height: desktop ? 120 : 80, width: desktop ? 120 : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).shadowColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                    Container(height: desktop ? 20 : 10, width: double.maxFinite, color: Theme.of(context).shadowColor),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      height: desktop ? 15 : 10, width: double.maxFinite, color: Theme.of(context).shadowColor,
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(
                      children: List.generate(5, (index) {
                        return Icon(Icons.star, color: Theme.of(context).shadowColor, size: 12);
                      }),
                    ),
                  ]),
                ),

                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: desktop ? Dimensions.paddingSizeSmall : 0),
                    child: Icon(
                      Icons.favorite_border,  size: desktop ? 30 : 25,
                      color: Theme.of(context).shadowColor,
                    ),
                  ),
                ]),

              ]),
            ),
          ),
          desktop ? const SizedBox() : Padding(
            padding: EdgeInsets.only(left: desktop ? 130 : 90),
            child: Divider(color: hasDivider ? Theme.of(context).shadowColor : Colors.transparent),
          ),
        ],
      ),
    );
  }
}
