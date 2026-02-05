import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileBgWidget extends StatelessWidget {
  final Widget circularImage;
  final Widget mainWidget;
  final bool backButton;
  const ProfileBgWidget({super.key, required this.mainWidget, required this.circularImage, required this.backButton});

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      Stack(clipBehavior: Clip.none, children: [

        Container(
          width: 1170, height: 260,
          color: Theme.of(context).primaryColor,
        ),

        SizedBox(
          width: context.width, height: 260,
          child: Center(child: Image.asset(Images.profileBg, height: 260, width: 1170, fit: BoxFit.fill)),
        ),

        Positioned(
          top: 200, left: 0, right: 0, bottom: 0,
          child: Center(
            child: Container(
              width: 1170,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top+10, left: 0, right: 0,
          child: Text(
            'profile'.tr, textAlign: TextAlign.center,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: Theme.of(context).cardColor),
          ),
        ),

        backButton ? Positioned(
          top: MediaQuery.of(context).padding.top, left: 10,
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.arrow_back_rounded, color: Theme.of(context).cardColor, size: 18),
              ),
            ),
          ),
        ) : const SizedBox(),

        Positioned(
          top: 150, left: 0, right: 0,
          child: circularImage,
        ),

      ]),

      Expanded(
        child: mainWidget,
      ),

    ]);
  }
}
