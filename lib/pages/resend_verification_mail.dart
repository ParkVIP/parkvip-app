import 'package:flutter/material.dart';
import '../helper/utils.dart';
import 'login.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'package:ParkVip/widgets/custom_text_form_field.dart';
import '../helper/api_base_helper.dart';

class ResendVerificationMailPage extends StatefulWidget {
  static String tag = 'resend-verification-mail';
  const ResendVerificationMailPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ResendVerificationMailPage();
  }
}
class _ResendVerificationMailPage extends State<ResendVerificationMailPage> {
  var utils = Utils();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _key = GlobalKey();
  final _emailIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final apiHelper = ApiBaseHelper();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstant.whiteA700,
        appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text("Verification Email",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
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
            child: Form(
              key: _key,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextFormField(
                      width: 380,
                      //focusNode: FocusNode(),
                      controller: _usernameController,
                      hintText: "Username",
                      fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
                      margin:getMargin(left: 24, top: 36, right: 24),
                      alignment: Alignment.center,
                      prefix: Container(
                        margin: getMargin(left: 23,top: 21,right: 15,bottom: 21),
                        child: CommonImageView(svgPath: ImageConstant.imgUser)),
                      prefixConstraints: BoxConstraints(
                          minWidth: getSize(16.00),
                          minHeight: getSize(16.00)),
                      validator: (value) {
                          if (value!.isEmpty) {
                              return 'Username should not be empty.';
                          }
                          return null;
                      },
                  ),
                  CustomTextFormField(
                    width: 380,
                   // focusNode: FocusNode(),
                    controller: _emailIdController,
                    hintText: "Email ID",
                    textInputType:TextInputType.emailAddress,
                    fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
                    margin:getMargin(left: 24, top: 24, right: 24),
                    padding: TextFormFieldPadding.PaddingTB21,
                    textInputAction: TextInputAction.done,
                    alignment: Alignment.center,
                    prefix: Container(
                        margin: getMargin(left: 21,top: 20,right: 13,bottom: 20),
                        child: CommonImageView(svgPath: ImageConstant.imgMessage)),
                    prefixConstraints: BoxConstraints(
                        minWidth: getSize(15.00),
                        minHeight: getSize(15.00)),
                    validator: (value) {
                      bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value!);
                      if (value.isEmpty) {
                        return 'Please enter email id';
                      }
                      if(!emailValid){
                        return 'Please enter correct email id';
                      }
                      return null;
                      },
                  ),
                  CustomButton(
                      width: 380,
                      text: "Send",
                      onTap : () async {
                          _resendVerificationMailApiCall(context);
                      },
                      margin: getMargin(left: 24,top: 550,right: 24,bottom: 20),
                  ),

                ]
              )
            )
          )
        )
      )
    );
          // body: Container(
          //     child:Stack(
          //         children: <Widget>[
          //         Positioned(
          //          child:new Align(
          //             alignment: Alignment.topCenter,
          //               child:new Container(
          //                 color: Color(0xffffffff),
          //                 width: MediaQuery.of(context).size.width,
          //                 padding: EdgeInsets.all(15),
          //                 child: Form(
          //                   key: _key,
          //                   child: _generateTokenForm()
          //                 ),
          //               ),
          //               ),
          //           ),
          //           Positioned(
          //             child: Align(
          //               alignment: FractionalOffset.bottomCenter,
          //               child: new Container(
          //                  width: MediaQuery.of(context).size.width,
          //                  padding: EdgeInsets.all(15),
          //                   child: new Container(
          //                     height: 50,
          //                     child: ElevatedButton(
          //                       style: TextButton.styleFrom(
          //                         shape: StadiumBorder(),
          //                         backgroundColor: Color.fromRGBO(47,111,182,1.0),
          //                       ),
          //                       child: Text('Send',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16)),
          //                       onPressed: () {
          //                         _resendVerificationMailApiCall(context);
          //                       },
          //                     ),
          //                   )
          //               ),
          //             ),
          //           ),
          //       ],
          //     )
          // )
  }
  // _generateTokenForm(){
  //   return new Column(
  //       children:[
  //         new Container(
  //             width: MediaQuery.of(context).size.width,
  //             child:new Column(
  //               children: <Widget>[
  //                 new Container(
  //                     color: Color(0xffffffff),
  //                     width: MediaQuery.of(context).size.width,
  //                     padding: EdgeInsets.only(top:10, bottom:15),
  //                     child:new Column(
  //                         children: <Widget>[
  //                           new TextFormField(
  //                             controller: _usernameController,
  //                             decoration: InputDecoration(
  //                               filled: true,
  //                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide.none,),
  //                               hintText: 'Username',
  //                               prefixIcon: Icon(Icons.account_circle_outlined,size: 14,color: Color(0xffa9a9a9)),
  //                               hintStyle: TextStyle(fontSize: 14.0, color: Color(0xffa9a9a9)),
  //                               fillColor:Color.fromRGBO(229,229,229,0.5)
  //                             ),
  //                             validator: (value) {
  //                               if (value!.isEmpty) {
  //                                 return 'Username should not be empty.';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                           SizedBox(height: 30),
  //                           new TextFormField(
  //                             controller: _emailIdController,
  //                             keyboardType: TextInputType.emailAddress,
  //                             decoration: InputDecoration(
  //                               filled: true,
  //                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide.none,),
  //                               hintText: 'Email ID',
  //                               prefixIcon: Icon(Icons.email,size: 14,color: Color(0xffa9a9a9)),
  //                               hintStyle: TextStyle(fontSize: 14.0, color: Color(0xffa9a9a9)),
  //                               fillColor:Color.fromRGBO(229,229,229,0.5)
  //                             ),
  //                             validator: (value) {
  //                               bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value!);
  //                               if (value.isEmpty) {
  //                                 return 'Please enter email id';
  //                               }
  //                               if(!emailValid){
  //                                 return 'Please enter correct email id';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                         ]
  //                     )
  //                 ),
  //               ],
  //             )
  //         ),
  //       ]
  //   );
  // }
  _resendVerificationMailApiCall(BuildContext context) async {
    var email = _emailIdController.text;
    var username = _usernameController.text;
    var formData = <String, dynamic>{};
    formData['email'] = email;
    formData['username'] = username;
    var jsonResponse = await apiHelper.postWithoutToken('resend_verification_mail',formData,'');
    if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
      utils.longToast(jsonResponse['message']);
      setState(() {
        Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
      });
    } else{
      utils.longToast(jsonResponse['message']);
    }
  }
}