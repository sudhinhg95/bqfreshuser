import 'dart:convert';

import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/api/local_client.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/banner/domain/models/banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/others_banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/promotional_banner_model.dart';
import 'package:sixam_mart/features/banner/domain/repositories/banner_repository_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/header_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class BannerRepository implements BannerRepositoryInterface {
  final ApiClient apiClient;
  BannerRepository({required this.apiClient});

  @override
  Future getList({int? offset, bool isBanner = false, bool isTaxiBanner = false, bool isFeaturedBanner = false, bool isParcelOtherBanner = false, bool isPromotionalBanner = false, bool isPopUpBanner = false,DataSourceEnum? source}) async {
    if (isBanner) {
      return await _getBannerList(source: source!);
    } else if (isTaxiBanner) {
      return await _getTaxiBannerList();
    } else if (isFeaturedBanner) {
      return await _getFeaturedBannerList();
    } else if (isParcelOtherBanner) {
      return await _getParcelOtherBannerList();
    } else if (isPromotionalBanner) {
      return await _getPromotionalBannerList();
    } else if(isPopUpBanner) {
      return await _getPopUpBannerList();

    }
  }

  Future<BannerModel?> _getBannerList({required DataSourceEnum source}) async {
    BannerModel? bannerModel;
    String cacheId = '${AppConstants.bannerUri}-${Get.find<SplashController>().module!.id!}';

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.bannerUri);
        if (response.statusCode == 200) {
          bannerModel = BannerModel.fromJson(response.body);
          LocalClient.organize(source, cacheId, jsonEncode(response.body), apiClient.getHeader());

        }
      case DataSourceEnum.local:

        String? cacheResponseData = await LocalClient.organize(source, cacheId, null, null);
        if(cacheResponseData != null) {
          bannerModel = BannerModel.fromJson(jsonDecode(cacheResponseData));
        }
    }


    return bannerModel;
  }

  
Future<BannerModel?> _getPopUpBannerList() async {
  BannerModel? bannerModel;

  try {
    print('🔔 Popup API: Calling ${AppConstants.popupBannerUri}');
    Response response = await apiClient.getData(AppConstants.popupBannerUri).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('🔔 Popup API: Request timed out after 10 seconds');
        return const Response(statusCode: 408, statusText: 'Timeout', body: null);
      },
    );
    print('🔔 Popup API: Response Status: ${response.statusCode}');
    print('🔔 Popup API: Response Body: ${response.body}');

    if (response.statusCode == 200 && response.body != null) {
      print('🔔 Popup API: Response body type: ${response.body.runtimeType}');
      // Check if response.body is already a BannerModel structure
      if (response.body is Map<String, dynamic>) {
        final body = response.body as Map<String, dynamic>;
        print('🔔 Popup API: Response is Map, keys: ${body.keys.toList()}');
        // If it already has 'banners' or 'campaigns' key, use it directly
        if (body.containsKey('banners') || body.containsKey('campaigns')) {
          print('🔔 Popup API: Found banners/campaigns key, parsing directly');
          bannerModel = BannerModel.fromJson(body);
          // Debug: Check if banners were parsed
          if (bannerModel.banners != null) {
            print('🔔 Popup API: Parsed ${bannerModel.banners!.length} banners');
            for (var i = 0; i < bannerModel.banners!.length; i++) {
              final b = bannerModel.banners![i];
              print('🔔 Popup API: Banner $i - imageFullUrl: ${b.imageFullUrl}, image: ${b.image}');
              // If imageFullUrl is null but we have image_full_url in raw data, fix it
              if (b.imageFullUrl == null && body['banners'] is List) {
                final rawBanner = (body['banners'] as List)[i];
                if (rawBanner is Map && rawBanner.containsKey('image_full_url')) {
                  print('🔔 Popup API: Fixing banner $i - setting imageFullUrl from raw data');
                  b.imageFullUrl = rawBanner['image_full_url'] as String?;
                  print('🔔 Popup API: Fixed banner $i - imageFullUrl: ${b.imageFullUrl}');
                }
              }
            }
          }
        } else {
          // If it's a single banner object, wrap it in a list
          print('🔔 Popup API: No banners key, wrapping body as single banner');
          bannerModel = BannerModel.fromJson({
            'banners': [body]
          });
        }
      } else if (response.body is List) {
        // If response is a list, wrap it in banners
        print('🔔 Popup API: Response is List, wrapping in banners');
        bannerModel = BannerModel.fromJson({
          'banners': response.body
        });
      } else {
        // Single object, wrap in list
        print('🔔 Popup API: Response is other type, wrapping as single banner');
        bannerModel = BannerModel.fromJson({
          'banners': [response.body]
        });
      }
    } else {
      print('🔔 Popup API: Error - Status ${response.statusCode}, body: ${response.body}');
    }
  } catch (e, stackTrace) {
    print('Popup Banner API Exception: $e');
    print('Stack trace: $stackTrace');
  }

  // Optional: print just the image URLs for easier debugging
  final banners = bannerModel?.banners;
  if (banners != null) {
    print('🔔 Popup API: Found ${banners.length} banners in model');
    for (var b in banners) {
      print('🔔 Popup API: Banner ID: ${b.id}, Title: ${b.title}');
      print('🔔 Popup API: Banner imageFullUrl: ${b.imageFullUrl}');
      print('🔔 Popup API: Banner image: ${b.image}');
      print('🔔 Popup API: Banner type: ${b.type}');
    }
  }

  final campaigns = bannerModel?.campaigns;
  if (campaigns != null) {
    print('Popup Banner: Found ${campaigns.length} campaigns');
    for (var c in campaigns) {
      print('Campaign Image URL: ${c.imageFullUrl}');
    }
  }

  return bannerModel;
}

  

  Future<BannerModel?> _getTaxiBannerList() async {
    BannerModel? bannerModel;
    Response response = await apiClient.getData(AppConstants.taxiBannerUri);
    if (response.statusCode == 200) {
      bannerModel = BannerModel.fromJson(response.body);
    }
    return bannerModel;
  }

  Future<BannerModel?> _getFeaturedBannerList() async {
    BannerModel? bannerModel;
    Response response = await apiClient.getData('${AppConstants.bannerUri}?featured=1', headers: HeaderHelper.featuredHeader());
    if (response.statusCode == 200) {
      bannerModel = BannerModel.fromJson(response.body);
    }
    return bannerModel;
  }

  Future<ParcelOtherBannerModel?> _getParcelOtherBannerList() async {
    ParcelOtherBannerModel? parcelOtherBannerModel;
    Response response = await apiClient.getData(AppConstants.parcelOtherBannerUri);
    if (response.statusCode == 200) {
      parcelOtherBannerModel = ParcelOtherBannerModel.fromJson(response.body);
    }
    return parcelOtherBannerModel;
  }

  Future<PromotionalBanner?> _getPromotionalBannerList() async {
    PromotionalBanner? promotionalBanner;
    Response response = await apiClient.getData(AppConstants.promotionalBannerUri);
    if (response.statusCode == 200 && response.body is Map) {
      promotionalBanner = PromotionalBanner.fromJson(response.body);
    }
    return promotionalBanner;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}