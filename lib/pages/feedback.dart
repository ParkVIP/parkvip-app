import 'package:flutter/material.dart';
import '../helper/utils.dart';
import '../helper/api_base_helper.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';

class FeedbackPage extends StatefulWidget {
  static String tag = 'feedback-page';
  final accessToken;
  final userDetails;
  const FeedbackPage(this.accessToken,this.userDetails, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FeedbackPageState();
  }
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();
  final apiHelper = ApiBaseHelper();

  var utils = Utils();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ColorConstant.whiteA700,
      appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text('Account deletion',style: AppStyle.txtUrbanistRomanBold24.copyWith()),
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
                  margin: getMargin(left: 24, top: 33, right: 24,bottom:444),
                  decoration: AppDecoration.fillGray51.copyWith(borderRadius:BorderRadiusStyle.roundedBorder12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        minLines: 10,
                        maxLines: null,
                        autofocus: false,
                        controller: _feedbackController,
                        decoration: InputDecoration(
                          filled: true,
                          border : OutlineInputBorder(
                            borderRadius: BorderRadius.circular(getHorizontalSize(12.00,),),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Please let us know why you\'d like to delete your \naccount.',
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
                    ]
                  )
                )
              ),
              CustomButton(
                  width: 380,
                  text: "Submit",
                  onTap : () async {
                    _feedbackApiCall();
                  },
                  margin: getMargin(left: 24, top: 0, right: 24, bottom: 20),
                  shape: ButtonShape.RoundedBorder16,
                  alignment: Alignment.center
              )
            ]
          ),
        ),
      ),
    );
  }
  _feedbackApiCall() async {
    var feedback = <String, dynamic>{};
    var message = _feedbackController.text;
    feedback['message'] = message.replaceAll("\n", " ");
    feedback['user_id'] = widget.userDetails['user_id'].toString();
    feedback['type'] = 'feedback';

    var jsonResponse =await  apiHelper.post(context,'feedback', widget.accessToken, feedback,'');

    if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
      utils.toast("We're sorry to see you go. Please allow up to 24 hours for your account to be deleted.");
      setState(() {
        Navigator.pop(context);
      });
    }
    else{
      utils.toast(jsonResponse['message']);
    }
  }
}