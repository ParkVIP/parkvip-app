import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../helper/utils.dart';
import '../helper/api_base_helper.dart';
import '../pages/parking.dart';
import '../pages/locations.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ParkVip/core/app_export.dart';

var utils = Utils();

//Activities page
class ActivitiesPage extends StatefulWidget {
  final accessToken;
  final userDetails;
  const ActivitiesPage(this.accessToken,this.userDetails, {Key? key}) : super(key: key);

    @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> with SingleTickerProviderStateMixin {
  final apiHelper = ApiBaseHelper();
  var currentTab = true;
  var _setList;
  var currentTabData;
  var historyTabData;
  var _currentIndex;
  var selectedTab ;
  late TabController _tabController;
  late ProgressDialog activityDialog;

  @override
  void initState() {
    super.initState();
    if(_setList == null){
      _getActivityListApiCall('current').then(
        (s) => setState(() {
          _setList = s;
          selectedTab = 'current';
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
        _getActivityListApiCall('current').then(
          (s) => setState(() {
            _setList = s;
            selectedTab = 'current';
          })
        );
      }else{
        _getActivityListApiCall('history').then(
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
    return PopScope(
      canPop: true,
      onPopInvoked : (didPop) async{
        Navigator.push(context,MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)));
      },
      child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text("Activities",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
          leading:const BackButton(color:Colors.black)
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        //padding: const EdgeInsets.symmetric(horizontal: 10.0),
        padding: const EdgeInsets.only(top:20,bottom: 20,left:10,right:10),
        child: SingleChildScrollView(
            child:Wrap(
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
                                  width:100,                       
                                  child: Text('Current',
                                  textAlign:TextAlign.center,
                                  style:AppStyle.txtUrbanistRomanBold18ColorLess.copyWith(letterSpacing:0.20)),
                              ),
                              SizedBox(
                                width:100,
                                child: Text('History',
                                   textAlign:TextAlign.center,
                                  style:AppStyle.txtUrbanistRomanBold18ColorLess.copyWith(letterSpacing:0.20)),
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
                          height: MediaQuery.of(context).size.height -190 ,//- 170 *0.91,
                          margin: getMargin(left: 20, top: 24, right: 20),
                          decoration: AppDecoration.outlineBlack9000c.copyWith(borderRadius:BorderRadiusStyle.roundedBorder16),                         
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              Column(
                                children:[
                                  (listItems==null)?Container(
                                      margin: getMargin(left: 24, top: 24, right: 24),
                                      alignment: Alignment.center,
                                      child:Text('Loading...',style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20))
                                  ):Expanded(
                                    child: _renderTabsBody(context,listItems['data']),
                                  )
                                ]
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height,//*0.7,
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
                            ]
                          ),
                        ),
                      ]
                    )
                  ),
                  const SizedBox(height:10.0),
                ]
            )
        ),
      ),
      //drawer: utils.drawerMenu(context,widget.accessToken,widget.userDetails),
      ),
    );
  }

  Widget _renderTabsBody(BuildContext context,listItems){
    if(listItems==null || listItems.length < 1){
      if(selectedTab=='current' ) {
        return Container(
            padding: getPadding(left: 24, top: 47, right: 24, bottom: 20),
            child: Text('No current activity found', style: AppStyle.txtUrbanistRomanMedium18.copyWith())
        );
      }else{
        return Container(
            padding: getPadding(left: 24, top: 47, right: 24, bottom: 20),
            child: Text('Activity history not found', style: AppStyle.txtUrbanistRomanMedium18.copyWith())
        );
      }
    }else{
     var tabBody;
     if(selectedTab=='history'){
       tabBody = _setHistoryListView(listItems);
       return ListView(
            physics: const PageScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: tabBody,

       );
     }else{
      return ListView.builder(
          physics: const PageScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: listItems!=null?listItems.length:1,
          padding: const EdgeInsets.only(bottom:5,left: 5,right: 5),
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
    var formatDateTime = DateFormat("MM/dd/yyyy hh:mm a");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(utils.capitalize(listItems['location_name']),textAlign: TextAlign.left,style: AppStyle.txtUrbanistSemiBoldGray16.copyWith(letterSpacing:0.20),),
            Text("Location: ${listItems['section']}",textAlign: TextAlign.left,style: AppStyle.txtUrbanistSemiBoldGray16.copyWith(letterSpacing:0.20),),
            (listItems['level']=='' || listItems['level']==null) ? Container() : Text( "Floor: ${listItems['level'].toString()}",textAlign: TextAlign.left,style: AppStyle.txtUrbanistSemiBoldGray16.copyWith(letterSpacing:0.20),),
            Text("Space: ${listItems['parking_no'].toString()}",textAlign: TextAlign.left,style: AppStyle.txtUrbanistSemiBoldGray16.copyWith(letterSpacing:0.20),),
            Text("In time: ${formatDateTime.format((DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateTime.parse(listItems['in_time']).toString(),true)).toLocal()).toString()}"
              , textAlign: TextAlign.left,style:AppStyle.txtUrbanistSemiBoldGray16.copyWith(letterSpacing:0.20),),
          ],
        ),
        buttonStyle(listItems),
      ],
    );
  }
 
  _setHistoryListView(listItems) {
    var formatDateTime = DateFormat("MM/dd/yyyy hh:mm a");
    var tabBody = <Widget>[];
    for (var i = 0; i < listItems.length; i++) {
      tabBody.add(Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Padding(
            padding: getPadding(left: 24, top: 26, right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:getPadding(bottom: 2),
                  child: Text("Brand name",
                    overflow:TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20))
                ),
                Padding(
                  padding: getPadding(top: 1),
                  child: Text(listItems[i]['location_name'],
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
                  child: Text("Location name",
                    overflow:TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20)
                  )
                ),
                Padding(
                    padding: getPadding(top: 2),
                    child: Text(listItems[i]['section'],
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
                              style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith( letterSpacing:0.20))),
                      Padding(
                          padding:
                              getPadding(bottom: 1),
                          child: Text(listItems[i]['level'].toString(),
                              overflow:
                                  TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtUrbanistRomanBold18Gray900.copyWith(letterSpacing:0.20))),
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
                        child: Text("Space #",
                            overflow:TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith( letterSpacing:0.20))),
                    Padding(
                        padding:getPadding(bottom: 1),
                        child: Text(listItems[i]['parking_no'].toString(),
                            overflow:
                                TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtUrbanistRomanBold18Gray900.copyWith(letterSpacing:0.20)))
                  ])),
          Padding(
              padding: getPadding(left: 24, top: 13, right: 24),
              child: Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                        padding:getPadding(bottom: 2),
                        child: Text("In time",
                            overflow:TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20))),
                    Padding(
                        padding: getPadding(top: 1),
                        child: Text((listItems[i]['in_time']!=null)?formatDateTime.format((DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateTime.parse(listItems[i]['in_time']).toString(),true)).toLocal()).toString():'',
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
                      child: Text("Out time",
                        overflow:TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtUrbanistSemiGray700Bold18.copyWith(letterSpacing:0.20))),
                  Padding(
                      padding: getPadding(top: 1),
                      child: Text((listItems[i]['out_time']!=null)?formatDateTime.format((DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateTime.parse(listItems[i]['out_time']).toString(),true)).toLocal()).toString():'',
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
                        padding: getPadding(top: 2),
                        child: Text(
                            "Time spent",
                            overflow:
                                TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle
                                .txtUrbanistSemiGray700Bold18
                                .copyWith(
                                    letterSpacing:
                                        0.20))),
                    Padding(
                        padding:
                            getPadding(bottom: 1),
                        child: Text(listItems[i]['spend_time'].toString(),
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
                  left: 24, top: 12, right: 24),
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
                        child: Text(
                            "Total amount",
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
                        child: Text(listItems[i]['cost'].toString(),
                            overflow:
                                TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle
                                .txtUrbanistRomanBold18Gray900
                                .copyWith(
                                    letterSpacing:
                                        0.20)))
                  ])),
          Container(
            height: getVerticalSize(1.00),
            width: getHorizontalSize(332.00),
            margin: getMargin(left: 24, top: 22, right: 24),
            decoration: BoxDecoration(color: ColorConstant.gray200)),
        ]

      ));
    }
    return tabBody;
  }

  buttonStyle(data) {
    if (data == null) {
      return Container();
    }
    return SizedBox(
        width: 92,
        height: 46,
        child: ElevatedButton(
          style: TextButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: const Color.fromRGBO(47,111,182,1.0),
          ),            
          child: Text(data['parking_status'],
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,fontFamily: "Urbanist")
          ),
          onPressed: () async {
            activityDialog = ProgressDialog(context,
                message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),backgroundColor: Colors.blue.withOpacity(.5)
            );
            activityDialog.show();
            var sectionList = await _getSectionsList(data['section_id']);
            var locationsListData = await _getLocationsListApiCall(data['location_id']);
            int formsubmission ;
            if(data['prepaid_amount']!= '-NA-' && data['stay_length'] !='-NA-'){
              formsubmission =4;
            }
            else{
              formsubmission =0;
            }

            final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
            sharedPrefs.setString('parking_detail_id',json.encode(data['parking_detail_id']));
            if (!(sectionList == null)) {
                activityDialog.dismiss();
                Future.delayed(Duration.zero).then((value) {
                    Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                      ParkingPage(
                      widget.accessToken,
                      locationsListData['data'][0],
                      sectionList['data'],
                      data,
                      null,
                      widget.userDetails,
                      data['space_id'],
                      'true',
                      formsubmission,
                      DateTime.parse('2000-01-01'),
                      0,data['stay_length'],data['prepaid_amount'])),
                  );
              });
            }
          }
        )
    );
  }


  _getActivityListApiCall(tabType) async{
    //var uri = endpoints.callToUrl('get_'+tabType+'_activity')+widget.userDetails['user_id'].toString();
    String queryParams =widget.userDetails['user_id'].toString();
    var jsonResponse = await apiHelper.get(context,'get_${tabType}_activity', widget.accessToken, queryParams);
    return jsonResponse;
  }


  _getSectionsList(sectionId) async{
    String queryParams ='&section_id=${sectionId.toString()}';
    var jsonResponse = await apiHelper.get(context,'get_sections', widget.accessToken, queryParams);
    return jsonResponse;
  }

  _getLocationsListApiCall(locationId) async {
    String queryParams ='';
    var loggedInUserID = widget.userDetails['user_id'];
    if(locationId !=0){
        queryParams='&location_id=${locationId.toString()}&user_id=${loggedInUserID.toString()}';
    }
    var jsonResponse = await apiHelper.get(context,'get_locations', widget.accessToken, queryParams);
    return jsonResponse;
  }
}