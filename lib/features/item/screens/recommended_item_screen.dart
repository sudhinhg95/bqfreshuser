import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';

class RecommendedItemScreen extends StatefulWidget {
  const RecommendedItemScreen({super.key});

  @override
  State<RecommendedItemScreen> createState() => _RecommendedItemScreenState();
}

class _RecommendedItemScreenState extends State<RecommendedItemScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Load the full recommended list when opening this screen.
    Get.find<ItemController>().getRecommendedItemList(true, 'all', false);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(
          key: _scaffoldKey,
          title: 'item_that_you_love'.tr,
          showCart: true,
        ),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: SingleChildScrollView(
          child: FooterView(
            child: Column(children: [
              SizedBox(
                width: Dimensions.webMaxWidth,
                child: ItemsView(
                  isStore: false,
                  stores: null,
                  items: itemController.recommendedItemList,
                ),
              ),
            ]),
          ),
        ),
      );
    });
  }
}
