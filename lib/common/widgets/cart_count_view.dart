import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class CartCountView extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  const CartCountView({super.key, required this.item, this.child, this.index = -1});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
        // Prepare the inline counter widget (fixed width) and the small single-add
        // button. Wrap both into a fixed-size slot so toggling doesn't change
        // surrounding layout.
        // Slightly larger slot so the counter is more readable
        // while still compact inside the item card.
        const double slotWidth = 70;
        const double slotHeight = 26;

      Widget inlineCounter = Container(
        width: slotWidth,
        height: slotHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
            onTap: cartController.isLoading ? null : () {
              if (cartController.cartList[cartIndex].quantity! > 1) {
                cartController.setDirectlyAddToCartIndex(index);
                cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);
              } else {
                cartController.removeFromCart(cartIndex);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              padding: const EdgeInsets.all(3),
              child: Icon(
                Icons.remove, size: 12, color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: cartController.isLoading && cartController.directAddCartItemIndex == index
              ? SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 2))
                : Text(cartQty.toString(),
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
            ),
          ),

          InkWell(
            onTap: cartController.isLoading ? null : () {
              cartController.setDirectlyAddToCartIndex(index);
              cartController.setQuantity(true, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].quantityLimit);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              padding: const EdgeInsets.all(3),
              child: Icon(
                Icons.add, size: 12, color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ]),
      );

      Widget singleAdd = InkWell(
        onTap: () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: Container(
          height: 19, width: 19,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)],
          ),
          child: Icon(Icons.add, size: 14, color: Theme.of(context).primaryColor),
        ),
      );

      return SizedBox(
        width: slotWidth,
        height: slotHeight,
        child: Align(
          alignment: Alignment.centerRight,
          child: cartQty != 0 ? inlineCounter : singleAdd,
        ),
      );
    });
  }
}
