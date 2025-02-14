import 'package:flutter/material.dart';
import '../helper/utils.dart';
import '../pages/terms_of_use.dart';
import '../pages/privacy_policy.dart';
import '../pages/support.dart';
import '../pages/reset_password.dart';
import '../pages/notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:ParkVip/core/app_export.dart';


var utils = Utils();
var appBarLogoDimension = {'height':50.0,'width':40.0};

//Settings page
class SettingsPage extends StatefulWidget {
  final selectedLanguage;
  final userDetails;
  final accessToken;
  const SettingsPage(this.accessToken,this.selectedLanguage,this.userDetails, {Key? key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  var timezone;

  @override
  void initState() {
    super.initState();
    if (timezone == null) {
      getTimeZone().then((s) => setState(() {
        timezone = s.replaceAll("_", " ");
      }));
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorConstant.whiteA700,
        appBar: AppBar(
            backgroundColor: const Color(0xffffffff),
            title: Text("Settings",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
            iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                    alignment: Alignment.center,
                    child: Padding(
                        padding: getPadding(left: 24, top: 38, right: 24),
                        child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                  padding: getPadding(top: 1),
                                  child: Text("Languages",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle
                                          .txtUrbanistSemiBold18Gray800
                                          .copyWith(
                                              letterSpacing: 0.20))),
                              Text( (widget.selectedLanguage==null) ? "English" : widget.selectedLanguage ,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtUrbanistSemiBold18Gray800.copyWith(letterSpacing: 0.20))
                            ]))),
                Container(
                  height: getVerticalSize(1.00),
                  width: getHorizontalSize(380.00),
                  margin: getMargin(left: 24, top: 20, right: 24),
                  decoration:BoxDecoration(color: ColorConstant.gray200)),
                GestureDetector(
                  //behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => NotificationsPage(widget.accessToken)),);
                  },
                  child:Container(
                    width:MediaQuery.of(context).size.width,
                    padding: getPadding(left: 24, top: 22, right: 24),
                    child: Text("Notifications",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtUrbanistSemiBold18Gray800.copyWith(letterSpacing: 0.20))),
                ),
                Container(
                  height: getVerticalSize(1.00),
                  width: getHorizontalSize(380.00),
                  margin: getMargin(left: 24, top: 20, right: 24),
                  decoration:BoxDecoration(color: ColorConstant.gray200)),
              
              GestureDetector(
                //behavior: HitTestBehavior.opaque,
                 onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SupportPage(widget.accessToken,widget.userDetails)),
                  );
                },
                child:Container(
                  width:MediaQuery.of(context).size.width,
                  padding: getPadding(left: 24, top: 25, right: 24),
                  child: Text("Support",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtUrbanistSemiBold18Gray800.copyWith(letterSpacing: 0.20))),
              ),
              Container(
                  height: getVerticalSize(1.00),
                  width: getHorizontalSize(380.00),
                  margin: getMargin(left: 24, top: 20, right: 24),
                  decoration:BoxDecoration(color: ColorConstant.gray200)),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ResetPasswordPage(widget.accessToken,widget.userDetails)),
                  );
                },
                child:Container(
                  width:MediaQuery.of(context).size.width,
                  padding: getPadding(left: 24, top: 24, right: 24),
                  child: Text("Reset password",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtUrbanistSemiBold18Gray800
                          .copyWith(letterSpacing: 0.20))),
              ),
              Container(
                  height: getVerticalSize(1.00),
                  width: getHorizontalSize(380.00),
                  margin: getMargin(left: 24, top: 20, right: 24),
                  decoration:BoxDecoration(color: ColorConstant.gray200)),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TermsOfUsePage(widget.userDetails)),
                  );
                },
                child:Container(
                  width:MediaQuery.of(context).size.width,
                  padding: getPadding(left: 24, top: 24, right: 24),
                  child: Text("Terms of use",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle.txtUrbanistSemiBold18Gray800.copyWith(letterSpacing: 0.20))),
              ),
              Container(
                  height: getVerticalSize(1.00),
                  width: getHorizontalSize(380.00),
                  margin: getMargin(left: 24, top: 20, right: 24),
                  decoration:BoxDecoration(color: ColorConstant.gray200)),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                 onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrivacyPolicyPage(widget.userDetails)),
                  );
                },
                child :Container(
                  width:MediaQuery.of(context).size.width,
                  padding: getPadding(left: 24, top: 24, right: 24),
                  child: Text("Privacy policy",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle.txtUrbanistSemiBold18Gray800.copyWith(letterSpacing: 0.20))),
              ),
              Container(
                  height: getVerticalSize(1.00),
                  width: getHorizontalSize(380.00),
                  margin: getMargin(left: 24, top: 20, right: 24),
                  decoration:BoxDecoration(color: ColorConstant.gray200)),
              Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: getPadding(left: 24, top: 22, right: 24, bottom: 415),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              //width:MediaQuery.of(context).size.width - 150,
                                padding: getPadding(bottom: 3),
                                child: Text("Timezone",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle
                                        .txtUrbanistSemiBold18Gray800
                                        .copyWith(
                                            letterSpacing: 0.20))),
                            Padding(
                                padding: getPadding(top: 1),
                                child: Text( (timezone==null) ? '' :timezone,
                                  //overflow: TextOverflow.ellipsis,
                                  //textAlign: TextAlign.left,
                                  style: AppStyle.txtUrbanistSemiBold18Gray800.copyWith(letterSpacing: 0.20)))
                          ]))),
              Container(
                  height: getVerticalSize(1.00),
                  width: getHorizontalSize(380.00),
                  margin: getMargin(left: 24, top: 20, right: 24),
                  decoration:BoxDecoration(color: ColorConstant.gray200)),
            ]),
          ),
      ),
      //drawer: utils.drawerMenu(context,widget.access_token,widget.userDetails)
    );
  }
  getTimeZone() async{
    var tmzone = await FlutterTimezone.getLocalTimezone();
    return tmzone;
  }
}