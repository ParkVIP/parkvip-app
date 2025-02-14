import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../helper/utils.dart';
import '../pages/locations.dart';
import '../pages/card_details.dart';
import '../helper/api_base_helper.dart';
import 'package:ndialog/ndialog.dart';
import '../pages/support.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'login.dart';
import '../pages/payments.dart';
// import 'package:ParkVip/chat/screens/conversation_list_screen.dart';
// import 'package:twilio_chat_conversation/twilio_chat_conversation.dart';
// import 'package:ParkVip/chat/screens/chat_details_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pages/pick_space.dart';
import 'package:url_launcher/url_launcher.dart';



class ParkingPage extends StatefulWidget {
  final locationDetails;
  final sectionDetails;
  final userParkingDetails;
  final accessToken;
  final userDetails;
  final userIMEI;
  final spaceId;
  final fromSession;
  final fromReservation;
  final reservationDateTime;
  final reservationId;
  final reservationLength;
  final paidAmount;
  final firstOddThenEven;
  final rsvp_intent;

  const ParkingPage(
      this.accessToken,
      this.locationDetails,
      this.sectionDetails,
      this.userParkingDetails,
      this.userIMEI,
      this.userDetails,
      this.spaceId,
      this.fromSession,
      this.fromReservation,
      this.reservationDateTime,
      this.reservationId,
      this.reservationLength,
      this.paidAmount,
      [this.firstOddThenEven,this.rsvp_intent]);
  createState() => _ParkingPageState();
}
enum ConfirmAction { CANCEL, ACCEPT }
class _ParkingPageState extends State<ParkingPage> with SingleTickerProviderStateMixin {
//  final TwilioChatConversation twilioChatConversationPlugin = TwilioChatConversation();
  var accessToken;
  var utils = Utils();
  final apiHelper = ApiBaseHelper();
  var appBarLogoDimension = {'height': 50.0, 'width': 40.0};
  var paymentList;
  var amountDetails;
  var enterNow = false;
  var letMeOutAmount;
  var reservationTimeRemaining = 0;
  var cancelReservationButton = 0;
  var letMeInBtnText = 'Let me in';
  var letMeInBtnIcon = Icons.input_outlined;
  var reservationIdRename = 0;
  var reservation=0;
  var currentDateTime = DateTime.now();
  num amountTopost =0;
  var length;
  int timerCostVal =0;
  var calculatedAmountForParking;
  bool isFromReservation = true;
  bool isLetmeinButtonPressed =false;
  bool doNotRefresh = false;
  static DateTime now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  bool letMeIn =true;
  bool enterNowText = true;
  bool startStop = true;
  bool started = false;
  int blocked = 0;
  String difference = '';
  String elapsedTime = '';
  String amount = '0';
  late String reservationTime;
  late String reservationDate;
  String formattedDate = DateFormat('EEEE MMMM d, y').format(DateTime.now());
  bool reserveCheck = true;
  bool confirmReservationBtn = true;
  var listOfHours = {'01:00':'1 Hour','02:00':'2 Hours','03:00':'3 Hours','04:00':'4 Hours','05:00':'5 Hours','06:00':'6 Hours','07:00':'7 Hours','08:00':'8 Hours','09:00':'9 Hours','10:00':'10 Hours','11:00':'11 Hours','12:00':'12 Hours','13:00':'13 Hours','14:00':'14 Hours','15:00':'15 Hours','16:00':'16 Hours','17:00':'17 Hours','18:00':'18 Hours','19:00':'19 Hours','20:00':'20 Hours','21:00':'21 Hours','22:00':'22 Hours','23:00':'23 Hours'};
  var stayLength;
  Stopwatch watch = Stopwatch();
  late Timer timer;
  var reservationAmount;
  var strToRemove ;
  var imagePath ;
  var timerVal;
  late ProgressDialog letMeInDialog;
  late ProgressDialog reservationDialog;
  bool imageBytesLoaded =false;
  late Uint8List bytes;
  var switchBtn = true;
  var deviceDetail=null;
  var paymentStatus=null;
  //final Completer _completerBlueToothConnection = Completer();
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }
  @override
  void initState() {
    letMeIn =true;
    enterNow = false;
    switchBtn = true;
    reservationAmount=0;
    super.initState();
    print("PARKING ****************************");
    print(widget.rsvp_intent);
    if(widget.reservationLength !=null){
      stayLength = listOfHours[widget.reservationLength];
    }

    if (paymentList == null) {
       _getPaymentDetails().then((s) => setState(() {
        paymentList = s;
      }));
    }
    if(widget.reservationDateTime !=null){
      if (widget.fromReservation==1 || widget.fromReservation==2){
        setState((){
          reservationTimeRemaining = widget.reservationDateTime.difference(currentDateTime).inMinutes;
        });
      }
    }
    if (widget.fromReservation == 1) {
      if(reservationTimeRemaining > 15){
        setState(() {
          reservation = 1;
          letMeInBtnText = 'Confirm reservation';
          letMeInBtnIcon = Icons.check;
          letMeIn =false;
        });
      }
    }
    if (widget.fromReservation == 2) {
      setState(() {
        reservation = 2;
        if (reservationTimeRemaining<15){
          letMeInBtnText = 'Let me in';
          cancelReservationButton = 0;
          letMeIn =true;
          switchBtn = false;
        }
        else {
          letMeInBtnText = 'Cancel reservation';
          cancelReservationButton = 1;
          letMeInBtnIcon = Icons.cancel;
          letMeIn =false;
        }
      });
    }
    if(reservation==2 && reservationTimeRemaining < 15 && letMeInBtnText=='Let me in'){
      if(widget.rsvp_intent==null || widget.rsvp_intent =='-NA-'){
        print('inside here----');
        setState(() {
          reserveCheck=false;
          confirmReservationBtn=false;
        });
        if(paymentStatus == null ){
          _getPaymentStatus().then((s) => 
            setState(() {
              paymentStatus = s;
              if (paymentStatus['response_code'] == 200 && paymentStatus['data'] != null) {
                if(paymentStatus['data']['card_updated']==false){
                  reserveCheck=false;
                  confirmReservationBtn=false;
                }else{
                  reserveCheck=true;
                  confirmReservationBtn=true;
                }
              }else{
                reserveCheck=true;
                confirmReservationBtn=true;
              }
            })
          );
        }
      }else{
        setState(() {
          reserveCheck=true;
          confirmReservationBtn=true;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    calculatedAmountForParking = _calculateReservationAmount();
    if(widget.reservationDateTime !=null){
      if(widget.reservationDateTime !=DateTime.parse("2000-01-01")) {
        formattedDate = DateFormat('EEEE MMMM d, y').format(widget.reservationDateTime);
      }
    }
    if (widget.fromSession == 'true') {
      setState(() {
        enterNow = true;
        enterNowText = false;
        letMeIn =false;
      });
    }

  return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async{
        startOrStop(false);
        Navigator.push(context,MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)));
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorConstant.whiteA700,
        appBar: AppBar(
            backgroundColor: const Color(0xffffffff),
            title: Text("Parking Space",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                startOrStop(false);
                Navigator.push(context,MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)));
              }
            ),
        ),
        body: SizedBox(
          width: size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _setHeader(),
                CustomButton(
                  width: 428,
                  text: DateFormat('EEEE, MMMM d, yyyy').format(currentDateTime).toString(),
                  variant: ButtonVariant.FillGrayTwoSide300,
                  shape: ButtonShape.Square,
                  padding: ButtonPadding.PaddingAll11,
                  fontStyle: ButtonFontStyle.UrbanistRomanMedium18),
                CustomButton(
                  width: 428,
                  text: "\$${(double.parse(widget.locationDetails['first_hour'].toString())).toStringAsFixed(2)} up to 1 hour and \$${(double.parse(widget.locationDetails['additional_hour'].toString())).toStringAsFixed(2)} per each additional hour",
                  shape: ButtonShape.Square,
                  padding: ButtonPadding.PaddingAll11,
                  fontStyle: ButtonFontStyle.UrbanistRomanBold14),
                Padding(
                  padding: getPadding(left: 24, top: 20, right: 24),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // For checkbox
                        (letMeIn ==true && reservation !=1  && reservation !=2 ) ? _checkbox() :
                          (enterNow == true || reservation == 1 || reservation == 2) ?
                            (letMeInBtnText=='Confirm reservation' && isFromReservation ==true) ? _checkbox() : Container() : Container(),
                        // For checkbox text
                        (letMeIn ==true && reservation !=1  && reservation !=2 ) ? SizedBox(
                          width: getHorizontalSize(315.00),
                          child: Text("By clicking Let me in, I agree to be charged the Total Cost below. In addition, I agree to be charged the overage cost if I happen to exceed my requested time slot.",
                            maxLines: null,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtUrbanistRomanMedium12.copyWith(letterSpacing: 0.20)
                          )
                        ) : Container(),
                        (enterNow == true || reservation == 1 || reservation == 2) ?
                        (letMeInBtnText=='Confirm reservation' && isFromReservation ==true) ?
                        SizedBox(
                          width: getHorizontalSize(315.00),
                          child: Text("By clicking Confirm reservation, I agree to be charged the Total Cost below. In addition, I agree to be charged the overage cost if I happen to exceed my requested time slot.",
                            maxLines: null,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtUrbanistRomanMedium12.copyWith(letterSpacing: 0.20)
                          )
                        ) : Container() : Container(),
                      ]
                  )
                ),
                setContentBody(),
                _setParkingNumber(),
                _setParkingDetails(),
                _needhelp(),
              ]
            ),
          ),
        ),
      ),
    );
  }
  _checkbox(){
      return Checkbox(
        activeColor: const Color.fromRGBO(47,111,182,1.0),
        checkColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          side: MaterialStateBorderSide.resolveWith(
              (states) => const BorderSide(width: 2, color:Color.fromRGBO(47,111,182,1.0)),
          ),
        value: reserveCheck,
        onChanged: _confirmReservationCheck
      );
  }
  _setHeader() {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.12,
          decoration: BoxDecoration(
            color: ColorConstant.blue800,//const Color(0xff0071bc),
            image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
              image: const AssetImage('assets/directions.png'),
            ),
          ),
        ),
        InkWell(
          onTap: () async{
            var longLat= (widget.sectionDetails['long_lat']!=null) ? widget.sectionDetails['long_lat'] : 0;
            var latitude=(longLat!=0 && longLat['coordinates']!=null) ? longLat['coordinates'][1] : 0;
            var longitude=(longLat!=0 && longLat['coordinates']!=null) ? longLat['coordinates'][0] : 0;
            utils.openMap(latitude,longitude);
          },
          child:Container( 
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.12,
            padding:  EdgeInsets.only(top:(MediaQuery.of(context).size.height> 700)? 35 : 27,),
            child: Column(
              children : [
                  Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (enterNow == true ) ?
                        Text(
                            (enterNowText) ?
                              (letMeInBtnText!='Confirm reservation') ? 'Approach and tap Let me in button \nto lower the device' : ''
                              : 'Your session is active',
                            style: AppStyle.txtUrbanistRomanBold20.copyWith(),textAlign: TextAlign.center
                        )
                        : Text((cancelReservationButton==1) ? 'You\'ll be able to enter your spot within 15 \nminutes of your reservation time' : (letMeInBtnText!='Confirm reservation') ? 'Approach and tap Let me in button \nto lower the device' : '',
                          style: AppStyle.txtUrbanistRomanBold20.copyWith(),textAlign: TextAlign.center),
                    ]
                  ),
                Expanded( 
                  child: cancelReservationButton!=1
                    ? Container(
                      alignment: Alignment.bottomRight,
                      child: const Image(
                        image:AssetImage('assets/directions2.png'),
                        //width:90.0,
                        height:20.0,
                      )
                    )
                    : Container()
                ),
              ]
            ),  
          ),
        ),
      ]
    );
  }
  setContentBody() { 
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: getPadding(left: 20,top: 10,bottom:10, right: 20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              UnconstrainedBox(
                child: SizedBox(
                  height: 40.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        (enterNowText== true) ? 
                        SizedBox(
                          width:(letMeInBtnText ==  'Cancel reservation')?getHorizontalSize(159):(letMeIn == false) ? MediaQuery.of(context).size.width - 40 : (switchBtn==true) ? 150 : MediaQuery.of(context).size.width -40,
                          child:(letMeInBtnText ==  'Cancel reservation')?
                          ElevatedButton.icon(
                            onPressed: () async{
                              var longLat= (widget.sectionDetails['long_lat']!=null) ? widget.sectionDetails['long_lat'] : 0;
                              var latitude=(longLat!=0 && longLat['coordinates']!=null) ? longLat['coordinates'][1] : 0;
                              var longitude=(longLat!=0 && longLat['coordinates']!=null) ? longLat['coordinates'][0] : 0;
                              utils.openMap(latitude,longitude);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: (reserveCheck==true)? const Color.fromRGBO(47,111,182,1.0) :Colors.grey ,
                              shape: const StadiumBorder(),
                            ),
                            icon: Image.asset(
                              'assets/navigate.png', // Replace with your image path
                              height: 23.0, // Adjust height as needed
                              width: 23.0, // Adjust width as needed
                            ),
                            label: Text('Directions',textAlign: TextAlign.center,
                                style: AppStyle.txtUrbanistRomanBold18.copyWith(letterSpacing:0.20)
                            )
                          ):
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor: (reserveCheck==true) ? const Color.fromRGBO(47,111,182,1.0) : Colors.grey ,
                              shape: const StadiumBorder(),
                            ),
                          onPressed:(confirmReservationBtn == false) ? null : ((reservation==1 || reservation==2) && (reservationTimeRemaining > 15) && cancelReservationButton == 0 )
                          ? () async {
                           // print('For Let me in with reservation============');
                            reservationDialog = ProgressDialog(context,
                                message:const Text("Please wait...."),
                                dismissable: false,
                                title: const Text("Loading..."),
                                backgroundColor: Colors.blue.withOpacity(.5)
                            );
                            reservationDialog.show();
                            paymentList= await _getPaymentDetails();
                            if(paymentList != null ){
                              if(paymentList['response_code'] ==404 && reservation ==1){
                                Navigator.push(context,MaterialPageRoute(builder: (context) => CardDetailsPage(widget.accessToken,'Card Details',widget.userDetails,widget.locationDetails,calculatedAmountForParking,paymentList))).then((value) {
                                  _getPaymentDetails().then((s) => setState(() {
                                    paymentList = s;
                                    if (paymentList['response_code'] == 200) {
                                      _callApi(paymentList,reservationDialog);
                                    }else{
                                      reservationDialog.dismiss();
                                    }
                                  }));
                                });
                              }else if (paymentList['response_code'] == 200) {
                                _callApi(paymentList,reservationDialog);
                              }else{
                                reservationDialog.dismiss();
                                //print('here in else part');
                              }
                            } else{
                              reservationDialog.dismiss();
                            }
                          }:(cancelReservationButton == 1)
                            ? () async{
                              //print('Cancel reservation =====');
                              reservationDialog = ProgressDialog(context,
                                message:const Text("Please wait...."),
                                dismissable: false,
                                title: const Text("Loading..."),
                                backgroundColor: Colors.blue.withOpacity(.5)
                              );
                              reservationDialog.show();
                              setState((){
                                reservation = 2;
                              });
                              await _letMeInApiCall('Cancel Reservation',0);
                            } : (enterNow == true) 
                              ? () { //for let me out 
                                //print('for letme out======');
                                    startOrStop(false);
                                    setState(() {
                                      reservation=0;
                                      enterNow = true;                    
                                      if (widget.fromSession == 'true') {
                                        enterNowText = true;
                                      } else {
                                        enterNowText = !enterNowText;
                                      }
                                      if (enterNowText != true) {
                                        _letMeInApiCall('',0);
                                      }
                                      if (enterNowText == true) {
                                       // _sessionEndConfirmation(context);
                                        enterNow = true;
                                        enterNowText = false;
                                        // startOrStop(true);
                                      }
                                    });
                              }
                            : () async{ 
                                //For Let me in without reservation
                                letMeInDialog = ProgressDialog(context,
                                  message:const Text("Please wait...."),
                                  dismissable: false,
                                  title: const Text("Loading..."),
                                  backgroundColor: Colors.blue.withOpacity(.5)
                                );
                                letMeInDialog.show();
                                setState(() {
                                  reservation =0;
                                  enterNow = true;
                                  isFromReservation =false;
                                  enterNowText =true;
                                  // letMeIn=true;
                                });

                                paymentList= await _getPaymentDetails();
                                _afterLetMEINButtonPress(paymentList,letMeInDialog);
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  (enterNow == true )
                                  ? ((enterNowText
                                  ? const Icon(Icons.input_rounded,color: Colors.white, size: 15)
                                  : const Icon(Icons.forward, color: Colors.white, size: 15)))
                                  : Icon(letMeInBtnIcon, color: Colors.white, size: 15),
                                  const SizedBox(width: 10,),
                                  (enterNow == true ) ?
                                  Text((enterNowText) ? 'Let me in' : 'Let me out',
                                    textAlign: TextAlign.center,
                                    style: AppStyle.txtUrbanistRomanBold16.copyWith(letterSpacing:0.20)
                                  ):

                                  Text(letMeInBtnText,textAlign: TextAlign.center,
                                    style: AppStyle.txtUrbanistRomanBold16.copyWith(letterSpacing:0.20)
                                  ),
                                ]
                            ),
                        )
                      ) : Container(),
                      (letMeIn == false) ? const SizedBox(width:0) : (switchBtn==true) ? const SizedBox(width:10) : const SizedBox(width:0),
                      (letMeIn == false) ? Container() : (switchBtn==true) ? SizedBox(
                        width:150,
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor: const Color.fromRGBO(240, 248, 255,1.0)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Icon(Icons.swap_horiz_rounded,color: Color.fromRGBO(47,111,182,1.0), size: 15),
                              const SizedBox(width:5,),
                              Text('Switch space',textAlign: TextAlign.center,style: AppStyle.txtUrbanistRomanBold16Blue800.copyWith(letterSpacing:0.20)),
                            ]
                          ),
                          onPressed: () { 
                            Navigator.push(context,
                             MaterialPageRoute(builder: (context) => PickSpace(widget.firstOddThenEven,widget.locationDetails,widget.sectionDetails,widget.accessToken,
                              widget.userDetails,
                                widget.fromReservation,widget.reservationDateTime,widget.reservationLength)),
                            );
                          },
                        ),
                      ) : Container(),
                      (letMeIn==false && letMeInBtnText!='Cancel reservation' && letMeInBtnText!='Confirm reservation')
                      ? widget.userDetails['isMotorcycle']!=true ? 
                        Text('When you\'re ready to leave,\n just drive off and your session will end.',
                          style: AppStyle.txtUrbanistBlueRomanBold18.copyWith(letterSpacing:0.20),
                          textAlign: TextAlign.center
                        ) : 
                        SizedBox(
                          width:MediaQuery.of(context).size.width - 40,
                         // padding: (switchBtn==false) ? widget.userDetails['isMotorcycle']!=true ? EdgeInsets.only(left:0):EdgeInsets.only(left:0):EdgeInsets.all(0),
                          child: ElevatedButton(
                            style: TextButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: (reserveCheck==true)? const Color.fromRGBO(47,111,182,1.0) : Colors.grey,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(Icons.forward,
                                color: Colors.white, size: 15),
                                const SizedBox(width: 5,),
                                Text('Let me out',textAlign: TextAlign.center,
                                  style: AppStyle.txtUrbanistRomanBold20.copyWith(letterSpacing:0.20))
                              ]
                            ),
                            onPressed: () async {
                              reservationDialog = ProgressDialog(context,
                                message:const Text("Please wait...."),
                                dismissable: false,
                                title: const Text("Loading..."),
                                backgroundColor: Colors.blue.withOpacity(.5)
                              );
                              startOrStop(false);
                              setState(() {
                                  reservation=0;
                                  enterNow = true;                    
                                  if (widget.fromSession == 'true') {
                                    enterNowText = true;
                                  } else {
                                    enterNowText = !enterNowText;
                                  }
                                  if (enterNowText != true) {
                                    _letMeInApiCall('',0);
                                  }
                                  if (enterNowText == true) {
                                    _sessionEndConfirmation(context);
                                    enterNow = true;
                                    enterNowText = false;
                                    startOrStop(true);
                                  }
                              });
                            }
                          ),
                        ) : Container(),
                    ]
                  ),
                  ),
                ),
              //SizedBox(height: 24,),
            ],
        )
      ),
    );
  }
  _setParkingNumber(){
    return Align(
        alignment: Alignment.center,
        child: Container(
            width: double.infinity,
            margin: getMargin(left: 24, top: 20, right: 24),
            decoration: AppDecoration.fillGray50.copyWith(borderRadius:BorderRadiusStyle.roundedBorder12),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (widget.userParkingDetails['level']!=null && widget.userParkingDetails['level']!='') ? Padding(
                      padding: getPadding(left: 119, top: 10, right: 119),
                      child: Text('Floor: ${widget.userParkingDetails['level']}',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtUrbanistRomanBold24Blue800.copyWith())) : Container(),
                  Padding(
                      padding: getPadding(left: 10,top: 10,right: 10,bottom: 14),
                      child: Text('Space: ${widget.userParkingDetails['space_number']}',
                          textAlign: TextAlign.center,
                          style: AppStyle.txtUrbanistRomanBold24Blue800.copyWith()))
                          //style: AppStyle.txtUrbanistRomanMedium18.copyWith(letterSpacing: 0.20)))
                ]))
    );
  }
  _setParkingDetails(){
    String sectionName;
    timerVal = elapsedTime;
    var timeDifference;

    if (widget.fromSession == 'true') {
      var nowTime =DateTime.now().toUtc().toIso8601String();// (DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateTime.parse(widget.userParkingDetails['current_time']).toString(),true)).toLocal().toString();
      if (nowTime.isNotEmpty) {
        var cTime = DateTime.parse(nowTime);
        var inTime =DateTime.parse(widget.userParkingDetails['in_time']); //widget.userParkingDetails['in_time'];
        timeDifference = cTime.difference(inTime);
        int diffInMinutes =timeDifference.inMinutes;
        timerVal= '${(timeDifference.inHours).toString().padLeft(2,"0")}:${(timeDifference.inMinutes % 60).toString().padLeft(2,"0")}:${(timeDifference.inSeconds % 60).toString().padLeft(2, '0')}';
        startOrStop(true);
        if(diffInMinutes != 0){
          if(mounted){
            setState((){
              timerCostVal = diffInMinutes;
            });
          }
        }
      }
      sectionName = widget.userParkingDetails['section'].toString();
    } else {
      sectionName = widget.sectionDetails['section_name'].toString();
    }
    if(widget.reservationLength !=0){
      _calculateReservationAmount();
    }
    var additionalHours = double.parse(widget.locationDetails['additional_hour'].toString());
    return Align(
      alignment: Alignment.center,
      child : Container(
        width: MediaQuery.of(context).size.width,
        margin: getPadding(left: 24, top: 20, right: 24,),
        decoration: AppDecoration.outlineBlack9000c.copyWith(borderRadius:BorderRadiusStyle.roundedBorder16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                padding: getPadding(left: 25, right: 24,top:26),
                child: Row(
                  children: [
                    SizedBox(
                      height:10,
                      width:10,
                      child: CommonImageView(
                        svgPath: ImageConstant.imgCar,
                        height: getVerticalSize(15.00,),
                        width: getHorizontalSize(16.00,),
                      )
                    ),
                    const SizedBox(width:5),
                    Text('Total cost',style:AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20),),
                    const Spacer(),
                    Text("\$$reservationAmount",style: AppStyle.txtUrbanistRomanBold20Gray900.copyWith(letterSpacing: 0.20,),),
                  ],
                )
            ),
            Container(
              margin: getPadding(left: 24,right: 24,top:24),
              height:getVerticalSize(1.00),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: ColorConstant.gray200)
            ),
            (reservation ==1 ||reservation ==2) ?
              Container(
                padding: getPadding(left: 25, right: 25,top:24),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.date_range, color: Colors.grey, size: 15),
                      const SizedBox(width:5),
                      Text(
                        'Reservation Date',
                        style:AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MM/dd/yyyy').format(widget.reservationDateTime).toString(),
                        style: AppStyle.txtUrbanistRomanBold20Gray900.copyWith(letterSpacing: 0.20,),
                      ),
                    ],
                  )
              ) : Container(),
            (reservation ==1 ||reservation ==2)?
            Container(
              padding: getPadding(left: 25, right: 25,top:24),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.watch, color: Colors.grey, size: 15),
                    const SizedBox(width:5),
                    Text(
                      'Reservation Time',
                      style:AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat.jm().format(widget.reservationDateTime).toString(),
                      style: AppStyle.txtUrbanistRomanBold20Gray900.copyWith(letterSpacing: 0.20,),
                    ),
                  ],
                )
              )
                : Container(),
            Container(
                padding: getPadding(left: 25, right: 24,top:24),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.timer,color: Colors.grey, size: 15),
                    const SizedBox(width:5),
                    Text('Duration',style:AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20),),
                    const Spacer(),
                    Text(stayLength,style: AppStyle.txtUrbanistRomanBold20Gray900.copyWith(letterSpacing: 0.20,),),
                  ],
                )
            ),
            Container(
              padding: getPadding(left: 25, right: 24,top:24),
                child: Row(
                  children: <Widget>[
                    Icon((reservation == 1 || reservation==2)? Icons.attach_money : Icons.timelapse,color: Colors.grey, size: 15),
                    const SizedBox(width:5),
                    Text(
                      (reservation == 1 || reservation==2)?'Overage Cost':'Timer',
                      style:AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20),
                    ),
                    const Spacer(),
                    Text(
                      (reservation == 1 || reservation==2)?"\$${additionalHours.toStringAsFixed(2)}/hr":timerVal,
                      style: AppStyle.txtUrbanistRomanBold20Gray900.copyWith(letterSpacing: 0.20,),
                    ),
                  ],
                )),
            Container(
              padding: getPadding(left: 25, right: 24,top:24),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.place,color: Colors.grey, size: 15),
                  const SizedBox(width:5),
                  Text('Location',style:AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20),),
                  const Spacer(),
                  Text(sectionName,style:AppStyle.txtUrbanistRomanBold20Gray900.copyWith(letterSpacing: 0.20,),),
                ],
              )
            ),
            const SizedBox(height:24),
          ]
        ),
      ),
    );
  }
  //TODO:Can be moved to parking_helper files
  _needhelp(){
    String sectionName;
    if (widget.fromSession == 'true') {
      sectionName = widget.userParkingDetails['section'].toString();
    } else {
      sectionName = widget.sectionDetails['section_name'].toString();
    }
    double topmargin=20;
    if(letMeInBtnText=='Cancel reservation' || letMeInBtnText=='Confirm reservation'){
      topmargin=10;
    }
    return
      Align(
      alignment: Alignment.center,
      child : Container(
        //width: getHorizontalSize(159),
        margin: getMargin(left: 24, top: topmargin, right: 24, bottom: 10),
        child:Row(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: getHorizontalSize(159),
                margin: getMargin(right: 15),
                child:ElevatedButton(
                style: TextButton.styleFrom(
                  side: const BorderSide(width: 2.0, color: Color.fromRGBO(47,111,182,1.0),),
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //const Icon(Icons.info,color: Color.fromRGBO(47,111,182,1.0), size: 20),
                    //const SizedBox(width:5),
                    Text('Need help? ',textAlign: TextAlign.center,style:AppStyle.txtUrbanistRomanBold16Blue800.copyWith()),
                  ]
                ),
                onPressed: () async{
                  var name=widget.userDetails['username'];
                  if(widget.userDetails['full_name']!='' && widget.userDetails['full_name']!=null){
                    name=widget.userDetails['full_name'];
                  }
                  var message = name+"\n\n"+sectionName+", "+widget.userParkingDetails['space_number'].toString()+"\n\n"+DateFormat('MM/dd/yyyy').format(widget.reservationDateTime).toString()+" "+DateFormat.jm().format(widget.reservationDateTime).toString();
                  print("message---$message");
                  _launchSMS('8052163303',message);
                  // if(kIsWeb){
                  //   Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => SupportPage(widget.accessToken,widget.userDetails)),
                  //   );
                  // }else{
                  //   List conversationList=[];
                  //   conversationList=await twilioChatConversationPlugin.getConversations() ?? [];
                  //   if(conversationList.isEmpty || widget.userDetails['is_twilio_admin']==true){
                  //     Navigator.push(context,
                  //       MaterialPageRoute(builder: (context) =>
                  //         ConversationListScreen(
                  //           //conversationList: conversationList,
                  //           userDetails: widget.userDetails,
                  //           accessToken:widget.accessToken,
                  //           is_twilio_admin:widget.userDetails['is_twilio_admin']
                  //         )
                  //       ),
                  //     );
                  //   }else{
                  //     String result = await twilioChatConversationPlugin.joinConversation(conversationId: conversationList[0]['sid']) ?? "UnImplemented Error";
                  //     if(result!=conversationList[0]['sid']){
                  //       utils.toast('Having some error to join converstion.');
                  //     }else{
                  //        Navigator.push( context,
                  //         MaterialPageRoute(builder: (context) =>
                  //           ChatDetailsScreen(
                  //             conversationName: conversationList[0]['conversationName'],
                  //             conversationSid: result,
                  //             author:conversationList[0]['createdBy'],
                  //             userDetails: widget.userDetails,
                  //             messageInit: true,
                  //             isDirect: true,
                  //             accessToken: widget.accessToken
                  //           )
                  //         ),
                  //       );
                  //     }
                  //   }
                  // }
               },
            )
            ),
            (cancelReservationButton==1)?Expanded(
                child:
                Container(
                  width: getHorizontalSize(159),
                  child:
                  ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(47,111,182,1.0) ,
                      shape: const StadiumBorder(),
                    ),
                    onPressed:() async{
                      //print('Cancel reservation =====');
                      reservationDialog = ProgressDialog(context,
                          message:const Text("Please wait...."),
                          dismissable: false,
                          title: const Text("Loading..."),
                          backgroundColor: Colors.blue.withOpacity(.5)
                      );
                      reservationDialog.show();
                      setState((){
                        reservation = 2;
                      });
                      await _letMeInApiCall('Cancel Reservation',0);

                    },
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(letMeInBtnIcon, color: Colors.white, size: 15),
                          const SizedBox(width: 10,),
                          Text(letMeInBtnText,textAlign: TextAlign.center,
                              style: AppStyle.txtUrbanistRomanBold16.copyWith(letterSpacing:0.20)
                          ),
                        ]
                    ),
                  )
              )
            ):Container()

      ]),
    )
    );
  }

  void _launchSMS(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{
        'body': message,
      },
    );
   // if (await canLaunch(smsUri.toString())) {
      await launch(smsUri.toString());
    // } else {
    //   utils.toast('Could not launch $smsUri');
    // }
  }
 
  _callBluetoothPage(letMeInDialog,type) async{
      int resfromblue;
      var parkingRes;
      resfromblue=-1 ;///await _connectAndInitiateBluetooth('Unlock');
      parkingRes= await _letMeInApiCall('',resfromblue);
      if(type=='reserve'){
        reservationDialog.dismiss();
      }else{
        if(parkingRes !=null){
          if(parkingRes['data']['response_code'] ==200){
            startOrStop(true);
            setState(() {
              letMeIn =false;
              enterNowText =false;
            });
          }else if(parkingRes['data']['response_code'] ==500 ){
            if(widget.fromReservation==2){
              setState(() {
                reservation=2;
                letMeInBtnText = 'Let me in';
                letMeIn= false;
                utils.longToast('Your Payment failed.Please try again later!');
              });
            }else{
              setState(() {
                letMeInBtnText = 'Let me in';
                enterNow= false;
                utils.longToast('Your Payment failed.Please try again later!');
              });
            }
          }
        }
        letMeInDialog.dismiss();
      }
    }

  _getPaymentStatus() async {
    var queryParams ='?rsvp_id=${widget.reservationId}&user_id=${widget.userDetails['user_id'].toString()}';
    print('queryParams-------------------');
    print(queryParams);
    var response = await apiHelper.get(context,'get_payment_status', widget.accessToken, queryParams);
    print('_getPaymentStatus response------------------');
    print(response);
    return response;
  }
  _getDeviceDetails( imei,accessToken) async {
    var queryParams ='/$imei';
    var response = await apiHelper.get(context,'get_device', widget.accessToken, queryParams);
    if (!response.isEmpty) {
      if(response['response_code']==200){
        return response;
      }else{
        return null;
      }
    } else {
      return null;
    }
  }
  _afterLetMEINButtonPress(paymentList,letMeInDialog) async{
    if(paymentList !=null){
      if (letMeInBtnText =="Let me in" && paymentList['response_code'] == 200 && paymentList['data']['customer_id'] != null  && (paymentList['data']['customer_id'] != '')) {
        if(paymentList['data']['payment_method_id']=='gpay_apay' || paymentList['data']['is_selected']==false){
          _callCardPage(letMeInDialog);
        }else{
          //print('bluetooth step 2');
          _callBluetoothPage(letMeInDialog,'');
        } 
      } else{
        setState(() {
          letMeInBtnText = 'Let me in';
          enterNow= false;
        });
        _callCardPage(letMeInDialog);
      }
    }else{
      setState(() {
          letMeInBtnText = 'Let me in';
          enterNow= false;
        });
      _callCardPage(letMeInDialog);
    }
  }
  _callApi(paymentList,reservationDialog) async{
    if((reservation==1 || reservation==2) && (reservationTimeRemaining > 15) && cancelReservationButton == 0){ 
      if((paymentList['data']['payment_method_id']=='gpay_apay' || paymentList['data']['is_selected']==false)){
        Navigator.push(context,MaterialPageRoute(builder: (context) => CardDetailsPage(widget.accessToken,'Card Details',
          widget.userDetails,widget.locationDetails,calculatedAmountForParking,paymentList))).then((value) {
          _getPaymentDetails().then((s) => setState(() async{
            paymentList = s;
            if (paymentList['response_code'] == 200) {
              if(paymentList['data']['is_selected'] ==true){
               // print('bluetooth step 3');
                _callBluetoothPage(reservationDialog,'reserve'); 
              }else{
                reservationDialog.dismiss();
                _renderParkingDetailsPage();
              }         
            }
          }));
        });                       
      }else{
        if((paymentList['data']['customer_id'] != null) && (paymentList['data']['customer_id'] != '') && paymentList['data']['payment_method_id']!='gpay_apay'){
         await _letMeInApiCall('',0);
         reservationDialog.dismiss();
        }
      }                                   
    }else{
      reservationDialog.dismiss();
    }
  }
  _letMeInApiCall(clickBtnStatus,int blueLock) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var amount =_calculateReservationAmount();
    amountTopost =num.parse(amount);
    length=  widget.reservationLength;
    var inTime = DateTime.now().toUtc().toIso8601String();
    String reservationDate ="";
    if(widget.reservationDateTime!=null && reservation !=0){
      if(!widget.reservationDateTime.isUtc) {
        reservationDate =widget.reservationDateTime.toUtc().toIso8601String();
        if (reservation == 1 || clickBtnStatus !='' ) {
          inTime = reservationDate;
        }
        else{
          inTime = DateTime.now().toUtc().toIso8601String();
        }
      }
      else{
        reservationDate = widget.reservationDateTime.toIso8601String();
        inTime=reservationDate;
      }
    }

    if(reservation == 1 || reservation == 2 || reservationTimeRemaining >15){
      var resp=await _apiToSaveReservationData(null);
      print('_apiToSaveReservationData results------------------------');
      print(resp);
      reservationDialog.dismiss();
      Future.delayed(const Duration(milliseconds: 3000), () async{
        if(resp['response_code']==401){
          await prefs.clear();
          utils.longToast(resp['message']);         
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => true,
          );
        }
        if(resp['response_code']==500 && resp['type']=='payment'){ print('inside here-------------');
          //letMeInDialog.dismiss();
          _paymentFailedPopUp(context,resp['message']);
        }
        if(clickBtnStatus=='Cancel Reservation'){
          Navigator.push(context,MaterialPageRoute(builder: (context) =>LocationsPage(widget.accessToken, widget.userDetails)),);
        }
      });
    }

    var formData = <String, dynamic>{};
    formData['block'] = (reservation == 1 || clickBtnStatus !='')?'10':'0';
    formData['command'] = (reservation == 1 || clickBtnStatus !='')?'ReserveSpaceApiCall':'OperationRequestCommandR0';
    formData['imei'] =widget.userIMEI.toString();
    formData['user_id'] = widget.userDetails['user_id'];
    formData['valid_time'] = '30';
    formData['cost'] = "0";
    formData['time'] = '0';
    formData['running_late'] = '0';
    formData['section_id'] = widget.sectionDetails['section_id'];
    formData['space_id'] = widget.spaceId.toString();
    formData['level_id'] = widget.userParkingDetails['level_id'].toString();
    formData['space_number'] =widget.userParkingDetails['space_number'].toString();
    formData['in_time'] = inTime;
    formData['out_time'] = '';
    formData['username'] = widget.userDetails['username'];
    formData['location_id'] = widget.sectionDetails['location_id'];
    formData['reservation_date'] = reservationDate;
    formData['stay_length'] = widget.reservationLength;
    formData['prepaid_amount'] = (widget.fromReservation == 2 || (widget.fromReservation == 1 && reservationTimeRemaining >15))? 0 : amount;
    if(reservationIdRename !=0){
      formData['reserve_id'] = reservationIdRename;
    }
    if(widget.reservationId !=0){
      formData['reserve_id'] = widget.reservationId;
    }
    if(clickBtnStatus!='' && (reservation == 1 || reservation == 2)){
      formData['status'] = clickBtnStatus;
    }else if((reservation == 1 || reservation == 2) && (reservationTimeRemaining>15)){
      formData['status'] = 'Reserved';
    }else{
      formData['status'] = 'Parked';
    }
    formData['isBlueLock'] = (blueLock==-1) ? 'false' : 'true';
    
    if(widget.sectionDetails['business_id']!=null){
      formData['business_id'] = widget.sectionDetails['business_id'];
    }
    var jsonResponse =await  apiHelper.post(context,'post_parking_details',widget.accessToken,formData,null);
    if (formData['status'] == 'Parked'){
      if(reservation==1 || reservation ==2){
        _apiToSaveReservationData(formData['status']);
      }
      if (!jsonResponse.isEmpty) {
        if(jsonResponse['response_code']==401){
          utils.longToast(jsonResponse['message']);
          await prefs.clear();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
        if(jsonResponse['response_code']==500 && jsonResponse['type']=='payment'){
          letMeInDialog.dismiss();
          _paymentFailedPopUp(context,jsonResponse['message']);
        }
        if((jsonResponse['response_code'] == 500 && jsonResponse['type']!='payment') || jsonResponse['response_code'] ==504){
          setState(() {
            letMeInBtnText = 'Let me in';
            enterNow= false;
          });
          utils.toast("Payment failed ${jsonResponse['error']}");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentsPage(widget.accessToken,widget.userDetails,false)),
          );
        }
        if(jsonResponse['response_code'] ==404){
          setState(() {
            letMeInBtnText = 'Let me in';
            enterNow= false;
          });
          utils.toast(jsonResponse['message']);
          return null;
        }

        prefs.setBool("isSessionActive", true);
        utils.parkingDetailId = jsonResponse['data']['parking_detail_id'];
        prefs.setString('parking_detail_id',json.encode(jsonResponse['data']['data']['parking_detail_id']));
        return jsonResponse;
      }
      else if (jsonResponse.isEmpty) {
        return false;
      } else {
        utils.toast(jsonResponse['message']);
        return false;
      }
    }
  }
  //TODO:Can be moved to parking_helper files
  updateTime(Timer timer) {
    if (watch.isRunning) {
      if(mounted){
        setState(() {
          elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
        });
      }
    }
  }
  //show timer on enter now click
  startOrStop(startStop) {
    if (startStop) {
      startWatch(startStop);
    } else {
      stopWatch();
    }
  }
  startWatch(startStop) {
    setState(() {
      startStop = startStop;
      watch.start();
      timer = Timer.periodic(const Duration(seconds: 1), updateTime) ;
    });
  }
  stopWatch() {
    setState(() {
      startStop = true;
      watch.stop();
      setTime();
    });
  }
  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;//watch.elapsed.inSeconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
  }
  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    String hoursStr =(hours < 10) ? '0$hours' : hours.toString();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$hoursStr:$minutesStr:$secondsStr";
  }

  void _confirmReservationCheck(bool? newValue) => setState(() {
    reserveCheck = newValue!;
    if (reserveCheck) {
      setState(()=>
        confirmReservationBtn = true
      );
    } else {
      setState(()=>
        confirmReservationBtn = false
      );
    }
  });
  _calculateReservationAmount() {
    var finalAmount;
    var alreadyPaidAmount;
    num paidAmount;

    if(widget.reservationLength !=0){
      var firstHour = double.parse(widget.locationDetails['first_hour'].toString());
      var additionalHours =double.parse(widget.locationDetails['additional_hour'].toString());
      double hours;
      double timerHours;
      int totaltimerVal =0;
      int timeDiff;
      if(timerCostVal !=0 ){
        setState((){
          totaltimerVal = timerCostVal ;
        });
      }
      String reservationLength = widget.reservationLength;
      List<String> hourMin = reservationLength.split(":");
      int hour = int.parse(hourMin[0]);
      int mins = int.parse(hourMin[1]);
      int hoursInMins = hour * 60;
      int total = hoursInMins + mins;
      int totalAdditionalHour;
      int totalTimerAdditionalHour=0;
      double totalCost;
      if(total > 60){
        int additionalHour = total-60;
        if(additionalHour <= 60){
          totalAdditionalHour = 1;
        }
        else{
          hours =additionalHour/60;
          var roundUpadditionalHours =hours.ceil();
          totalAdditionalHour =roundUpadditionalHours.toInt();
        }
        totalCost =(totalAdditionalHour*additionalHours)+firstHour;
        finalAmount = totalCost.toStringAsFixed(2);//totalCost.toString();
        setState(() {
          alreadyPaidAmount = finalAmount;
        });
      }
      else if(totaltimerVal !=0 && totaltimerVal > total){
        timeDiff =totaltimerVal-total;
        if(timeDiff > 60){
          int additionalTimerHour = timeDiff-60;
          if(additionalTimerHour <= 60){
            totalTimerAdditionalHour = 1;
          }
          else{
            timerHours =additionalTimerHour/60;
            var roundUpTimerHours =timerHours.ceil();
            totalTimerAdditionalHour =roundUpTimerHours.toInt();
          }
          if(widget.paidAmount !=0){
            paidAmount =num.parse(widget.paidAmount.toString());//double.parse(widget.paidAmount);
          }
          else{
            paidAmount =alreadyPaidAmount;
          }
          totalCost =totalTimerAdditionalHour*additionalHours+firstHour+paidAmount;
          finalAmount = totalCost.toStringAsFixed(2);
        }
        else{
          if(widget.paidAmount != 0){
            paidAmount =num.parse(widget.paidAmount.toString());//double.parse(widget.paidAmount);
          }
          else{
            paidAmount =alreadyPaidAmount;
          }
          totalCost =additionalHours+paidAmount;
          finalAmount =totalCost.toStringAsFixed(2) ;
        }

      }
      else {
        finalAmount = firstHour.toStringAsFixed(2);
      }
      if(finalAmount != null){
        setState(() {
          reservationAmount = finalAmount.toString();
        });
      }
    }
    return finalAmount;
  }
  _apiToSaveReservationData(status) async {
    var reservationToastMsg = "Space has been reserved";
    if(cancelReservationButton ==1){
      reservationToastMsg ='Reservation has been cancelled';
    }
    var amount = _calculateReservationAmount();
    var date;
    var enddateTime;
    var time;
    var toDate;
    if(widget.reservationDateTime!=null){
      enddateTime =widget.reservationDateTime;
      if(reservation==1){
        List<String> hourMin = widget.reservationLength.split(":");
        int hour = int.parse(hourMin[0]);
        int mins = int.parse(hourMin[1]);
        toDate = enddateTime.add(Duration(hours: hour, minutes:mins));
        if(!toDate.isUtc) {
          toDate =toDate.toUtc().toIso8601String();
        }
        else{
          toDate = toDate.toIso8601String();
        }
      }
      if(!widget.reservationDateTime.isUtc) {
        date =widget.reservationDateTime.toUtc().toIso8601String();
        time=date;
      }
      else{
        date = widget.reservationDateTime.toIso8601String();
        time=date;
      }
    }
    var reservationsData = <String, dynamic>{};
    reservationsData['date'] = date;
    reservationsData['time'] = time;
    reservationsData['length'] = widget.reservationLength;

    if(reservation==1){
      reservationsData['toDate'] = toDate;
      reservationsData['fromDate'] = date;
      reservationsData['amount'] = amount;

    }
    if(status=='Parked'){
      reservationsData['status'] = false;
    }
    else{
      reservationsData['status'] = (widget.reservationId==0)?1:0;
    }
    reservationsData['user_id'] = widget.userDetails['user_id'];
    reservationsData['section_id'] = widget.sectionDetails['section_id'];
    reservationsData['space_id'] = widget.spaceId;
    reservationsData['level_id'] = widget.userParkingDetails['level_id'].toString();
    reservationsData['location_id'] = widget.locationDetails['location_id'];
    if(widget.reservationId >0){
      reservationsData['reserve_id'] = widget.reservationId;
    }
    if(reservationIdRename >0){
      reservationsData['reserve_id'] = reservationIdRename;
      if(reservation ==2){
        reservationsData['status'] =0;
      }
    }
    if(widget.sectionDetails['business_id']!=null){
      reservationsData['business_id'] = widget.sectionDetails['business_id'];
    }
    var jsonResponse =await  apiHelper.post(context,'post_reservations',widget.accessToken,reservationsData,'');
    print('rsvp results------');
    print(jsonResponse);
    if(!jsonResponse.isEmpty){
      if(jsonResponse['response_code']==200){
        utils.toast(reservationToastMsg);
        setState((){
          cancelReservationButton = 1;
          letMeInBtnText = 'Cancel reservation';
          letMeInBtnIcon = Icons.cancel;
          reservationIdRename = jsonResponse['reserve_id'];
          // letMeIn=true;
        });
      }else if(jsonResponse['response_code']==500 && jsonResponse['type']=='payment'){

      }else{
        utils.toast('Some error occurred while saving reservation!');
      }
      return jsonResponse;    
    }
  }

  //TODO:Can be moved to parking_helper files
  _callCardPage(letMeInDialog) async {
    Navigator.push(context,MaterialPageRoute(builder:(context) =>
      CardDetailsPage(widget.accessToken,'Card Details',widget.userDetails,widget.locationDetails,calculatedAmountForParking,paymentList))).then((s) => setState(() async{
        paymentList= await _getPaymentDetails();
        if(paymentList['response_code'] == 200 && (paymentList['data']['customer_id'] != null  && paymentList['data']['customer_id'] != '')){
          if((paymentList['data']['is_selected'] ==true)){
            //print('bluetooth step 1');
            _callBluetoothPage(letMeInDialog,'');
          }else{
            letMeInDialog.dismiss();
             _renderParkingDetailsPage();
          }
        }else{
          letMeInDialog.dismiss();
          _renderParkingDetailsPage();
        }
    }) );
  }
  _getPaymentDetails() async {
    var queryParams ='?user_id=${widget.userDetails['user_id']}';
    var response =await apiHelper.get(context,'get_payment',widget.accessToken,queryParams);
    if (!response.isEmpty) {
      return response;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("letMeInText", "Let me in");
    }
  }
  _getAmount() async{
    paymentList ??= await _getPaymentDetails();

    if(paymentList !=null){
      if (paymentList['response_code'] == 404) {
        showDialog(
            context: context,
            builder: (context) => Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0,bottom:250,top:100),
                child:AlertDialog(
                  title: const Text("Add Payment Details",style:TextStyle(fontSize: 15.0)),
                  content: CardDetailsPage(
                      widget.accessToken, 'Card Details', widget.userDetails,widget.locationDetails,calculatedAmountForParking,paymentList),
                ))).then((value) {
          _getPaymentDetails().then((s) =>
            setState(() {
              paymentList = s;
            }
          ));
        });
      }
      if(paymentList['response_code'] == 200) {
        var calculatedAmount = _calculateReservationAmount();
        final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
        var parkingDetailId = sharedPrefs.getString('parking_detail_id');
        if (parkingDetailId == null) {
          parkingDetailId = utils.parkingDetailId;
          parkingDetailId ??= widget.userParkingDetails['parking_detail_id'];
        }
        String queryParams;
        amountTopost = num.parse(widget.paidAmount.toString());
        if (amountTopost == 0) {
          amountTopost =
              num.parse(calculatedAmount); //num.parse(reservationAmount);
        }
        length = widget.reservationLength;
        queryParams = '?screen_type=payment_amount&username=${widget.userDetails['username']}&stay_length=${length.toString()}&prepaid_amount=${amountTopost.toString()}&parking_detail_id=${parkingDetailId.toString()}&fromdash=1';
        num amount = 0;
        var amountDetails =await  apiHelper.get(context,'get_data',widget.accessToken,queryParams);
        if (!amountDetails.isEmpty) {
          if (amountDetails['response_code'] == 200 && amountDetails['data'] != null) {
            if (amountDetails['data']['amount'] != 0) {
              amount =
              (num.parse(amountDetails['data']['amount']) + amountTopost);
            }
            if (amountDetails['data']['amount'] == 0) {
              amount = amountTopost;
            }
            amountDetails['data']['amount'] = amount;
            if ((paymentList['response_code'] == 200) && (paymentList['data']['customer_id'] != null) && (paymentList['data']['customer_id'] != ''))  {
              // await _getDeviceDetails(widget.userIMEI,widget.accessToken).then((s) => setState(() {
              //   deviceDetail = s;
              // }));

              int resfromblue=-1 ;//await _connectAndInitiateBluetooth('Lock');
              reservationDialog.dismiss();
              await _letMeOutCall(amount,resfromblue);

              return await showDialog<void>(
                context: context,
                barrierDismissible:false,
                builder: (BuildContext context) {
                  return AlertWrapper(
                      amountDetails, widget.accessToken, widget.userDetails);
                },
              );
              //}));
            }
          } if (amountDetails['response_code'] == 500) {
            utils.toast("Payment failed");
          }
          else {
          }
        }
      }
    }
  }

  _letMeOutCall(num amount,int blueLock) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    var parkingDetailId = sharedPrefs.getString('parking_detail_id');
    if (parkingDetailId == null) {
      parkingDetailId = utils.parkingDetailId;
      parkingDetailId ??= widget.userParkingDetails['parking_detail_id'];
    }
    var queryP='/$parkingDetailId';
    var parkingDetails =await  apiHelper.get(context,'get_parking-details',widget.accessToken,queryP);
    double finalAmount;
    finalAmount = amount / 100;
    if (parkingDetails['response_code'] == 200) {
      var formData = <String, dynamic>{};
      formData['block'] = '1';
      formData['command'] = 'OperationRequestCommandR0';
      formData['imei'] =widget.userIMEI.toString();
      formData['user_id'] = widget.userDetails['user_id'].toString();
      formData['valid_time'] = '30';
      formData['cost'] = finalAmount.toString(); //amountDetails['data']['amount'];
      formData['time'] =timerVal.toString();// elapsedTime.toString();
      formData['running_late'] = '0';
      formData['section_id'] = widget.sectionDetails['section_id'].toString();
      formData['space_id'] = widget.spaceId.toString();
      formData['level_id'] = widget.userParkingDetails['level_id'].toString();
      formData['space_number'] = widget.userParkingDetails['space_number'].toString();
      formData['in_time'] = parkingDetails['data']['in_time'];
      formData['out_time'] = _formatDateTime(DateTime.now());
      formData['username'] = widget.userDetails['username'];
      formData['location_id'] = widget.sectionDetails['location_id'].toString();
      formData['status'] = 'Completed';
      formData['parking_detail_id'] = parkingDetails['data']['parking_detail_id'].toString();
      formData['fromDash']='1';
      formData['isBlueLock']=(blueLock==-1) ? 'false' : 'true';
      await  apiHelper.post(context,'post_parking_details',widget.accessToken, formData,'');
      return true;
    } else {
      utils.toast(parkingDetails['message']);
    }
  }
  Future<ConfirmAction> _sessionEndConfirmation(BuildContext context) async {
      startOrStop(true);
      bool? dialogDisplayed =true;
      return await showDialog<ConfirmAction>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(getHorizontalSize(24.50,),)),
            title : Column(
              children:[
                Padding(
                  padding: getPadding(top: 2,),
                  child: Text("Are you sure you'd like to end your parking session?",textAlign:TextAlign.center,style: AppStyle.txtUrbanistRomanBold24.copyWith())
                ),
                Container(
                 height:getVerticalSize(1.00),
                 width: 333,
                 margin: getMargin(left: 20,right: 20,top:34),
                 decoration: BoxDecoration(color: ColorConstant.gray200)
                ),
              ]
            ),
            actions: <Widget>[
              CustomButton(
                width: 316,
                text: "Accept",
                onTap : () async {
                  reservationDialog = ProgressDialog(context,
                      message:const Text("Please wait...."),
                      dismissable: false,
                      title: const Text("Loading..."),
                      backgroundColor: Colors.blue.withOpacity(.5)
                  );
                  reservationDialog.show();
                  dialogDisplayed =false;
                  await _getAmount();
                  Navigator.of(context).pop(ConfirmAction.ACCEPT);
                  startOrStop(false);
                },
                margin: getMargin(left: 32,top: 5,right: 32)),
              CustomButton(
                  width: 316,
                  text: "Cancel",
                  margin: getMargin(left: 32,top: 12,right: 32,bottom: 27),
                  variant: ButtonVariant.FillBlue50,
                  fontStyle: ButtonFontStyle.UrbanistRomanBold16Blue800,
                  onTap: () async {
                    //startOrStop(true);
                    dialogDisplayed =true;
                    Navigator.of(context).pop(ConfirmAction.CANCEL);
                  },
              )
            ],
          );
        }
      ).then((value) => startOrStop(dialogDisplayed) );
  }
  _paymentFailedPopUp(BuildContext context,message) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(getHorizontalSize(24.50,),)),
        title : Column(
          children:[
            Padding(
              padding: getPadding(top: 2,),
              child: Text(message,textAlign:TextAlign.center,style: AppStyle.txtUrbanistRomanBold24.copyWith())
            ),
          ]
        ),
        actions: <Widget>[
          CustomButton(
            width: 316,
            text: "Update Payment",
            onTap : () async {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => PaymentsPage(widget.accessToken,widget.userDetails,false)),
              );
            },
            margin: getMargin(left: 32,top: 5,right: 32)),
            CustomButton(
                width: 316,
                text: "Cancel",
                margin: getMargin(left: 32,top: 12,right: 32,bottom: 27),
                variant: ButtonVariant.FillBlue50,
                fontStyle: ButtonFontStyle.UrbanistRomanBold16Blue800,
                onTap: () async {
                  _renderParkingDetailsPage();
                },
            )
        ],
      ),
    );
  }
  _renderParkingDetailsPage()async{
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>ParkingPage(widget.accessToken,widget.locationDetails,widget.sectionDetails,widget.userParkingDetails,widget.userIMEI,
            widget.userDetails,widget.spaceId,widget.fromSession,widget.fromReservation,widget.reservationDateTime,widget.reservationId,
            widget.reservationLength,widget.paidAmount,widget.firstOddThenEven)
      )
    );
  }
}
class AlertWrapper extends StatefulWidget {
  final amountDetails;
  final accessToken;
  final userDetails;
  const AlertWrapper(this.amountDetails,this.accessToken,this.userDetails, {Key? key}) : super(key: key);


