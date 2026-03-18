import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/checkout/widgets/slot_widget.dart';

class TimeSlotBottomSheet extends StatefulWidget {
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  const TimeSlotBottomSheet({super.key, required this.tomorrowClosed, required this.todayClosed, required this.module});

  @override
  State<TimeSlotBottomSheet> createState() => _TimeSlotBottomSheetState();
}

class _TimeSlotBottomSheetState extends State<TimeSlotBottomSheet> {

  int selectedTimeSlotIndex = 0;
  String selectedTimeSlot = '';

  @override
  void initState() {
    super.initState();
    selectedTimeSlotIndex = Get.find<CheckoutController>().selectedTimeSlot;
    selectedTimeSlot = Get.find<CheckoutController>().preferableTime;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return GetBuilder<StoreController>(builder: (storeController) {
        // Custom slot logic with three delivery windows:
        // 7:00 AM - 10:00 AM, 10:00 AM - 1:00 PM, 1:00 PM - 4:00 PM
        final now = DateTime.now();
        final todaySlots = <String>[];
        final tomorrowSlots = <String>[];

        const slotMorning = '7:00 AM - 10:00 AM';
        const slotMidday = '10:00 AM - 1:00 PM';
        const slotAfternoon = '1:00 PM - 4:00 PM';

        // Today: hide slots that are already in the past
        if (checkoutController.selectedDateSlot == 0) {
          if (now.hour < 7) {
            todaySlots.addAll([slotMorning, slotMidday, slotAfternoon]);
          } else if (now.hour < 10) {
            todaySlots.addAll([slotMidday, slotAfternoon]);
          } else if (now.hour < 15) {
            todaySlots.add(slotAfternoon);
          }
        }

        // Tomorrow: always offer all three slots
        if (checkoutController.selectedDateSlot == 1) {
          tomorrowSlots.addAll([slotMorning, slotMidday, slotAfternoon]);
        }

        final slots = checkoutController.selectedDateSlot == 0 ? todaySlots : tomorrowSlots;
        final bool isClosedDay =
          (checkoutController.selectedDateSlot == 0 && widget.todayClosed) ||
          (checkoutController.selectedDateSlot == 1 && widget.tomorrowClosed);
        final bool noSlots = !isClosedDay && slots.isEmpty;

        return Container(
          width: ResponsiveHelper.isDesktop(context) ? 550 : context.width,
          constraints: BoxConstraints(
            maxHeight: noSlots ? context.height * 0.5 : context.height * 0.8,
            minHeight: 0,
          ),
          margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: ResponsiveHelper.isMobile(context)
                ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
                : const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                !ResponsiveHelper.isDesktop(context)
                    ? InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          height: 4,
                          width: 35,
                          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    : const SizedBox(),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(children: [
                        Expanded(
                          child: tabView(
                              context: context,
                              title: 'today'.tr,
                              isSelected: checkoutController.selectedDateSlot == 0,
                              onTap: () {
                                checkoutController.updateDateSlot(0, Get.find<StoreController>().store!.orderPlaceToScheduleInterval);
                              }),
                        ),
                        Expanded(
                          child: tabView(
                              context: context,
                              title: 'tomorrow'.tr,
                              isSelected: checkoutController.selectedDateSlot == 1,
                              onTap: () {
                                checkoutController.updateDateSlot(1, Get.find<StoreController>().store!.orderPlaceToScheduleInterval);
                              }),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Flexible(
                        child: isClosedDay
                            ? Center(child: Text(widget.module!.showRestaurantText! ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr))
                            : slots.isNotEmpty
                                ? GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : 2,
                                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                                      crossAxisSpacing: Dimensions.paddingSizeSmall,
                                      childAspectRatio: ResponsiveHelper.isDesktop(context)
                                          ? 3
                                          : 2.2,
                                    ),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(left: 2),
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: slots.length,
                                    itemBuilder: (context, index) {
                                      final time = slots[index];
                                      return SlotWidget(
                                        title: time,
                                        isSelected: selectedTimeSlotIndex == index,
                                        onTap: () {
                                          setState(() {
                                            selectedTimeSlotIndex = index;
                                            selectedTimeSlot = time;
                                          });
                                        },
                                      );
                                    },
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                      child: Text(
                                        'no_slot_available'.tr,
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall * 1.25,
                                          color: Theme.of(context).disabledColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                      ),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall),
                  child: Row(children: [
                    Expanded(
                      child: CustomButton(
                        radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                        height: ResponsiveHelper.isDesktop(context) ? 50 : null,
                        isBold: ResponsiveHelper.isDesktop(context) ? false : true,
                        buttonText: 'cancel'.tr,
                        color: Theme.of(context).disabledColor,
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: CustomButton(
                        radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                        height: ResponsiveHelper.isDesktop(context) ? 50 : null,
                        isBold: ResponsiveHelper.isDesktop(context) ? false : true,
                        buttonText: 'schedule'.tr,
                        onPressed: () {
                          checkoutController.updateTimeSlot(selectedTimeSlotIndex);
                          checkoutController.setPreferenceTimeForView(selectedTimeSlot);
                          Get.back();
                        },
                      ),
                    ),
                  ]),
                )
              ],),
          ),
        );
      });
    });
  }

  Widget tabView({required BuildContext context, required String title, required bool isSelected, required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(title, style: isSelected ? robotoBold.copyWith(color: Theme.of(context).primaryColor) : robotoMedium),
          ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
          Divider(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, thickness: isSelected ? 2 : 1),
        ],
      ),
    );
  }

}
