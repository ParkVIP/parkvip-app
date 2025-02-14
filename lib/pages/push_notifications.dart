import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../pages/reservations.dart';
import '../pages/locations.dart';
import '../helper/utils.dart';
import '../pages/activities.dart';
import '../pages/payments.dart';
import '../pages/user_notification.dart';
import '../pages/generate-firebase-token.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../pages/splash_screen.dart';
import '../helper/api_base_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ParkVip/chat/bloc/chat_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twilio_chat_conversation/twilio_chat_conversation.dart';
import 'package:ParkVip/chat/bloc/chat_events.dart';
import 'package:ParkVip/chat/common/providers/chats_provider.dart';
import 'package:ParkVip/chat/common/providers/models_provider.dart';
import 'package:ParkVip/chat/repository/chat_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class PushNotification extends StatefulWidget {
  static String tag = 'notification';

  const PushNotification({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    if(kIsWeb){
      return  _PushNotificationStateWeb();
    }else{
      return _PushNotificationState();
    }
  }
}

class _PushNotificationState extends State<PushNotification> with WidgetsBindingObserver{
  final apiHelper = ApiBaseHelper();
  var accessToken;
  var userDetails;
  var _userParkingDetails;
  var utils = Utils();
  var firebaseToken =NotificationHandler();
  late FirebaseMessaging messaging;
  ChatBloc? chatBloc;
  TwilioChatConversation twilioChatConversationPlugin =TwilioChatConversation();

