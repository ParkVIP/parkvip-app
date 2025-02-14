import 'dart:convert';
import 'package:flutter/material.dart';
import '../helper/utils.dart';
import '../pages/parking.dart';
import 'dart:typed_data';
import '../helper/api_base_helper.dart';
import 'locations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ndialog/ndialog.dart';
import 'dart:async';
import '../pages/reservation_dialog.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'login.dart';
import '../model/BusinessDownItems.dart';
import '../pages/sections.dart';
import 'package:dropdown_search/dropdown_search.dart';

class BusinessPage extends StatefulWidget {
  final locationDetails;
  final accessToken;
  final userDetails;
  final datetimeSelected;
  final cancelReservation;
  final reservationDate;
  final reservationTime;
  final reservationLength;

  const BusinessPage(this.accessToken,this.locationDetails,this.userDetails,this.datetimeSelected,this.cancelReservation,this.reservationDate,this.reservationTime,this.reservationLength, {Key? key}) : super(key: key);

  @override
  _BusinessPageState createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final apiHelper = ApiBaseHelper();
  var utils = Utils();
  var appBarLogoDimension = {'height':50.0,'width':40.0};
  var _setList;
  var _sectionList;
  var _favouriteIconColor;
  var locationsOnUpdate;
  String reservationTime ="";
  String reservationDate ="";
  var cancelReservation = 0;
  bool lengthOfStay=false;
  late ProgressDialog sectionPageDialog;
  var _getReservationListData;
  late Timer timer;
  late TimeOfDay selectedTime;
  String futureValSelected ="";
  String dropItem="0";
  var selectedsection="Select Business";
  final List<BusinessDownItems> _items =  <BusinessDownItems>[];
  var locImage = 0;
  late Uint8List bytes;

  @override
  void initState() {
    super.initState();
    if(_setList == null){
      _getBusinessList().then(
        (s) => setState(() {_setList = s;})
      );
    }
    lengthOfStay=false;
    if (reservationDate.isNotEmpty || reservationTime.isNotEmpty){
      setState(() {
        lengthOfStay=true;
      });
    }
    if(_getReservationListData == null){
      _getReservationList().then(
              (s) => setState(() {
            timer = Timer.periodic(const Duration(seconds: 30), (Timer t) =>_getReservationList());
            _getReservationListData = s;})
      );
    }
  }

