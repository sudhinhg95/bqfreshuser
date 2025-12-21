import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressWidget extends StatelessWidget {
  final AddressModel? address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function? onRemovePressed;
  final Function? onEditPressed;
  final Function? onTap;
  final bool isSelected;
  final bool fromDashBoard;
  // Optional override for the displayed address type key (e.g. show
  // 'your_location' instead of the raw addressType like 'others').
  final String? overrideAddressTypeKey;
  const AddressWidget({super.key, required this.address, required this.fromAddress, this.onRemovePressed, this.onEditPressed,
    this.onTap, this.fromCheckout = false, this.isSelected = false, this.fromDashBoard = false, this.overrideAddressTypeKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: fromCheckout ? 0 : Dimensions.paddingSizeSmall),
      child: Container(
        decoration: fromDashBoard ? BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent, width: isSelected ? 1 : 0),
        ) : fromCheckout ? const BoxDecoration() : BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor, width: isSelected ? 0.5 : 0),
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity( 0.1), blurRadius: 5, spreadRadius: 1)],
        ),
        child: CustomInkWell(
          onTap: onTap as void Function()?,
          radius: fromDashBoard ? Dimensions.radiusDefault : fromCheckout ? 0 : Dimensions.radiusSmall,
          child: Padding(
            padding: EdgeInsets.all(
              fromCheckout
                  ? Dimensions.paddingSizeExtraSmall
                  : (ResponsiveHelper.isDesktop(context)
                      ? Dimensions.paddingSizeDefault
                      : Dimensions.paddingSizeSmall),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Image.asset(
                        (overrideAddressTypeKey ?? address!.addressType) == 'home'
                            ? Images.homeIcon
                            : (overrideAddressTypeKey ?? address!.addressType) == 'office'
                                ? Images.workIcon
                                : Images.otherIcon,
                        color: Theme.of(context).primaryColor,
                        height: ResponsiveHelper.isDesktop(context) ? 25 : 20,
                        width: ResponsiveHelper.isDesktop(context) ? 25 : 20,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Text(
                        (overrideAddressTypeKey ?? address!.addressType)!.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      address!.address ?? '',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      maxLines: fromCheckout ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    Builder(builder: (context) {
                      // On checkout, only show the main delivery address line,
                      // not the detailed flat/building/road/block/area summary.
                      if(fromCheckout) {
                        return const SizedBox();
                      }

                      final parts = <String>[];
                      // Order: Flat/Villa, Building, Road, Block, Area
                      if(address!.floor != null && address!.floor!.isNotEmpty) {
                        parts.add('${'Flat/Villa'.tr}: ${address!.floor!}');
                      }
                      if(address!.house != null && address!.house!.isNotEmpty) {
                        parts.add('${'Building'.tr}: ${address!.house!}');
                      }
                      if(address!.streetNumber != null && address!.streetNumber!.isNotEmpty) {
                        parts.add('${'Road'.tr}: ${address!.streetNumber!}');
                      }
                      if(address!.block != null && address!.block!.isNotEmpty) {
                        parts.add('${'Block'.tr}: ${address!.block!}');
                      }
                      if(address!.area != null && address!.area!.isNotEmpty) {
                        parts.add('${'Area'.tr}: ${address!.area!}');
                      }

                      if(parts.isEmpty) {
                        return const SizedBox();
                      }

                      return Text(
                        parts.join(', '),
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ]),
                ),

                fromAddress ? IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 25),
                  onPressed: onEditPressed as void Function()?,
                ) : const SizedBox(),

                fromAddress ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 25),
                  onPressed: onRemovePressed as void Function()?,
                ) : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}