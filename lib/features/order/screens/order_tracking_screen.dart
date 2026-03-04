import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/widgets/permission_dialog_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/marker_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/order/widgets/track_details_view_widget.dart';
import 'package:sixam_mart/features/order/widgets/tracking_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen({super.key, required this.orderID, this.contactNumber});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polyline> _polylines = HashSet<Polyline>();
  LatLng? _lastDeliveryLatLng;
  Timer? _timer;
  bool showChatPermission = true;
  bool isHovered = false;
  bool _routeErrorShown = false;

  void _loadData() async {
    await Get.find<OrderController>().trackOrder(widget.orderID, null, true, contactNumber: widget.contactNumber);
    await Get.find<LocationController>().getCurrentLocation(true, notify: false, defaultLatLng: LatLng(
      double.parse(AddressHelper.getUserAddressFromSharedPref()!.latitude!),
      double.parse(AddressHelper.getUserAddressFromSharedPref()!.longitude!),
    ));
  }

  void _startApiCall(){
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);
    });
  }

  @override
  void initState() {
    super.initState();

    _loadData();
    _startApiCall();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _timer?.cancel();
  }

  void onEntered(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'order_tracking'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel? track;
        if(orderController.trackModel != null) {
          track = orderController.trackModel;

          if(track!.orderType != 'parcel') {
            if (track.store!.storeBusinessModel == 'commission') {
              showChatPermission = true;
            } else if (track.store!.storeSubscription != null && track.store!.storeBusinessModel == 'subscription') {
              showChatPermission = track.store!.storeSubscription!.chat == 1;
            } else {
              showChatPermission = false;
            }
          } else {
            showChatPermission = AuthHelper.isLoggedIn();
          }
        }

        return track != null ? SingleChildScrollView(
          physics: isHovered || !ResponsiveHelper.isDesktop(context) ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          child: FooterView(
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, height: ResponsiveHelper.isDesktop(context) ? 700 : MediaQuery.of(context).size.height * 0.85, child: Stack(children: [

              MouseRegion(
                onEnter: (event) => onEntered(true),
                onExit: (event) => onEntered(false),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: LatLng(
                    double.parse(track.deliveryAddress!.latitude!), double.parse(track.deliveryAddress!.longitude!),
                  ), zoom: 16),
                  minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                  zoomControlsEnabled: false,
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    _isLoading = false;
                    setMarker(
                      track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                          address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, track.deliveryMan,
                      track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                        latitude: Get.find<LocationController>().position.latitude.toString(),
                        longitude: Get.find<LocationController>().position.longitude.toString(),
                        address: Get.find<LocationController>().address,
                      ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                    );
                  },
                  style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                ),
              ),

              // Ensure marker/polyline updates when track data changes (timer updates)
              // If controller is ready and deliveryMan location changed, update map visuals
              Builder(builder: (_) {
                // Guard against nulls captured by the closure: ensure track and deliveryMan exist before access
                if (_controller != null && track != null && track.deliveryMan != null) {
                  final dm = track.deliveryMan!;
                  try {
                    final LatLng currentDeliveryLatLng = LatLng(double.parse(dm.lat ?? '0'), double.parse(dm.lng ?? '0'));
                    // Only update map when coordinate changed to avoid excessive redraws
                    if (_lastDeliveryLatLng == null || _lastDeliveryLatLng!.latitude != currentDeliveryLatLng.latitude || _lastDeliveryLatLng!.longitude != currentDeliveryLatLng.longitude) {
                      _lastDeliveryLatLng = currentDeliveryLatLng;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setMarker(
                          track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                              address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, dm,
                          track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                            latitude: Get.find<LocationController>().position.latitude.toString(),
                            longitude: Get.find<LocationController>().position.longitude.toString(),
                            address: Get.find<LocationController>().address,
                          ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                        );
                      });
                    }
                  } catch (_) {}
                }
                return const SizedBox.shrink();
              }),

              _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),

              Positioned(
                top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                child: TrackingStepperWidget(status: track.orderStatus, takeAway: track.orderType == 'take_away'),
              ),

              Positioned(
                right: 15, bottom: track.orderType != 'take_away' && track.deliveryMan == null ? 150 : 220,
                child: InkWell(
                  onTap: () => _checkPermission(() async {
                    AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                    setMarker(
                      track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                          address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, track.deliveryMan,
                      track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                        latitude: Get.find<LocationController>().position.latitude.toString(),
                        longitude: Get.find<LocationController>().position.longitude.toString(),
                        address: Get.find<LocationController>().address,
                      ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                      currentAddress: address, fromCurrentLocation: true,
                    );
                  }),
                  child: Container(
                    padding: const EdgeInsets.all( Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                    child: Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: 25),
                  ),
                ),
              ),

              Positioned(
                bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                child: TrackDetailsViewWidget(status: track.orderStatus, track: track, showChatPermission: showChatPermission, callback: () async{
                  _timer?.cancel();
                  await Get.toNamed(RouteHelper.getChatRoute(
                    notificationBody: NotificationBodyModel(deliverymanId: track!.deliveryMan!.id, orderId: int.parse(widget.orderID!)),
                    user: User(id: track.deliveryMan!.id, fName: track.deliveryMan!.fName, lName: track.deliveryMan!.lName, imageFullUrl: track.deliveryMan!.imageFullUrl),
                  ));
                  _startApiCall();
                }),
              ),

            ]))),
          ),
        ) : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  void setMarker(Store? store, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway, bool parcel, bool isRestaurant, {AddressModel? currentAddress, bool fromCurrentLocation = false}) async {
    try {

      BitmapDescriptor restaurantImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: (isRestaurant || parcel) ? 30 : isRestaurant ? 30 : 50,
        imagePath: parcel ? Images.userMarker : isRestaurant ? Images.restaurantMarker : Images.markerStore,
      );

      BitmapDescriptor deliveryBoyImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 30, imagePath: Images.deliveryManMarker,
      );
      BitmapDescriptor destinationImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 30, imagePath: takeAway ? Images.myLocationMarker : Images.userMarker,
      );

      /// Animate to coordinate: compute bounds that include user, store and delivery man
      LatLngBounds? bounds;
      double rotation = 0;
      if(_controller != null) {
        List<LatLng> boundPoints = [];

        // For tracking, focus the camera on the live trip only:
        // rider + user destination. We still show the store marker,
        // but do not include it in the bounds so the view
        // stays tight around the current route instead of the
        // original pickup location.
        if (addressModel != null && addressModel.latitude != null && addressModel.longitude != null) {
          boundPoints.add(LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)));
        }
        if (deliveryMan != null && deliveryMan.lat != null && deliveryMan.lng != null) {
          boundPoints.add(LatLng(double.parse(deliveryMan.lat!), double.parse(deliveryMan.lng!)));
        }

        if (boundPoints.length >= 2) {
          double south = boundPoints.first.latitude;
          double north = boundPoints.first.latitude;
          double west = boundPoints.first.longitude;
          double east = boundPoints.first.longitude;

          for (final point in boundPoints.skip(1)) {
            south = south > point.latitude ? point.latitude : south;
            north = north < point.latitude ? point.latitude : north;
            west = west > point.longitude ? point.longitude : west;
            east = east < point.longitude ? point.longitude : east;
          }

          bounds = LatLngBounds(
            southwest: LatLng(south, west),
            northeast: LatLng(north, east),
          );
        }
      }
      LatLng centerBounds = bounds != null
          ? LatLng(
              (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
              (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
            )
          : LatLng(
              double.parse(addressModel!.latitude!),
              double.parse(addressModel.longitude!),
            );

      if(fromCurrentLocation && currentAddress != null) {
        LatLng currentLocation = LatLng(
          double.parse(currentAddress.latitude!),
          double.parse(currentAddress.longitude!),
        );
        _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLocation, zoom: GetPlatform.isWeb ? 15 : 17)));
      }

      if(!fromCurrentLocation && bounds != null) {
        // Fit all key points (user, store, rider) nicely on screen with padding
        _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      } else if (!fromCurrentLocation) {
        // Fallback if bounds could not be computed
        _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 15 : 17)));
      }

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();

      ///current location marker set
      if(currentAddress != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          visible: true,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.parse(currentAddress.latitude!),
            double.parse(currentAddress.longitude!),
          ),
          icon: destinationImageData,
        ));
        setState(() {});
      }

      if(currentAddress == null){
        addressModel != null ? _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'sender'.tr : 'Destination'.tr,
            snippet: addressModel.address,
          ),
          icon: destinationImageData,
        )) : const SizedBox();
      }

      ///store for normal order , but receiver for parcel order
      store != null ? _markers.add(Marker(
        markerId: const MarkerId('store'),
        position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
        infoWindow: InfoWindow(
          title: parcel ? 'receiver'.tr : Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'store'.tr : 'store'.tr,
          snippet: store.address,
        ),
        icon: restaurantImageData,
      )) : const SizedBox();

      deliveryMan != null ? _markers.add(Marker(
        markerId: const MarkerId('delivery_boy'),
        position: LatLng(double.parse(deliveryMan.lat ?? '0'), double.parse(deliveryMan.lng ?? '0')),
        infoWindow: InfoWindow(
          title: 'delivery_man'.tr,
          snippet: deliveryMan.location,
        ),
        rotation: rotation,
        icon: deliveryBoyImageData,
      )) : const SizedBox();

      // Build a route polyline between delivery person and destination/store using direction-api,
      // falling back to a straight line if route data is unavailable
      try {
        _polylines = HashSet<Polyline>();

        LatLng? origin;
        LatLng? destination;

        if (deliveryMan != null && deliveryMan.lat != null && deliveryMan.lng != null) {
          origin = LatLng(double.parse(deliveryMan.lat!), double.parse(deliveryMan.lng!));
        }

        if (addressModel != null && addressModel.latitude != null && addressModel.longitude != null) {
          destination = LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!));
        } else if (store != null && store.latitude != null && store.longitude != null) {
          destination = LatLng(double.parse(store.latitude!), double.parse(store.longitude!));
        }

        List<LatLng> routePoints = [];
        if (origin != null && destination != null) {
          routePoints = await _getRoutePoints(origin, destination);
        }

        if (routePoints.isEmpty && origin != null && destination != null) {
          routePoints = [origin, destination];
        }

        if (routePoints.length >= 2) {
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: routePoints,
            color: Get.theme.primaryColor,
            width: 4,
          ));
        }
      } catch (_) {}

    }catch(_) {}
    setState(() {});
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng destination) async {
    try {
      // Call Google Directions directly using the same JSON format you sent.
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin='
          '${origin.latitude},${origin.longitude}&destination='
          '${destination.latitude},${destination.longitude}'
          '&mode=driving&key=${AppConstants.googleMapsApiKey}';

      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is Map) {
          if (data['status'] == 'OK') {
            final dynamic routes = data['routes'];
            if (routes is List && routes.isNotEmpty) {
              final dynamic overview = routes[0]['overview_polyline'];
              if (overview is Map && overview['points'] is String) {
                final points = _decodePolyline(overview['points'] as String);
                if (!_routeErrorShown) {
                  _routeErrorShown = true;
                  // ignore: avoid_print
                  print('Directions OK, route points: ${points.length}');
                }
                return points;
              }
            }
          } else if (!_routeErrorShown) {
            _routeErrorShown = true;
            final dynamic status = data['status'];
            final dynamic errorMessage = data['error_message'];
            // Log once so you can see the real problem in the console
            // (for example: REQUEST_DENIED, API not enabled, etc.).
            // This does not crash the app; we still fall back to straight line.
            // You can see this in "flutter run" / browser console.
            // ignore: avoid_print
            print('Google Directions API error: status=' '$status' ', message=' '$errorMessage');
          }
        }
      } else if (!_routeErrorShown) {
        _routeErrorShown = true;
        // ignore: avoid_print
        print('Google Directions HTTP error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      if (!_routeErrorShown) {
        _routeErrorShown = true;
        // ignore: avoid_print
        print('Google Directions exception: $e');
      }
    }
    return <LatLng>[];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = <LatLng>[];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int result = 0;
      int shift = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      result = 0;
      shift = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    }else {
      onTap();
    }
  }

}
