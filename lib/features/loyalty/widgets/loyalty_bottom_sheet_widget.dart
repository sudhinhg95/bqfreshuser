import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/loyalty/controllers/loyalty_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';

class LoyaltyBottomSheetWidget extends StatefulWidget {
  final String amount;
  const LoyaltyBottomSheetWidget({super.key, required this.amount});

  @override
  State<LoyaltyBottomSheetWidget> createState() => _LoyaltyBottomSheetWidgetState();
}

class _LoyaltyBottomSheetWidgetState extends State<LoyaltyBottomSheetWidget> {

  final TextEditingController _amountController = TextEditingController();

  int _selectedAmount = 100;

  int? exchangePointRate = Get.find<SplashController>().configModel!.loyaltyPointExchangeRate ?? 0;
  int? minimumExchangePoint = Get.find<SplashController>().configModel!.minimumPointToTransfer ?? 0;

  @override
  void initState() {
    super.initState();
    int availablePoints = int.tryParse(widget.amount) ?? 0;

    if(availablePoints >= 500) {
      _selectedAmount = 500;
    }else if(availablePoints >= 400) {
      _selectedAmount = 400;
    }else if(availablePoints >= 300) {
      _selectedAmount = 300;
    }else if(availablePoints >= 200) {
      _selectedAmount = 200;
    }else if(availablePoints >= 100) {
      _selectedAmount = 100;
    }

    _amountController.text = _selectedAmount.toString();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
          width: ResponsiveHelper.isDesktop(context) ? 400 : 550,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Image.asset(ResponsiveHelper.isDesktop(context) ? Images.loyaltyConvertIcon : Images.creditIcon, height: 50, width: 50),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '$exchangePointRate ${'points'.tr}= ',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                Text(
                  PriceConverter.convertPrice(1), textDirection: TextDirection.ltr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                'Available Points: ${widget.amount}',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                'Once converted, it will show in your wallet.',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge :  Dimensions.paddingSizeLarge),

              SizedBox(
                width: ResponsiveHelper.isDesktop(context) ? 260 : 180,
                child: DropdownButtonFormField<int>(
                  value: _selectedAmount,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                    labelText: 'Select points to convert',
                  ),
                  items: const [100, 200, 300, 400, 500].map((value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  )).toList(),
                  onChanged: (value) {
                    if(value != null) {
                      setState(() {
                        _selectedAmount = value;
                        _amountController.text = value.toString();
                      });
                    }
                  },
                ),
              ),

              SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeLarge),

              GetBuilder<LoyaltyController>(builder: (walletController) {
                return CustomButton(
                  width: ResponsiveHelper.isDesktop(context) ? 136 : context.width/3, isBold: false,
                  buttonText: 'convert'.tr, radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : 50,
                  isLoading: walletController.isLoading,
                  onPressed: () {
                    if(_amountController.text.isEmpty) {
                      if(Get.isBottomSheetOpen!){
                        Get.back();
                      }
                      showCustomSnackBar('input_field_is_empty'.tr);
                    }else{
                      int amount = int.parse(_amountController.text.trim());
                      int? point = Get.find<ProfileController>().userInfoModel!.loyaltyPoint;

                      if(amount <minimumExchangePoint!){
                        if(Get.isBottomSheetOpen!){
                          Get.back();
                        }
                        showCustomSnackBar('${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}');
                      }else if(point! < amount){
                        if(Get.isBottomSheetOpen!){
                          Get.back();
                        }
                        showCustomSnackBar('you_do_not_have_enough_point_to_exchange'.tr);
                      } else {
                        walletController.pointToWallet(amount);
                      }
                    }

                  },
                );
              }),
            ]),
          ),
        ),
        Positioned(
          top: 10, right: 10,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.clear, size: 18),
          ),
        ),
      ],
    );
  }
}