  @override
  _AlertWrapperState createState() => _AlertWrapperState();
}
class _AlertWrapperState extends State<AlertWrapper> {
  int _count = 60;//15;
  @override
  void initState() {
    super.initState();
    startCountDown();
  }
  void startCountDown() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(
      oneSec,
          (Timer countDown) => setState(
            () {
          if (_count < 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)),
            );
            countDown.cancel();
          }
          else {
            _count = _count - 1;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String res;
    res=widget.amountDetails['data']['total_time_spend'];
    var hourSpent=  res.split(":");
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async => false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(getHorizontalSize(24.50,),)),
        title : Column(
          children:[
            Padding(
              padding: getPadding(top: 14,),
              child: Text("Thank you.",textAlign:TextAlign.center,style: AppStyle.txtUrbanistRomanBold24.copyWith())
            ),
            Container(
             height:getVerticalSize(1.00),
             width: 333,
             margin: getMargin(left: 20,right: 20,top:24),
             decoration: BoxDecoration(color: ColorConstant.gray200)
            ),
          ]
        ),
        contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 25, bottom: 25),
        content: SizedBox(
          width: 330.0,
          //height: 200.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: getPadding(left: 32,top: 0, right: 32),
                        child: Text("Your session has ended. Please vacate within $_count seconds.",
                            textAlign:TextAlign.center,
                            style: AppStyle.txtUrbanistRomanBold22Gray900.copyWith())),
                    Container(
                        height:
                            getVerticalSize(1.00),
                        width: getHorizontalSize(
                            316.00),
                        margin: getMargin(
                            left: 32,
                            top: 28,
                            right: 32),
                        decoration: BoxDecoration(
                            color: ColorConstant
                                .gray200)),
                    Padding(
                        padding: getPadding(left: 32,top: 28,right: 32),
                        child: Text(
                            "Your total spend is",
                            //overflow: TextOverflow.ellipsis,
                            textAlign:TextAlign.center,
                            style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20))),
                    Padding(
                        padding: getPadding(left: 32,top: 4,right: 32),
                        child: Text("\$ " + widget.amountDetails['data']['amount'].toStringAsFixed(2),
                            overflow: TextOverflow
                                .ellipsis,
                            textAlign:
                                TextAlign.left,
                            style: AppStyle
                                .txtUrbanistRomanBold22Gray900
                                .copyWith())),
                    Padding(
                        padding: getPadding(left: 32,top: 21,right: 32),
                        child: Text(
                            "Time spent",
                            //overflow: TextOverflow.ellipsis,
                            textAlign:TextAlign.center,
                            style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20))),
                    Padding(
                        padding: getPadding(left: 32,top: 5,right: 32,bottom:15),
                        child: Text(int.parse(hourSpent[0]) < 1
                          ? 'Less than 1 hour'
                          : widget.amountDetails['data']
                      ['total_time_spend']
                          .toString() +
                          ' hours',
                           // overflow: TextOverflow .ellipsis,
                            textAlign:
                                TextAlign.center,
                            style: AppStyle.txtUrbanistRomanBold22Gray900.copyWith())),
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
