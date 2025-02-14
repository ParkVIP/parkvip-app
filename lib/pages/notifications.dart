import 'dart:convert';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter/material.dart';
import '../helper/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_base_helper.dart';
import 'package:ParkVip/core/app_export.dart';

var utils = Utils();
var appBarLogoDimension = {'height':50.0,'width':40.0};

//Notifications page
class NotificationsPage extends StatefulWidget {
  final accessToken;
  const NotificationsPage(this.accessToken);
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}
class _NotificationsPageState extends State<NotificationsPage> {
  bool upcomingReservationSwitch = true;
  bool revealedParkingSpaceSwitch = true;
  bool lateToReservationSwitch = true;
  bool reservationExpiringSwitch = true;
  bool toggle =false;
  var _setList;
  final apiHelper = ApiBaseHelper();

  @override
  void initState() {
    super.initState();
    if(_setList == null){
        _getNotificationsList().then(
          (s) => setState(() {_setList = s;})
       );
    }
  }
  @override
  Widget build(BuildContext context) {
    var notificationsData = _setList;
    final notificationsList = <Widget>[];
    if(notificationsData == null){
      return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xffffffff),
            title: Text("Settings",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
            iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Container(
          padding:const EdgeInsets.all(16),
          alignment: Alignment.center,
          child:const Text('Loading...',style: TextStyle(fontSize: 20,fontFamily: "Urbanist"))
        )
      );
    }else{
      for (var i = 0; i < notificationsData['data'].length; i++) {
          notificationsList.add(Column(
            children:[
              Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: getPadding(left: 24, top: 36, right: 24, bottom: 805),
                      child: Row(
                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                                padding: getPadding(top: 4),
                                child: Text(notificationsData['data'][i]['label'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtUrbanistSemiBold18Gray800.copyWith(letterSpacing: 0.20))),
                            FlutterSwitch(
                              height:30.0,
                              width: 52.0,
                              value: notificationsData['data'][i]['value'],
                              onToggle: (value) {
                                setState(() {
                                   notificationsData['data'][i]['value'] = value;
                                  _updateNotification(notificationsData['data'][i]['notification_id'],value);
                                });
                              },
                              //activeTrackColor: Color.fromRGBO(47,111,182,1.0), 
                              activeColor: const Color.fromRGBO(47,111,182,1.0),
                            ),

                          ])))
            ]
            )            
          );
        }
      return Scaffold(
          appBar: AppBar(
              backgroundColor: const Color(0xffffffff),
              title: Text("Notifications",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
              iconTheme: const IconThemeData(color: Colors.black),
          ),

        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: notificationsList
            )
          )
        )
      );
    }
  }
  _getNotificationsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userDetails = jsonDecode(prefs.getString('user_details').toString());
    var query="/${userDetails['user_id']}";
    var jsonResponse = await apiHelper.get(context,'get_notifications', widget.accessToken, query);
    return jsonResponse;
  }
  _updateNotification(notificationId,value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userDetails = jsonDecode(prefs.getString('user_details').toString());

    var notificationDetails = <String, dynamic>{};
    notificationDetails['status'] = value.toString();
    notificationDetails['user_id'] = userDetails['user_id'].toString();
    notificationDetails['notification_id'] = notificationId.toString();
    var jsonResponse =await  apiHelper.post(context,'update_user_notification', widget.accessToken, notificationDetails,'');
    return jsonResponse;
  }
}