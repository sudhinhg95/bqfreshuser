import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/banner/domain/models/banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/others_banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/promotional_banner_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/banner/domain/services/banner_service_interface.dart';

class BannerController extends GetxController implements GetxService {
  final BannerServiceInterface bannerServiceInterface;
  BannerController({required this.bannerServiceInterface});

  List<String?>? _bannerImageList;
  List<String?>? get bannerImageList => _bannerImageList;

    List<String?>? _bannerPopUpImageList;
  List<String?>? get popupBannerImageList => _bannerPopUpImageList;
  
  List<String?>? _taxiBannerImageList;
  List<String?>? get taxiBannerImageList => _taxiBannerImageList;
  
  List<String?>? _featuredBannerList;
  List<String?>? get featuredBannerList => _featuredBannerList;
  
  List<dynamic>? _bannerDataList;
  List<dynamic>? get bannerDataList => _bannerDataList;

  List<dynamic>? _bannerPopUpDataList;
  List<dynamic>? get popupBannerDataList => _bannerPopUpDataList;
  
  List<dynamic>? _taxiBannerDataList;
  List<dynamic>? get taxiBannerDataList => _taxiBannerDataList;
  
  List<dynamic>? _featuredBannerDataList;
  List<dynamic>? get featuredBannerDataList => _featuredBannerDataList;
  
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  ParcelOtherBannerModel? _parcelOtherBannerModel;
  ParcelOtherBannerModel? get parcelOtherBannerModel => _parcelOtherBannerModel;
  
  PromotionalBanner? _promotionalBanner;
  PromotionalBanner? get promotionalBanner => _promotionalBanner;

  Future<void> getFeaturedBanner() async {
    BannerModel? bannerModel = await bannerServiceInterface.getFeaturedBannerList();
    if (bannerModel != null) {
      _featuredBannerList = [];
      _featuredBannerDataList = [];

      List<int?> moduleIdList = bannerServiceInterface.moduleIdList();

      for (var campaign in bannerModel.campaigns!) {
        if(_featuredBannerList!.contains(campaign.imageFullUrl)) {
          _featuredBannerList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
        } else {
          _featuredBannerList!.add(campaign.imageFullUrl);
        }
        _featuredBannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if(_featuredBannerList!.contains(banner.imageFullUrl)) {
          _featuredBannerList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          _featuredBannerList!.add(banner.imageFullUrl);
        }
        if(banner.item != null && moduleIdList.contains(banner.item!.moduleId)) {
          _featuredBannerDataList!.add(banner.item);
        }else if(banner.store != null && moduleIdList.contains(banner.store!.moduleId)) {
          _featuredBannerDataList!.add(banner.store);
        }else if(banner.type == 'default') {
          _featuredBannerDataList!.add(banner.link);
        }else{
          _featuredBannerDataList!.add(null);
        }
      }
    }
    update();
  }

  void clearBanner() {
    _bannerImageList = null;
  }
  
  void clearPopupBanner() {
    _bannerPopUpImageList = null;
    _bannerPopUpDataList = null;
  }

  Future<void> getBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_bannerImageList == null || reload || fromRecall) {
      if(reload) {
        _bannerImageList = null;
      }
      BannerModel? bannerModel;
      if(dataSource == DataSourceEnum.local) {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.local);
        await _prepareBanner(bannerModel);

        getBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.client);
        _prepareBanner(bannerModel);
      }

    }
  }

  Future<BannerModel?> getPopUpBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
  if (_bannerPopUpImageList == null || reload || fromRecall) {
    if (reload) _bannerPopUpImageList = null;

    BannerModel? bannerModel;
    if (dataSource == DataSourceEnum.local) {
      bannerModel = await bannerServiceInterface.getPopUpBannerList(source: DataSourceEnum.local);
    
      await _preparePopUpBanner(bannerModel);
      getPopUpBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
    } else {
      bannerModel = await bannerServiceInterface.getPopUpBannerList(source: DataSourceEnum.client);
      _preparePopUpBanner(bannerModel);
    }
    return bannerModel; // <- return here
  }
  return null; // or return previously fetched model
}

