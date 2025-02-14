import 'package:ParkVip/pages/locations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../pages/login.dart';
import '../pages/my_profile.dart';
import '../pages/settings.dart';
import '../pages/feedback.dart';
import '../pages/activities.dart';
import '../pages/reservations.dart';
import '../pages/payments.dart';
import '../pages/user_notification.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ParkVip/core/app_export.dart';
import '../pages/how_it_works.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:twilio_chat_conversation/twilio_chat_conversation.dart';
import 'package:ParkVip/domain/googleauth/google_auth_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ParkVip/chat/screens/conversation_list_screen.dart';
import 'package:ParkVip/chat/screens/chat_details_screen.dart';
import '../helper/api_base_helper.dart';
import '../pages/generate-firebase-token.dart';

class Utils{
  var parkingDetailId;
  final apiHelper = ApiBaseHelper();
  final TwilioChatConversation twilioChatConversationPlugin = TwilioChatConversation();
  appLogo(logoDimensions,appBar){
    return Container(
      padding: (appBar==1)?const EdgeInsets.only(top: 0.0):const EdgeInsets.only(top: 20.0),
      height: getVerticalSize(119.00),
      width: getHorizontalSize(84.00),
      child: Image.asset("assets/images/img_1200x600wa21.png"),
    );
  }

