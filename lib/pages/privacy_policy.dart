import 'package:flutter/material.dart';
import '../helper/utils.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

var utils = Utils();
var appBarLogoDimension = {'height':50.0,'width':40.0};

//My profile page
class PrivacyPolicyPage extends StatefulWidget {
  final userDetails;

  const PrivacyPolicyPage(this.userDetails, {Key? key}) : super(key: key);
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}


class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: const Color(0xffffffff),
              title: Text("Privacy policy",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
              iconTheme: const IconThemeData(color: Colors.black),
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
                      child: Container(
                          width: getHorizontalSize(373.00),
                          margin: getMargin(left: 24, top: 37, right: 24),
                          child: Text("At parkvip.app, accessible from https://parkvip.app/, one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by parkvip.app and how we use it.",
                              maxLines: null,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtUrbanistRegular12.copyWith(
                                  letterSpacing: 0.20, height: 1.50)))),
                                          Padding(
                      padding: getPadding(left: 24, top: 18, right: 24),
                      child: Text("Log Files",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtUrbanistSemiBold14Gray800
                              .copyWith(letterSpacing: 0.20))),
                                          Align(
                      alignment: Alignment.center,
                      child: Container(
                          width: getHorizontalSize(380.00),
                          margin: getMargin(left: 24, top: 11, right: 24),
                          child: Text("parkvip.app follows a standard procedure of using log files. These files log visitors when they visit websites. All hosting companies do this and a part of hosting services’ analytics. The information collected by log files include internet protocol (IP) addresses, browser type, Internet Service Provider (ISP), date and time stamp, referring/exit pages, and possibly the number of clicks. These are not linked to any information that is personally identifiable. The purpose of the information is for analyzing trends, administering the site, tracking users’ movement on the website, and gathering demographic information.",
                              maxLines: null,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtUrbanistRegular12.copyWith(
                                  letterSpacing: 0.20, height: 1.50)))),
                                          Padding(
                      padding: getPadding(left: 24, top: 16, right: 24),
                      child: Text("Cookies and Web Beacons",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtUrbanistSemiBold14Gray800
                              .copyWith(letterSpacing: 0.20))),
                                          Align(
                      alignment: Alignment.center,
                      child: Container(
                          width: getHorizontalSize(370.00),
                          margin: getMargin(left: 24, top: 15, right: 24),
                          child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Like any other website, parkvip.app uses ‘cookies’. These cookies are used to store information including visitors’ preferences, and the pages on the website that the visitor accessed or visited. The information is used to optimize the users’ experience by customizing our web page content based on visitors’ browser type and/or other information.\nFor more general information on cookies, please read ",
                                      style: TextStyle(
                                          color: ColorConstant.gray800,
                                          fontSize: getFontSize(12),
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.20,
                                          height: 1.50)),
                                  TextSpan(
                                      text: "What Are Cookies",
                                      style: TextStyle(
                                          color: ColorConstant.blue800,
                                          fontSize: getFontSize(12),
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.20,
                                          height: 1.50),
                                        recognizer: TapGestureRecognizer()
                                         ..onTap = () { launchUrl(Uri.parse('https://www.kaspersky.com/resource-center/definitions/cookies'));},
                                  ),
                                  TextSpan(
                                      text: ".",
                                      style: TextStyle(
                                          color: ColorConstant.gray800,
                                          fontSize: getFontSize(12),
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.20,
                                          height: 1.50))
                              ]),
                              textAlign: TextAlign.left))),
                                          Padding(
                      padding: getPadding(left: 24, top: 23, right: 24),
                      child: Text("Google DoubleClick DART Cookie",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtUrbanistSemiBold14Gray800
                              .copyWith(letterSpacing: 0.20))),
                                          Align(
                      alignment: Alignment.center,
                      child: Container(
                          width: getHorizontalSize(371.00),
                          margin: getMargin(left: 24, top: 11, right: 24),
                          child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: "Google is one of a third-party vendor on our site. It also uses cookies, known as DART cookies, to serve ads to our site visitors based upon their visit to www.website.com and other sites on the internet. However, visitors may choose to decline the use of DART cookies by visiting the Google ad and content network Privacy Policy at the following URL – ",
                                    style: TextStyle(
                                        color: ColorConstant.gray800,
                                        fontSize: getFontSize(12),
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.20,
                                        height: 1.50)),
                                TextSpan(
                                    text: "https://policies.google.com/technologies/ads",
                                    style: TextStyle(
                                        color: ColorConstant.blue800,
                                        fontSize: getFontSize(12),
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.20,
                                        height: 1.50),
                                    recognizer: TapGestureRecognizer()
                                         ..onTap = () { launchUrl(Uri.parse('https://policies.google.com/technologies/ads' ));},
                                    )
                              ]),
                              textAlign: TextAlign.left))),
                                          Padding(
                      padding: getPadding(left: 24, top: 18, right: 24),
                      child: Text("Our Advertising Partners",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtUrbanistSemiBold14Gray800
                              .copyWith(letterSpacing: 0.20))),
                                          Align(
                      alignment: Alignment.center,
                      child: Container(
                          width: getHorizontalSize(363.00),
                          margin: getMargin(
                              left: 24, top: 11, right: 24, bottom: 20),
                          child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: "Some of advertisers on our site may use cookies and web beacons. Our advertising partners are listed below. Each of our advertising partners has their own Privacy Policy for their policies on user data. For easier access, we hyperlinked to their Privacy Policies below.\nGoogle ",
                                    style: TextStyle(
                                        color: ColorConstant.gray800,
                                        fontSize: getFontSize(12),
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.20,
                                        height: 1.50)),
                                TextSpan(
                                    text: "https://policies.google.com/technologies/ads",
                                    style: TextStyle(
                                        color: ColorConstant.blue800,
                                        fontSize: getFontSize(12),
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.20,
                                        height: 1.50),
                                    recognizer: TapGestureRecognizer()
                                         ..onTap = () { launchUrl(Uri.parse('https://policies.google.com/technologies/ads') );},)
                              ]),
                              textAlign: TextAlign.left)))
                                        ])))));
  }
}