  @override
  void initState() {

    super.initState();
    checkAlreadyLogin();
    listenToAccessTokenStatus();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){});

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async{
     print('onMessage==================');
     if(mounted){
        if(event.notification!=null){
          if(event.data['screen'] == 'UserNotificationPage' ){
            setUnraedCount();
          }
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(event.notification!.title!),
                ),
                subtitle: HtmlWidget(event.notification!.body!)
              ),
              actions: <Widget>[
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xff008ace),
                    ),
                    onPressed: ()  async{
                     // setState(() async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        var isChatScreen = prefs.getBool('isChatScreen') ?? false;
                        print(isChatScreen);
                        if(event.data['title']=='Parkvip Twilio Reminder' && isChatScreen){
                           Navigator.of(context, rootNavigator: true).pop('dialog');                        
                        }else{
                          _navigateToNotificationScreen(event.data);
                        }                  
                      //});
                    },
                    child: const Text('Ok')
                ),
              ],
            ),
          );
        }
     }
      

    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      _navigateToNotificationScreen(message.data);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  listenToAccessTokenStatus() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    twilioChatConversationPlugin.onTokenStatusChange.listen((tokenData) {
      /// update token if your access token is about to expire
      if (tokenData["statusCode"] == 401) {
        chatBloc?.add(UpdateTokenEvent());
      }
    });
  }

  setUnraedCount() async{ 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token');
    var ntcount=0;
    ntcount=await _readNotificationCount(accessToken);
    prefs.setInt('unread_notify',ntcount);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        // --
        print('Inactive');
        break;
      case AppLifecycleState.paused:
        // --
        print('Paused');
        break;
      case AppLifecycleState.detached:
        // --
       print('Detached');
        break;
      case AppLifecycleState.hidden:
      // --
      print('Detached');
        break;
    }
  }
  void onResumed() async{
    var activeSession=false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token') ;
    userDetails = prefs.getString('user_details') ;
    print(userDetails);
    if(userDetails!=null){
      var userData=jsonDecode(userDetails);
      await setUnraedCount();
      var status = prefs.getBool('isSessionActive') ?? false;
      if(status==true && userData['isMotorcycle']!=true){
        var username=(userData['full_name']!=null) ? userData['full_name'] : userData['username'];
        getUserParkingDetails().then((s) => setState(() {
            _userParkingDetails = s;
            if(_userParkingDetails!=null){
              if(_userParkingDetails['data']!=null) {
                if (_userParkingDetails['data'].length > 0 && _userParkingDetails['data'] != null && _userParkingDetails['data'][0]['status'] == 'Parked') {
                  activeSession = true;
                }
              }else{
                activeSession=false;
              }
            }
            if(activeSession==false){
              prefs.setBool("isSessionActive", false);
              showSessionEndPopUp(userDetails,username);
            }
          })
        );
      }
    }
  }

  showSessionEndPopUp(userDetails,username){
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: const Text('Session Ended'),
          subtitle: Text('Hi $username Your ParkVip session has ended.'),
        ),
        actions: <Widget>[
          TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff008ace),
              ),
              onPressed: ()  {
                setState(() {
                  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>LocationsPage(accessToken,jsonDecode(userDetails))),);
                });
              },
              child: const Text('Ok')
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _navigateToNotificationScreen(Map<String, dynamic> message) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      accessToken = prefs.getString('access_token') ;
      userDetails = prefs.getString('user_details') ;
    });
    if(status==true && userDetails !=null){
      if(message['title']=='Session Ended'){
        prefs.setBool("isSessionActive", false);
      }
      if(message['body'] != null){
        if(message['screen'] == 'ReservationsPage' ){
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => 
            ReservationsPage(accessToken,jsonDecode(userDetails))),);
        }
        else if(message['screen'] == 'LocationsPage'){
          //Navigator.of(context).pop();
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>
           LocationsPage(accessToken,jsonDecode(userDetails))),);
        }
        else if(message['screen'] == 'PaymentsPage'){
          //Navigator.of(context).pop();
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>
           PaymentsPage(accessToken,jsonDecode(userDetails),true)),);
        }
        else if(message['screen'] == 'ActivitiesPage' ){
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => 
            ActivitiesPage(accessToken,jsonDecode(userDetails))),);
        }
        else if(message['screen'] == 'UserNotificationPage' ){
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => 
            UserNotificationPage(accessToken,jsonDecode(userDetails))),);
        }
        else{
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
      }
    }else{
      Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ModelsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
      ],
     
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child : MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ParkVIP',
          theme: ThemeData(
             useMaterial3: false,
            primaryColor: Colors.transparent,
            fontFamily: 'Urbanist',
          ),
          home: BlocProvider(
            create: (context) => ChatBloc(
              chatRepository: ChatRepositoryImpl(),
            ),
            child: StreamBuilder<Map>(
                stream: TwilioChatConversation().onTokenStatusChange,
                builder: (context, snapshot) {
                  return const SplashScreen();
                }),
          ),
          routes: <String, WidgetBuilder>{
            SplashScreen.tag: (context) => const SplashScreen()
          },
        ),
      ),
    );
  }

  void checkAlreadyLogin() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    var accessToken = prefs.getString('access_token') ;
    var userDetails = prefs.getString('user_details') ;
    var userId = prefs.getString('user_id') ;
    if(status==true && userDetails !=null){
      var receivedFirebaseToken = await firebaseToken.generateToken();
      updateUserTimezone(accessToken,userId);
      postFirebaseToken(receivedFirebaseToken,accessToken,userId);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            LocationsPage(accessToken, jsonDecode(userDetails))));
      }
    }
  }

  getUserParkingDetails ()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token') ;
    userDetails = prefs.getString('user_details') ;
    var userData =jsonDecode(userDetails);
    var queryParams =userData['username'];
    var parkingDetails = await apiHelper.get(context,'get_user_parking_details',accessToken, queryParams);
    if(!parkingDetails.isEmpty){
      return parkingDetails;
    }
  }

  postFirebaseToken (firebaceToken,accessToken,userId) async{
    var formData = <String, dynamic>{};
    formData['registration_token'] = firebaceToken.toString();
    formData['user_id'] = userId.toString();
    await apiHelper.post(context,'post_firebase_token',accessToken,formData,'');
  }

  updateUserTimezone (accessToken,userId) async{
    var tmzone = await FlutterTimezone.getLocalTimezone();
    if(tmzone.isNotEmpty){
      var formData = <String, dynamic>{};
      formData['usertimeZone'] = tmzone.toString();
      formData['user_id']=userId.toString();
      await apiHelper.post(context,'update_timezone',accessToken,formData,'');
    }
  }

  _readNotificationCount(accessToken) async{
    var jsonResponse = await apiHelper.get(context,'unreadCount',accessToken,'');
    if(jsonResponse['response_code']==200){
      return jsonResponse['count'];
    }else{
      return 0;
    }
  }
}

