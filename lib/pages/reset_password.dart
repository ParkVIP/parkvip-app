import 'package:flutter/material.dart';
import '../helper/utils.dart';
import '../pages/locations.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import '../helper/api_base_helper.dart';

class ResetPasswordPage extends StatefulWidget {
  static String tag = 'feedback-page';
  final accessToken;
  final userDetails;
  const ResetPasswordPage(this.accessToken,this.userDetails, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ResetPasswordPage();
  }
}
class _ResetPasswordPage extends State<ResetPasswordPage> {
  var utils = Utils();
  final apiHelper = ApiBaseHelper();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _enterNewPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _hiddenText = true;
  bool _hiddenText2 = true;

  @override
  void initState() {
    super.initState();
  }
  void _toggle() {
    setState(() {
      _hiddenText = !_hiddenText;
    });
  }
  void _toggleConfirm() {
    setState(() {
      _hiddenText2 = !_hiddenText2;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child : Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text("Reset Password",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
          leading:const BackButton(color:Colors.black)
      ),
      backgroundColor: ColorConstant.whiteA700,
      body: SizedBox(
          width: size.width,
          child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                    children:[
                      Container(
                          width: getHorizontalSize(380),
                           margin: getMargin(left: 24, top: 33, right: 24),
                          child: TextFormField(
                            obscureText: _hiddenText,
                            controller: _enterNewPassword,
                            decoration: InputDecoration(
                              hintText: "New password",
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
                                child: Icon(_hiddenText ? Icons.visibility_off : Icons.visibility,color:Colors.grey[600],size:16),
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
                      Container(
                          width: getHorizontalSize(380),
                           margin: getMargin(left: 24, top: 33, right: 24,bottom:470),
                          child: TextFormField(
                            obscureText: _hiddenText2,
                            controller: _confirmPassword,
                            decoration: InputDecoration(
                              hintText: "Confirm password",
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
                              suffixIcon: GestureDetector(onTap: _toggleConfirm,child:Container(margin: getMargin(left: 30,top: 22,right: 21,bottom: 22),
                                child: Icon(_hiddenText2 ? Icons.visibility_off : Icons.visibility,color: Colors.grey[600],size:16),
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
                              if(value != _enterNewPassword.text) {
                                return 'password does not Match';
                              }
                              return null;
                            } ,
                          ),
                      ),
                      CustomButton(
                          width: 380,
                          text: "Submit",
                          onTap : () async {
                            _resetPasswordApiCall(context);
                          },
                          margin: getMargin(
                              left: 24,
                              right: 24,
                              bottom: 20),
                          alignment: Alignment.center)
                    ] ))))));
  }

  _resetPasswordApiCall(BuildContext context) async {
    var uri =widget.userDetails['user_id'].toString();
    var passwordFormData = <String, dynamic>{};
    passwordFormData['password'] =   _confirmPassword.text;
    passwordFormData['full_name'] =  widget.userDetails['full_name'].toString();
    passwordFormData['username'] =  widget.userDetails['username'].toString();
    passwordFormData['mobile_no'] =  widget.userDetails['mobile_no'].toString();
    passwordFormData['email'] =  widget.userDetails['email'].toString();
    passwordFormData['role'] =  widget.userDetails['role'].toString();
    passwordFormData['user_type'] = "user";
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
      var jsonResponse = await apiHelper.post(context,'update_user',widget.accessToken, passwordFormData,uri);
      if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
        utils.toast(jsonResponse['message']);
        setState(() {
          Navigator.push(context,MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)));
        });
      }else{
        utils.toast(jsonResponse['message']);
      }
    }
  }
}