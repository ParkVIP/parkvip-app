// ignore_for_file: avoid_unnecessary_containers
import 'package:flutter/material.dart';
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


var utils = Utils();

//Reservations page
class ReservationsPage extends StatefulWidget {
  final accessToken;
  final userDetails;

  const ReservationsPage(this.accessToken, this.userDetails, {Key? key}) : super(key: key);
  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> with SingleTickerProviderStateMixin {
  var currentTab = true;
  var _setList;
  var currentTabData;
  var historyTabData;
  late TabController _tabController;
  var _currentIndex;
  var selectedTab ;
  final apiHelper = ApiBaseHelper();
  late ProgressDialog reservationDialog;
  var currentDateTime = DateTime.now();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    if(_setList == null){
      _getReservationListApiCall('current').then(
              (s) => setState(() {
            _setList = s;
            selectedTab = 'current';
            timer = Timer.periodic(const Duration(minutes: 1), (Timer t) =>_getReservationListApiCall('current'));
          })
      );
    }
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _tabChange(){
    _currentIndex = _tabController.index;
    if(_currentIndex == 0){
      _getReservationListApiCall('current').then(
              (s) => setState(() {
            _setList = s;
            selectedTab = 'current';
          })
      );
    }else{
      _getReservationListApiCall('history').then(
              (s) => setState(() {
            _setList = s;
            selectedTab = 'history';
          })
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var listItems = _setList;
    return  Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text("Reservations",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)),
              );
            },
          ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top:20,bottom: 20,left:10,right:10),
        child: SingleChildScrollView(
            child:Column(
                children: [
                  DefaultTabController(
                      length: 2,
                      child:Column(
                          children:[
                            Container(
                              height: 40,
                              margin: const EdgeInsets.only(left: 10,right:10),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                                color: Color.fromRGBO(47,111,182,1.0),
                              ),
                              child: TabBar(
                                tabs: [
                                  SizedBox(
                                    width: 100.0,
                                    child: Text('Current',textAlign:TextAlign.center,style:AppStyle.txtUrbanistRomanBold18ColorLess.copyWith(letterSpacing:0.20)),
                                  ),
                                  SizedBox(
                                    width: 100.0,
                                    child: Text('History',textAlign:TextAlign.center,style:AppStyle.txtUrbanistRomanBold18ColorLess.copyWith(letterSpacing:0.20)),
                                  )
                                ],
                                unselectedLabelColor: Colors.white,
                                indicatorPadding: const EdgeInsets.all(5),
                                indicatorColor: Colors.transparent,
                                dividerColor: Colors.transparent,
                                labelColor: const Color.fromRGBO(47,111,182,1.0),
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorWeight:1.0,
                                isScrollable: false,
                                controller: _tabController,
                                indicator: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                                   color: Colors.white
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height -190 ,
                              margin: getMargin(left: 20, top: 24, right: 20),
                              decoration: AppDecoration.outlineBlack9000c.copyWith(borderRadius:BorderRadiusStyle.roundedBorder16),  
                              child: TabBarView(
                                  controller: _tabController,
                                  children: <Widget>[
                                    Container(
                                        child: Column(
                                            children:[
                                              (listItems==null)?Container(
                                                  margin: getMargin(left: 24, top: 24, right: 24),
                                                  alignment: Alignment.center,
                                                  child:Text('Loading...',style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20))
                                              ):Expanded(
                                                child: _renderTabsBody(context,listItems['data']),
                                              )
                                            ]
                                        )
                                    ),
                                    SizedBox(
                                        height: MediaQuery.of(context).size.height,//*0.2,
                                        child: Column(
                                            children:[
                                              (listItems==null)?Container(
                                                alignment: Alignment.center,
                                                margin: getMargin(left: 24, top: 24, right: 24),
                                                child:Text('Loading...',style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20))
                                              ):
                                              Expanded(
                                                child: _renderTabsBody(context,listItems['data']),
                                              )
                                            ]
                                        )
                                    ),
                                  ]
                              ),
                            ),
                          ]
                      )
                  ),
                 // SizedBox(height:10.0),
                ]

            )
        ),
      ),
    );
  }

  Widget _renderTabsBody(BuildContext context,listItems){
    if(listItems==null || listItems.length < 1){
      if(selectedTab=='current') {
        return Container(
          padding: getPadding(left: 24, top: 47, right: 24, bottom: 20),
            child: Text('No current reservations found', style: AppStyle.txtUrbanistRomanMedium18.copyWith(letterSpacing:0.20))
        );
      }else{
        return Container(
          padding: getPadding(left: 24, top: 47, right: 24, bottom: 20),
            child: Text('Reservations history not found', style:  AppStyle.txtUrbanistRomanMedium18.copyWith(letterSpacing:0.20))
        );
      }
    }else{
      var tabBody;
      if(selectedTab=='history'){
        tabBody = _setHistoryListView(listItems);
        return ListView(
          physics: const PageScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: tabBody,
        );
      }else{
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: listItems!=null?listItems.length:1,
          itemBuilder: (context, i) {
            return Container(
              padding: getPadding(left: 24, top: 26, right: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    _setCurrentListView(listItems[i]),
                    Container(
                        height: getVerticalSize(1.00),
                        width: getHorizontalSize(332.00),
                        margin: getMargin(left: 24, top: 22, right: 24),
                        decoration: BoxDecoration(color: ColorConstant.gray200)),
                  ]
                )
            );
          },
        );
      }
    }
  }


  _setCurrentListView(listItems) {
    var formatDate = DateFormat("MM/dd/yyyy");
    var btnType="View Details";
    var reservationTimeRemaining =0;
    DateTime reservationDateFormat = DateTime.parse(listItems['time']).toLocal();
   // reservationTimeRemaining= reservationDateFormat.difference(currentDateTime).inMinutes;
    // if(listItems['payment_intent_id']==null && reservationTimeRemaining <= 60 && !listItems['isCredit']){
    //   btnType="Update Card";
    // }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox (
              width: MediaQuery.of(context).size.width - 110,
              child : Text(utils.capitalize(listItems['location_name']),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20.0,fontFamily: 'Urbanist',fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox (
              width: (MediaQuery.of(context).size.width - 88) / 1.9,
              child : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Location: ${listItems['section_name']}",textAlign: TextAlign.left,
                    style: AppStyle.txtUrbanistgray500Regular18.copyWith(letterSpacing:0.20)
                  ),
                  (listItems['level']=='' || listItems['level']==null) ? Container() : Text( "Floor: ${listItems['level']}",textAlign: TextAlign.left,style: AppStyle.txtUrbanistgray500Regular18.copyWith(letterSpacing:0.20),),
                  Text("Space: ${listItems['space_number']}",textAlign: TextAlign.left,style: AppStyle.txtUrbanistgray500Regular18.copyWith(letterSpacing:0.20)),
                  Text("Date: ${formatDate.format(DateTime.parse(listItems['fromDate'].toString()).toLocal())}",textAlign: TextAlign.left,
                    style: AppStyle.txtUrbanistgray500Regular18.copyWith(letterSpacing:0.20)),
                  Text("Time: ${DateFormat.jm().format((DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateTime.parse(listItems['time']).toString(),true)).toLocal())}",
                    textAlign: TextAlign.left,style: AppStyle.txtUrbanistgray500Regular18.copyWith(letterSpacing:0.20)),
                ],
              ),
            ),    
            buttonStyle(btnType,listItems),
          ],
        )
      ]
    );
  }

  _setHistoryListView(listItems) {
    var tabBody = <Widget>[];
    var formatDate = DateFormat("MM/dd/yyyy");
    for (var i = 0; i < listItems.length; i++) {
      tabBody.add(
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: getPadding(left: 24, top: 26, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:getPadding(bottom: 2),
                      child: Text("Brand",
                        overflow:TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20))
                    ),
                    Padding(
                      padding: getPadding(top: 1),
                      child: Text(listItems[i]['location_name'] ?? '',
                        overflow:TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtUrbanistRomanBold18Gray900.copyWith(letterSpacing:0.20))
                    )
                  ]
                )
              ),
              Padding(
                padding: getPadding(left: 24, top: 14, right: 24),
                child: Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:getPadding(bottom: 4),
                      child: Text("Location",
                        overflow:TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20)
                      )
                    ),
                    Padding(
                        padding: getPadding(top: 2),
                        child: Text(listItems[i]['section_name'] ?? '',
                            overflow:
                                TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle
                                .txtUrbanistRomanBold18Gray900
                                .copyWith(
                                    letterSpacing:
                                        0.20)))
                  ]
                )
              ),
              (listItems[i]['level']=='' || listItems[i]['level']==null) ? Container() :
              Padding(
                  padding: getPadding(left: 24, top: 11, right: 24),
                  child: Row(
                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                            padding: getPadding(top: 1),
                            child: Text("Floor",
                                overflow:TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20))),
                        Padding(
                            padding:getPadding(bottom: 1),
                            child: Text(listItems[i]['level'].toString(),
                              overflow:TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtUrbanistRomanBold18Gray900.copyWith(letterSpacing:0.20)))
                      ])),
              Padding(
                  padding: getPadding(
                      left: 24, top: 11, right: 24),
                  child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                            padding: getPadding(top: 1),
                            child: Text("Space",
                                overflow:TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20))),
                        Padding(
                            padding:getPadding(bottom: 1),
                            child: Text(listItems[i]['space_number'].toString(),
                                overflow:TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtUrbanistRomanBold18Gray900.copyWith(letterSpacing:0.20)))
                      ])),
              Padding(
                  padding: getPadding(
                      left: 24, top: 13, right: 24),
                  child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                            padding:
                                getPadding(bottom: 2),
                            child: Text("Date",
                                overflow:
                                    TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle
                                    .txtUrbanistSemiGray700Bold18
                                    .copyWith(
                                        letterSpacing:
                                            0.20))),
                        Padding(
                            padding: getPadding(top: 1),
                            child: Text(formatDate.format(DateTime.parse(listItems[i]['fromDate'].toString()).toLocal()).toString(),
                                overflow:
                                    TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle
                                    .txtUrbanistRomanBold18Gray900
                                    .copyWith(
                                        letterSpacing:
                                            0.20)))
                      ])),
              Padding(
                  padding: getPadding(
                      left: 24, top: 13, right: 24),
                  child: Row(
                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                            padding:getPadding(bottom: 2),
                            child: Text("Time",
                              overflow:TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20))),
                        Padding(
                            padding: getPadding(top: 1),
                            child: Text(DateFormat.jm().format(DateTime.parse(listItems[i]['time'].toString()).toLocal()).toString(),
                                overflow:TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtUrbanistRomanBold18Gray900.copyWith(letterSpacing:0.20)))
                      ])),
              Container(
                  height: getVerticalSize(1.00),
                  width: getHorizontalSize(332.00),
                  margin: getMargin(left: 24, top: 22, right: 24),
                  decoration: BoxDecoration(color: ColorConstant.gray200)),
            ]
          )
        )
      );
    }
    return tabBody;
  }


  buttonStyle(textButtonText,resData) {
    var locationDetails;
    var sectionDetails;
    var spaceDetails;
    var reservationSpace;
    var data;
    DateTime reservationDateFormat = DateTime.parse(resData['time']).toLocal();
    if(textButtonText==null){
      return Container();
    }
    return CustomButton(
        width: 140,
        text: textButtonText,
        onTap : () async {
          reservationDialog = ProgressDialog(context,
              message:const Text("Please wait...."),
              title:const Text("Loading..."),
              backgroundColor: Colors.blue.withOpacity(.5),
              dismissable: false,
          );
          reservationDialog.show();

          reservationSpace = await _getReservationSpace(resData['location_id'],resData['section_id'],resData['space_id'],resData['toDate'],resData['fromDate'],resData['length']);
          if(reservationSpace['data']==null || reservationSpace['data']==''){
            if(reservationSpace['response_code']==404){
               reservationDialog.dismiss();
              _noSpaceAvailable();  
            }else{
              data=resData;
            }
          }else{
            data=reservationSpace['data'];
          }
          locationDetails = await _getLocationsListApiCall(resData['location_id'],'');
          sectionDetails = await _getSectionsList(data['section_id'],resData['fromDate'],resData['toDate'],resData['stay_length']);
          sectionDetails['data']['business_id']=data['business_id'];
          spaceDetails = await _getSpaceList(data['space_id']);
          if(spaceDetails['sectionSpace']['overflow'] == true){
            reservationDialog.dismiss();
            Future.delayed(const Duration(seconds:1)).then((value) {
                 _overflowDialog(locationDetails['data'][0],sectionDetails['data'],spaceDetails['sectionSpace'],spaceDetails['sectionSpace']['imei'],data['space_id'],
                  reservationDateFormat,resData['reserve_id'],resData['length'],resData['amount'],resData['payment_intent_id']);
            });
          }
          else if(textButtonText =='Update Card'){
            reservationDialog.dismiss();
            Future.delayed(const Duration(seconds:1)).then((value) {
              _makePaymentDialog(resData);
            });
          }
          else{
            reservationDialog.dismiss();
            Future.delayed(Duration.zero).then((value) {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      ParkingPage(widget.accessToken,locationDetails['data'][0],sectionDetails['data'],spaceDetails['sectionSpace'],
                          spaceDetails['sectionSpace']['imei'],widget.userDetails,data['space_id'],'false',2,
                          reservationDateFormat,resData['reserve_id'],resData['length'],resData['amount'],null,resData['payment_intent_id'])
                  ),);
            });
          }
        },
        margin: getMargin(bottom: 2,top:10,right:2),
        alignment: Alignment.center
      );
  }
  
  _getReservationSpace(locationId,sectionId,spaceId,toDate,fromdate,stayLength) async {
    String queryParams;
    queryParams='&location_id=$locationId&section_id=$sectionId&space_id=$spaceId&toDate=$toDate&fromDate=$fromdate&stay_length=$stayLength&type=checkReservation';
    var jsonResponse = await apiHelper.get(context,'get_section_spaces', widget.accessToken, queryParams);
    return jsonResponse;
  }

  _getLocationsListApiCall(locationId,tabType) async {
    String queryParams;
    var loggedInUserID = widget.userDetails['user_id'];
    queryParams='&location_id=$locationId&user_id=$loggedInUserID&isImage=false';
    var jsonResponse = await apiHelper.get(context,'get_locations', widget.accessToken, queryParams);
    return jsonResponse;
  }

  _getSectionsList(sectionId,fromDate,toDate,stayLength) async{
    var uri ='&section_id=$sectionId&fromDate=$fromDate&toDate=$toDate&stay_length=$stayLength';
    var jsonResponse = await apiHelper.get(context,'get_sections',widget.accessToken, uri);
    return jsonResponse;
  }

  _getSpaceList(spaceId)async{
    var uri = '&space_id=$spaceId';
    var jsonResponse = await apiHelper.get(context,'get_section_spaces',widget.accessToken, uri);
    return jsonResponse;
  }


  _getReservationListApiCall(tabType) async{
    var uri = "${widget.userDetails['user_id']}?type=app";
    var jsonResponse = await apiHelper.get(context,'get_${tabType}_reservations',widget.accessToken, uri);
    print('mdvmxvmxnc nxn--------------------');
    print(jsonResponse);
    return jsonResponse;
  }
  _noSpaceAvailable() {
    return showDialog<String>(
      barrierDismissible: false,
        context: context,
        builder:(context) =>AlertDialog(
        actions: <Widget>[
          ElevatedButton(
              style: TextButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: const Color.fromRGBO(47,111,182,1.0),
              ),
              child: const Text('Ok',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16)),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }
          ),
        ],
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        contentPadding: const EdgeInsets.only(left: 25, right: 25),
        content: const SizedBox(
          width: 200.0,
          height: 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child:Text("Sorry, this space is not avaliable.",
                      style: TextStyle(
                        fontSize: 18,fontWeight: FontWeight.bold,//color: Color(0xff0071bc),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _overflowDialog(locationDetails,sectionDetails,sectionSpace,imei,spaceId,reservationDateFormat,reservId,length,amount,intentId) {
    return showDialog<String>(
      barrierDismissible: false,
        context: context,
        builder:(context) =>AlertDialog(
        actions: <Widget>[
          ElevatedButton(
              style: TextButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: const Color.fromRGBO(47,111,182,1.0),
              ),
              child: const Text('Ok',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      ParkingPage(widget.accessToken,locationDetails,sectionDetails,sectionSpace,imei,
                          widget.userDetails,spaceId,'false',2,reservationDateFormat,reservId,length,amount,null,intentId)
                  ),
                );
              }
          ),
        ],
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        contentPadding: const EdgeInsets.only(left: 25, right: 25),
        content: SizedBox(
          width: 300.0,
          height: 200.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child:Text("We're sorry but your Space is still being used by the previous user. We found another great space for you. Please park in space #${sectionSpace['space_number']}.",
                      style: const TextStyle(
                        fontSize: 18,fontWeight: FontWeight.bold,//color: Color(0xff0071bc),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  _makePaymentDialog(resData){
    showDialog<String>(
      context: context,
      builder:(context) =>AlertDialog(
        actions: <Widget>[
          ElevatedButton(
            style: TextButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: const Color.fromRGBO(47,111,182,1.0),
            ),
             child: const Text('CANCEL',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16)),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('Reservation');
            },
          ),
          ElevatedButton(
              style: TextButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: const Color.fromRGBO(47,111,182,1.0),
              ),
              child: const Text('Update Card',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentsPage(widget.accessToken,widget.userDetails,true)),
                );
               // _makePaymentApiCall(resData);
              }
          ),
        ],
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        contentPadding: const EdgeInsets.only(left: 25, right: 25),
        content: const SizedBox(
          width: 300.0,
          height: 200.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child:Text("Payment failed. Please update your payment method.",
                      style: TextStyle(
                        fontSize: 18,fontWeight: FontWeight.bold,//color: Color(0xff0071bc),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
