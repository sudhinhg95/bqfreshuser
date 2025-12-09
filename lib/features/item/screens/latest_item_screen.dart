import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';

class LatestItemScreen extends StatefulWidget {
  const LatestItemScreen({super.key});

  @override
  State<LatestItemScreen> createState() => _LatestItemScreenState();
}

class _LatestItemScreenState extends State<LatestItemScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // load latest items
    Get.find<ItemController>().getLatestItemList(true, Get.find<ItemController>().latestType, false);
  }

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return GetBuilder<ItemController>(builder: (itemController) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(
          key: scaffoldKey,
          title: isShop ? 'Latest Products'.tr : 'Latest Items'.tr,
          showCart: true,
          type: itemController.latestType,
          onVegFilterTap: (String type) => itemController.getLatestItemList(true, type, true),
        ),
        endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
        body: SingleChildScrollView(child: FooterView(child: Column(
          children: [
            SizedBox(
              width: Dimensions.webMaxWidth,
              child: ItemsView(isStore: false, stores: null, items: itemController.latestItemList),
            ),
          ],
        ))),
      );
    });
  }
}
