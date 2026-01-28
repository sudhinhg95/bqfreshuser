import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/verification/controllers/verification_controller.dart';
import 'package:sixam_mart/features/verification/screens/verification_screen.dart';
// removed unused imports after simplifying flow
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  final bool fromDialog;
  const ForgetPassScreen({super.key, this.fromDialog = false});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _numberFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  String? _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
  GlobalKey<FormState>? _formKeyLogin;
  bool isEmail = false;
  bool isPhone = true; // Force phone-based flow without OTP

  @override
  void initState() {
    super.initState();

    // Always use phone-only flow without OTP, per requirement
    isPhone = true;
    isEmail = false;

    _formKeyLogin = GlobalKey<FormState>();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_numberFocusNode);
      });
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _numberFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
      body: Center(child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Center(
          child: Container(
            height: widget.fromDialog ? 600 : null,
            width: widget.fromDialog ? 475 : context.width > 700 ? 700 : context.width,
            decoration: context.width > 700 ? BoxDecoration(
              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow:  ResponsiveHelper.isDesktop(context) ?  null : [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
            ) : null,
            child: Column(
              children: [
                ResponsiveHelper.isDesktop(context) ? Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.clear),
                  ),
                ) : const SizedBox(),

                // Simplified phone-only reset: phone + current password + new password + confirm
                Padding(
                  padding: widget.fromDialog ? const EdgeInsets.all(Dimensions.paddingSizeExtremeLarge) : context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Column(children: [

                    Image.asset(Images.logo, height: widget.fromDialog ? 100 : 70),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: Text('forgot_your_password'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge), textAlign: TextAlign.center),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Text('please_enter_the_registered_phone_where_you_want'.tr, style: robotoRegular.copyWith(fontSize: widget.fromDialog ? Dimensions.fontSizeSmall : null, color: Theme.of(context).hintColor), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                    Form(
                      key: _formKeyLogin,
                      child: Column(children: [
                        CustomTextField(
                          titleText: 'xxxx-xxxx'.tr,
                          controller: _numberController,
                          focusNode: _numberFocusNode,
                          inputType: TextInputType.phone,
                          inputAction: TextInputAction.next,
                          isPhone: true,
                          onCountryChanged: (CountryCode countryCode) { _countryDialCode = countryCode.dialCode; },
                          countryDialCode: CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code ?? Get.find<LocalizationController>().locale.countryCode,
                          labelText: 'phone'.tr,
                          validator: (value) => ValidateCheck.validateEmptyText(value, null),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        // Removed current password field per requirement
                        CustomTextField(
                          titleText: '8+characters'.tr,
                          controller: _newPasswordController,
                          focusNode: _newPasswordFocusNode,
                          inputType: TextInputType.visiblePassword,
                          inputAction: TextInputAction.next,
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          labelText: 'new_password'.tr,
                          validator: (value) => ValidateCheck.validateEmptyText(value, 'please_enter_new_password'.tr),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        CustomTextField(
                          titleText: '8+characters'.tr,
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          inputType: TextInputType.visiblePassword,
                          inputAction: TextInputAction.done,
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          labelText: 'confirm_password'.tr,
                          validator: (value) => ValidateCheck.validateEmptyText(value, 'please_enter_confirm_password'.tr),
                        ),
                      ]),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                    GetBuilder<VerificationController>(builder: (verificationController) {
                      return GetBuilder<AuthController>(builder: (authController) {
                        return CustomButton(
                          radius: Dimensions.radiusDefault,
                          buttonText: 'change_password'.tr,
                          isLoading: verificationController.isLoading || authController.isLoading,
                          onPressed: () => _onPressedChangeByPhone(_countryDialCode!),
                        );
                      });
                    }),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text('or'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor), textAlign: TextAlign.center),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    RichText(text: TextSpan(children: [
                      TextSpan(
                        text: '${'back_to'.tr} ',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                      TextSpan(
                        text: 'login_in'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.back(),
                      ),
                    ]), textAlign: TextAlign.center, maxLines: 3),

                  ]),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  void _onPressedChangeByPhone(String countryCode) async {
    String phone = _numberController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    String numberWithCountryCode = countryCode + phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if(_formKeyLogin!.currentState!.validate()) {
      if(!phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
        return;
      }
      if(newPassword.length < 6) {
        showCustomSnackBar('password_should_be'.tr);
        return;
      }
      if(newPassword != confirmPassword) {
        showCustomSnackBar('confirm_password_does_not_matched'.tr);
        return;
      }

      // Directly call resetPassword using phone only (no OTP/token),
      // as per requirement to bypass email/otp verification.
      Get.find<VerificationController>().resetPassword(
        resetToken: null,
        phone: numberWithCountryCode,
        email: null,
        password: newPassword,
        confirmPassword: confirmPassword,
      ).then((response) {
        if(response.isSuccess) {
          showCustomSnackBar('password_reset_successfully'.tr, isError: false);
          if(!ResponsiveHelper.isDesktop(Get.context)) {
            Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.resetPassword));
          } else {
            Get.back();
          }
        } else {
          showCustomSnackBar(response.message);
        }
      });
    }
  }
}
