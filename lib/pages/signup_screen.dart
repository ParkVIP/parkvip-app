import 'package:flutter/material.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/core/utils/validation_functions.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'package:ParkVip/widgets/custom_text_form_field.dart';


class SigninPage extends StatefulWidget {
  static String tag = 'signin-page';

  const SigninPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SigninPageState();
  }
}

class _SigninPageState extends State<SigninPage> with SingleTickerProviderStateMixin {

  TextEditingController statusDefaultController5 = TextEditingController();
  TextEditingController statusDefaultOneController3 = TextEditingController();
  TextEditingController statusDefaultController = TextEditingController();
  TextEditingController statusDefaultOneController = TextEditingController();
  TextEditingController statusDefaultTwoController = TextEditingController();
  TextEditingController statusDefaultThreeController = TextEditingController();
  TextEditingController statusDefaultFourController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TabController _tabController;
  var selectedTab ;
  var _currentIndex;

  @override
  void dispose() {
      statusDefaultController5.dispose();
      statusDefaultOneController3.dispose();
      statusDefaultController.dispose();
      statusDefaultOneController.dispose();
      statusDefaultTwoController.dispose();
      statusDefaultThreeController.dispose();
      statusDefaultFourController.dispose();
      super.dispose();
  }
  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabChange);
  }

  void _tabChange(){
    _currentIndex = _tabController.index;
    if(_currentIndex == 0){
      setState(() {
        selectedTab = 'current';
      });
    }else{
      setState(() {
        selectedTab = 'history';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.lightBlue,
            body: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Container(
                    margin: getMargin(left: 24, top: 68, right: 24, bottom: 48),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SingleChildScrollView(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                                                              Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                            padding: getPadding(
                                                left: 78, right: 78),
                                            child: CommonImageView(
                                                imagePath: ImageConstant
                                                    .img1200x600wa21,
                                                height:
                                                    getVerticalSize(119.00),
                                                width: getHorizontalSize(
                                                    84.00)))),
                                                                              Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                            padding: getPadding(
                                                left: 78,
                                                top: 39,
                                                right: 78),
                                            child: Text(
                                                "msg_welcome_to_park".tr,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: AppStyle.txtUrbanistRomanBold48.copyWith())
                                        )
                                                                              ),
                                                                              Container(
                                        margin: getMargin(top: 49),
                                        decoration: AppDecoration
                                            .fillBlue800
                                            .copyWith(
                                                borderRadius:
                                                    BorderRadiusStyle
                                                        .roundedBorder24),
                                        child:
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                mainAxisSize:
                                                    MainAxisSize.max,
                                                children: [
                                              CustomButton(
                                                  width: 186,
                                                  text: "lbl_sign_in".tr,
                                                  margin: getMargin(
                                                      top: 4, bottom: 4),
                                                  shape: ButtonShape
                                                      .RoundedBorder20,
                                                  padding: ButtonPadding
                                                      .PaddingAll11,
                                                  fontStyle: ButtonFontStyle
                                                      .UrbanistRomanBold18),
                                              CustomButton(
                                                  width: 186,
                                                  text: "lbl_sign_up".tr,
                                                  margin: getMargin(
                                                      top: 4, bottom: 4),
                                                  variant: ButtonVariant
                                                      .FillWhiteA700,
                                                  shape: ButtonShape
                                                      .RoundedBorder20,
                                                  padding: ButtonPadding
                                                      .PaddingAll11,
                                                  fontStyle: ButtonFontStyle
                                                      .UrbanistRomanBold18Blue800)
                                            ])),
                                                                              CustomTextFormField(
                                        width: 380,
                                        focusNode: FocusNode(),
                                        controller:statusDefaultController5,
                                        hintText: "Username".tr,
                                        margin:
                                            getMargin(left: 24, top: 48, right: 24),
                                        fontStyle: TextFormFieldFontStyle
                                            .UrbanistRomanMedium14,
                                        prefix: Container(
                                            margin: getMargin(
                                                left: 23,
                                                top: 21,
                                                right: 15,
                                                bottom: 21),
                                            child: CommonImageView(
                                                svgPath: ImageConstant.imgUser16X13)),
                                        prefixConstraints: BoxConstraints(
                                            minWidth: getSize(16.00),
                                            minHeight: getSize(16.00)),
                                        validator: (value) {
                                          if (!isText(value)) {
                                            return "Please enter valid text";
                                          }
                                          return null;
                                        }),
                                                                              CustomTextFormField(
                                        width: 380,
                                        focusNode: FocusNode(),
                                        controller:statusDefaultOneController3,
                                        hintText: "●●●●●●●●●●●●",
                                        margin:
                                            getMargin(left: 24, top: 24, right: 24),
                                        fontStyle: TextFormFieldFontStyle
                                            .UrbanistRomanMedium14,
                                        textInputAction: TextInputAction.done,
                                        prefix: Container(
                                            margin: getMargin(
                                                left: 22,
                                                top: 21,
                                                right: 14,
                                                bottom: 21),
                                            child: CommonImageView(
                                                svgPath: ImageConstant.imgLock16X14)),
                                        prefixConstraints: BoxConstraints(
                                            minWidth: getSize(16.00),
                                            minHeight: getSize(16.00)),
                                        suffix: Container(
                                            margin: getMargin(
                                                left: 30,
                                                top: 22,
                                                right: 21,
                                                bottom: 22),
                                            child: CommonImageView(
                                                svgPath:
                                                    ImageConstant.imgUnionGray900)),
                                        suffixConstraints: BoxConstraints(
                                            minWidth: getHorizontalSize(16.00),
                                            minHeight: getVerticalSize(14.00))),
                                                                              CustomButton(
                                        width: 380,
                                        text: "Sign in".tr,
                                        margin:
                                            getMargin(left: 24, top: 24, right: 24)),


                                                                             GestureDetector(
                                        onTap: () {
                                          //onTapTxtForgotthepass();
                                        },
                                        child: Padding(
                                            padding: getPadding(
                                                left: 24, top: 29, right: 24),
                                            child: Text("Forgot the password?".tr,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: AppStyle.txtUrbanistSemiBold16
                                                    .copyWith(letterSpacing: 0.20)))),
                                                                              Center(
                                        child: Text("Resend verification email".tr,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: AppStyle.txtUrbanistSemiBold16
                                                .copyWith(letterSpacing: 0.20)))

                                                                            ]))))
                        ])))));
  }
}
