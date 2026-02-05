import 'package:sixam_mart/features/auth/widgets/sign_up_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignUpScreen({super.key, this.exitFromApp = false});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context) ? null : !widget.exitFromApp ? AppBar(
        leadingWidth: 48,
        leading: Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.arrow_back_rounded, size: 18, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: const [SizedBox()],
      ) : null),
      backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: Center(
          child: Container(
            width: context.width > 700 ? 700 : context.width,
            padding: context.width > 700 ? const EdgeInsets.all(0) : const EdgeInsets.all(Dimensions.paddingSizeLarge),
            margin: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
            decoration: context.width > 700 ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ) : null,
            child: SingleChildScrollView(
              child: Column(children: [

                ResponsiveHelper.isDesktop(context) ? Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.clear),
                  ),
                ) : const SizedBox(),

                Image.asset(Images.logo, width: 125),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                Align(
                  alignment: Alignment.topLeft,
                  child: Text('sign_up'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                const SignUpWidget(),

              ]),
            ),

          ),
        ),
      ),
    );
  }
}
