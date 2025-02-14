import 'dart:io';
import 'dart:convert';
import '../helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import '../helper/api_base_helper.dart';
import '../pages/my_profile.dart';


class UploadImageDemo extends StatefulWidget {
  final accessToken;
  final userDetails;
  const UploadImageDemo(this.accessToken,this.userDetails, {Key? key}) : super(key: key);
  @override
  UploadImageDemoState createState() => UploadImageDemoState();
}
class UploadImageDemoState extends State<UploadImageDemo> {
  var utils = Utils();
  final apiHelper = ApiBaseHelper();
  String status = '';
  late String base64Image;
  String errMessage = 'Error Uploading Image';
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future clickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
      }
    });
    setStatus('');
  }


  Future chooseImage() async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery,imageQuality: 50);
     setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
      }
    });
     setStatus('');
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  startUpload() {
    setStatus('Uploading Image...');
    if (null == _image) {
      setStatus(errMessage);
      return;
    }
    upload();
  }

  upload() async{
    //print('start uplaod-----');
    var uri = widget.userDetails['user_id'].toString();
    if(_image!=null){
      base64Image = base64Encode(_image!.readAsBytesSync());
    }
    var dataPost = <String, dynamic>{};
    dataPost['user_image'] =base64Image;
    dataPost['user_id'] = widget.userDetails['user_id'].toString();
    var jsonResponse=await apiHelper.post(context,'update_user',widget.accessToken,dataPost,uri);
    //print(jsonResponse);
    if(jsonResponse['response_code']==200){
      setStatus(jsonResponse['response_code'] == 200 ? 'Profile Updated!' : errMessage);
      utils.toast('Profile picture updated!');
      widget.userDetails['user_image']=base64Image;
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.push(context,MaterialPageRoute(builder: (context) => MyProfilePage(widget.accessToken,widget.userDetails)));         
      });
    }else{
      setStatus(errMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xffffffff),
            title: Text("Upload profile picture",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
            iconTheme: const IconThemeData(color: Colors.black),
            leading: IconButton(
            icon:  const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
        ),
        backgroundColor: ColorConstant.whiteA700,
        body: SizedBox(
        width: size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                  alignment: Alignment.center,
                  child:GestureDetector(
                    onTap: () {
                      clickImage();
                    },
                    child: Container(
                      margin: getMargin(left: 24, top: 33, right: 24),
                      decoration: AppDecoration.fillBlue50.copyWith(
                          borderRadius:
                              BorderRadiusStyle.circleBorder29),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                             Padding(
                                 padding:
                                     getPadding(top: 20, bottom: 20),
                                 child: CommonImageView(
                                     svgPath: ImageConstant.imgCamera,
                                     height: getVerticalSize(15.00),
                                     width: getHorizontalSize(15.00))),
                             Container(
                                 margin: getMargin(
                                     left: 18, top: 16, bottom: 16),
                                 decoration:
                                     AppDecoration.txtOutlineBlue7003f,
                                 child: Text("Open camera",
                                     overflow: TextOverflow.ellipsis,
                                     textAlign: TextAlign.center,
                                     style: AppStyle
                                         .txtUrbanistRomanBold16Blue800
                                     .copyWith(letterSpacing: 0.20)))

                          ],)))
              ),
              CustomButton(
                  width: 380,
                  text: "Choose image",
                  margin: getMargin(left: 24, top: 24, right: 24),
                  variant: ButtonVariant.FillBlue50,
                  onTap : () async {
                    chooseImage();
                  },
                  fontStyle: ButtonFontStyle.UrbanistRomanBold16Blue800,
                  alignment: Alignment.center
              ),

              Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: getPadding(left: 24, top: 49, right: 24,bottom: _image ==null? 430 : 90),
                    child: (_image ==null)
                    ? Text("No image selected",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing: 0.20))
                    : Image.file(_image!,
                      fit: BoxFit.cover,
                    )
                  )
              ),
              CustomButton(
                  width: 380,
                  text: "Upload image",
                  margin: getMargin( left: 24, right: 24, bottom: 20),
                  //variant: ButtonVariant.FillIndigo300,
                  shape: ButtonShape.RoundedBorder16,
                  alignment: Alignment.center,
                  onTap : () async {
                    startUpload();
                  }
              )
                    ])))));
  }
}
