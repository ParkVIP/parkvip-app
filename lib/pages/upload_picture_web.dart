import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ParkVip/pages/app_pic.dart';
import 'package:file_picker/file_picker.dart';
import '../helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import '../helper/api_base_helper.dart';
import '../pages/my_profile.dart';
// import 'package:file_picker/_internal/file_picker_web.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pages/upload_export_web.dart';


class UploadImageWeb extends StatefulWidget {
  final accessToken;
  final userDetails;
  const UploadImageWeb(this.accessToken,this.userDetails, {Key? key}) : super(key: key);
  @override
  UploadImageWebState createState() => UploadImageWebState();
}
class UploadImageWebState extends State<UploadImageWeb> {
  var utils = Utils();
  final apiHelper = ApiBaseHelper();
  String status = '';
  late String base64Image;
  String errMessage = 'Error Uploading Image';
  var displayImage = 0;
  Uint8List? fileBytes;

  @override
  void initState() {
    super.initState();
  }

Future chooseImage() async {
		print('chooseImage--------------');
		if(kIsWeb){
			FilePickerResult? result = await getImagePath();
			if (result != null) {
			  try {
    			setState(() async {
    				fileBytes = result!.files.first.bytes; 
			    	base64Image = base64Encode(fileBytes!);
    				print(base64Image);
            	displayImage=1;
            });
			  } catch (err) {
			    print(err);
			  }
			} else {
			  print('No Image Selected');
			}
	  }else{
	    	 print('No Image Selected');
	    }
    setStatus('');
}

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  startUpload() {
    setStatus('Uploading Image...');
    if (displayImage ==0) {
      setStatus(errMessage);
      return;
    }
    upload();
  }

  upload() async{
  	print('inside uplaod-------------------');
    var uri = widget.userDetails['user_id'].toString();
    var dataPost = <String, dynamic>{};
    dataPost['user_image'] =base64Image;
    dataPost['user_id'] = widget.userDetails['user_id'].toString();
    var jsonResponse=await apiHelper.post(context,'update_user',widget.accessToken,dataPost,uri);
    print(jsonResponse);
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
			                    	padding: getPadding(left: 24, top: 49, right: 24,bottom: displayImage ==0 ? 430 : 90),
			                    	child: (displayImage ==0)
			                    	? Text("No image selected",
			                        	overflow: TextOverflow.ellipsis,
			                        	textAlign: TextAlign.left,
			                        	style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing: 0.20))
			                    	: Image.memory(fileBytes!,fit: BoxFit.cover,)
			                  	)
			              	),
			             	CustomButton(
			                  width: 380,
			                  text: "Upload image",
			                  margin: getMargin( left: 24, right: 24, bottom: 20),
			                  shape: ButtonShape.RoundedBorder16,
			                  alignment: Alignment.center,
			                  onTap : () async {
			                    startUpload();
			                  }
			              )
			            ]
		           	)
		        )
	    	)
    	)
    );
  }
}
