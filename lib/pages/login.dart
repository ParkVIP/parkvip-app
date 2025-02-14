import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../helper/utils.dart';
import '../pages/locations.dart';
import '../pages/generate-firebase-token.dart';
import '../pages/forget_password.dart';
import '../helper/endpoints.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../pages/resend_verification_mail.dart';
import '../helper/api_base_helper.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/core/utils/validation_functions.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'package:ParkVip/widgets/custom_icon_button.dart';
import 'package:ParkVip/widgets/custom_text_form_field.dart';
import 'package:ParkVip/domain/googleauth/google_auth_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../pages/googlesigninbutton.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../.env.dart';


class LoginPage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailIdController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _usernameController = TextEditingController();
  final _signUpUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _signUppasswordController = TextEditingController();
  final accessToken = null;
  bool isMotorcycle=false;
  var utils = Utils();
  var endpoint = Endpoints();
  var endpoints =Endpoints();
  final apiHelper = ApiBaseHelper();
  var firebaseToken = !kIsWeb? NotificationHandler():null;
  var heightOfregistrationForm;
  bool _obscureText = true;
  int blocked =0;
  final FocusNode _focus = FocusNode();

  TextStyle style =  const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<FormState> _signupKey = GlobalKey();
  var status;
  var userDetails;
  bool isLoading =true;
  var loginImage=null;
  late Uint8List bytes;
  var isLoginImage=false;
  late ProgressDialog pr;
  var selectedTab='login' ;
  var _currentIndex;
  double heightbetweenForm=220.0;
  bool loginSubmit=false;
  bool signupSubmit=false;
  late TabController _tabController;
  BoxConstraints boxconstraintsDefault = BoxConstraints(
    minWidth: getSize(15.00),
    minHeight: getSize(15.00)
  );
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  GoogleSignIn googleSignIn = GoogleSignIn(clientId:google_client_id,);
  @override
  void initState() {
    super.initState();

    if(!kIsWeb) {
      _initPackageInfo();
    }else{
      googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async{
        if (account != null) {
          var signformData = <String, dynamic>{};
          signformData['full_name'] = account.displayName;
          signformData['mobile_no'] ="";
          signformData['username'] = account.email;
          signformData['email'] = account.email;
          signformData['user_type'] = 'user';
          signformData['is_from'] = 'google';
          signformData['url'] = account.photoUrl;
          signUpandLoginForOther(signformData,'google','google_auth');
        } else {
          utils.toast("User not found");
          await pr.hide();
        }
      });
    }
    _focus.addListener(_onFocusChange);
    if (loginImage == null) {
      _getLoginImage(context).then((s) =>
          setState(() {
            if(s!=null){
              print('image data---');
              print(loginImage);
              loginImage = s;
              isLoginImage = true;
            }
          })
      );
    }
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabChange);

  }

  void _tabChange(){
    _currentIndex = _tabController.index;
    if(_currentIndex == 0){
        setState(() {
          selectedTab = 'login';
        });
      }else{
        setState(() {
          selectedTab = 'signup';
        });
      }
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _onFocusChange(){}

  @override
  void dispose() {
    _focus.dispose();
    _tabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _signUpUsernameController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override

  Widget build(BuildContext context) {
      pr = ProgressDialog(
          context, type: ProgressDialogType.download, isDismissible: false);
      pr.style(
        widgetAboveTheDialog: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Loading...', textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20))
        ),
        message: 'Please wait...',
        borderRadius: 8.0,
        backgroundColor: Colors.white,
        progressWidget: Container(
            padding: const EdgeInsets.all(15.0), child: const CircularProgressIndicator()),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w400),
        progressTextStyle: const TextStyle(color: Colors.white),
      );
      if (isLoginImage == true) {
        if (loginImage['data']['asset_img'] != null) {
          var strToRemove = 'data:image/jpeg;base64,';
          var strToRemovepng = 'data:image/png;base64,';
          var strToRemovejpg = 'data:image/jpg;base64,';
          var imagePath = loginImage['data']['asset_img'];
          imagePath = imagePath.replaceAll(strToRemovepng, "");
          imagePath = imagePath.replaceAll(strToRemovejpg, "");
          bytes = base64Decode(imagePath.replaceAll(strToRemove, ""));
        }
      }
      if (selectedTab != 'signup') {
        heightbetweenForm = MediaQuery
            .of(context)
            .size
            .height - 400;
      } else {
        heightbetweenForm = MediaQuery
            .of(context)
            .size
            .height - 250;
      }
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.blue[300],
          resizeToAvoidBottomInset: false,
          body: Stack(
              children:[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: ColorConstant.blue7003f,
                  ),
                  child: (isLoginImage==true) ? ColorFiltered(
                    colorFilter: utils.appColorFilter(),
                    child:   Image.memory(bytes,gaplessPlayback:true,fit: BoxFit.cover),
                  ) : ColorFiltered(
                    colorFilter: utils.appColorFilter(),
                  ),
                ),
                SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding:getPadding(left: 24, top: 30, right: 24),
                              child: CommonImageView(
                                  imagePath: ImageConstant.img1200x600wa21,
                                  height: getVerticalSize(80.00),
                                )) ,
                          Padding(
                              padding:getPadding(left: 24, top: 24, right: 24),
                              child: Text("Welcome to ParkVIP",
                                  textAlign: TextAlign.center,
                                  style: AppStyle.txtUrbanistRomanBold38.copyWith())),

                         // (selectedTab=='login') ?
                           (!kIsWeb)

                          ? (Theme.of(context).platform != TargetPlatform.iOS)?CustomIconButton(
                            width: 380,
                            height:65,
                            margin:getMargin(left: 24, top: 24, right: 24),
                            onTap: () async {
                              await pr.show();
                              onTapRowGoogle(context,pr);
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonImageView(
                                      imagePath: ImageConstant.imgGoogle,
                                      color: false
                                  ),
                                  Padding(
                                      padding:getPadding(left: 10),
                                      child : Text("Continue with Google",
                                          textAlign: TextAlign.center,style: AppStyle.txtUrbanistRomanBold24White.copyWith()
                                      )
                                  )
                                ]
                            ),
                          ):
                          Container(
                            width: getHorizontalSize(380),
                            margin:getMargin(left: 24, top: 24, right: 24),
                            child: SignInWithAppleButton(
                              style:SignInWithAppleButtonStyle.white,
                              text: 'Continue with Apple',
                              onPressed: () async {
                                final credential = await SignInWithApple.getAppleIDCredential(
                                    scopes: [
                                      AppleIDAuthorizationScopes.email,
                                      AppleIDAuthorizationScopes.fullName,
                                    ],
                                    webAuthenticationOptions: WebAuthenticationOptions(
                                      clientId: apple_client_id, 
                                      redirectUri: Uri.parse(endpoint.callToUrl('apple_auth')),
                                    )
                                );
                                // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                                var appleAuthData = <String, dynamic>{};
                                appleAuthData['code'] = credential.authorizationCode;
                                appleAuthData['firstName'] =credential.givenName ?? "";
                                appleAuthData['lastName'] = credential.familyName ?? "";
                                appleAuthData['useBundleId'] = !kIsWeb && (Theme.of(context).platform == TargetPlatform.iOS)
                                  ? 'true'
                                  : 'false';
                                appleAuthData['state'] = credential.state;
                                signUpandLoginForOther(appleAuthData,'apple','apple_auth');
                              },

                            )

                          )

                          : Padding(
                            padding:getPadding(left: 24, top: 39, right: 24),
                            child:buildSignInButton(context)
                          ),
                          //: Container(),
                          //(selectedTab=='login') ? 
                          Padding(
                              padding:getPadding(left: 24, top: 24, right: 24),
                              child: Text("or",
                                  textAlign: TextAlign.center,
                                  style: AppStyle.txtUrbanistRomanBold38.copyWith())) ,
                          //: Container(),

                          Container(
                            height: 45,
                            margin: const EdgeInsets.only(top:24,left:24,right:24,bottom:0),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(25.0)),
                              color: Color.fromRGBO(47,111,182,1.0),
                            ),
                            child: TabBar(
                              tabs: [
                                SizedBox(
                                  width: 100.0,
                                  child: Text('Sign in',
                                      textAlign:TextAlign.center,
                                      style:TextStyle(fontSize: getFontSize(20),fontFamily: "Urbanist",fontWeight: FontWeight.w700,)),
                                ),
                                SizedBox(
                                  width: 100.0,
                                  child: Text('Sign up',
                                      textAlign:TextAlign.center,
                                      style:TextStyle(fontSize:getFontSize(20),fontFamily: "Urbanist",fontWeight: FontWeight.w700,)),
                                )
                              ],
                              unselectedLabelColor: Colors.white,
                              indicatorPadding: const EdgeInsets.all(5),
                              indicatorColor: Colors.transparent,
                              labelColor: const Color.fromRGBO(47,111,182,1.0),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorWeight:1.0,
                              isScrollable: false,
                              controller: _tabController,
                              dividerColor: Colors.transparent,
                              indicator: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                                  color: Colors.white
                              ),
                            ),
                          ),
                          Container(
                            height: heightbetweenForm,
                            margin: const EdgeInsets.only(top:10),
                            child: TabBarView(
                                controller: _tabController,
                                children: <Widget>[
                                  SizedBox(
                                      height: heightbetweenForm,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:CrossAxisAlignment.center,
                                          mainAxisAlignment:MainAxisAlignment.start,
                                          children:[
                                            Expanded(
                                              child:_renderLoginForm(_key,boxconstraintsDefault),
                                            )
                                          ]
                                      )
                                  ),
                                  SizedBox(
                                      height: heightbetweenForm,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:CrossAxisAlignment.center,
                                          mainAxisAlignment:MainAxisAlignment.start,
                                          children:[
                                            Expanded(
                                              child:_renderRegistrationForm(_signupKey,boxconstraintsDefault),
                                            )
                                          ]
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ]
                    )
                )
              ]
          ),
        ),
      );
   // }



  }

  _renderLoginForm(key,BoxConstraints constraints){
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Form(
     key: key,
     child: Column(
       mainAxisSize: MainAxisSize.min,
       crossAxisAlignment: CrossAxisAlignment.center,
       mainAxisAlignment: MainAxisAlignment.start,
       children: [
         Expanded(
           child: Align(
             alignment:const Alignment(0.0, -0.5),
             child: SingleChildScrollView(
               reverse: true,
               child: Padding(
                 padding: EdgeInsets.only(bottom: bottom),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment:CrossAxisAlignment.center,
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: [
                     CustomTextFormField(
                       width: 380,
                       controller:_usernameController,
                       hintText: "Username",
                       errorColor:true,
                       margin:getMargin(left: 24, top: 0, right: 24),
                       fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
                       prefix: Container(
                         margin: getMargin(left: 23,top: 21,right: 15,bottom: 21),
                         child: CommonImageView(svgPath: ImageConstant.imgUser16X13)
                       ),
                       prefixConstraints: BoxConstraints(minWidth: getSize(16.00), minHeight: getSize(16.00)),
                       validator: (value) {
                         if (value!.isEmpty) {
                           return "Please enter valid username";
                         }
                         return null;
                       }
                     ),
                     Container(
                       width: getHorizontalSize(380),
                       margin:getMargin(left: 24, top: 24, right: 24),
                       child: TextFormField(
                         obscureText: _obscureText,
                         controller: _passwordController,
                         style:AppStyle.txtUrbanistRomanMedium18.copyWith(),
                         decoration: InputDecoration(
                           hintText: "Password",
                           hintStyle:AppStyle.txtUrbanistRomanMedium18.copyWith(),
                           errorStyle: TextStyle(color:ColorConstant.whiteA700, fontSize: getFontSize(18),fontFamily:'Urbanist',fontWeight: FontWeight.w400),
                           filled: true,
                           border:OutlineInputBorder(borderRadius: BorderRadius.circular(getHorizontalSize(12.00, ),),borderSide: BorderSide.none,),
                           prefixIcon: Container(margin: getMargin(left: 22,top: 21,right: 14,bottom: 21),child: CommonImageView( svgPath: ImageConstant.imgLock)),
                           prefixIconConstraints: BoxConstraints(minWidth: getSize(16.00),minHeight: getSize(16.00)),
                           fillColor:ColorConstant.gray51,
                           suffixIcon: GestureDetector(onTap: _toggle,child:Container(margin: getMargin(left: 30,top: 22,right: 21,bottom: 22),
                             child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,color: Colors.grey[600],size:16),
                           )),
                           suffixIconConstraints: BoxConstraints(
                             minWidth: getHorizontalSize(16.00),
                             minHeight: getVerticalSize(14.00)
                           ),
                           contentPadding:getPadding(left: 20,top: 23,right: 22,bottom: 20,),
                         ),
                         validator: (value) {
                           if (value!.isEmpty) {
                             return 'Please enter password';
                           }
                           return null;
                         },
                       ),
                     ),
                     CustomButton(
                       width: 380,
                       text: "Sign in",
                       margin:getMargin(left: 24, top: 24, right: 24),
                       onTap : () async{
                         if (key.currentState!.validate()){
                           await pr.show();
                           _loginApiCall(context,pr);
                         }
                       }
                     ),
                     GestureDetector(
                       onTap: () {
                         Navigator.push(context,MaterialPageRoute(builder: (context) => const ForgetPasswordPage()));
                       },
                       child: Padding(
                           padding: getPadding(
                               left: 24, top: 24, right: 24),
                           child: Text("Forgot the password?",
                               overflow: TextOverflow.ellipsis,
                               textAlign: TextAlign.left,
                               style: AppStyle.txtUrbanist18.copyWith(letterSpacing: 0.20)
                           )
                       )
                     ) ,
                     InkWell(
                       onTap:(){
                         Navigator.push(context,MaterialPageRoute(builder: (context) => const ResendVerificationMailPage()));
                       },
                       child:Container(
                         padding: getPadding(left: 24, top: 27, right: 24, bottom: 20),
                         child: Text("Resend verification mail",
                             overflow: TextOverflow.ellipsis,
                             textAlign: TextAlign.left,
                             style: AppStyle.txtUrbanist18
                                 .copyWith(letterSpacing: 0.20)))
                     ),
                   ]
                 ),
               ),
             ),
           ),
         ),
       ]
     )
          );
  }

  _renderRegistrationForm(signupKey,BoxConstraints constraints){
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Form(
      key: signupKey,
      child: Container(
          margin: getMargin(left: 24,right: 24, bottom: 28),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          reverse: true,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: bottom),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CustomTextFormField(
                                        width: 380,
                                        controller: _fullnameController,
                                        hintText: "Full name",
                                        errorColor:true,
                                        fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
                                        padding: TextFormFieldPadding.PaddingTB21,
                                        prefix: Container(
                                          margin: getMargin(left: 22,top: 20,right: 14,bottom: 20),
                                          child: CommonImageView(svgPath: ImageConstant.imgTicket15X15)
                                        ),
                                        prefixConstraints: BoxConstraints(
                                          minWidth: getSize(15.00),
                                          minHeight: getSize(15.00)
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter valid full name';
                                          }
                                          if (value.length >255) {
                                            return 'this field can contain max 255 character';
                                          }
                                          return null;
                                        }
                                      ),
                                      CustomTextFormField(
                                        width: 380,
                                        controller: _signUpUsernameController,
                                        hintText: "Username",
                                        errorColor:true,
                                        margin: getMargin(top: 20),
                                        fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
                                        prefix: Container(
                                          margin: getMargin(left: 23,top: 21,right: 15,bottom: 21),
                                          child: CommonImageView(svgPath: ImageConstant.imgUser16X13)
                                        ),
                                        prefixConstraints: BoxConstraints(
                                          minWidth: getSize(16.00),
                                          minHeight: getSize(16.00)
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter valid username';
                                          }
                                          if (value.length >50) {
                                            return 'username must be less than 50 character';
                                          }
                                          return null;
                                        }
                                      ),

                                      Container(
                                          width: getHorizontalSize(380),
                                          margin: getMargin(top: 20),
                                          child: TextFormField(
                                            obscureText: _obscureText,
                                            controller: _signUppasswordController,
                                            //focusNode: _focus,
                                            decoration: InputDecoration(
                                              hintText: "Password",
                                              errorStyle: TextStyle(color:ColorConstant.whiteA700, fontSize: getFontSize(18),fontFamily:'Urbanist',fontWeight: FontWeight.w400),
                                              hintStyle:TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: getFontSize(18,),
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.w500,
                                              ),
                                              filled: true,
                                              border:OutlineInputBorder(borderRadius: BorderRadius.circular(getHorizontalSize(12.00, ),),borderSide: BorderSide.none,),                        
                                              prefixIcon: Container(margin: getMargin(left: 22,top: 21,right: 14,bottom: 21),child: CommonImageView( svgPath: ImageConstant.imgLock16X14)),
                                              prefixIconConstraints: BoxConstraints(minWidth: getSize(16.00),minHeight: getSize(16.00)),
                                              fillColor:ColorConstant.gray51,
                                              suffixIcon: GestureDetector(onTap: _toggle,child:Container(margin: getMargin(left: 30,top: 22,right: 21,bottom: 22),
                                                child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,color: Colors.grey[600],size:16),
                                              )),
                                              suffixIconConstraints: BoxConstraints(
                                                minWidth: getHorizontalSize(16.00),
                                                minHeight: getVerticalSize(14.00)
                                              ),
                                              contentPadding:getPadding(left: 20,top: 23,right: 22,bottom: 20,),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter password';
                                              }
                                              if (value.length < 8) {
                                                return 'Password must contain minimum 8 characters.';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      CustomTextFormField(
                                          width: 380,
                                          //focusNode: FocusNode(),
                                          controller: _emailIdController,
                                          hintText: "Email",
                                          errorColor:true,
                                          margin: getMargin(top: 20),
                                          fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
                                          padding: TextFormFieldPadding.PaddingTB21,
                                          prefix: Container(
                                              margin: getMargin(left: 21, top: 20,right: 13,bottom: 20),
                                              child: CommonImageView(svgPath: ImageConstant.imgMessageGray900)),
                                          prefixConstraints: BoxConstraints(
                                              minWidth: getSize(15.00),
                                              minHeight: getSize(15.00)),
                                          validator: (value) {
                                            bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value!);
                                            if ((!isValidEmail(value,
                                                    isRequired: true))) {
                                              return "Please enter valid email";
                                            }
                                            if(!emailValid){
                                              return 'Please enter correct email id';
                                            }
                                            return null;
                                          }),
                                      CustomTextFormField(
                                          width: 380,
                                          //focusNode: FocusNode(),
                                          controller: _mobileNoController,
                                          hintText: "Phone Number",
                                          errorColor:true,
                                          fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
                                          margin: getMargin(top: 20),
                                          padding: TextFormFieldPadding.PaddingTB21,
                                          textInputAction:TextInputAction.done,
                                          textInputType:TextInputType.number,
                                          prefix: Container(
                                              margin: getMargin(left: 21,top: 19,right: 13, bottom: 19),
                                              decoration: BoxDecoration(borderRadius:BorderRadius.circular(getHorizontalSize(4.00))),
                                              child: CommonImageView(svgPath: ImageConstant.imgFolder,color:false)),
                                          prefixConstraints: BoxConstraints(
                                            minWidth: getSize(18.00),
                                            minHeight: getSize(18.00)),
                                          validator: (value) {
                                            if (!isValidPhone(value)) {
                                              return "Please enter valid phone number";
                                            }
                                            if(value!.length < 10){
                                              return 'Mobile No. should not be less then 10 digits.';
                                            }
                                            if(value.length >15){
                                              return 'Mobile No. should not be greater then 15 digits.';
                                            }
                                            return null;
                                          }),
                                      const SizedBox( height:10,),
                                      Row(
                                        mainAxisAlignment:MainAxisAlignment.center,
                                        crossAxisAlignment:CrossAxisAlignment.center,
                                        mainAxisSize:MainAxisSize.max,
                                        children: <Widget>[
                                          Padding(
                                            padding: getPadding(bottom:1),
                                            child: Text("Are you on a motorcycle ?",
                                              overflow: TextOverflow.ellipsis,
                                              textAlign:TextAlign.left,
                                              style: AppStyle.txtUrbanistRomanBold18.copyWith(letterSpacing:0.20)),
                                          ),
                                          const SizedBox(
                                            width:100,
                                          ),
                                          Padding(
                                            padding: getPadding(top:5,bottom:1),
                                            child: Checkbox(
                                              activeColor: Colors.white,
                                              checkColor: const Color.fromRGBO(47,111,182,1.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6.0),
                                              ),
                                              side: MaterialStateBorderSide.resolveWith(
                                                (states) => const BorderSide(width: 2, color: Colors.white),
                                              ),
                                              value: (isMotorcycle)?true:false,
                                              onChanged: _updateMotorcycleVal,
                                            ),
                                          ),

                                        ],
                                      ),
                                      CustomButton(
                                        width: 380,
                                        text: "Sign up",
                                        margin: getMargin(top: 10),
                                        onTap : () async{
                                          if (signupKey.currentState!.validate()){
                                            _signUpApiCall(context);
                                          }
                                        },
                                      )
                                    ]
                            )))))
              ]
          )
      )
    );
  }

  void _updateMotorcycleVal(bool? newValue) => setState(() {
    isMotorcycle = newValue!;
    if (isMotorcycle) {
        isMotorcycle = true;
    } else {
      isMotorcycle = false;
    }
  });

  onTapRowGoogle(BuildContext context,pr) async {
    await GoogleAuthHelper().googleSignInProcess().then((googleUser) async{

        if (googleUser != null) {
          var signformData = <String, dynamic>{};
          signformData['full_name'] = googleUser.displayName;
          signformData['mobile_no'] ="";

          signformData['username'] = googleUser.email;
          signformData['email'] = googleUser.email;
          signformData['user_type'] = 'user';
          signformData['is_from'] = 'google';
          signformData['url'] = googleUser.photoUrl;
          signUpandLoginForOther(signformData,'google','google_auth');
        } else {
          utils.toast("User not found");
          await pr.hide();
        }
      }).catchError((onError) async{
        utils.toast(onError.toString());
        await pr.hide();
      });
  }

  signUpandLoginForOther (signformData,type,endpoint) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jsonResponse =await  apiHelper.postWithoutToken(endpoint, signformData,'');
    print(jsonResponse);
    print(jsonResponse['response_code']);
    if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200 ){
      if(!kIsWeb)  {
        var receivedFirebaseToken   = await firebaseToken?.generateToken();
        postFirebaseToken(receivedFirebaseToken,jsonResponse['access_token'],jsonResponse['user_details']['user_id']);
      }    
      
      updateUserTimezone(jsonResponse['access_token'],jsonResponse['user_details']['user_id']);
      prefs.setString("access_token", jsonResponse['access_token']);
      prefs.setString("refresh_token", jsonResponse['refresh_token']);
      prefs.setString("user_id", jsonEncode(jsonResponse['user_details']['user_id']));
      //Get user image
      var qr='?user_id=${jsonEncode(jsonResponse['user_details']['user_id'])}';
      var userimageRes = await apiHelper.get(context,'get_user_image',jsonResponse['access_token'], qr);

      if (!userimageRes.isEmpty || userimageRes != null) {
        if (userimageRes['response_code'] == 200) {
          jsonResponse['user_details']['user_image']=userimageRes['data'][0]['user_image'];
        }
      } 
      await pr.hide();
      prefs.setString("user_details", jsonEncode(jsonResponse['user_details']));
      prefs.setBool("isLoggedIn", true);
      Navigator.push(context, MaterialPageRoute(builder: (context) =>LocationsPage(jsonResponse['access_token'],jsonResponse['user_details'])));
    }else{
      await pr.hide();
      utils.toast(jsonResponse['message']);
    }
  }


  _loginApiCall(BuildContext context,pr) async { 
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var status = prefs.getBool('isLoggedIn') ?? false;
      var accessToken = prefs.getString('access_token') ;
      var userDetails = prefs.getString('user_details') ;
      var userId = prefs.getString('user_id') ;
      var receivedFirebaseToken;
      if(status==true && userDetails !=null){
        await pr.hide();
        if(!kIsWeb){
            receivedFirebaseToken= await firebaseToken?.generateToken();
            postFirebaseToken(receivedFirebaseToken,accessToken,userId);
        }
        updateUserTimezone(accessToken,userId);
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              LocationsPage(accessToken, jsonDecode(userDetails))));
        }
      }else {
        var uri = endpoints.callToUrl('user_login');
        var localV=kIsWeb?'2.1.2':_packageInfo.version;
        if (localV=='Unknown') {
          localV='2.1.2';
        }
        var formData = <String, dynamic>{};
        formData['username'] = _usernameController.text;
        formData['password'] = _passwordController.text;
        formData['app_version'] = localV;
        var sw = Stopwatch()..start();
        http.Response response = await http.post(
          Uri.parse(uri),
          body: formData,
        );
        var jsonResponse = json.decode(response.body);
        sw.stop();

        if (!jsonResponse.isEmpty) {
          if (jsonResponse['response_code'] == 200) {
            prefs.setString("access_token", jsonResponse['access_token']);
            prefs.setString("refresh_token", jsonResponse['refresh_token']);
            prefs.setString("user_id", jsonEncode(jsonResponse['user_details']['user_id']));
            prefs.setString("user_details", jsonEncode(jsonResponse['user_details']));
            prefs.setBool("isLoggedIn", true);
            if(!kIsWeb){
              receivedFirebaseToken   = await firebaseToken?.generateToken();
              postFirebaseToken(receivedFirebaseToken,jsonResponse['access_token'],jsonResponse['user_details']['user_id']);
            }
            updateUserTimezone(jsonResponse['access_token'],jsonResponse['user_details']['user_id']);
            print('herery you are--');
            //Get user image
            var qr='?user_id=${jsonEncode(jsonResponse['user_details']['user_id'])}';
            print(qr);
            var userimageRes = await apiHelper.get(context,'get_user_image',jsonResponse['access_token'], qr);
             print("user iamge res-------------------$userimageRes");
            if (!userimageRes.isEmpty || userimageRes != null) {
              if (userimageRes['response_code'] == 200) {
                jsonResponse['user_details']['user_image']=userimageRes['data'][0]['user_image'];
              }
            }
            
            await pr.hide();
            
            Navigator.push(context, MaterialPageRoute(builder: (context) =>LocationsPage(jsonResponse['access_token'],jsonResponse['user_details'])));
          }else if (jsonResponse['response_code'] != 200) {
            await pr.hide();
            utils.toast(jsonResponse['message']);
          }else {
            await pr.hide();
            utils.toast(jsonResponse['message']);
          }
        }else {
          await pr.hide();
          return const CircularProgressIndicator();
        }
      }
    }catch (e) {
      if(e.toString().contains('SocketException')) {
        utils.toast('Server is unreachable');
        Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
      }
      else{
        await pr.hide();
        Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
      }
    }
  }

  _signUpApiCall(BuildContext context) async {
    await pr.show();
    var formData = <String, dynamic>{};
    formData['full_name'] = _fullnameController.text;
    formData['mobile_no'] = _mobileNoController.text;
    formData['username'] = _signUpUsernameController.text;
    formData['password'] = _signUppasswordController.text;
    formData['email'] = _emailIdController.text;
    formData['user_type'] = 'user';
    formData['isMotorcycle']=isMotorcycle.toString();

    var jsonResponse =await  apiHelper.postWithoutToken('user_signup', formData,'');
    print(jsonResponse);
    if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
      utils.toast(jsonResponse['message']);
      await pr.hide();
      Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
    }else{
      utils.toast(jsonResponse['message']);
      await pr.hide();
    }
  }

  postFirebaseToken (firebaceToken,accessToken,userId) async{
    endpoints.callToUrl('post_firebase_token');
    var formData = <String, dynamic>{};
    formData['registration_token'] = firebaceToken.toString();
    formData['user_id'] = userId.toString();
    var res= await apiHelper.post(context,'post_firebase_token',accessToken, formData,'');
     print("firebase token  update res--$res");
    return res;
  }

  updateUserTimezone (accessToken,userId) async{
    var tmzone = await FlutterTimezone.getLocalTimezone();
    if(tmzone.isNotEmpty){
      endpoints.callToUrl('update_timezone');
      var formData = <String, dynamic>{};
      formData['usertimeZone'] =tmzone.toString();
      formData['user_id']=userId.toString();
      print(formData);
      var res=await apiHelper.post(context,'update_timezone',accessToken, formData,'');
      print("timezone update res--$res");
      return res;
    }
  }

  _getLoginImage(context) async {
    var query='?asset_type=Login Page';
    var jsonResponse = await apiHelper.get(context,'get_asset','', query);
    return jsonResponse;
  }
}