  appColorFilter(){
    return ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop);
  }

  openMap(double latitude, double longitude) async {
     Uri url;
     if(!kIsWeb){
      if (Platform.isAndroid) {
        String urll= 'google.navigation:q=$latitude,$longitude&ll=$latitude,$longitude&directionsmode=driving';
         await launchUrl(Uri.parse(urll));
      } else if (Platform.isIOS) {
        var params = {
          'll': '$latitude,$longitude',
          'q': '$latitude, $longitude',
        };
        url = Uri.https('maps.apple.com', '/', params);
        await launchUrl(url);
      }
    }else{
      url = Uri.https('www.google.com', '/maps/search/',{'api': '1', 'query': '$latitude,$longitude'});
      await launchUrl(url);
    }
      
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return  File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  customizedAppBarColor(context,appBarLogoDimensions,accessToken,userDetails){
    var userImageUploaded = 0;
    late Uint8List bytes;

    if(userDetails['user_image'] != null){//&& (userDetails['is_from']==null || userDetails['is_from']=="")
      userImageUploaded = 1;
      bytes = base64Decode(base64.normalize(userDetails['user_image']));
    }
    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child:AppBar(iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: const Color(0xffffffff),
        titleSpacing: 0.0,
        title: Row(
          children:[
            const Spacer(flex: 3,),
            Padding(
              padding: getPadding(left: 21),
              child:ClipRRect(
                borderRadius:BorderRadius.circular(getHorizontalSize(14.00)),
                child: CommonImageView(
                    imagePath: ImageConstant.img1200x600wa3,
                    height:getSize(28.00),
                    width:getSize(28.00))),
            ),
            Flexible(
              flex:5,
              child:Text(' ParkVIP',textAlign:TextAlign.center,style: AppStyle.txtUrbanistRomanBold24.copyWith()),
            ),
            const Spacer(
              flex: 5,
            ),
            Flexible(
              flex: 2,
              child: GestureDetector(
                child:CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: (userImageUploaded == 0) 
                    ? (userDetails['url']!=null && userDetails['url']!="")  
                    ? Image.network(userDetails['url'],fit: BoxFit.cover,width: 30, height: 30,)
                    : Image.asset('images/user-default.png',fit: BoxFit.cover,width: 30, height: 30, )
                    : Image.memory(bytes,gaplessPlayback: true,fit: BoxFit.cover,width: 30, height: 30, ),
                  ),
                ),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => MyProfilePage(accessToken,userDetails)));
                },
              ),
            )
          ]
        ),
      )
    );
  }

  drawerMenu(context,accessToken,userDetails,unreadCount){
    var userImageUploaded = 0;
    late Uint8List bytes;
    if(userDetails['user_image'] != null ){//&& (userDetails['is_from']==null || userDetails['is_from']=="")
      bytes = base64Decode(base64.normalize(userDetails['user_image']));
      userImageUploaded = 1;
    }
    String selected = ""; 

    return SizedBox(
        width: MediaQuery.of(context).size.width/1.2,
        child:Drawer(
          child:Container(
            margin:const EdgeInsets.only(left:5,right:5),
            padding: const EdgeInsets.only(top:34,),
            decoration: AppDecoration.fillWhiteA700,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize:MainAxisSize.max,
                  children: [
                     GestureDetector(
                      onTap: () {
                        Navigator.push(context,MaterialPageRoute(builder: (context) => MyProfilePage(accessToken,userDetails)));
                      },
                        child:Container(
                          height: getVerticalSize(40.00),
                          width: getHorizontalSize(40.00),
                          margin:  const EdgeInsets.only(left:30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xff359ccc),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: (userImageUploaded == 0) 
                              ? (userDetails['url']!=null ) 
                              ? NetworkImage(userDetails['url']) 
                              : const ExactAssetImage('images/user-default.png') as ImageProvider
                              : MemoryImage(bytes) ,
                            ),
                          ),
                        ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Container( 
                        padding:getPadding(left: 16),
                        child: Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: [
                            Text(
                              userDetails['username'],
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing: 0.20)
                            )
                          ],
                        ),
                      )
                    ),
                    const Spacer(),
                    Container(
                      margin: getMargin(right:8),
                      child : InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.clear,color: ColorConstant.blue800,size: 25,),
                      ),   
                    ),                      
                ],
                ), 
                Container(
                    height: getVerticalSize(1.00),
                    width:getHorizontalSize(308.00),
                    margin: getMargin(left: 24,top: 32,right: 24),
                    decoration: BoxDecoration(color: ColorConstant.gray200)), 
                    
                GestureDetector(
                  onTap: () {
                    selected = 'profile';
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyProfilePage(accessToken,userDetails)),
                    );
                  },   
                  child:Container( color:Colors.white,
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: getPadding(left: 72,top: 30,right: 72),
                        child: Text("My profile",
                          overflow:TextOverflow.ellipsis,
                          textAlign:TextAlign.left,
                          style: (selected == 'profile') ? AppStyle.txtUrbanistSemiBold18Red500.copyWith(letterSpacing:0.20) : AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing:0.20))),
                  )
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child:GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HowItWorksScreen()),
                        );
                      },
                    child: Container( 
                      width:MediaQuery.of(context).size.width,
                      padding: getPadding(left: 72,top: 30,right: 72),
                      child: Text("How it works",
                        overflow:TextOverflow.ellipsis,
                        textAlign:TextAlign.left,
                        style: AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing:0.20))))),
                Align(
                  alignment: Alignment.centerLeft,
                  child:GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PaymentsPage(accessToken,userDetails,false)),
                        );
                      },
                    child: Container(
                      width:MediaQuery.of(context).size.width,
                      padding: getPadding(left: 72,top: 30,right: 72),
                      child: Text("Payments",
                        overflow:TextOverflow.ellipsis,
                        textAlign:TextAlign.left,
                        style: AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing:0.20))))),  
                Align(
                  alignment: Alignment.centerLeft,
                  child:GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LocationsPage(accessToken,userDetails)),
                        );
                      },
                    child: Container(
                      width:MediaQuery.of(context).size.width,
                      padding: getPadding(left: 72,top: 30,right: 72),
                      child: Text("Locations",
                        overflow:TextOverflow.ellipsis,
                        textAlign:TextAlign.left,
                        style: AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing:0.20))))), 
              Align(
                alignment: Alignment.centerLeft,
                child:GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ActivitiesPage(accessToken,userDetails)),
                      );
                    },
                  child: Container(
                    width:MediaQuery.of(context).size.width,
                    padding: getPadding(left: 72,top: 30,right: 72),
                    child: Text("Activity",
                      overflow:TextOverflow.ellipsis,
                      textAlign:TextAlign.left,
                      style: AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing:0.20))))), 
                Align(
                  alignment: Alignment.centerLeft,
                  child:GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReservationsPage(accessToken,userDetails)),
                        );
                      },
                    child: Container(
                      width:MediaQuery.of(context).size.width,
                      padding: getPadding(left: 72,top: 30,right: 72),
                      child: Text("Reservations",
                        overflow:TextOverflow.ellipsis,
                        textAlign:TextAlign.left,
                        style: AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing:0.20))))), 
                Align(
                  alignment: Alignment.centerLeft,
                  child:GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsPage(accessToken,null,userDetails)),
                        );
                      },
                    child: Container(
                      width:MediaQuery.of(context).size.width,
                      padding: getPadding(left: 72,top: 30,right: 72),
                      child: Text("Settings",
                        overflow:TextOverflow.ellipsis,
                        textAlign:TextAlign.left,
                        style: AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing:0.20))))), 
                Align(
                  alignment: Alignment.centerLeft,
                  child:GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FeedbackPage(accessToken,userDetails)),
                        );
                      },
                    child: Container(
                      width:MediaQuery.of(context).size.width,
                      padding: getPadding(left: 72,top: 30,right: 72),
                      child: Text("Account Deletion",
                        overflow:TextOverflow.ellipsis,
                        textAlign:TextAlign.left,
                        style: AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing:0.20))))),
                 // Align(
                 //    alignment: Alignment.centerLeft,
                 //    child:GestureDetector(
                 //        onTap: () async {
                 //          List conversationList=[];
                 //          conversationList=await twilioChatConversationPlugin.getConversations() ?? [];
                 //          if(conversationList.length==0 || userDetails['is_twilio_admin']==true){
                 //            Navigator.push(
                 //              context,
                 //              MaterialPageRoute(builder: (context) =>ConversationListScreen(userDetails: userDetails,accessToken:accessToken,is_twilio_admin:userDetails['is_twilio_admin'])),
                 //            );
                 //          }else{
                 //            String result = await twilioChatConversationPlugin.joinConversation(conversationId: conversationList[0]['sid']) ?? "UnImplemented Error";
                 //            if(result!=conversationList[0]['sid']){
                 //              this.toast('Having some error to join converstion.');
                 //            }else{
                 //               Navigator.push( context,
                 //                MaterialPageRoute(builder: (context) => 
                 //                  ChatDetailsScreen(
                 //                    conversationName: conversationList[0]['conversationName'],
                 //                    conversationSid: result,
                 //                    author:conversationList[0]['createdBy'],
                 //                    userDetails: userDetails,
                 //                    messageInit: true,
                 //                    isDirect: true,
                 //                    accessToken: accessToken
                 //                  )
                 //                ),
                 //              );
                 //            } 
                 //          }
                 //        },
                 //        child: kIsWeb?Container():Container(
                 //            width:MediaQuery.of(context).size.width,
                 //            padding: getPadding(left: 72,top: 30,right: 72),
                 //            child: Text("Live Support",
                 //                overflow:TextOverflow.ellipsis,
                 //                textAlign:TextAlign.left,
                 //                style: AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing:0.20))
                 //        )
                 //    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child:GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserNotificationPage(accessToken,userDetails)),
                      );
                    },
                    child: Container(
                      width:MediaQuery.of(context).size.width,
                      padding: getPadding(left: 72,top: (unreadCount==0) ? 30 : 18,right: 72),
                      child: Row(
                          children:[
                            Text( "Notifications",
                                overflow:TextOverflow.ellipsis,
                                textAlign:TextAlign.left,
                                style: AppStyle.txtUrbanistSemiBold18.copyWith(letterSpacing:0.20)),
                            (unreadCount==0) ? Text ("") : Container(
                              margin: getMargin(left:10),
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.red,
                                ),
                              ),
                              child: Text( unreadCount.toString(),
                                  overflow:TextOverflow.ellipsis,
                                  textAlign:TextAlign.left,
                                  style: AppStyle.txtUrbanistSemiBold22.copyWith(letterSpacing:0.20)),
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
                Container(
                  height: getVerticalSize(1.00),
                  width:getHorizontalSize(308.00),
                  margin: getMargin(
                      left: 24,
                      top: 33,
                      right: 24),
                  decoration: BoxDecoration(
                      color: ColorConstant.gray200)),
                Align(
                  alignment: Alignment.centerLeft,
                  child:GestureDetector(
                      onTap: () {
                        _logoutCall(context);
                      },
                    child: Padding(
                      padding: getPadding(left: 72,top: 30,right: 72),
                      child: Text("Logout",
                        overflow:TextOverflow.ellipsis,
                        textAlign:TextAlign.left,
                        style: AppStyle.txtUrbanistSemiBold18Red500.copyWith(letterSpacing:0.20))))), 
              ],
            )
          )
        )
    );
  }

  void clearSharedPreferences() async{
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
  _logoutCall(context) async{
      var firebaseToken = !kIsWeb? NotificationHandler():null;
      GoogleAuthHelper().googleSignOutProcess();
      clearSharedPreferences();
      await firebaseToken?.deleteToken();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
  }
  String capitalize(String input) {
    if (input.isEmpty) {
      return input;
    }
    else{
      return input[0].toUpperCase() + input.substring(1);
    }
  }
  void toast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: (!kIsWeb) ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
        gravity:  (!kIsWeb) ? ToastGravity.BOTTOM : ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        webPosition:'center',
        fontSize: 16.0);
  }
  void longToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: (!kIsWeb) ? ToastGravity.BOTTOM : ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        webPosition:'center',
        fontSize: 16.0);
  }
}
extension PrettyJson on Map<String, dynamic> {
  String toPrettyString() {
    var encoder = const JsonEncoder.withIndent("     ");
    return encoder.convert(this);
  }
}