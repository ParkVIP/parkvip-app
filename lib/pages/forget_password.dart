import 'package:flutter/material.dart';
import '../helper/utils.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/endpoints.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'package:ParkVip/widgets/custom_text_form_field.dart';
import '../helper/api_base_helper.dart';

class ForgetPasswordPage extends StatefulWidget {
  static String tag = 'forgot-password';
  const ForgetPasswordPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ForgetPasswordPage();
  }
}
class _ForgetPasswordPage extends State<ForgetPasswordPage> {
  var utils = Utils();
  var endpoints =Endpoints();
  final apiHelper = ApiBaseHelper();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailIdController = TextEditingController();
  final _validateTokenController = TextEditingController();
  final _enterNewPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  var generateToken =false;
  var validateToken =false;
  @override
  void initState() {
    generateToken =false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteA700,
      appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text("Forgot Password",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
          leading: IconButton(
            icon:  CommonImageView(
              svgPath: ImageConstant.imgArrowleft,
              height:getVerticalSize(15.00),
              width: getHorizontalSize(19.00)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
      ),
      key: _scaffoldKey,
      body: SizedBox(
        width: size.width,
        child: SingleChildScrollView(
          child:Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                  (generateToken==false) ? _generateTokenForm():(validateToken==false) ? _validateTokenForm() : _changePasswordForm(),
                  CustomButton(
                    width: 380,
                    text: (generateToken==false) ? "Generate token":(validateToken==false) ? "Validate token" : "Reset password",
                    onTap : () async {
                      (generateToken==false) ? _generateTokenApiCall(context):(validateToken==false) ? _validateTokenApiCall(context) :  _resetPasswordApiCall(context);
                    },
                    margin: getMargin(left: 24,top: 650,right: 24,bottom: 20),
                    alignment: Alignment.center
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
  _generateTokenForm(){
    return CustomTextFormField(
      width: 380,
      focusNode: FocusNode(),
      controller:_emailIdController,
      fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
      hintText: "Enter email ID",
      margin:getMargin(left: 24, top: 25, right: 24),
      padding: TextFormFieldPadding.PaddingTB21,
      textInputAction: TextInputAction.done,
      alignment: Alignment.center,
      prefix: Container(
          margin: getMargin(left: 21,top: 20,right: 13,bottom: 20),
          child: CommonImageView(
          svgPath: ImageConstant.imgMessage)
      ),
      prefixConstraints: BoxConstraints(
          minWidth: getSize(15.00),
          minHeight: getSize(15.00)
      ),
      validator: (value) {
        bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value!);
        if (value.isEmpty) {
          return 'Please enter email id';
        }
        if(!emailValid){
          return 'Please enter correct email id';
        }
        return null;
      }
    );
  }
  _validateTokenForm(){
    return CustomTextFormField(
      width: 380,
      focusNode: FocusNode(),
      controller:_validateTokenController,
      fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
      hintText: "Enter token",
      margin:getMargin(left: 24, top: 25, right: 24),
      padding: TextFormFieldPadding.PaddingTB21,
      textInputAction: TextInputAction.done,
      alignment: Alignment.center,
      prefix: const Icon(Icons.vpn_key,size: 20,color: Color(0xffa9a9a9)),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter token';
        }
        return null;
      },
    );
  }
  _passwordField(text,controller){
    return CustomTextFormField(
      width: 380,
      focusNode: FocusNode(),
      controller: controller,
      hintText: text,
      fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
      margin:getMargin(left: 24, top: 33, right: 24),
      padding: TextFormFieldPadding.PaddingT22,
      alignment: Alignment.center,
      prefix: Container(
          margin: getMargin(left: 22,top: 19,right: 14,bottom: 19),
          child: CommonImageView(svgPath: ImageConstant.imgLock)
      ),
      prefixConstraints: BoxConstraints(
        minWidth: getSize(16.00),
        minHeight: getSize(16.00)),
      suffix: Container(
        margin: getMargin(left: 30,top: 20,right: 21,bottom: 20),
        child: CommonImageView(svgPath: ImageConstant.imgUnion)
      ),
      suffixConstraints: BoxConstraints(
        minWidth: getHorizontalSize(16.00),
        minHeight: getVerticalSize(14.00)
      ),
      validator: (value) {
        if(text=="New password"){
          if (value!.isEmpty) {
            return 'Please enter password';
          }
          if (value.length < 8) {
            return 'Password must contain minimum 8 characters.';
          }
        }else{
            if (value!.isEmpty){
              return 'Please enter password';
            }
            if(value != _enterNewPassword.text){
              return 'password does not Match';
            }
        }
        return null;
      },
      isObscureText: true
    );
  }
  _changePasswordForm(){
    return Column(
      children: <Widget>[
        _passwordField("New password",_enterNewPassword),
        _passwordField("Confirm password",_confirmPassword),
      ]
    );
  }
  _generateTokenApiCall(BuildContext context) async {
      var email = _emailIdController.text;
      String queryParams ="?email=$email";
      var jsonResponse = await apiHelper.get(context,'verify_email_reset_pass','', queryParams);
      if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
        utils.longToast(jsonResponse['message']);
        final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
       sharedPrefs.setString('forget_password_userId',jsonResponse['id'].toString());
        setState((){
          generateToken =true;
        });
        _validateTokenForm();
      }
      else{
        utils.longToast(jsonResponse['message']);
      }
  }
  _validateTokenApiCall(BuildContext context) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    var token =   _validateTokenController.text;
    var userId= sharedPrefs.getString('forget_password_userId');    
    String queryParams ="?id=$userId&token=$token";
    var jsonResponse = await apiHelper.get(context,'verify_token_reset_pass','', queryParams);
    if(!jsonResponse.isEmpty){
      if(jsonResponse['response_code']==200){
        utils.toast('Token verified. Please update new password!');
        setState((){
          validateToken =true;
        });
        _changePasswordForm();
      }
      else if(jsonResponse['response_code'] !=200){
        utils.toast('Token not verified. Please try again later');
        setState((){
        validateToken =false;
        });
        _changePasswordForm();
      } else{
        //utils.toast(jsonResponse['message']);
      }
    }
    else{
      utils.toast('Some error occurred. Please try again later.');
    }

  }
  _resetPasswordApiCall(BuildContext context) async {
    var passwordFormData = <String, dynamic>{};
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    passwordFormData['password'] =   _confirmPassword.text;
    passwordFormData['id'] =sharedPrefs.getString('forget_password_userId').toString();
    var newPassword = _enterNewPassword.text;
    if(newPassword.isEmpty){
      utils.toast('please enter password');
    }
    if(passwordFormData['password'].isEmpty){
      utils.toast('confirm password field cannot be empty');
    }
    if(newPassword!=passwordFormData['password']){
      utils.toast('password not matched');
    }
    if(newPassword==passwordFormData['password']){
      var jsonResponse = await apiHelper.postWithoutToken('reset_password', passwordFormData,'');
      if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
        utils.longToast(jsonResponse['message']);
        setState(() {
          Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
        });
      }
      else{
        utils.longToast(jsonResponse['message']);
      }
    }
  }
}