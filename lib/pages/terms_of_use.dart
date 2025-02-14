import 'package:flutter/material.dart';
import '../helper/utils.dart';
import 'package:ParkVip/core/app_export.dart';

var utils = Utils();
var appBarLogoDimension = {'height':50.0,'width':40.0};

//My profile page
class TermsOfUsePage extends StatefulWidget {
  final userDetails;

  const TermsOfUsePage(this.userDetails);
  @override
  _TermsOfUsePageState createState() => _TermsOfUsePageState();
}

class _TermsOfUsePageState extends State<TermsOfUsePage> {
  //var _setList;
  late Column col;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: const Color(0xffffffff),
              title: Text("Terms of use",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
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

                          Padding(
                              padding: getPadding(left: 24, top: 39, right: 24),
                              child: Text("General",
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtUrbanistSemiBold14Gray800
                                      .copyWith(letterSpacing: 0.20))),
                          Align(
                              alignment: Alignment.center,
                              child: Container(
                                  width: getHorizontalSize(380.00),
                                  margin: getMargin(left: 24, top: 15, right: 24),
                                  child: Text("parkvip.app strives to ensure that its services are accessible to people with disabilities. parkvip.app has invested a significant amount of resources to help ensure that its website is made easier to use and more accessible for people with disabilities, with the strong belief that every person has the right to live with dignity, equality, comfort and independence.",
                                      maxLines: null,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtUrbanistRegular12.copyWith(
                                          letterSpacing: 0.20, height: 1.50)))),
                          Padding(
                              padding: getPadding(left: 24, top: 18, right: 24),
                              child: Text("Accessibility on parkvip.app",
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtUrbanistSemiBold14Gray800
                                      .copyWith(letterSpacing: 0.20))),
                          Align(
                              alignment: Alignment.center,
                              child: Container(
                                  width: getHorizontalSize(370.00),
                                  margin: getMargin(left: 24, top: 12, right: 24),
                                  child: Text("parkvip.app makes available the UserWay Website Accessibility Widget that is powered by a dedicated accessibility server. The software allows parkvip.app to improve its compliance with the Web Content Accessibility Guidelines (WCAG 2.1).",
                                      maxLines: null,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtUrbanistRegular12.copyWith(
                                          letterSpacing: 0.20, height: 1.50)))),
                          Padding(
                              padding: getPadding(left: 24, top: 18, right: 24),
                              child: Text("Enabling the Accessibility Menu",
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtUrbanistSemiBold14Gray800
                                      .copyWith(letterSpacing: 0.20))),
                          Align(
                              alignment: Alignment.center,
                              child: Container(
                                  width: getHorizontalSize(373.00),
                                  margin: getMargin(left: 24, top: 12, right: 24),
                                  child: Text("The parkvip.app accessibility menu can be enabled by clicking the accessibility menu icon that appears on the corner of the page. After triggering the accessibility menu, please wait a moment for the accessibility menu to load in its entirety.",
                                      maxLines: null,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtUrbanistRegular12.copyWith(
                                          letterSpacing: 0.20, height: 1.50)))),
                          Padding(
                              padding: getPadding(left: 24, top: 16, right: 24),
                              child: Text("Disclaimer",
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtUrbanistSemiBold14Gray800
                                      .copyWith(letterSpacing: 0.20))),
                          Align(
                              alignment: Alignment.center,
                              child: Container(
                                  width: getHorizontalSize(375.00),
                                  margin: getMargin(left: 24, top: 15, right: 24),
                                  child: Text("parkvip.app continues its efforts to constantly improve the accessibility of its site and services in the belief that it is our collective moral obligation to allow seamless, accessible and unhindered use also for those of us with disabilities.\nIn an ongoing effort to continually improve and remediate accessibility issues, we also regularly scan parkvip.app with UserWay’s Accessibility Scanner to identify and fix every possible accessibility barrier on our site. Despite our efforts to make all pages and content on parkvip.app fully accessible, some content may not have yet been fully adapted to the strictest accessibility standards. This may be a result of not having found or identified the most appropriate technological solution.",
                                      maxLines: null,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtUrbanistRegular12.copyWith(
                                          letterSpacing: 0.20, height: 1.50)))),
                                        ])))));

  }
}