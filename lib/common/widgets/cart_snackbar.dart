import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

void showCartSnackBar() {
  final context = Get.context;
  if (context == null) return;

  final messenger = ScaffoldMessenger.of(context);
  final snackBar = SnackBar(
    dismissDirection: DismissDirection.horizontal,
    margin: EdgeInsets.only(
      right: ResponsiveHelper.isDesktop(context) ? context.width * 0.7 : Dimensions.paddingSizeSmall,
      top: Dimensions.paddingSizeSmall,
      bottom: Dimensions.paddingSizeSmall,
      left: Dimensions.paddingSizeSmall,
    ),
    duration: const Duration(seconds: 3),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
    content: Text('item_added_to_cart'.tr, style: robotoMedium.copyWith(color: Colors.white)),
    action: SnackBarAction(
      label: 'view_cart'.tr,
      textColor: Colors.white,
      onPressed: () {
        messenger.hideCurrentSnackBar();
        Get.toNamed(RouteHelper.getCartRoute());
      },
    ),
  );

  messenger.showSnackBar(snackBar);

  // Force-hide after 3 seconds so it never lingers.
  Future.delayed(const Duration(seconds: 3), () {
    messenger.hideCurrentSnackBar();
  });
}