class _PushNotificationStateWeb extends State<PushNotification> with WidgetsBindingObserver{
  final apiHelper = ApiBaseHelper();
  var accessToken;
  var userDetails;
  var _userParkingDetails;
  var utils = Utils();
  //var firebaseToken =new NotificationHandler();
  //late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    checkAlreadyLogin();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
      // --
      //print('Inactive');
        break;
      case AppLifecycleState.paused:
      // --
      //print('Paused');
        break;
      case AppLifecycleState.detached:
      // --
      // print('Detached');
        break;
      case AppLifecycleState.hidden:
      // --
      // print('Detached');
        break;
    }
  }
  void onResumed() async {
    var activeSession = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token');
    userDetails = prefs.getString('user_details');
    if (userDetails != null) {
      var userData = jsonDecode(userDetails);
      var status = prefs.getBool('isSessionActive') ?? false;
      if (status == true && userData['isMotorcycle'] != true) {
        getUserParkingDetails().then((s) =>
            setState(() {
              _userParkingDetails = s;
              if (_userParkingDetails != null) {
                if (_userParkingDetails['data'] != null) {
                  if (_userParkingDetails['data'].length > 0 &&
                      _userParkingDetails['data'] != null &&
                      _userParkingDetails['data'][0]['status'] == 'Parked') {
                    activeSession = true;
                  }
                } else {
                  activeSession = false;
                }
              }
              if (activeSession == false) {
                prefs.setBool("isSessionActive", false);
                showSessionEndPopUp(userDetails, userData['username']);
              }
            })
        );
      }
    }
  }

  showSessionEndPopUp(userDetails,username){
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: const Text('Session Ended'),
          subtitle: Text('Dear $username Your ParkVip session has ended.'),
        ),
        actions: <Widget>[
          TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff008ace),
              ),
              onPressed: ()  {
                setState(() {
                  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>LocationsPage(accessToken,jsonDecode(userDetails))),);
                });
              },
              child: const Text('Ok')
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _navigateToNotificationScreen(Map<String, dynamic> message) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      accessToken = prefs.getString('access_token') ;
      userDetails = prefs.getString('user_details') ;
    });
    if(status==true && userDetails !=null){
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>LocationsPage(accessToken,jsonDecode(userDetails))),);
      if(message['title']=='Session Ended'){
        prefs.setBool("isSessionActive", false);
      }
      if(message['body'] != null){
        if(message['screen'] == 'ReservationsPage' ){
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>
            ReservationsPage(accessToken,jsonDecode(userDetails))),);
        }
        else if(message['screen'] == 'LocationsPage'){

          //Navigator.of(context).pop();
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>
           LocationsPage(accessToken,jsonDecode(userDetails))),);
        }
        else if(message['screen'] == 'ActivitiesPage' ){
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>
            ActivitiesPage(accessToken,jsonDecode(userDetails))),);
        }
        else{
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
      }
    }else{
      Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: 'ParkVIP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
           useMaterial3: false,
          primaryColor: Colors.transparent,
          fontFamily: 'Urbanist',
        ),

        home: const SplashScreen(),
        routes: <String, WidgetBuilder>{
          SplashScreen.tag: (context) => const SplashScreen()
        },
        // home: LoginPage(),
        // routes: <String, WidgetBuilder>{
        //   LoginPage.tag: (context) => new LoginPage()
        // },
      ),
    );
  }

  void checkAlreadyLogin() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    var accessToken = prefs.getString('access_token') ;
    var userDetails = prefs.getString('user_details') ;
    var userId = prefs.getString('user_id') ;
    if(status==true && userDetails !=null){
      updateUserTimezone(accessToken,userId);
      // postFirebaseToken(receivedFirebaseToken,accessToken,userId);
      Navigator.push(context,MaterialPageRoute(builder: (context) => LocationsPage(accessToken,jsonDecode(userDetails))));
    }
  }

  getUserParkingDetails ()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token') ;
    userDetails = prefs.getString('user_details') ;
    var userData =jsonDecode(userDetails);
    var queryParams =userData['username'];
    var parkingDetails = await apiHelper.get(context,'get_user_parking_details',accessToken, queryParams);
    if(!parkingDetails.isEmpty){
      return parkingDetails;
    }
  }

  // postFirebaseToken (firebaceToken,accessToken,userId) async{
  //   var formData = new Map<String, dynamic>();
  //   formData['registration_token'] = firebaceToken.toString();
  //   formData['user_id'] = userId.toString();
  //   var data = await apiHelper.post(context,'post_firebase_token',accessToken,formData,'');
  // }

  updateUserTimezone (accessToken,userId) async{
    var tmzone = await FlutterTimezone.getLocalTimezone();
    if(tmzone.isNotEmpty){
      var formData = <String, dynamic>{};
      formData['usertimeZone'] = tmzone.toString();
      formData['user_id']=userId.toString();
      await apiHelper.post(context,'update_timezone',accessToken,formData,'');
    }
  }
}

