import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/endpoints.dart';
import '../helper/utils.dart';
import '../pages/parking.dart';
import '../helper/api_base_helper.dart';
import 'package:ndialog/ndialog.dart';
import 'dart:async';
import '../pages/sections.dart';
import '../pages/business.dart';
import '../pages/payments.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'dart:typed_data';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'login.dart';
import 'package:geolocator/geolocator.dart';
import '../.env.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ParkVip/chat/bloc/chat_bloc.dart';
// import 'package:ParkVip/chat/bloc/chat_events.dart';
// import 'package:ParkVip/chat/bloc/chat_states.dart';
// import 'package:ParkVip/chat/common/shared_preference.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationsPage extends StatefulWidget {
  static String tag = 'locations-page';
  final accessToken;
  final userDetails;
  const LocationsPage(this.accessToken,this.userDetails, {Key? key}) : super(key: key);
  @override
  _LocationsPageState createState() {
    return _LocationsPageState();
  }
}

  enum ConfirmAction { CANCEL, ACCEPT }

class _LocationsPageState extends State<LocationsPage> with SingleTickerProviderStateMixin {
  //ChatBloc? chatBloc;
  //SharedPreference sharedPreference = SharedPreference();
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final apiHelper = ApiBaseHelper();
  var utils = Utils();
  var endpoint =Endpoints();
  var appBarLogoDimension = {'height':50.0,'width':40.0};
  var _setList;
  var _userParkingDetails;
  var parkingSectionDetails;
  String reservationDate ="";
  late TimeOfDay selectedTime ;
  String reservationTime  ="";
  var datetimeSelected;
  var cancelReservation = 0;
  late TabController _tabController;
  var _currentIndex;
  var selectedTab ;
  late ProgressDialog pr;
  var _getReservationListData;
  bool dialog =false;
  late Timer timer;
  late Timer notificationTimer;
  int i=1;
  var brandImage=null;
  late Uint8List byte;
  var isBrandImage=false;
  bool tabLoading=false;
  var listItems=null;
  var loggedinUserFirstName="";
  var unreadCount=0;
  // _startTwilioClient(){
  //   chatBloc = BlocProvider.of<ChatBloc>(context);
  //    chatBloc!.add(GenerateTokenEvent(
  //     credentials: {
  //       "accountSid": twilio_account_sid,
  //       "apiKey": twilio_api_key,
  //       "apiSecret": twilio_api_secret,
  //       "identity": widget.userDetails['username'],
  //       "serviceSid": twilio_service_sid,
  //       "user_token":widget.accessToken
  //   }
  //   ));
  // }