_preparePopUpBanner(BannerModel? bannerModel) async {
  try {
    if (bannerModel != null) {
      _bannerPopUpImageList = [];
      _bannerPopUpDataList = [];

      // Use a set to avoid duplicate URLs
      final seen = <String>{};

      // Include campaigns first (if any) so popup shows campaign images first
      for (var campaign in bannerModel.campaigns ?? []) {
        // prefer full url; campaigns may not provide a raw image filename, so we only use imageFullUrl
        String? url = campaign.imageFullUrl;
        if (url != null && url.isNotEmpty && !seen.contains(url)) {
          _bannerPopUpImageList!.add(url);
          _bannerPopUpDataList!.add(campaign);
          seen.add(url);
        }
      }

      // Then include normal banners
      for (var banner in bannerModel.banners ?? []) {
        String? url = banner.imageFullUrl;
        print('🔔 Popup Prepare: Banner imageFullUrl = $url');
        print('🔔 Popup Prepare: Banner image = ${banner.image}');
        // If server returned only filename in 'image', construct a few likely URLs
        if ((url == null || url.isEmpty) && (banner.image != null && banner.image!.isNotEmpty)) {
          final filename = banner.image!.trim();
          // common storage locations used by Laravel apps — try them in order
          final candidates = [
            '${AppConstants.baseUrl}/storage/app/public/store/cover/$filename',
            '${AppConstants.baseUrl}/storage/app/public/banner/$filename',
            '${AppConstants.baseUrl}/storage/app/public/$filename',
            '${AppConstants.baseUrl}/storage/$filename',
          ];
          for (final candidate in candidates) {
            if (!seen.contains(candidate)) {
              _bannerPopUpImageList!.add(candidate);
              _bannerPopUpDataList!.add(banner);
              seen.add(candidate);
              print('🔔 Popup Prepare: Added candidate banner URL to list: $candidate');
            }
          }
        } else {
          if (url != null && url.isNotEmpty && !seen.contains(url)) {
            _bannerPopUpImageList!.add(url);
            _bannerPopUpDataList!.add(banner);
            seen.add(url);
            print('🔔 Popup Prepare: Added banner URL to list: $url');
          } else {
            print('🔔 Popup Prepare: Skipped banner (url null/empty or duplicate)');
          }
        }
      }
      print('🔔 Popup Prepare: Final banner list length: ${_bannerPopUpImageList?.length ?? 0}');
    }
    update();
  } catch (e, stack) {
    print("Error in _prepareBanner: $e");
    print(stack);
  }
}


  _prepareBanner(BannerModel? bannerModel) async{
  
    if (bannerModel != null) {
      _bannerImageList = [];
      _bannerDataList = [];
      for (var campaign in bannerModel.campaigns!) {
        if(_bannerImageList!.contains(campaign.imageFullUrl)) {
          _bannerImageList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
        } else {
          _bannerImageList!.add(campaign.imageFullUrl);
        }
        _bannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {

        if(_bannerImageList!.contains(banner.imageFullUrl)) {
          _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          _bannerImageList!.add(banner.imageFullUrl);
        }

        if(banner.item != null) {
          _bannerDataList!.add(banner.item);
        }else if(banner.store != null){
          _bannerDataList!.add(banner.store);
        }else if(banner.type == 'default'){
          _bannerDataList!.add(banner.link);
        }else{
          _bannerDataList!.add(null);
        }
      }
    }


    update();
  }

  Future<void> getTaxiBannerList(bool reload) async {
    if(_taxiBannerImageList == null || reload) {
      _taxiBannerImageList = null;
      BannerModel? bannerModel = await bannerServiceInterface.getTaxiBannerList();
      if (bannerModel != null) {
        _taxiBannerImageList = [];
        _taxiBannerDataList = [];
        for (var campaign in bannerModel.campaigns!) {
          _taxiBannerImageList!.add(campaign.imageFullUrl);
          _taxiBannerDataList!.add(campaign);
        }
        for (var banner in bannerModel.banners!) {
          _taxiBannerImageList!.add(banner.imageFullUrl);
          if(banner.item != null) {
            _taxiBannerDataList!.add(banner.item);
          }else if(banner.store != null){
            _taxiBannerDataList!.add(banner.store);
          }else if(banner.type == 'default'){
            _taxiBannerDataList!.add(banner.link);
          }else{
            _taxiBannerDataList!.add(null);
          }
        }
        if(ResponsiveHelper.isDesktop(Get.context) && _taxiBannerImageList!.length % 2 != 0){
          _taxiBannerImageList!.add(_taxiBannerImageList![0]);
          _taxiBannerDataList!.add(_taxiBannerDataList![0]);
        }
      }
      update();
    }
  }

  Future<void> getParcelOtherBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_parcelOtherBannerModel == null || reload || fromRecall) {
      ParcelOtherBannerModel? parcelOtherBannerModel;
      if(dataSource == DataSourceEnum.local) {
        parcelOtherBannerModel = await bannerServiceInterface.getParcelOtherBannerList(source: dataSource);
        _prepareParcelBanner(parcelOtherBannerModel);
        getParcelOtherBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        parcelOtherBannerModel = await bannerServiceInterface.getParcelOtherBannerList(source: dataSource);
        _prepareParcelBanner(parcelOtherBannerModel);
      }
    }
  }

  _prepareParcelBanner(ParcelOtherBannerModel? parcelOtherBannerModel) {
    if (parcelOtherBannerModel != null) {
      _parcelOtherBannerModel = parcelOtherBannerModel;
    }
    update();
  }

  Future<void> getPromotionalBannerList(bool reload) async {
    if(_promotionalBanner == null || reload) {
      PromotionalBanner? promotionalBanner = await bannerServiceInterface.getPromotionalBannerList();
      if (promotionalBanner != null) {
        _promotionalBanner = promotionalBanner;
      }
      update();
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  /// Return the first non-empty banner image URL from the prepared banner list
  /// or null if none is available. This is a safe helper for UI popups that
  /// need a single banner image.
  String? getFirstBannerImage() {
    if (_bannerImageList == null || _bannerImageList!.isEmpty) return null;
    for (final img in _bannerImageList!) {
      if (img != null && img.trim().isNotEmpty) return img.trim();
    }
    return null;
  }
  
  /// Return the first image from the popup banner list, if any.
  String? getFirstPopupBannerImage() {
    if (_bannerPopUpImageList == null || _bannerPopUpImageList!.isEmpty) return null;
    for (final img in _bannerPopUpImageList!) {
      if (img != null && img.trim().isNotEmpty) return img.trim();
    }
    return null;
  }
  
}