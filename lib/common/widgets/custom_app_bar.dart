import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/veg_filter_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final Function? onBackPressed;
  final bool showCart;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final String? leadingIcon;
  const CustomAppBar({super.key, required this.title, this.backButton = true, this.onBackPressed, this.showCart = false, this.leadingIcon, this.onVegFilterTap, this.type});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : AppBar(
      title: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: true,
      leadingWidth: 48,
      leading: backButton
          ? Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: leadingIcon != null
                        ? Image.asset(leadingIcon!, height: 16, width: 16)
                        : Icon(Icons.arrow_back_rounded, size: 18, color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            )
          : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).disabledColor.withOpacity( 0.5),
      elevation: 2,
      actions: showCart || onVegFilterTap != null ? [
        showCart ? IconButton(
          onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
          icon: CartWidget(color: Theme.of(context).textTheme.bodyLarge!.color, size: 25),
        ) : const SizedBox(),

        onVegFilterTap != null ? VegFilterWidget(
          type: type,
          onSelected: onVegFilterTap,
          fromAppBar: true,
        ) : const SizedBox(),

      ] : [const SizedBox()],
    );
  }

  @override
  Size get preferredSize => Size(Get.width, GetPlatform.isDesktop ? 100 : 50);
}