  @override
  void initState() {
    super.initState();
    setScreenData(true);

    if(_setList == null){
      _getLocationsListApiCall(0,'nearby').then(
        (s) => setState(() {
          _setList = s;
          selectedTab = 'nearby';
        })
      );
    }
    
    if(!kIsWeb) {
      //_startTwilioClient();
      final newVersion = NewVersionPlus(
        iOSId: 'app.parkvip.parkvip',
        androidId: 'app.parkvip.parkvip',
      );
      // You can let the plugin handle fetching the status and showing a dialog,
      // or you can fetch the status and display your own dialog, or no dialog.
      const simpleBehavior = false;
      if (simpleBehavior) {
        basicStatusCheck(newVersion);
      } else {
        advancedStatusCheck(newVersion);
      }
    }
    if(_userParkingDetails == null){
      getUserParkingDetails().then(
        (s) => setState(() {_userParkingDetails = s;})
      );
    }

    if(_getReservationListData == null){
      _getReservationList().then(
          (s) => setState(() {
            timer = Timer.periodic(const Duration(seconds: 30), (Timer t) =>_getReservationList());
            _getReservationListData = s;
            print('_getReservationListData----');
            print(_getReservationListData);
          })
      );
    }
    if(brandImage == null){
      _getBrandImage().then(
          (s) => setState(() {
            brandImage = s;
            isBrandImage=true;
          })
      );
    }
    _getBrandImage().then(
        (s) => setState(() {
          brandImage = s;
          isBrandImage=true;
        })
    );

     notificationTimer = Timer.periodic(const Duration(seconds: 5), (Timer t) =>
        getUnreadCount().then(
          (s) => setState(() {
            print(s);
            if(s!=null){            
              unreadCount = s;
            }
          })
        ),
     );
    
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabChange);
    if(widget.userDetails['full_name']!=null){
      List<String> nameList = widget.userDetails['full_name'].split(' '); // Split the input string by space
      // If the input string contains only one word, return it
      if (nameList.length == 1) {
        loggedinUserFirstName = widget.userDetails['full_name'];
      } else {
        // If the input string contains multiple words, return the first word
        loggedinUserFirstName = nameList[0];
      }
    }else{
      loggedinUserFirstName =widget.userDetails['username'];
    }
  }

  getUnreadCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var notifyCount=prefs?.getInt("unread_notify");
    return notifyCount;
  }

  setScreenData(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isChatScreen", value);
  }

  void  _tabChange() async {
    tabLoading=true;
    pr =  ProgressDialog(context,message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),
      backgroundColor: Colors.blue.withOpacity(.5));
    if(!pr.isShowed){
      pr.show();
    }
    _currentIndex = _tabController.index;
    _setList = null;
    _tabController.removeListener(_tabChange); //Remove listener
    if(_currentIndex == 0){
      var s = await _getLocationsListApiCall(0,'nearby');
      setState(() {
        tabLoading=false;
        _setList = s;
        selectedTab = 'nearby';
        pr.dismiss();
      });
      _tabController.addListener(_tabChange); //Re-add listener
    }else{
      var s = await _getLocationsListApiCall(0,'favourites');
      setState(() {
            tabLoading=false;
            _setList = s;
            selectedTab = 'favourites';
            pr.dismiss();
          });
        _tabController.addListener(_tabChange);
      }
  }

  basicStatusCheck(NewVersionPlus newVersion) {
    newVersion.showAlertIfNecessary(context: context);
  }

  advancedStatusCheck(NewVersionPlus newVersion) async {
    final appStatus = await newVersion.getVersionStatus();
    if (appStatus != null) {
      var localV = appStatus.localVersion;
      var storeV = appStatus.storeVersion;
      if(localV.compareTo(storeV) == -1){
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: appStatus,
          dialogTitle: 'Update ParkVIP',
          dialogText: 'Update app from ${appStatus.localVersion} to ${appStatus.storeVersion}',
          dismissButtonText:'Cancel',
          dismissAction:()=>closeOnCancelUpdate(context)
        );
      }
    }
  }

  void closeOnCancelUpdate(context){
   Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
    setScreenData(false);
    timer.cancel();//cancel the timer here
    notificationTimer.cancel();
  }

  @override
  Widget build(BuildContext context) { 
    double windowSize = MediaQuery.of(context).size.width;
    double windowHeight= MediaQuery.of(context).size.height;
    var userParkingList = _userParkingDetails;
    var activeSession=false;
    if(isBrandImage==true){
      if(brandImage['data']['asset_img'] != null){
        var imagePath = brandImage['data']['asset_img'];
        var strToRemove = 'data:image/jpeg;base64,';
        var strToRemovepng = 'data:image/png;base64,';
        var strToRemovejpg = 'data:image/jpg;base64,';
        imagePath = imagePath.replaceAll(strToRemovepng, "");
        imagePath=imagePath.replaceAll(strToRemovejpg, "");
        byte = base64Decode(imagePath.replaceAll(strToRemove, ""));
      }
    }
    
    if(userParkingList!=null){
      if(userParkingList['data']!=null) {
        if (userParkingList['data'].length > 0 &&
          userParkingList['data'] != null &&
          userParkingList['data'][0]['status'] == 'Parked') {
          activeSession = true;
        }
      }else{
        activeSession=false;
      }
    }
    if (activeSession==true){
      return PopScope(
        canPop: true,
        onPopInvoked : (didPop){
          Future.value(false);
        },
        child: Scaffold(
          key:_scaffoldkey,
          resizeToAvoidBottomInset: false,
          appBar: utils.customizedAppBarColor(context,appBarLogoDimension,widget.accessToken,widget.userDetails),
          body: SingleChildScrollView(
                  child:Column(
                    children: <Widget>[
                      _setHeader(windowSize),
                      Container(
                        width: windowSize,
                        height: MediaQuery.of(context).size.height - 350,
                        color: Colors.white70,
                        child : Column(
                          children: <Widget>[
                            const SizedBox(height:60.0),
                            Text('Active Session in Progress!',style:AppStyle.txtUrbanistSemiBold20.copyWith()),
                            const SizedBox(height:40.0),
                            ElevatedButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color.fromRGBO(47,111,182,1.0), backgroundColor: const Color.fromRGBO(47,111,182,1.0),
                                  shape: const StadiumBorder(),
                                ),
                                child:  Text('Go to Session Page', textAlign: TextAlign.center,style: AppStyle.txtUrbanistSemiBold16.copyWith()),
                                onPressed: () async {
                                  pr =  ProgressDialog(context,message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),backgroundColor: Colors.blue.withOpacity(.5));
                                  pr.show();
                                  var sectionList = await _getSectionsList(userParkingList['data'][0]['section_id']);
                                  print("inside section list");
                                  print(sectionList);
                                  var locationsListData = await _getLocationsListApiCall(userParkingList['data'][0]['location_id'],'');
                                  print("inside location list data");
                                  print(locationsListData);
                                  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
                                  sharedPrefs.setString('parking_detail_id', json.encode(userParkingList['data'][0]['parking_detail_id']));
                                  if(!(_setList['data']==null || sectionList==null) ){
                                    Future.delayed(const Duration(seconds:1)).then((value) async{
                                      pr.dismiss();
                                      await Navigator.push(context,MaterialPageRoute(builder: (context) =>ParkingPage(
                                          widget.accessToken,
                                          locationsListData['data'][0],
                                          sectionList['data'],
                                          userParkingList['data'][0],
                                          userParkingList['data'][0]['imei'].toString(),
                                          widget.userDetails,
                                          userParkingList['data'][0]['space_id'],
                                          'true',
                                          3,
                                          DateTime.parse('2000-01-01'),
                                          0,
                                          userParkingList['data'][0]['stay_length'],
                                          userParkingList['data'][0]['prepaid_amount']
                                      )),
                                      );
                                    });
                                  }
                                }
                            ),
                          ]
                        ),
                      ),
                    ],
                  ),
                ),
          // BlocConsumer<ChatBloc, ChatStates>(
          //     builder: (BuildContext context, ChatStates state) {
                
              // }, listener: (BuildContext context, ChatStates state) {
              //   if (state is GenerateTokenLoadingState) {
              //     //ProgressBar.show(context);
              //   }
              //   if (state is GenerateTokenLoadedState) {
              //     //ProgressBar.dismiss(context);
              //     initializeConversationClient(accessToken: state.token);
              //   }
              //   if (state is GenerateTokenErrorState) {
              //     //ProgressBar.dismiss(context);
              //     //ToastUtility.showToastAtCenter(state.message);
              //   }
              //   if (state is InitializeConversationClientLoadingState) {
              //     //ProgressBar.show(context);
              //   }
              //   if (state is InitializeConversationClientLoadedState) {
              //     //ProgressBar.dismiss(context);
              //     SharedPreference.setIdentity(identity: widget.userDetails['username']);
              //   }
              //   if (state is InitializeConversationClientErrorState) {
              //     //ProgressBar.dismiss(context);
              //     //ToastUtility.showToastAtCenter(state.message);
              //   }
              // }),
              drawer: utils.drawerMenu(context,widget.accessToken,widget.userDetails,unreadCount),
        ),
      );
    }else{
      listItems = _setList;
      return PopScope(
        canPop: true,
        onPopInvoked : (didPop){
          Future.value(false);
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: utils.customizedAppBarColor(context,appBarLogoDimension,widget.accessToken,widget.userDetails),
          body: SizedBox(
                  width: double.infinity,
                 // height: double.infinity,
                  //child: SingleChildScrollView(
                      child:Column(
                          children: <Widget>[
                            _setHeader(windowSize),
                            Container(
                              color: Colors.white,
                              child : Column(
                                children: <Widget>[
                                  const SizedBox(height:10.0),
                                  DefaultTabController(
                                      length: 2,
                                      child:Column(
                                          children:[
                                            Container(
                                              height: 45,
                                              margin: const EdgeInsets.only(top:20,left:24,right:24,bottom:5),
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                                                color: Color.fromRGBO(47,111,182,1.0),
                                              ),
                                              child: TabBar(
                                                tabs: [
                                                  SizedBox(
                                                    width: 100.0,
                                                    child: Text('Nearby lots',
                                                        textAlign:TextAlign.center,
                                                        style:TextStyle(fontSize: getFontSize(20),fontFamily: "Urbanist",fontWeight: FontWeight.w700,)),
                                                  ),
                                                  SizedBox(
                                                    width: 100.0,
                                                    child: Text('Favorites',
                                                        textAlign:TextAlign.center,
                                                        style:TextStyle(fontSize:getFontSize(20),fontFamily: "Urbanist",fontWeight: FontWeight.w700,)),
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
                                              height: (_getReservationListData !=null && _getReservationListData['response_code'] ==200) ? windowHeight - 416 : windowHeight - 367,//MediaQuery.of(context).size.height*0.51,
                                              margin: const EdgeInsets.only(top:24,left:24,right:24,bottom:24),
                                              decoration: AppDecoration.outlineBlack9000c.copyWith(borderRadius: BorderRadiusStyle.roundedBorder16),
                                              child: TabBarView(
                                                  controller: _tabController,
                                                  children: <Widget>[
                                                    Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment:CrossAxisAlignment.start,
                                                        mainAxisAlignment:MainAxisAlignment.center,
                                                        children:[
                                                          (listItems==null)?Container(
                                                              padding:const EdgeInsets.all(16),
                                                              alignment: Alignment.center,
                                                              child:Text('Loading...',style:AppStyle.txtUrbanistSemiBold20.copyWith())
                                                          ):
                                                          Expanded(
                                                            child:_setListView(context,listItems['data'],windowSize),
                                                          )
                                                        ]
                                                    ),
                                                    Container(
                                                        //height: MediaQuery.of(context).size.height*0.50,
                                                        padding: const EdgeInsets.only(top:15,bottom: 10),
                                                        child: Column(
                                                            children:[
                                                              (listItems==null)?Container(
                                                                  padding:const EdgeInsets.all(16),
                                                                  alignment: Alignment.center,
                                                                  child:Text('Loading...',style: AppStyle.txtUrbanistSemiBold20.copyWith())
                                                              ):
                                                              Expanded(
                                                                child:_setListView(context,listItems['data'],windowSize),
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
                                ]
                              ),
                            ),
                          ]
                      )
                  //),
                ), 
          // BlocConsumer<ChatBloc, ChatStates>(
          //     builder: (BuildContext context, ChatStates state) {
                
          //     }, listener: (BuildContext context, ChatStates state) {
          //   if (state is GenerateTokenLoadingState) {
          //     //ProgressBar.show(context);
          //   }
          //   if (state is GenerateTokenLoadedState) {
          //     //ProgressBar.dismiss(context);
          //     initializeConversationClient(accessToken: state.token);
          //   }
          //   if (state is GenerateTokenErrorState) {
          //     //ProgressBar.dismiss(context);
          //     //ToastUtility.showToastAtCenter(state.message);
          //   }
          //   if (state is InitializeConversationClientLoadingState) {
          //     //ProgressBar.show(context);
          //   }
          //   if (state is InitializeConversationClientLoadedState) {
          //     //ProgressBar.dismiss(context);
          //     SharedPreference.setIdentity(identity: widget.userDetails['username']);
          //   }
          //   if (state is InitializeConversationClientErrorState) {
          //     //ProgressBar.dismiss(context);
          //     // ToastUtility.showToastAtCenter(state.message);
          //   }
          // }),
          drawer: utils.drawerMenu(context,widget.accessToken,widget.userDetails,unreadCount),
        ),

      );
    }
  }

  // void initializeConversationClient({required String accessToken}) {
  //   chatBloc!.add(InitializeConversationClientEvent(accessToken: accessToken));
  // }

  _setHeader(windowSize){
    return Stack(
        children:[
          Container(
            width: windowSize,
            height: 150,
            decoration: const BoxDecoration(
              color: Color(0xff0071bc),
            ),
            child: (isBrandImage==true) ? ColorFiltered(
              colorFilter: utils.appColorFilter(),
              child:   Image.memory(byte,gaplessPlayback:true,fit: BoxFit.cover),
            ) : ColorFiltered(
              colorFilter: utils.appColorFilter(),
            ),
          ),
          Container(
            margin:getMargin(top:60),
            alignment:Alignment.center,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:[
                SizedBox(
                  width: double.infinity,
                  child:Text("Hello ${loggedinUserFirstName}",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppStyle.txtUrbanistRomanBold32.copyWith()),
                ),
                const SizedBox(height: 10.0,),
                Text("Let's find you a VIP space",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppStyle.txtUrbanistRegular18WhiteA700.copyWith(letterSpacing: 0.20)),
              ]
            ),
          ),
          (_getReservationListData !=null && _getReservationListData['response_code'] ==200) ?
              Container(
                margin:const EdgeInsets.only(top:150),//MediaQuery.of(context).size.height*0.23
                width: windowSize,
                height: 50,
                color: Colors.green[400],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    GestureDetector(
                      child: Text('Your reservation is ready - Click here', style: AppStyle.txtUrbanist18.copyWith()),
                      onTap: () async{
                        pr =  ProgressDialog(context,message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),backgroundColor: Colors.blue.withOpacity(.5));
                        pr.show();
                       
                        if(_getReservationListData['data'][0]['payment_intent_id']==null && _getReservationListData['data'][0]['isCredit'] != null && !_getReservationListData['data'][0]['isCredit']){
                          _makePaymentDialog();
                        }else{
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool('isResListClicked',true);
                          var reservationSpace = await _getReservationSpace(_getReservationListData['data'][0]['location_id'],_getReservationListData['data'][0]['section_id'],_getReservationListData['data'][0]['space_id'],_getReservationListData['data'][0]['toDate'],_getReservationListData['data'][0]['fromDate'],_getReservationListData['data'][0]['length']);
                          var overflowdata;

                          if(reservationSpace['data']==null || reservationSpace['data']==''){
                            overflowdata=_getReservationListData['data'][0];
                          }else{
                            overflowdata=reservationSpace['data'];
                          }
                         
                          var locationDetails = await _getSingleLocationApiCall(overflowdata['location_id']);
                          var sectionDetails = await _getResvervationSectionsList(overflowdata['section_id'],_getReservationListData['data'][0]['fromDate'],overflowdata['toDate'],overflowdata['length']);
                          sectionDetails['data']['business_id']=overflowdata['business_id'];
                          var spaceDetails = await _getSpaceList(overflowdata['space_id']);
                           print('sectionDetails=========================================');
                          print(sectionDetails['data']);
                          DateTime reservationDateFormat = DateTime.parse(_getReservationListData['data'][0]['time']).toLocal();
                          pr.dismiss();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                ParkingPage(widget.accessToken,locationDetails['data'][0],
                                  sectionDetails['data'],
                                  spaceDetails['sectionSpace'],
                                  spaceDetails['sectionSpace']['imei'],
                                  widget.userDetails,
                                   overflowdata['space_id'],
                                  'false',2,reservationDateFormat,
                                  _getReservationListData['data'][0]['reserve_id'],
                                  _getReservationListData['data'][0]['length'],
                                  _getReservationListData['data'][0]['amount'],null,
                                  _getReservationListData['data'][0]['payment_intent_id'])
                            ),
                          );
                        }
                      },
                      ),
                    ]
                  ),
              )
          : Container(),
        ]
    );
  }

  _makePaymentDialog(){
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
                Navigator.push(context,MaterialPageRoute(builder: (context) => PaymentsPage(widget.accessToken,widget.userDetails,true)),
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

  Widget _setListView(BuildContext context,listItems,windowSize) {
    if(listItems.length < 1){
      return Center(
       // margin: const EdgeInsets.all(50),
        child:Text('No records found',style: AppStyle.txtUrbanistSemiBold18.copyWith())
      );
    }else{
      return ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const PageScrollPhysics(),
        shrinkWrap: true,
        itemCount: listItems!=null?listItems.length:1,
        itemBuilder: (context, index) {
          var currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
          //var myTimeStamp2 = DateTime.parse('2024-02-01 00:00:00').millisecondsSinceEpoch;
          if(listItems[index]['activateon']==null || DateTime.parse(listItems[index]['activateon']).millisecondsSinceEpoch <= currentTimeStamp) {
            return Container( 
              width:windowSize,
              margin:getMargin(left:20,right:20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:CrossAxisAlignment.start,
                mainAxisAlignment:MainAxisAlignment.center,
                children: [
                  Container(
                      padding: getPadding(top: 21),
                      child: Text(utils.capitalize(listItems[index]['location_name']),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtUrbanistRomanBold22Gray900.copyWith())
                  ),
                  Container( 
                    alignment: Alignment.center,
                    child: Padding(
                      padding: getPadding(top: 8),
                      child: Row(
                        children: [
                          Column(
                            mainAxisSize:MainAxisSize.min,
                            crossAxisAlignment:CrossAxisAlignment.start,
                            mainAxisAlignment:MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:getPadding(top: 3),
                                child: Row(
                                  mainAxisAlignment:MainAxisAlignment.start,
                                  crossAxisAlignment:CrossAxisAlignment.center,
                                  mainAxisSize:MainAxisSize.min,
                                  children: [
                                    Text(listItems[index]['total_spaces'].toString(),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style: AppStyle.txtUrbanistBlueRomanBold18.copyWith(letterSpacing: 0.20)),
                                        Padding(
                                          padding:getPadding(left:4,top:1,bottom:1),
                                          child: Text(
                                            "total spaces",
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: AppStyle.txtUrbanistRegular15.copyWith(letterSpacing: 0.20))
                                        )
                                  ]
                                )
                              ),
                              Padding(
                                padding:getPadding(top: 6,),
                                child: Row(
                                  mainAxisAlignment:MainAxisAlignment.start,
                                  crossAxisAlignment:CrossAxisAlignment.center,
                                  mainAxisSize:MainAxisSize.min,
                                  children: [
                                    Text("\$${listItems[index]['first_hour']}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtUrbanistRomanBold18Gray700.copyWith(letterSpacing: 0.20)),
                                    Padding(
                                      padding:getPadding(left:4,top:1,bottom:1),
                                      child: Text("/ for first hour".tr,overflow: TextOverflow.ellipsis,textAlign: TextAlign.left,style: AppStyle.txtUrbanistRegular15.copyWith(letterSpacing: 0.20)))
                                  ]
                                )
                              ),
                              Padding(
                                padding:getPadding(top: 6,bottom:2),
                                child: Row(
                                  mainAxisAlignment:MainAxisAlignment.start,
                                  crossAxisAlignment:CrossAxisAlignment.center,
                                  mainAxisSize:MainAxisSize.max,
                                  children: [
                                    Text("\$${listItems[index]['additional_hour']}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtUrbanistRomanBold18Gray700.copyWith(letterSpacing: 0.20)),
                                    Padding(
                                      padding: getPadding(left:4,top:1,bottom:1),
                                      child: Text("/ each additional hour".tr,overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,style: AppStyle.txtUrbanistRegular15.copyWith(letterSpacing: 0.20)))
                                  ]
                                )
                              )
                            ]
                          ),
                          const Spacer(),
                          Column(
                            mainAxisSize:MainAxisSize.max,
                            crossAxisAlignment:CrossAxisAlignment.end,
                            mainAxisAlignment:MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                width: 135,
                                text: "Choose",
                                onTap :  () async { 
                                  pr =  ProgressDialog(context,message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),backgroundColor: Colors.blue.withOpacity(.5));
                                  pr.show();
                                  var locationNewdata=await _getLocationsListApiCall(listItems[index]['location_id'],selectedTab);
                                  if(locationNewdata!=null){
                                    pr.dismiss();
                                    listItems[index]['isBusiness']==true ?
                                    Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => BusinessPage(widget.accessToken,locationNewdata['data'][0],widget.userDetails,0,0,null,null,null)),
                                    ) :
                                    Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => SectionsPage(widget.accessToken,locationNewdata['data'][0],widget.userDetails,0,0,null,null,null,null)),
                                    );
                                  }
                                },
                                variant:  ButtonVariant.OutlineBlue800,
                                padding: ButtonPadding.PaddingAll22,
                                fontStyle: (ButtonFontStyle.UrbanistSemiBold16),
                              ),
                            ]),
                              
                        ]
                      )
                    )
                  ),
                  Container(
                    height: getVerticalSize(1.00),
                    width: getHorizontalSize(340.00),
                    margin: getMargin(top: 20),
                    decoration: BoxDecoration(color: ColorConstant.gray200)),                
                ]
              )
            );
          }
          return null;
        },
      );
    }
  }

  showLoaderDialog(){
    AlertDialog alert=AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(margin: const EdgeInsets.only(left: 7),child:const Text("Loading..." )),
        ],),
    );
    showDialog(barrierDismissible: true,
      context:context,
      builder:(BuildContext context){
        Future.delayed(const Duration(seconds: 2), () {
        });
        return alert;
      },
    );
  }

  _getSingleLocationApiCall(locationId) async {
    String queryParams ='';
    if(locationId !=null){
        queryParams='?location_id=$locationId';
    }
    var jsonResponse = await apiHelper.get(context,'get_single_loc', widget.accessToken, queryParams);
    return jsonResponse;
  }

  _determinePosition() async {
    bool isEnable=true;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isEnable=false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        isEnable=false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      isEnable=false;
    } 
    return isEnable;
  }


  _getLocationsListApiCall(locationId,tabType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var searchParam = '';
    String queryParams ='';
    var additionalFilters='';
    var loggedInUserID = widget.userDetails['user_id'];
    var isEnable=await _determinePosition();
    if(isEnable==true){
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      var latLongCorrdinates = "${position.longitude},${position.latitude}";   
      prefs.setString("latLongCorrdinates",latLongCorrdinates);
      additionalFilters = '&long_lat=$latLongCorrdinates';
    }else{
      prefs.setString("latLongCorrdinates","");
    }
     
    if(locationId !=0){
      if(tabType!='nearby'){
        queryParams='&location_id=$locationId&user_id=$loggedInUserID';
      }else{
          queryParams='&location_id=$locationId&user_id=$loggedInUserID&type=$tabType$additionalFilters$searchParam';
      }
    }else if(tabType !='' && locationId==0){
      if(tabType!='nearby'){
        queryParams='&user_id=$loggedInUserID&type=$tabType$additionalFilters$searchParam';
      }else{
        queryParams='&user_id=$loggedInUserID&type=$tabType$additionalFilters$searchParam';
      }
    }
    print("reached here");
    var jsonResponse = await apiHelper.get(context,'get_locations', widget.accessToken, queryParams);
    print(jsonResponse);
    return jsonResponse;
  }

  _getBrandImage() async {
    var query='?asset_type=Brand Page';
    var jsonResponse = await apiHelper.get(context,'get_asset', widget.accessToken, query);
    return jsonResponse;
  }

  getUserParkingDetails ()async{
    String queryParams =widget.userDetails['username'];
    var parkingDetails = await apiHelper.get(context,'get_user_parking_details', widget.accessToken, queryParams);
    if(!parkingDetails.isEmpty){
      if(parkingDetails['response_code']==401){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => true,
        );
      }
      else {
        return parkingDetails;
      }
    }
  }

  _getSectionsList(sectionId) async{
    String queryParams ='&section_id=$sectionId';
    var jsonResponse = await apiHelper.get(context,'get_sections', widget.accessToken, queryParams);
    return jsonResponse;
  }

  _getResvervationSectionsList(sectionId,fromDate,toDate,stayLength) async{
    String queryParams ='&section_id=$sectionId&fromDate=$fromDate&toDate=$toDate&stay_length=$stayLength';
    var jsonResponse = await apiHelper.get(context,'get_sections', widget.accessToken, queryParams);
    return jsonResponse;
  }

  _getReservationList() async {
    String queryParams;
    queryParams = '?user_id=${widget.userDetails['user_id']}';
    var jsonResponse = await apiHelper.get(context,'get_reserveList', widget.accessToken, queryParams);
    if (!jsonResponse.isEmpty || jsonResponse != null) {
      if (jsonResponse['response_code'] == 200 ) {
        if(jsonResponse['data'][0]['payment_intent_id'] ==null && jsonResponse['data'][0]['final_amount']==0){
          return jsonResponse;
        }else if(jsonResponse['data'][0]['payment_intent_id'] !=null && jsonResponse['data'][0]['final_amount']!=0){
          return jsonResponse;
        }
      }
    }
  }
  _getSpaceList(spaceId)async{
    String queryParams = '&space_id=$spaceId';
    var jsonResponse = await apiHelper.get(context,'get_section_spaces', widget.accessToken, queryParams);
    return jsonResponse;
  }
  _getReservationSpace(locationId,sectionId,spaceId,toDate,fromdate,stayLength) async {
    String queryParams;
    queryParams='&location_id=$locationId&section_id=$sectionId&space_id=$spaceId&toDate=$toDate&fromDate=$fromdate&stay_length=$stayLength&type=checkReservation';
    var jsonResponse = await apiHelper.get(context,'get_section_spaces', widget.accessToken, queryParams);
    return jsonResponse;
  }
}
