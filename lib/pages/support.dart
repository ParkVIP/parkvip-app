
import 'package:flutter/material.dart';
import '../helper/utils.dart';
import '../helper/endpoints.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import '../helper/api_base_helper.dart';

class SupportPage extends StatefulWidget {
  static String tag = 'feedback-page';
  final accessToken;
  final userDetails;
  const SupportPage(this.accessToken,this.userDetails);

  @override
  State<StatefulWidget> createState() {
    return _SupportPageState();
  }
}

class _SupportPageState extends State<SupportPage> {
  final _supportTextField = TextEditingController();
  final apiHelper = ApiBaseHelper();
  var utils = Utils();
  var endpoints = Endpoints();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

  return SafeArea(
    child : Scaffold(
      backgroundColor: ColorConstant.whiteA700,
      appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text("Support",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
          iconTheme: const IconThemeData(color: Colors.black),
      ),
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
                  child: Container(
                      width: double.infinity,
                      margin: getMargin(left: 24, top: 33, right: 24,bottom:370),
                      decoration: AppDecoration.fillGray51.copyWith(
                          borderRadius:BorderRadiusStyle.roundedBorder12),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextFormField(
                              minLines: 10,
                              maxLines: null,
                              autofocus: false,
                              controller: _supportTextField,
                              decoration: InputDecoration(
                                filled: true,
                                border : OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(getHorizontalSize(12.00,),),
                                  borderSide: BorderSide.none,
                                ),
                                //border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide.none,),
                                hintText: 'Ask for support',
                                hintStyle: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                                fillColor:ColorConstant.gray51,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'field cannot be empty';
                                }
                                return null;
                              },
                            ),
                          ]))),
              CustomButton(
                  width: 380,
                  text: "Submit",
                  onTap : () async {
                    _feedbackApiCall();
                  },
                  margin: getMargin(left: 24, top: 0, right: 24, bottom: 20),
                  alignment: Alignment.center
              )
            ]
          ),
        ),
      ),
    )
    );
  }
  _feedbackApiCall() async {
    var feedback = <String, dynamic>{};
    var message = _supportTextField.text;
    feedback['message'] = message.replaceAll("\n", " ");
    feedback['user_id'] = widget.userDetails['user_id'].toString();
    var jsonResponse=await apiHelper.post(context,'feedback',widget.accessToken,feedback,'');
    if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
        utils.toast("Your Support request sent successfully!");
        setState(() {
          Navigator.pop(context);
        });
    }
    else{
      utils.toast(jsonResponse['message']);
    }
  }
}