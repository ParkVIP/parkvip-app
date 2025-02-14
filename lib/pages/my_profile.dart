import 'package:flutter/material.dart';
import 'dart:convert';
import '../pages/locations.dart';
import '../helper/utils.dart';
import '../helper/api_base_helper.dart';
import '../helper/endpoints.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'package:ParkVip/widgets/custom_text_form_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pages/uploadPicture.dart';
import '../pages/upload_picture_web.dart';
//import '../pages/upload_export_web.dart';

var utils = Utils();
var appBarLogoDimension = {'height':50.0,'width':40.0};

//My profile page
class MyProfilePage extends StatefulWidget {
  final accessToken;
  final userDetails;
  const MyProfilePage(this.accessToken,this.userDetails);
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final _emailIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _isMotorcycleController = TextEditingController();
  final apiHelper = ApiBaseHelper();
  final _key = GlobalKey<FormState>();
  var endpoints =Endpoints();
  final controller = CardEditController();
  bool cardButtonClicked = false;
  bool isLoading = true;
  bool reverseChildParam = false;
  bool isMotorcycleEditable=false;
  bool isMotorcycle=false;
  var _setList;


  @override
  void initState() {
    controller.addListener(update);
    super.initState();
    if(_setList == null){
      _getCurrentSession().then(
              (s) => setState(() {
            _setList = s;
            if(_setList['totalCount']==0){
              isMotorcycleEditable=true;
            }
          })
      );
    }
    _nameController.text =(widget.userDetails['username'] ?? '');
    _emailIdController.text =(widget.userDetails['email'] ?? '');
    _passwordController.text =(widget.userDetails['password'] ?? '');
    _mobileNoController.text =(widget.userDetails['mobile_no'] ?? '');
    _isMotorcycleController.text =(widget.userDetails['isMotorcycle']==true?'Yes':'No');

  }
  void update() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _emailIdController.dispose();
    _passwordController.dispose();
    _mobileNoController.dispose();
    _isMotorcycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)  {
    var userImageUploaded = 0;
    late Uint8List bytes;

    if(widget.userDetails['user_image'] != null){// && (widget.userDetails['is_from']==null || widget.userDetails['is_from']=="")
      userImageUploaded = 1;
      bytes = base64Decode(base64.normalize(widget.userDetails['user_image']));
    }


    return SafeArea(
        child : Scaffold(
            backgroundColor: ColorConstant.whiteA700,
            appBar: AppBar(
              backgroundColor: const Color(0xffffffff),
              title: Text("My profile",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
              iconTheme: const IconThemeData(color: Colors.black),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body:SizedBox(
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
                                focusNode: FocusNode(),
                                controller:_nameController,
                                hintText: "Username",
                                margin:getMargin(left: 24, top: 33, right: 24),
                                fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
                                alignment: Alignment.center,
                                prefix: Container(
                                    margin: getMargin(left: 23,top: 21,right: 15,bottom: 21),
                                    child: CommonImageView(svgPath: ImageConstant.imgUser16X13)),
                                prefixConstraints: BoxConstraints(
                                    minWidth: getSize(16.00),
                                    minHeight: getSize(16.00)),
                                readOnly:true,
                              ),
                              CustomTextFormField(
                                width: 380,
                                focusNode: FocusNode(),
                                controller: _emailIdController,
                                hintText: "Email",
                                margin:getMargin(left: 24, top: 24, right: 24),
                                padding: TextFormFieldPadding.PaddingT22,
                                fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
                                alignment: Alignment.center,
                                prefix: Container(
                                    margin: getMargin(
                                        left: 21,
                                        top: 20,
                                        right: 13,
                                        bottom: 20),
                                    child: CommonImageView(
                                        svgPath:
                                        ImageConstant.imgMessageGray900)),
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
                              CustomTextFormField(
                                width: 380,
                                focusNode: FocusNode(),
                                controller:_mobileNoController,
                                hintText: "Phone Number",
                                margin:getMargin(left: 24, top: 24, right: 24),
                                fontStyle: TextFormFieldFontStyle.UrbanistRomanMedium18,
                                textInputAction: TextInputAction.done,
                                alignment: Alignment.center,
                                prefix: Container(
                                    margin: getMargin(left: 20,top: 19,right: 12,bottom: 19),
                                    child: CommonImageView(svgPath: ImageConstant.imgFolder,color:false)),
                                prefixConstraints: BoxConstraints(
                                    minWidth: getSize(18.00),
                                    minHeight: getSize(18.00)),
                                validator : (value) {
                                  if (value!.length < 10){
                                    return 'It should not be less then 10 digits.';
                                  }
                                  if (value.length >15){
                                    return 'Should not be greater then 15 digits.';
                                  }
                                  return null;
                                },
                              ),
                              Container(//color:Colors.grey,
                                margin: getMargin(top:10,left:24,right:24),
                                child: Row(
                                  mainAxisAlignment:MainAxisAlignment.center,
                                  crossAxisAlignment:CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text("Are you on a motorcycle ?",
                                        overflow: TextOverflow.ellipsis,
                                        textAlign:TextAlign.left,
                                        style: AppStyle.txtUrbanistSemiBold18Gray900.copyWith(letterSpacing:0.20)),
                                    const Spacer(),
                                    Checkbox(
                                      activeColor: ColorConstant.blue800,
                                      checkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6.0),
                                      ),
                                      side: MaterialStateBorderSide.resolveWith((states) => BorderSide(width: 2, color: isMotorcycleEditable==true ? ColorConstant.blue800: ColorConstant.gray500),),
                                      value: (_isMotorcycleController.text=='Yes')?true:false,
                                      onChanged: isMotorcycleEditable==true ? _updateMotorcycleVal : null,
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                  alignment: Alignment.center,
                                  child:GestureDetector(
                                      onTap: () {
                                        if(kIsWeb){
                                          Navigator.push(context,MaterialPageRoute(builder: (context) =>UploadImageWeb(widget.accessToken,widget.userDetails)), );
                                        }else{
                                          Navigator.push(context,MaterialPageRoute(builder: (context) =>UploadImageDemo(widget.accessToken,widget.userDetails)), );
                                        }
                                      },
                                      child:Container(
                                          margin: getMargin(left: 24, top: 24, right: 24),
                                          decoration: AppDecoration.fillBlue50.copyWith( borderRadius: BorderRadiusStyle.circleBorder29),
                                          child: Row(
                                              mainAxisAlignment:MainAxisAlignment.center,
                                              crossAxisAlignment:CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                    padding: getPadding(top: 19, bottom: 19),
                                                    child: CommonImageView(svgPath:ImageConstant.imgPlus,height: getSize(16.00),width: getSize(16.00),color:false)),
                                                Container(
                                                    margin: getMargin(
                                                        left: 17,
                                                        top: 16,
                                                        bottom: 16
                                                    ),
                                                    decoration: AppDecoration.txtOutlineBlue7003f,
                                                    child: Text(
                                                        "Upload picture",
                                                        overflow:TextOverflow.ellipsis,
                                                        textAlign: TextAlign.center,
                                                        style: AppStyle.txtUrbanistRomanBold16Blue800.copyWith(letterSpacing:0.20)))
                                              ])))
                              ),
                              (userImageUploaded == 0)
                                ? (widget.userDetails['url']!=null && widget.userDetails['url']!="")
                                  ? Container(
                                    margin: getMargin(left: 24, top: 24, right: 24,bottom:24),
                                    alignment: Alignment.center,
                                    child:Image.network(widget.userDetails['url'],gaplessPlayback: true,fit: BoxFit.cover,),
                                  )
                                  : Container(
                                    height:200,
                                    margin: getMargin(left: 24, top: 24, right: 24,bottom:24),
                                  )
                                : Container(
                                  margin: getMargin(left: 24, top: 24, right: 24,bottom:24),
                                  alignment: Alignment.center,
                                  child:Image.memory(bytes,gaplessPlayback: true,fit: BoxFit.cover,),
                                ),
                              CustomButton(
                                  width: 380,
                                  text: "Update details",
                                  margin: getMargin(left: 24,right: 24,bottom: 20),
                                  alignment: Alignment.center,
                                  onTap : () async {
                                    if (_key.currentState!.validate()) {
                                      _updateUserProfileApiCall().then(
                                              (s) => setState(() {})
                                      );
                                    }
                                  }
                              )
                            ]
                        )
                    )
                )
            )
        )
    );
  }

  void _updateMotorcycleVal(bool? newValue) => setState(() {
    isMotorcycle = newValue!;
    if (isMotorcycle) {
      setState(()=>
        _isMotorcycleController.text = 'Yes'
      );
    } else {
      setState(()=>
        _isMotorcycleController.text = 'No'
      );
    }
  });

  _updateUserProfileApiCall() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userProfileData = <String, dynamic>{};
    userProfileData['full_name'] = widget.userDetails['full_name'];
    userProfileData['username'] =  _nameController.text;
    userProfileData['mobile_no'] =  _mobileNoController.text;
    userProfileData['email'] =  _emailIdController.text;
    userProfileData['isMotorcycle']=_isMotorcycleController.text=='Yes' ? 'true' : 'false';
    userProfileData['user_type'] = "user";
    userProfileData['updateWithoutPassword']="1";
    String queryP=widget.userDetails['user_id'].toString();
    var jsonResponse =await  apiHelper.post(context,'update_user',widget.accessToken, userProfileData,queryP);
    if((!jsonResponse.isEmpty)){
      utils.toast(jsonResponse['message']);
      if (jsonResponse['response_code']==200){
        prefs.setString("user_details", jsonEncode(jsonResponse['data']));
        widget.userDetails['username']=jsonResponse['data']['username'];
        widget.userDetails['mobile_no']=jsonResponse['data']['mobile_no'];
        widget.userDetails['email']=jsonResponse['data']['email'];
        widget.userDetails['isMotorcycle']=jsonResponse['data']['isMotorcycle'];
        setState(() {
          Navigator.push(context,MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)));
        });
      }
    }else{
      utils.toast(jsonResponse['message']);
    }
  }

  _getCurrentSession() async{
    var query=widget.userDetails['user_id'].toString();
    var jsonResponse = await apiHelper.get(context,'get_current_activity', widget.accessToken, query);
    return jsonResponse;
  }
}