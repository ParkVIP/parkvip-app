// ignore_for_file: avoid_unnecessary_containers
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import '../helper/utils.dart';
import '../helper/api_base_helper.dart';
import '../pages/parking.dart';
import '../pages/locations.dart';
import 'dart:async';
import '../pages/payments.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotificationPage extends StatefulWidget {
  final accessToken;
  final userDetails;

  const UserNotificationPage(this.accessToken, this.userDetails, {Key? key}) : super(key: key);
  @override
  _UserNotificationPageState createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage> with SingleTickerProviderStateMixin {
  var utils = Utils();
  final apiHelper = ApiBaseHelper();
  late ProgressDialog reservationDialog;
  var listItems=null;
  bool listFetched=false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    if(listItems == null){
      getNotifications();
    }
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) =>
      getNotifications()
    );
  }
  getNotifications(){
    _getUserNotification().then(
        (s) => setState((){
          listItems = s;
          listFetched=true;
          if(listItems['data'].length > 0){
             _updateNotificationStatus(listItems['data'][0]['user_note_id']);
             setUnraedCount();
          }        
        })
      );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  setUnraedCount() async{ 
    SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setInt('unread_notify',0) ;
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text("Notifications",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)),
              );
            },
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:(!listFetched)  
        ? Container(
          margin: getMargin(left: 24, top: 24, right: 24),
          alignment: Alignment.center,
          child:Text('Loading...',style: AppStyle.txtUrbanistSemiBold20.copyWith(letterSpacing:0.20))
        ) 
        : (listItems['data'].length ==0) 
        ? Center(
            child:Text('No records found',style: AppStyle.txtUrbanistSemiBold18.copyWith())
          ) 
        : Center(
          child: ListView.builder(
            itemCount: listItems['data'].length,
            itemBuilder: (BuildContext context, int index){
              return InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.blueGrey,
                    elevation: 10,
                    child: ListTile(
                      title: HtmlWidget(utils.capitalize(listItems['data'][index]['message']),
                          textStyle: TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold,color: Colors.white)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _deleteNotification(listItems['data'][index]['user_note_id'],listItems['data'][index],listItems['data']);
                                });
                              },
                              icon: const Icon(Icons.delete,color: Colors.greenAccent, )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          ),
      ),
    );
  }

   _deleteNotification (id,index,listItems) async{
    var query="?user_note_id="+id.toString();
    var jsonResponse = await apiHelper.delete(context,'get_user_notifications', widget.accessToken,query);
    utils.longToast(jsonResponse['message']);
    getNotifications();
  }


  _getUserNotification() async{ 
    var uri = "?user_id=${widget.userDetails['user_id']}";
    var jsonResponse = await apiHelper.get(context,'get_user_notifications',widget.accessToken, uri);
    return jsonResponse;
  }

  _updateNotificationStatus(id) async {
    var dataPost = <String, dynamic>{};
    dataPost['user_note_id'] = id.toString();
    var jsonResponse = await apiHelper.post(context,'notification_read_update', widget.accessToken, dataPost,'');
    return jsonResponse;
  }
}