  @override
  Widget build(BuildContext context){
    _favouriteIconColor ??= (widget.locationDetails['fav_locations']==1)?true:false;

    var listItems = _setList;
    if(listItems != null && _items.isEmpty ) { //
      for (var item in listItems['data']) {
        _items.add(BusinessDownItems(item));
      }
    }


    return  Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        title: Text("Locations",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.star_border,
              color: (_favouriteIconColor) ? const Color(0xffffcc00): Colors.black,
            ),
            onPressed: () {
              setState(()
              {
                if(_favouriteIconColor== true){
                  _favouriteIconColor= false;
                }else{
                  _favouriteIconColor= true;
                }
                _favouriteIconClicked(_favouriteIconColor);
                //need to call api here
              });
            },
          )
        ],
      ),

      body: PopScope(
        canPop: true,
        onPopInvoked : (didPop) async{
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)),
          );
        },
        child:SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _setHeader(),
                Container(
                  height: MediaQuery.of(context).size.height/ 1.5 ,
                  color:Colors.white,
                  child: Column(
                    children: <Widget>[
                      (listItems==null && listItems =='') ?
                      Container(
                        padding: getPadding(left: 24, top: 27, right: 24),
                        alignment: Alignment.topCenter,
                        child: Column(
                            children:[
                              Text('No business available',style:AppStyle.txtUrbanistSemiBold18.copyWith()),
                            ]
                        ),
                      ) : Container(
                          margin: getMargin(left: 24, top: 27, right: 24),
                          alignment: Alignment.center,
                          child: Column(
                              children:[
                                Container(
                                  margin: getMargin(bottom: 10),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children:[
                                        Text(widget.locationDetails['location_name'],
                                          style:AppStyle.txtUrbanistRomanBoldBlack32.copyWith(letterSpacing:0.20),textAlign: TextAlign.center),
                                      ]
                                  ),
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children:[
                                      Text("Pick a business:",overflow: TextOverflow.ellipsis,textAlign: TextAlign.left,
                                          style: AppStyle.txtUrbanistRomanBold22Gray900.copyWith(letterSpacing: 0.20))
                                    ]
                                ),
                              ]
                          )
                      ),
                      if (listItems==null) Container(
                          padding:const EdgeInsets.all(27),
                          alignment: Alignment.center,
                          child:Text('Loading...',style: AppStyle.txtUrbanistSemiBold20.copyWith())
                      ) else Container(
                          height: MediaQuery.of(context).size.height* 0.15,
                          alignment: Alignment.topCenter,
                          margin: getMargin(left: 24,top: 10,right: 24,bottom: 10),
                          decoration: AppDecoration.outlineBlack9000c.copyWith(borderRadius: BorderRadiusStyle.roundedBorder16),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Container(
                                width: 333,
                                margin: getMargin(left: 10,right: 10),
                                child : DropdownSearch<String>(
                                  items: _items.map((e)=> e.business_name).toList(),
                                  popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                      fit: FlexFit.loose,
                                      searchFieldProps: const TextFieldProps(
                                        decoration: InputDecoration(
                                          hintText: "Search",
                                        ),
                                      ),
                                      emptyBuilder: (context, searchEntry) => const Center(child: Text('Business not found.',style:TextStyle(color:Colors.blue))),
                                      constraints: const BoxConstraints.tightFor(
                                        width: 333,
                                        height: 350,
                                      ),
                                    ),
                                  onChanged: (value) async {
                                      selectedsection=value!;
                                      locImage = 0;
                                      var businessSectionDetail=await _getBusinessSectionsList(selectedsection);
                                      if(businessSectionDetail['response_code']==200){
                                        if(businessSectionDetail['data'].length <= 1){
                                          sectionPageDialog = ProgressDialog(context,
                                            message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),backgroundColor: Colors.blue.withOpacity(.5),
                                          );
                                          sectionPageDialog.show();
                                          _sectionList= await _getSectionsList(businessSectionDetail['data'][0]['section_id'].toString(),selectedsection);
                                          if(_sectionList['response_code']==200){
                                              if(_sectionList['data']['section_image'] != "" && _sectionList['data']['section_image'] != null){
                                                locImage = 1;
                                                var strToRemove = 'data:image/jpeg;base64,';
                                                var strToRemovepng = 'data:image/png;base64,';
                                                var strToRemovejpg = 'data:image/jpg;base64,';
                                                var imagePath = _sectionList['data']['section_image'];
                                                imagePath = imagePath.replaceAll(strToRemovepng, "");
                                                imagePath=imagePath.replaceAll(strToRemovejpg, "");
                                                bytes = base64Decode(imagePath.replaceAll(strToRemove, ""));
                                              }
                                              sectionPageDialog.dismiss();
                                              if(_sectionList['data']['available_spaces']!=0){
                                                _showLocationPopUp(_sectionList['data']);
                                              }else{
                                                utils.toast('No space available.');
                                              }
                                          }else{
                                            utils.toast(_sectionList['message']);
                                          }
                                        }else{
                                          Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => SectionsPage(
                                              widget.accessToken,widget.locationDetails,widget.userDetails,0,0,null,null,null,selectedsection)),
                                          );
                                        }
                                      }
                                  },
                                  selectedItem: selectedsection,
                                ),
                              ),
                              ],
                            ),
                          ),
                      ),
                    ]
                  ),
                ),
              ]),
        ),
        //),
      ),
    );
  }

  _favouriteIconClicked(status) async{
    var favouriteLocationsData = <String, dynamic>{};
    favouriteLocationsData['user_id'] = widget.userDetails['user_id'];
    favouriteLocationsData['location_id'] = widget.locationDetails['location_id'];
    favouriteLocationsData['status'] = status;
    await apiHelper.post(context,'post_favourite_locations',widget.accessToken,favouriteLocationsData,'');
  }

  getUpdatedLocation(locationId) async {
    String queryParams='';
    var loggedInUserID = widget.userDetails['user_id'];
    if(locationId !=0){
      queryParams='&location_id=$locationId&user_id=$loggedInUserID';
    }
    var jsonResponse = await apiHelper.get(context,'get_locations', widget.accessToken, queryParams);
    locationsOnUpdate = jsonResponse;
    return jsonResponse;
  }

  _getBusinessList() async{
    var uri = '?location_id=${widget.locationDetails['location_id']}&isDistinct=true';
    print(uri);
    var jsonResponse=await apiHelper.get(context,'get_business',widget.accessToken,uri);
    return jsonResponse;
  }

  _getResvervationSectionsList(sectionId,fromDate,toDate,stayLength) async{
    var uri = '&section_id=$sectionId&fromDate=$fromDate&toDate=$toDate&stay_length=$stayLength';
    var jsonResponse=await apiHelper.get(context,'get_sections',widget.accessToken,uri);
    return jsonResponse;
  }

  _setHeader(){
    var strToRemove = 'data:image/jpeg;base64,';
    var strToRemovepng = 'data:image/png;base64,';
    var strToRemovejpg = 'data:image/jpg;base64,';
    var imagePath = widget.locationDetails['image_path'];
    imagePath = imagePath.replaceAll(strToRemovepng, "");
    imagePath=imagePath.replaceAll(strToRemovejpg, "");
    Uint8List bytes = base64Decode(imagePath.replaceAll(strToRemove, ""));
    return Stack(
        children:[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.25,
            decoration: const BoxDecoration(
              color: Color(0xff0071bc),
            ),
            child:  ColorFiltered(
              colorFilter: utils.appColorFilter(),
              child:   Image.memory(bytes,gaplessPlayback:true,fit: BoxFit.cover),
            ) 
          ),
          (_getReservationListData !=null && _getReservationListData['response_code'] ==200)?
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,//MediaQuery.of(context).size.height*0.10,
            color: Colors.green[400],
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  GestureDetector(
                    child: Text('Your reservation is ready - Click here', style:AppStyle.txtUrbanist18.copyWith()),
                    onTap: () async{
                      sectionPageDialog =  ProgressDialog(context,message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),backgroundColor: Colors.blue.withOpacity(.5));
                      sectionPageDialog.show();
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool('isResListClicked',true);
                      var reservationSpace = await _getReservationSpace(_getReservationListData['data'][0]['location_id'],_getReservationListData['data'][0]['section_id'],_getReservationListData['data'][0]['space_id'],_getReservationListData['data'][0]['toDate'],_getReservationListData['data'][0]['fromDate'],_getReservationListData['data'][0]['length']);
                      var overflowdata;
                      if(reservationSpace['data']==null || reservationSpace['data']==''){
                        overflowdata=_getReservationListData['data'][0];
                      }else{
                        overflowdata=reservationSpace['data'];
                      }
                      var locationDetails = await getUpdatedLocation(_getReservationListData['data'][0]['location_id']);
                      var sectionDetails = await _getResvervationSectionsList(overflowdata['section_id'],_getReservationListData['data'][0]['fromDate'],_getReservationListData['data'][0]['toDate'],_getReservationListData['data'][0]['length']);
                      sectionDetails['data']['business_id']=overflowdata['business_id'];
                      var spaceDetails = await _getReservationSpaceList(overflowdata['space_id']);
                      DateTime reservationDateFormat = DateTime.parse(_getReservationListData['data'][0]['time']).toLocal();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            ParkingPage(
                              widget.accessToken,
                              locationDetails['data'][0],
                              sectionDetails['data'],
                              spaceDetails['sectionSpace'],
                              spaceDetails['sectionSpace']['imei'],
                              widget.userDetails,
                              overflowdata['space_id'],
                              'false',2,reservationDateFormat,
                              _getReservationListData['data'][0]['reserve_id'],
                              _getReservationListData['data'][0]['length'],
                              _getReservationListData['data'][0]['amount'],
                              null,_getReservationListData['data'][0]['payment_intent_id']
                            )
                        ),);
                    },
                  ),
                ]
            ),
          ) : Container(),

        ]
    );
  }

  _showLocationPopUp(sectionDetails) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(getHorizontalSize(24.50,),)),
        title: Text('Confirm Location', textAlign: TextAlign.center,style:AppStyle.txtUrbanistBoldWhite22.copyWith()),
        contentPadding: const EdgeInsets.only(top:15.0,bottom:5.0,left:15.0,right:15.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            locImage==1 ?  Container(
              //height: 100,
             // width: 220,
              alignment:Alignment.center,
              child:Image.memory(bytes,gaplessPlayback: true,fit: BoxFit.cover,height: 150,width:220),
            ) :
            Center(
              child: Text(sectionDetails['section_name'],style: AppStyle.txtUrbanistRomanBold18ColorLess.copyWith(letterSpacing:0.20))
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CustomButton(
                 width: 105,
                 text: "YES",
                 onTap:() async {
                    sectionPageDialog = ProgressDialog(context,
                      message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),backgroundColor: Colors.blue.withOpacity(.5),
                    );
                    sectionPageDialog.show();
                    _showPopupMenu(sectionDetails);
                 },
                 padding: ButtonPadding.PaddingAll16,
                 margin: getMargin(bottom: 24,left:7),
              ),
              CustomButton(
                 width: 105,
                 text: "NO",
                 onTap:() async {
                   Navigator.of(context, rootNavigator: true).pop('dialog');
                 },
                 padding: ButtonPadding.PaddingAll16,
                 margin: getMargin(bottom: 24,right:7),              )
            ]
          )
        ],
      ),
    );
  }

  _showPopupMenu(sectionDetails) async {
    sectionPageDialog.dismiss();
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(getHorizontalSize(24.50,),)),
          title: Text('Select an option', textAlign: TextAlign.center,style:AppStyle.txtUrbanistBoldWhite22.copyWith()),
          contentPadding: const EdgeInsets.all(15.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _popMenuFields("Park Now",sectionDetails),
              const SizedBox(height: 15),
              _popMenuFields('Park Later',sectionDetails),
              //SizedBox(height: 15),
            ],
          ),
          actions: <Widget>[
            Center(
              child : CustomButton(
                   width: 195,
                   text: "Cancel",
                   onTap:() async {
                     Navigator.of(context, rootNavigator: true).pop('dialog');
                   },
                   padding: ButtonPadding.PaddingAll16,
                   margin: getMargin(top: 12,bottom: 24),
                   variant: ButtonVariant.FillBlue50,
                   fontStyle: ButtonFontStyle.UrbanistRomanBold16Blue800,
                )
            )
          ],
        ),
      );
    //});

  }

  _popMenuFields(fieldName,sectionDetails){
    sectionPageDialog.dismiss();
    var dateLocal;
    if(widget.locationDetails['activateon']!=null){
      dateLocal=DateTime.parse(widget.locationDetails['activateon']).toLocal().toString();
      dateLocal=DateTime.parse(dateLocal).millisecondsSinceEpoch;
    }else{
      dateLocal=DateTime.now().millisecondsSinceEpoch;
    }
    var endDate;
    if(widget.locationDetails['end_date']!=null){
      endDate=DateTime.parse(widget.locationDetails['end_date']).toLocal().toString();
      endDate=DateTime.parse(endDate).millisecondsSinceEpoch;
    }

    return Container(
      alignment:Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: widget.locationDetails['end_date']!=null && endDate < DateTime.now().millisecondsSinceEpoch 
          ? const Color.fromRGBO(211,211,211,1.0) 
          : (fieldName=="Park Now" && widget.locationDetails['activateon']!=null && dateLocal > DateTime.now().millisecondsSinceEpoch) 
          ? const Color.fromRGBO(211,211,211,1.0) 
          : const Color.fromRGBO(47,111,182,1.0),
        boxShadow: const [
          BoxShadow(color: Colors.white, spreadRadius: 0),
        ],
      ),
      height:40,
      width:160,
      child: GestureDetector(
        onTap: widget.locationDetails['end_date']!=null && endDate < DateTime.now().millisecondsSinceEpoch 
          ? null 
          : (fieldName=="Park Now" && widget.locationDetails['activateon']!=null && dateLocal > DateTime.now().millisecondsSinceEpoch) 
          ? null 
          : () async {
            await _showReservationDialog(sectionDetails,fieldName);
          } ,
        child: Text(fieldName,
          textAlign: TextAlign.center,
          style: AppStyle.txtUrbanistRomanBold16.copyWith()),
      ),
    );
  }

  _showReservationDialog(sectionDetails,type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("datetimeSelected",0);
    prefs.setInt("cancelReservation",0);
    prefs.setString("reservationDate","");
    prefs.setString("futureValSelected","");
    await showDialog<String>(
      context: context,
      builder:(context) =>ReservationDialog(widget.accessToken,widget.locationDetails,sectionDetails,widget.userDetails,type),
    );
  }

  _getReservationList() async {
    String queryParams;
    queryParams='?user_id=${widget.userDetails['user_id']}';
    var jsonResponse = await apiHelper.get(context,'get_reserveList', widget.accessToken, queryParams);
    if (!jsonResponse.isEmpty || jsonResponse != null) {
      if (jsonResponse['response_code'] == 200 && jsonResponse['data'][0]['payment_intent_id'] !=null) {
        return jsonResponse;
      }
    }
  }
  _getReservationSpace(locationId,sectionId,spaceId,toDate,fromdate,stayLength) async {
    String queryParams;
    queryParams='&location_id=${locationId.toString()}&section_id=${sectionId.toString()}&space_id=${spaceId.toString()}&toDate=${toDate.toString()}''&fromDate=${fromdate.toString()}&stay_length=$stayLength&type=checkReservation';
    var jsonResponse = await apiHelper.get(context,'get_section_spaces', widget.accessToken, queryParams);
    if(jsonResponse['response_code']==401){
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => true,
      );
    }
    return jsonResponse;
  }

  _getReservationSpaceList(spaceId)async{
    var uri ='&space_id=$spaceId';
    var jsonResponse=await apiHelper.get(context,'get_section_spaces',widget.accessToken,uri);
    return jsonResponse;
  }
  _getBusinessSectionsList(value) async{
    var bussName = value.replaceAll('&', 'ampp');
    var uri ='?location_id=${widget.locationDetails['location_id']}&business_name=$bussName';
    var jsonResponse=await apiHelper.get(context,'get_business',widget.accessToken,uri);
    return jsonResponse;
  }

  _getSectionsList(sectionId,value) async{
    var bussName = value.replaceAll('&', 'ampp');
    var uri = '&location_id=${widget.locationDetails['location_id']}&section_id=$sectionId&business_name=$bussName&isImage=true';
    print(uri);
    var jsonResponse=await apiHelper.get(context,'get_sections',widget.accessToken,uri);
    return jsonResponse;
  }
}
