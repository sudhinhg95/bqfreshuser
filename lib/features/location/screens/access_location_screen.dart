import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sixam_mart/common/widgets/address_widget.dart';
import 'package:sixam_mart/common/widgets/no_internet_screen.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/location/screens/web_landing_page.dart';
import 'package:http/http.dart' as http;

class AccessLocationScreen extends StatefulWidget {
  final bool fromSignUp;
  final bool fromHome;
  final String? route;
  const AccessLocationScreen({super.key, required this.fromSignUp, required this.fromHome, required this.route});

  @override
  State<AccessLocationScreen> createState() => _AccessLocationScreenState();
}

class _AccessLocationScreenState extends State<AccessLocationScreen> {
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();

    if(AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }

    checkInternet();
  }

  void checkInternet() async {
    // On web, rely on the browser's own network state. A direct
    // probe to https://www.google.com will often fail due to CORS,
    // incorrectly triggering the NoInternetScreen.
    if (kIsWeb) {
      return;
    }

    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    final bool isNetworkAvailable = !results.contains(ConnectivityResult.none);

    if (!isNetworkAvailable) {
      // Show a lightweight message instead of kicking the user
      // out to a global NoInternetScreen, which felt like the
      // app was randomly restarting.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('no_internet_connection'.tr, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      ));
      return;
    }

    // Do not probe an external site like Google; rely on actual
    // API call failures to reflect connectivity issues.
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (_canExit) {
          if (GetPlatform.isAndroid) {
            SystemNavigator.pop();
          } else if (GetPlatform.isIOS) {
            exit(0);
          } else {
            Navigator.pushNamed(context, RouteHelper.getInitialRoute());
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          ));
          _canExit = true;
          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'select_location'.tr, backButton: widget.fromHome),
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(child: Padding(
          padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: GetBuilder<AddressController>(builder: (locationController) {
            bool isLoggedIn = AuthHelper.isLoggedIn();
            return (ResponsiveHelper.isDesktop(context) && AddressHelper.getUserAddressFromSharedPref() == null) ? WebLandingPage(
              fromSignUp: widget.fromSignUp, fromHome: widget.fromHome, route: widget.route,
            ) : isLoggedIn ? Column(children: [
              Expanded(child: SingleChildScrollView(
                child: FooterView(child: Column(mainAxisAlignment: (locationController.addressList != null && locationController.addressList!.isNotEmpty) ? MainAxisAlignment.start : MainAxisAlignment.center, children: [

                  locationController.addressList != null ? locationController.addressList!.isNotEmpty ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: locationController.addressList!.length,
                    itemBuilder: (context, index) {
                      return Center(child: SizedBox(width: 700, child: AddressWidget(
                        address: locationController.addressList![index],
                        fromAddress: false,
                        onTap: () {
                          Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                          AddressModel address = locationController.addressList![index];
                          Get.find<LocationController>().saveAddressAndNavigate(
                            address, widget.fromSignUp, widget.route, widget.route != null, ResponsiveHelper.isDesktop(context),
                          );
                        },
                      )));
                    },
                  ) : NoDataScreen(text: 'no_saved_address_found'.tr) : const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  ResponsiveHelper.isDesktop(context) ? BottomButton(fromSignUp: widget.fromSignUp, route: widget.route) : const SizedBox(),

                ])),
              )),
              ResponsiveHelper.isDesktop(context) ? const SizedBox() : BottomButton(fromSignUp: widget.fromSignUp, route: widget.route),
            ]) : Center(child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: FooterView(child: SizedBox( width: 700,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
                    Image.asset(Images.deliveryLocation, height: 220),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text('find_stores_and_items'.tr.toUpperCase(), textAlign: TextAlign.center, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                    Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      child: Text('by_allowing_location_access'.tr, textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Padding(
                      padding: ResponsiveHelper.isWeb() ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: BottomButton(fromSignUp: widget.fromSignUp, route: widget.route),
                    ),
              ]))),
            ));
          }),
        )),
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  final bool fromSignUp;
  final String? route;
  const BottomButton({super.key, required this.fromSignUp, required this.route});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 700,
        child: CustomButton(
          buttonText: 'add_new_address'.tr,
          icon: Icons.add,
          onPressed: () {
            // Navigate to the add-address screen from the location
            // selector so users can create a new address directly.
            Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0));
          },
        ),
      ),
    );
  }
}

