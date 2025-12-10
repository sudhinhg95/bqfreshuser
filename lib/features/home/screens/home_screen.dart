import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/brands/controllers/brands_controller.dart';
import 'package:sixam_mart/features/home/controllers/advertisement_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/home/widgets/all_store_filter_widget.dart';
import 'package:sixam_mart/features/home/widgets/cashback_logo_widget.dart';
import 'package:sixam_mart/features/home/widgets/cashback_dialog_widget.dart';
import 'package:sixam_mart/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/home/screens/modules/food_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/grocery_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/pharmacy_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/shop_home_screen.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/home/screens/taxi_home_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/home/screens/web_new_home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/module_view.dart';
import 'package:sixam_mart/features/parcel/screens/parcel_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  static Future<void> loadData(bool reload, {bool fromModule = false}) async {
    Get.find<LocationController>().syncZoneData();
    Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: fromModule);
    if(AuthHelper.isLoggedIn()) {
      Get.find<StoreController>().getVisitAgainStoreList(fromModule: fromModule);
    }

    final splashController = Get.find<SplashController>();
    final configModel = splashController.configModel;
    final module = splashController.module;
    final moduleConfig = configModel?.moduleConfig?.module;
    final isParcelModule = moduleConfig?.isParcel ?? false;
    final isTaxiModule = moduleConfig?.isTaxi ?? false;

    if(module != null && moduleConfig != null && !isParcelModule && !isTaxiModule) {
      Get.find<BannerController>().getBannerList(reload);
      Get.find<BannerController>().getPopUpBannerList(reload);
      Get.find<StoreController>().getRecommendedStoreList();
      if(module.moduleType.toString() == AppConstants.grocery) {
        Get.find<FlashSaleController>().getFlashSale(reload, false);
      }
      if(module.moduleType.toString() == AppConstants.ecommerce) {
        Get.find<ItemController>().getFeaturedCategoriesItemList(false, false);
        Get.find<FlashSaleController>().getFlashSale(reload, false);
        Get.find<BrandsController>().getBrandList();
      }
      Get.find<BannerController>().getPromotionalBannerList(reload);
      Get.find<ItemController>().getDiscountedItemList(reload, false, 'all');
      Get.find<CategoryController>().getCategoryList(reload);
      // Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
      Get.find<CampaignController>().getBasicCampaignList(reload);
      Get.find<CampaignController>().getItemCampaignList(reload);
      Get.find<ItemController>().getLatestItemList(reload, 'all', false);
      Get.find<ItemController>().getPopularItemList(reload, 'all', false);
      Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
      Get.find<StoreController>().getTopOfferStoreList(reload, false);
      Get.find<ItemController>().getReviewedItemList(reload, 'all', false);
      Get.find<ItemController>().getRecommendedItemList(reload, 'all', false);
      Get.find<StoreController>().getStoreList(1, reload);
      Get.find<AdvertisementController>().getAdvertisementList();
    }
    if(AuthHelper.isLoggedIn()) {
      // Get.find<StoreController>().getVisitAgainStoreList(fromModule: fromModule);
      await Get.find<ProfileController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<CouponController>().getCouponList();
    }
    splashController.getModules();
    if(splashController.module == null && splashController.configModel?.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<StoreController>().getFeaturedStoreList();
      if(AuthHelper.isLoggedIn()) {
        Get.find<AddressController>().getAddressList();
      }
    }
    if(splashController.module != null && isParcelModule) {
      Get.find<ParcelController>().getParcelCategoryList();
    }
    if(splashController.module != null && module?.moduleType.toString() == AppConstants.pharmacy) {
      Get.find<ItemController>().getBasicMedicine(reload, false);
      Get.find<StoreController>().getFeaturedStoreList();
      await Get.find<ItemController>().getCommonConditions(false);
      if(Get.find<ItemController>().commonConditions!.isNotEmpty) {
        Get.find<ItemController>().getConditionsWiseItem(Get.find<ItemController>().commonConditions![0].id!, false);
      }
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool searchBgShow = false;
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    print('🔔 Popup: initState called');
    // Do NOT read a persisted popup flag here. We want the popup to show
    // on every cold app start, but not when navigating back to Home during
    // the same session. The controller maintains a session-only flag.
    
    // Schedule popup independently of loadData completion
    // Use both postFrameCallback and direct delay to ensure it runs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔔 Popup: PostFrameCallback executed, scheduling popup in 2 seconds');
      // show popup after a short delay so UI has time to settle
      Future.delayed(const Duration(seconds: 2), () {
        print('🔔 Popup: 2 second delay completed, considering _showPopupBanner');
        if (mounted) {
          try {
            final splashController = Get.find<SplashController>();
            if (!(splashController.popupBannerShown)) {
              print('🔔 Popup: popupBannerShown is false, calling _showPopupBanner');
              _showPopupBanner();
            } else {
              print('🔔 Popup: popupBannerShown is true; skipping popup');
            }
          } catch (e) {
            print('🔔 Popup: Error checking popup status, defaulting to show -> $e');
            _showPopupBanner();
          }
        } else {
          print('🔔 Popup: Widget not mounted, cannot show popup');
        }
      });
    });
    
    // Also try direct delay as backup
    Future.delayed(const Duration(seconds: 3), () {
      print('🔔 Popup: Backup delay (3s) executed, checking if popup was shown');
      if (mounted) {
        try {
          final splashController = Get.find<SplashController>();
          if (splashController.popupBannerShown) {
            print('🔔 Popup: Backup - popupBannerShown is true; skipping backup popup');
            return;
          }
        } catch (e) {
          print('🔔 Popup: Backup - could not read popup status: $e');
        }

        final bannerController = Get.find<BannerController>();
        final banners = bannerController.popupBannerImageList;
        print('🔔 Popup: Backup check - banners count: ${banners?.length ?? 0}');
        if (banners == null || banners.isEmpty) {
          print('🔔 Popup: Backup - No banners, attempting to call _showPopupBanner again');
          _showPopupBanner();
        }
      }
    });
    
    try {
      HomeScreen.loadData(false).then((value) {
        try {
          Get.find<SplashController>().getReferBottomSheetStatus();

          if((Get.find<ProfileController>().userInfoModel?.isValidForDiscount??false) && Get.find<SplashController>().showReferBottomSheet) {
            _showReferBottomSheet();
          }
        } catch (e) {
          print('Error in HomeScreen initState callback: $e');
        }
      }).catchError((e) {
        print('Error loading HomeScreen data: $e');
      });
    } catch (e) {
      print('Error in HomeScreen initState: $e');
    }

    if(!ResponsiveHelper.isWeb()) {
      final address = AddressHelper.getUserAddressFromSharedPref();
      if(address != null && address.latitude != null && address.longitude != null) {
        Get.find<LocationController>().getZone(
            address.latitude,
            address.longitude, false, updateInAddress: true
        );
      }
    }

    _scrollController.addListener(() {
      if(_scrollController.position.userScrollDirection == ScrollDirection.reverse){
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), () => Get.find<HomeController>().changeFavVisibility());
        }
      }else {
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), () => Get.find<HomeController>().changeFavVisibility());
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  
  void _showPopupBanner() async {
    try {
      print('🔔 Popup: Starting _showPopupBanner function');
      if (!mounted) {
        print('🔔 Popup: Widget not mounted, returning');
        return;
      }
      
      final bannerController = Get.find<BannerController>();
      print('🔔 Popup: Fetching popup banners from API...');
      // Fetch banners from the server (client) first so popup shows all images
      await bannerController.getPopUpBannerList(true, dataSource: DataSourceEnum.client);

      if (!mounted) {
        print('🔔 Popup: Widget not mounted after API call, returning');
        return;
      }

      final List<String?>? banners = bannerController.popupBannerImageList;
      print('🔔 Popup: Banner list received: ${banners?.length ?? 0} banners');
      print('🔔 Popup: Banner URLs: $banners');

      if (banners == null || banners.isEmpty) {
        print('🔔 Popup: No popup banners configured; skipping popup');
        return;
      }

      // Normalize to non-null strings (only use popup list — do not fallback to main banners)
      final List<String> validBanners = banners.map((b) => (b ?? '').toString()).where((s) => s.isNotEmpty).toList();
      if (validBanners.isEmpty) {
        print('🔔 Popup: Popup banner list contains no valid URLs; skipping popup');
        return;
      }
      
        print('🔔 Popup: Showing dialog with ${validBanners.length} valid banners');
        print('🔔 Popup: Showing dialog with ${banners.length} banners');

      // Auto-slide PageView: create a controller and a timer, cancel after dialog closes
      final pageController = PageController(initialPage: 0);
      int currentIndex = 0;
      Timer? imageTimer;
      // Prepare video controllers for any video URLs (do NOT autoplay)
      final videoControllers = List<VideoPlayerController?>.filled(validBanners.length, null);
      final List<Future> initFutures = [];
      final videoExt = RegExp(r'\.(mp4|webm|mov|m4v)(\?|\#|$)', caseSensitive: false);
      for (int i = 0; i < validBanners.length; i++) {
        final url = validBanners[i];
        if (videoExt.hasMatch(url) && !url.startsWith('assets/')) {
          try {
            final controller = VideoPlayerController.networkUrl(Uri.parse(url));
            videoControllers[i] = controller;
            controller.setLooping(false); // do not loop; advance after finish
            controller.setVolume(0); // muted by default
            initFutures.add(controller.initialize().then((_) {
              // add listener to detect when playback finishes
              controller.addListener(() {
                  final value = controller.value;
                  if (!value.isInitialized) return;
                  // If video is playing, cancel any auto-advance timer
                  if (value.isPlaying) {
                    imageTimer?.cancel();
                  } else {
                    // Not playing: determine if it finished or simply paused
                    final duration = value.duration;
                    final position = value.position;
                    if (position >= duration && duration > Duration.zero) {
                      // playback finished, advance immediately (if still on same page)
                      if (currentIndex == i && mounted) {
                        final next = (currentIndex + 1) % validBanners.length;
                        try {
                          pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        } catch (_) {}
                      }
                    } else {
                      // paused mid-playback (or not started): start a short auto-advance timer
                      imageTimer?.cancel();
                      imageTimer = Timer(const Duration(seconds: 3), () {
                        if (!mounted) return;
                        // only advance if still paused and still on this page
                        final nowVal = controller.value;
                        if (!nowVal.isPlaying && currentIndex == i) {
                          final next = (currentIndex + 1) % validBanners.length;
                          try {
                            pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                          } catch (_) {}
                        }
                      });
                    }
                  }
                });
            }));
          } catch (e) {
            print('🔔 Popup: Failed to create VideoPlayerController for $url -> $e');
            videoControllers[i] = null;
          }
        }
      }
      // Wait (best-effort) for initializations so play button can appear immediately
      if (initFutures.isNotEmpty) {
        try {
          await Future.wait(initFutures);
        } catch (_) {}
      }
      // Start initial auto-advance timer depending on the first page state:
      if (validBanners.isNotEmpty) {
        final vc0 = videoControllers[currentIndex];
        if (vc0 != null) {
          // video present on initial page
          try {
            if (vc0.value.isPlaying) {
              imageTimer?.cancel();
            } else {
              // paused by default -> start image timer to advance after 3s
              imageTimer?.cancel();
              imageTimer = Timer(const Duration(seconds: 3), () {
                if (!mounted) return;
                if (!vc0.value.isPlaying && currentIndex == 0) {
                  final next = (currentIndex + 1) % validBanners.length;
                  try { pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut); } catch (_) {}
                }
              });
            }
          } catch (_) {
            // ignore
          }
        } else {
          // initial page is an image -> start image timer
          imageTimer?.cancel();
          imageTimer = Timer(const Duration(seconds: 3), () {
            if (!mounted) return;
            final next = (currentIndex + 1) % validBanners.length;
            try { pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut); } catch (_) {}
          });
        }
      }

      if (!mounted) {
        print('🔔 Popup: Widget not mounted before showing dialog');
        return;
      }

      print('🔔 Popup: About to show dialog');
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          print('🔔 Popup: Dialog builder called');
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  SizedBox(
                    // About 40% taller than previous height for a larger banner.
                    height: 500,
                    width: double.infinity,
                    child: StatefulBuilder(builder: (context, setState) {
                      // helper to start a 3s timer for images (cancels any existing)
                      void startImageTimer() {
                        imageTimer?.cancel();
                        imageTimer = Timer(const Duration(seconds: 3), () {
                          if (!mounted) return;
                          final next = (currentIndex + 1) % validBanners.length;
                          try {
                            pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                          } catch (_) {}
                        });
                      }

                      return PageView.builder(
                        controller: pageController,
                        itemCount: validBanners.length,
                        onPageChanged: (index) {
                          // cancel any timers and pause other videos
                          currentIndex = index;
                          imageTimer?.cancel();
                          for (int j = 0; j < videoControllers.length; j++) {
                            final vc = videoControllers[j];
                            if (vc != null && j != index) {
                              try { vc.pause(); vc.seekTo(Duration.zero); } catch (_) {}
                            }
                          }
                          // If new page is a video, start timer only when it's paused; if image, start timer immediately
                          final vc = videoControllers[index];
                          if (vc != null) {
                            try {
                              if (vc.value.isPlaying) {
                                imageTimer?.cancel();
                              } else {
                                startImageTimer();
                              }
                            } catch (_) {
                              startImageTimer();
                            }
                          } else {
                            startImageTimer();
                          }
                        },
                        itemBuilder: (context, index) {
                          final bannerUrl = validBanners[index];
                          final vController = videoControllers[index];
                          // If we have a prepared video controller, render the VideoPlayer with play/pause overlay
                          if (vController != null && vController.value.isInitialized) {
                            final isPlaying = vController.value.isPlaying;
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: vController.value.aspectRatio > 0 ? vController.value.aspectRatio : (16/9),
                                  child: VideoPlayer(vController),
                                ),
                                // Play/pause button overlay
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        if (vController.value.isPlaying) {
                                          try { await vController.pause(); } catch (_) {}
                                          // start auto-advance timer when paused
                                          imageTimer?.cancel();
                                          imageTimer = Timer(const Duration(seconds: 3), () {
                                            if (!mounted) return;
                                            if (!vController.value.isPlaying && currentIndex == index) {
                                              final next = (currentIndex + 1) % validBanners.length;
                                              try { pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut); } catch (_) {}
                                            }
                                          });
                                        } else {
                                          try { await vController.play(); } catch (_) {}
                                          // cancel any auto-advance while playing
                                          imageTimer?.cancel();
                                        }
                                        setState(() {});
                                      },
                                      child: Center(
                                        child: Container(
                                          decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                                          padding: const EdgeInsets.all(12),
                                          child: Icon(
                                            isPlaying ? Icons.pause : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          // Not a video (or failed to init) — show image with fallback
                          // start image timer only for first build of this page
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (currentIndex == index && (videoControllers[index] == null)) {
                              imageTimer?.cancel();
                              imageTimer = Timer(const Duration(seconds: 3), () {
                                if (!mounted) return;
                                final next = (currentIndex + 1) % validBanners.length;
                                try {
                                  pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                                } catch (_) {}
                              });
                            }
                          });
                          return Image.network(
                            bannerUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Image.asset(
                              "assets/image/no_coupon.png",
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      // After the dialog closes, mark popup as shown for this session so
      // it won't re-appear when navigating within the app. Do NOT persist
      // this value so the popup will show again on the next cold app start.
      try {
        Get.find<SplashController>().markPopupShownInSession();
        print('🔔 Popup: Marked popupBannerShown in session');
      } catch (e) {
        print('🔔 Popup: Failed to mark popup session status: $e');
      }

  // When dialog closes, stop any timers and dispose controller and video controllers
  imageTimer?.cancel();
      pageController.dispose();
      try {
        for (final vc in videoControllers) {
          if (vc != null) {
            try { vc.pause(); } catch (_) {}
            try { vc.dispose(); } catch (_) {}
          }
        }
      } catch (_) {}
    } catch (e, stackTrace) {
      print('Error showing popup banner: $e');
      print('Stack trace: $stackTrace');
      // Don't crash the app if popup fails
    }
  }



// void _showPopupBanner() {
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (_) {
//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Stack(
//             children: [
//               Image.network(
//                 "http://localhost:63882/assets/image/no_coupon.png",  // ← CHANGE THIS
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//               ),

//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: InkWell(
//                   onTap: () => Get.back(),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       shape: BoxShape.circle,
//                     ),
//                     padding: EdgeInsets.all(6),
//                     child: Icon(Icons.close, color: Colors.white, size: 20),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context) ? Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
        insetPadding: const EdgeInsets.all(22),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: const ReferBottomSheetWidget(),
      ),
      useSafeArea: false,
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false))
        : showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const ReferBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }

  Future<void> loadTaxiApis() async{
   await Get.find<TaxiHomeController>().getTaxiBannerList(true);
   await Get.find<TaxiHomeController>().getTopRatedCarList(1, true);
    if (AuthHelper.isLoggedIn()) {
      await Get.find<AddressController>().getAddressList();
      await Get.find<TaxiHomeController>().getTaxiCouponList(true);
      await Get.find<TaxiCartController>().getCarCartList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      if(splashController.moduleList != null && splashController.moduleList!.length == 1) {
        splashController.switchModule(0, true);
      }
      bool showMobileModule = !ResponsiveHelper.isDesktop(context) && splashController.module == null && splashController.configModel!.module == null;
      // bool isParcel = splashController.module != null && splashController.configModel!.moduleConfig!.module!.isParcel!;
      bool isParcel = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.parcel;
      bool isPharmacy = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.pharmacy;
      bool isFood = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.food;
      bool isShop = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.ecommerce;
      bool isGrocery = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.grocery;
      bool isTaxi = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.taxi;

      return GetBuilder<HomeController>(builder: (homeController) {
        return Scaffold(
          appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: isParcel ? const ParcelCategoryScreen() : SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                splashController.setRefreshing(true);
                if (Get.find<SplashController>().module != null && !isTaxi) {
                  await Get.find<LocationController>().syncZoneData();
                  await Get.find<BannerController>().getBannerList(true);
                  await Get.find<BannerController>().getPopUpBannerList(true);
                  if (isGrocery) {
                    await Get.find<FlashSaleController>().getFlashSale(true, true);
                  }
                  await Get.find<BannerController>().getPromotionalBannerList(true);
                  await Get.find<ItemController>().getDiscountedItemList(true, false, 'all');
                  await Get.find<CategoryController>().getCategoryList(true);
                  // await Get.find<StoreController>().getPopularStoreList(true, 'all', false);
                  await Get.find<CampaignController>().getItemCampaignList(true);
                  Get.find<CampaignController>().getBasicCampaignList(true);
                  await Get.find<ItemController>().getLatestItemList(true, 'all', false);
                  await Get.find<ItemController>().getPopularItemList(true, 'all', false);
                  await Get.find<StoreController>().getLatestStoreList(true, 'all', false);
                  await Get.find<StoreController>().getTopOfferStoreList(true, false);
                  await Get.find<ItemController>().getReviewedItemList(true, 'all', false);
                  await Get.find<StoreController>().getStoreList(1, true);
                  Get.find<AdvertisementController>().getAdvertisementList();
                  if (AuthHelper.isLoggedIn()) {
                    await Get.find<ProfileController>().getUserInfo();
                    await Get.find<NotificationController>().getNotificationList(true);
                    Get.find<CouponController>().getCouponList();
                  }
                  if (isPharmacy) {
                    Get.find<ItemController>().getBasicMedicine(true, true);
                    Get.find<ItemController>().getCommonConditions(true);
                  }
                  if (isShop) {
                    await Get.find<FlashSaleController>().getFlashSale(true, true);
                    Get.find<ItemController>().getFeaturedCategoriesItemList(true, true);
                    Get.find<BrandsController>().getBrandList();
                  }
                } else if(isTaxi) {
                  await loadTaxiApis();
                } else {
                  await Get.find<BannerController>().getFeaturedBanner();
                  await Get.find<SplashController>().getModules();
                  if (AuthHelper.isLoggedIn()) {
                    await Get.find<AddressController>().getAddressList();
                  }
                  await Get.find<StoreController>().getFeaturedStoreList();
                }
                splashController.setRefreshing(false);
              },
              child: ResponsiveHelper.isDesktop(context) ? WebNewHomeScreen(
                scrollController: _scrollController,
              ) : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [

                  /// App Bar
                  SliverAppBar(
                    floating: true,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    surfaceTintColor: Theme.of(context).colorScheme.surface,
                    backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).colorScheme.surface,
                    title: Center(child: Container(
                      width: Dimensions.webMaxWidth, height: Get.find<LocalizationController>().isLtr ? 60 : 70, color: Theme.of(context).colorScheme.surface,
                      child: Row(children: [
                        (splashController.module != null && splashController.configModel!.module == null && splashController.moduleList != null && splashController.moduleList!.length != 1) ? InkWell(
                          onTap: () {
                            splashController.removeModule();
                            Get.find<StoreController>().resetStoreData();
                          },
                          child: Image.asset(Images.moduleIcon, height: 25, width: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
                        ) : const SizedBox(),
                        SizedBox(width: (splashController.module != null && splashController.configModel!.module == null && splashController.moduleList != null && splashController.moduleList!.length != 1) ? Dimensions.paddingSizeSmall : 0),

                        Expanded(child: InkWell(
                          onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                              horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                            ),
                            child: GetBuilder<LocationController>(builder: (locationController) {
                              final address = AddressHelper.getUserAddressFromSharedPref();
                              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(
                                  AuthHelper.isLoggedIn() && address?.addressType != null ? address!.addressType!.tr : 'your_location'.tr,
                                  style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),

                                Row(children: [
                                  Flexible(
                                    child: Text(
                                      address?.address ?? 'Tap to select location',
                                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  Icon(Icons.expand_more, color: Theme.of(context).disabledColor, size: 18),

                                ]),

                              ]);
                            }),
                          ),
                        )),
                        InkWell(
                          child: GetBuilder<NotificationController>(builder: (notificationController) {
                            return Stack(children: [
                              Icon(CupertinoIcons.bell, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
                              notificationController.hasNotification ? Positioned(top: 0, right: 0, child: Container(
                                height: 10, width: 10, decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor, shape: BoxShape.circle,
                                border: Border.all(width: 1, color: Theme.of(context).cardColor),
                              ),
                              )) : const SizedBox(),
                            ]);
                          }),
                          onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                        ),
                      ]),
                    )),
                    actions: const [SizedBox()],
                  ),

                  /// Search Button
                  !showMobileModule && !isTaxi ? SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverDelegate(callback: (val){}, child: Center(child: Container(
                      height: 50, width: Dimensions.webMaxWidth,
                      color: searchBgShow ? Get.find<ThemeController>().darkTheme ? Theme.of(context).colorScheme.surface : Theme.of(context).cardColor : null,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: isTaxi? Container(color: Theme.of(context).primaryColor): InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity( 0.2), width: 1),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                          ),
                          child: Row(children: [
                            Icon(
                              CupertinoIcons.search, size: 25,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Expanded(child: Text(
                              Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
                              ),
                            )),
                          ]),
                        ),
                      ),
                    ))),
                  ) : const SliverToBoxAdapter(),

                  SliverToBoxAdapter(
                    child: Center(child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: !showMobileModule ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        isGrocery ? const GroceryHomeScreen()
                            : isPharmacy ? const PharmacyHomeScreen()
                            : isFood ? const FoodHomeScreen()
                            : isShop ? const ShopHomeScreen()
                            : isTaxi ? const TaxiHomeScreen()
                            : const SizedBox(),

                      ]) : ModuleView(splashController: splashController),
                    )),
                  ),

                  // Store header (title + nearby count + filters): hidden but preserved in the tree.
                  // Change `offstage: true` to `false` to make it visible again.
                  !showMobileModule && !isTaxi ? SliverPersistentHeader(
                    key: _headerKey,
                    pinned: true,
                    delegate: SliverDelegate(
                      height: 85,
                      callback: (val) {
                        searchBgShow = val;
                      },
                      child: const Offstage(
                        offstage: true,
                        child: AllStoreFilterWidget(),
                      ),
                    ),
                  ) : const SliverToBoxAdapter(),

                  // Stores section: intentionally hidden but kept in the widget tree.
                  // To re-enable visible stores, set `offstage: false` below or remove the Offstage wrapper.
                  SliverToBoxAdapter(child: !showMobileModule && !isTaxi ? Center(child: Offstage(
                    // Hidden by default per user request. Keeps state and code intact.
                    offstage: true,
                    child: GetBuilder<StoreController>(builder: (storeController) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? 0 : 100),
                        child: PaginatedListView(
                          scrollController: _scrollController,
                          totalSize: storeController.storeModel?.totalSize,
                          offset: storeController.storeModel?.offset,
                          onPaginate: (int? offset) async => await storeController.getStoreList(offset!, false),
                          itemView: ItemsView(
                            isStore: true,
                            items: null,
                            isFoodOrGrocery: (isFood || isGrocery),
                            stores: storeController.storeModel?.stores,
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                              vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
                            ),
                          ),
                        ),
                      );
                    }),
                  )) : const SizedBox()),

                ],
              ),
            ),
          ),

          floatingActionButton: AuthHelper.isLoggedIn() && homeController.cashBackOfferList != null && homeController.cashBackOfferList!.isNotEmpty ?
          homeController.showFavButton ? Padding(
            padding: EdgeInsets.only(bottom: 50.0, right: ResponsiveHelper.isDesktop(context) ? 50 : 0),
            child: InkWell(
              onTap: () => Get.dialog(const CashBackDialogWidget()),
              child: const CashBackLogoWidget(),
            ),
          ) : null : null,

        );
      });
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  Function(bool isPinned)? callback;
  bool isPinned = false;

  SliverDelegate({required this.child, this.height = 50, this.callback});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    isPinned = shrinkOffset == maxExtent /*|| shrinkOffset < maxExtent*/;
    callback!(isPinned);
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}
