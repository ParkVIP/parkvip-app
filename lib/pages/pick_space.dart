import 'package:xml/xml.dart';
import 'package:flutter/material.dart';
import '../pages/parking.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import '../helper/api_base_helper.dart';
import 'package:interactable_svg/interactable_svg/interactable_svg.dart';
import '../model/FloorDropDownItems.dart';
import '../helper/utils.dart';

class PickSpace extends StatefulWidget {
  final firstOddThenEven;
  final locationDetails;
  final sectionDetails;
  final accessToken;
  final userDetails;
  final datetimeSelected;
  final reservationDateFormat;
  final reservationLength;
  const PickSpace(this.firstOddThenEven,this.locationDetails,this.sectionDetails,this.accessToken,this.userDetails,this.datetimeSelected,this.reservationDateFormat,this.reservationLength, {Key? key}) : super(key: key);

  @override
  _PickSpaceState createState() => _PickSpaceState();
}
GlobalKey<InteractableSvgState> mapKey = GlobalKey();
class _PickSpaceState extends State<PickSpace> {
  late ProgressDialog reservationDialog;
  final apiHelper = ApiBaseHelper();
  var _setList=null;
  var selectedIndex=null;
  var selectedLevel=null;
  var selectedFloorName=null;
  var _setLevelList=null;
  var parkinglayoutsvg = null;
  final List<FloorDropDownItems> _floorDDItems =  <FloorDropDownItems>[];
  final Map<String, List> _levelSpacesData = {};
  Region? selectedRegion;
  bool hasLayoutSvg = false;
  late Future<List> _parkinglayoutDetails;
  var _spaceStatus;
  bool isFloorDDLoaded = false;
  String floorValSelected ="";
  var utils = Utils();

  @override
  void initState() {
    super.initState();
    _setList=widget.firstOddThenEven;
    if(widget.sectionDetails['isLevel'] && _setLevelList==null){
      _getLevels().then(
              (s) => setState(() {
            _setLevelList = s['data'];
            if(_setLevelList!=null){
              for(var v=0; v < _setLevelList.length; v++){
                _floorDDItems.add(FloorDropDownItems(_setLevelList[v]['_id']!,_setLevelList[v]['level']!));  //Level Dropdown Item
                var spaces=[];
                if(_setList.length!=0){
                  for(var i=0; i< _setList.length; i++){
                    if(_setList[i]['level_id']!=null){
                      if(_setLevelList[v]['_id'].toString()==_setList[i]['level_id'].toString()){
                        spaces.add( _setList[i]);
                      }
                    }
                  }
                }
                _levelSpacesData[_setLevelList[v]['_id']]=spaces;
              }
              isFloorDDLoaded = true;
            }
          })
      );
    }

    if(!widget.sectionDetails['isLevel'] && widget.sectionDetails['layout_svg']!=null && widget.sectionDetails['layout_svg']!=''){
      setState(() {
        hasLayoutSvg =true;
      });
      _parkinglayoutDetails = loadSvgImage('section',widget.sectionDetails['layout_svg']);
    }else{
      setState(() {
        hasLayoutSvg =false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorConstant.whiteA700,
        appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text("Pick a Space",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
                reservationDialog.dismiss();
              }
          ),
        ),
        body: SizedBox(
          width: size.width,
          child: SingleChildScrollView(
            child : Column(
                children: [
                  if(widget.sectionDetails['isLevel'] && _setLevelList!=null && _floorDDItems.isNotEmpty )  //Dropdown of Floors if there are floors
                    Container(
                      width: 330,
                      margin: getMargin(left: 10,top: 26,right: 10),
                      child:DropdownButtonFormField<String>(
                        decoration:_decoration('','Select Floor'),
                        style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20),
                        value: (floorValSelected.isEmpty) ?null :floorValSelected ,
                        items: _floorDDItems.map((floor) => DropdownMenuItem(
                          value: floor.value,
                          child: Text(floor.label,style:AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20),),
                        )).toList(),
                        onChanged: (value) {
                          setState((){
                            floorValSelected = value!;
                            var selectedFloor =  _setLevelList.where((e) => e['_id'] == floorValSelected).toList();
                            selectedFloorName = selectedFloor[0]['level'];
                            if(selectedFloor[0]['layout_svg']!=null && selectedFloor[0]['layout_svg']!=''){ //If floor has svg
                              hasLayoutSvg =true;
                              _setList = _levelSpacesData[floorValSelected];
                              _parkinglayoutDetails = loadSvgImage('floor',selectedFloor[0]['layout_svg']);
                            }else{
                              hasLayoutSvg = false;
                              _setList = _levelSpacesData[floorValSelected];
                            }

                          });
                        },
                      ),
                    )
                  else if(widget.sectionDetails['isLevel'] && _setLevelList!=null && isFloorDDLoaded==false)
                    Container(
                        padding:const EdgeInsets.all(27),
                        alignment: Alignment.center,
                        child:Text('Loading...',style: AppStyle.txtUrbanistSemiBold20.copyWith())
                    ),
                    //new container
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      children: [
                            Row(
                              children: [
                                CustomButton(
                                  width: 70,
                                  text: '',
                                  variant: ButtonVariant.OutlineBlue8001_2,
                                  shape: ButtonShape.RoundedBorder6,
                                  fontStyle: ButtonFontStyle.UrbanistRomanBold18Blue800,
                                  alignment: Alignment.center,
                                  padding:ButtonPadding.PaddingAll6
                                ),
                                SizedBox(width: 10), // Add some space between button and text
                                Container(
                                  width: 95,
                                  child: Text("Available"),
                                ),
                                CustomButton(
                                    width: 70,
                                    text: '',
                                    variant: ButtonVariant.FillGray300,
                                    shape: ButtonShape.RoundedBorder6,
                                    fontStyle: ButtonFontStyle.UrbanistRomanMedium18,
                                    alignment: Alignment.center,
                                    padding:ButtonPadding.PaddingAll6
                                  ),
                                SizedBox(width: 10), // Add some space between button and text
                                Container(
                                  width: 95,
                                  child: Text("Reserved"),
                                ),
                              ],
                            ),
                      ],
                    ),
                  ),
                  if(hasLayoutSvg==true) //Svg Layout
                    Column(
                      children: [
                        InteractiveViewer(
                          constrained: true,
                          scaleEnabled: true,
                          panEnabled: true,
                          child:Container(
                            margin: MediaQuery.of(context).size.width <=375 ?getMargin(left: 12,right: 12):getMargin(left: 32,right: 32),
                            width: MediaQuery.of(context).size.width / 0.9,
                            height: MediaQuery.of(context).size.height * 0.40,
                            // **************************Render a widget only after data is fetched and returned - using interactable_svg and FutureBuilder
                            child: FutureBuilder<List<dynamic>>(
                              future: _parkinglayoutDetails,
                              builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                                if (snapshot.hasData && snapshot.data!.length>1) {
                                  List<dynamic> data = snapshot.data!;
                                  return InteractableSvg.string(
                                    key: mapKey,
                                    svgAddress: "${data[0]}",
                                    onChanged: (region) {
                                      String? sid = region?.id;

                                      if (sid != null) {
                                        if(data[1].contains(int.parse(sid))){ //If Not available
                                          _spaceStatus = "na";
                                          utils.toast('Space:$sid is not available.');
                                          //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Space:'+sid+' is not available')));
                                        }else{
                                          _spaceStatus = "available";
                                          setState(() {
                                            var index = _setList.indexWhere((e) => e['space_number'].toString() == sid.toString());
                                            selectedIndex=index;
                                            if(!widget.sectionDetails['isLevel']){
                                              List newList = [];
                                              newList=_setList;
                                              for (var item in newList) {
                                                item.remove("highlight");
                                              }
                                              newList[index]['highlight']=true;
                                              _setList=newList;
                                            }else if(widget.sectionDetails['isLevel'] && _setLevelList!=null){
                                              var index = _setList.indexWhere((e) => e['space_number'].toString() == sid.toString());
                                              selectedIndex=index;
                                              selectedLevel=floorValSelected;
                                              Map<String, List> newList = {};
                                              newList=_levelSpacesData;
                                              for (var item in newList.values) {
                                                for (var it in item) {
                                                  it.remove("highlight");
                                                }
                                              }
                                              newList[floorValSelected]![index]['highlight']=true;
                                              newList[floorValSelected]![index]['level']=selectedFloorName;
                                              _levelSpacesData[floorValSelected]!=newList;
                                            }
                                          });
                                        }

                                      }
                                      setState(() {
                                        selectedRegion = region;
                                      });
                                    },
                                    width: 300,
                                    height: double.infinity,
                                    toggleEnable: false,
                                    isMultiSelectable: false,
                                    dotColor: Colors.black,
                                    selectedColor: _spaceStatus =='na'? const Color.fromRGBO(189, 195, 199,1.0) :const Color.fromRGBO(47,111,182,1.0).withOpacity(0.5),
                                    strokeColor: const Color.fromRGBO(47,111,182,1.0),
                                    unSelectableId: "ns",
                                    centerDotEnable: false,
                                    centerTextEnable: false,
                                    strokeWidth: 5.0,
                                    centerTextStyle:const TextStyle(
                                        fontSize:60,
                                        color: Color.fromRGBO(47,111,182,1.0),
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w900,height: .19)         //AppStyle.txtUrbanistRomanBoldBlue48.copyWith(),
                                  ,
                                  );
                                } else {
                                  return Container(
                                      margin: getMargin(left: 24, top: 24, right: 24),
                                      alignment: Alignment.center,
                                      child:Text('Loading...',style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20))
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  else if(hasLayoutSvg==false && ((widget.sectionDetails['isLevel'] && floorValSelected!="") || !widget.sectionDetails['isLevel'])) // Buttons layout
                    Container(
                      margin: getMargin(left: 32,top: 24,right: 32),
                      width: MediaQuery.of(context).size.width / 0.9,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: SingleChildScrollView(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 1.6,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 0
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          primary: true,
                          itemCount: (_setList != null) ? _setList.length : 1,
                          itemBuilder: (BuildContext context, int index) {
                            return  InkWell(
                                onTap: (_setList[index]['status'] ==false || _setList[index]['availability']==false) ? null : () async{
                                  setState(() {
                                    selectedIndex=index;
                                    if(!widget.sectionDetails['isLevel']){
                                      List newList = [];
                                      newList=_setList;
                                      for (var item in newList) {
                                        item.remove("highlight");
                                      }
                                      newList[index]['highlight']=true;
                                      _setList=newList;
                                    }else if(widget.sectionDetails['isLevel'] && _setLevelList!=null){
                                      selectedIndex=index;
                                      selectedLevel=floorValSelected;
                                      Map<String, List> newList = {};
                                      newList=_levelSpacesData;
                                      for (var item in newList.values) {
                                        for (var it in item) {
                                          it.remove("highlight");
                                        }
                                      }
                                      newList[floorValSelected]![index]['highlight']=true;
                                      newList[floorValSelected]![index]['level']=selectedFloorName;
                                      _levelSpacesData[floorValSelected]!=newList;
                                    }
                                  });

                                },
                                child: Container(
                                    padding: const EdgeInsets.only(top: 22,bottom:10),
                                    alignment:Alignment.center,
                                    decoration: BoxDecoration( color: Colors.white,
                                      border: Border.all(color: ColorConstant.gray400,width: 1),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children:[
                                                    (_setList[index]['availability']==true) ?
                                                    _setList[index]['status']==true ?
                                                    CustomButton(
                                                        width: 107,
                                                        text: _setList[index]['space_number'].toString(),
                                                        variant: _setList[index]['highlight']==true  ? ButtonVariant.OutlineGreen : ButtonVariant.OutlineBlue8001_2 ,
                                                        shape: ButtonShape.RoundedBorder12,
                                                        fontStyle: (_setList[index]['highlight']==true) ? ButtonFontStyle.UrbanistRomanBold18Green :ButtonFontStyle.UrbanistRomanBold18Blue800 ,
                                                        alignment:Alignment.center
                                                    )  :
                                                    CustomButton(
                                                        width: 107,
                                                        text: _setList[index]['space_number'].toString(),
                                                        variant: ButtonVariant.FillGray300 ,
                                                        shape: ButtonShape.RoundedBorder12,
                                                        fontStyle: ButtonFontStyle.UrbanistRomanMedium18 ,
                                                        alignment:Alignment.center
                                                    )
                                                        :
                                                    (_setList[index]['status']==false) ?
                                                    CustomButton(
                                                        width: 107,
                                                        text: _setList[index]['space_number'].toString(),
                                                        variant: ButtonVariant.FillGray300 ,
                                                        shape: ButtonShape.RoundedBorder12,
                                                        fontStyle: ButtonFontStyle.UrbanistRomanMedium18 ,
                                                        alignment:Alignment.center
                                                    ) :
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: InkWell(
                                                        child: Container(
                                                          width: getHorizontalSize(107),
                                                          padding: getPadding(all: 10,),
                                                          child: CommonImageView(
                                                              imagePath:ImageConstant.imgImage,
                                                              height: getVerticalSize(40.00),
                                                              width: getHorizontalSize(84.00)),
                                                        ),
                                                      ),
                                                    )
                                                  ]
                                              )
                                            ]
                                        ),
                                      ],
                                    )
                                )
                            );
                          },
                        ),
                      ),
                    ),
                  if((widget.sectionDetails['isLevel'] && floorValSelected!="") || !widget.sectionDetails['isLevel'])

                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CustomButton(
                            width: 316,
                            text: "Select",
                            variant: (selectedIndex!=null) ? ButtonVariant.OutlineGreen : ButtonVariant.FillIndigo300,
                            onTap:() async {
                              if(selectedIndex!=null){
                                reservationDialog = ProgressDialog(context,
                                  message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),backgroundColor: Colors.blue.withOpacity(.5),
                                );
                                reservationDialog.show();
                                if(!widget.sectionDetails['isLevel']){
                                  _renderParkingDetailsPage(widget.sectionDetails,
                                      _setList[selectedIndex],
                                      _setList[selectedIndex]['imei'],
                                      _setList[selectedIndex]['space_id'],
                                      widget.datetimeSelected,
                                      widget.reservationDateFormat,
                                      widget.reservationLength,
                                      _setList);
                                }else{
                                  if(selectedLevel!=null){

                                    _renderParkingDetailsPage(widget.sectionDetails,
                                        _setList[selectedIndex],
                                        _setList[selectedIndex]['imei'],
                                        _setList[selectedIndex]['space_id'],
                                        widget.datetimeSelected,
                                        widget.reservationDateFormat,
                                        widget.reservationLength,
                                        _setList);
                                  }else{

                                    if(selectedLevel!=null){
                                      _renderParkingDetailsPage(widget.sectionDetails,
                                          _levelSpacesData[selectedLevel]![selectedIndex],
                                          _levelSpacesData[selectedLevel]![selectedIndex]['imei'],
                                          _levelSpacesData[selectedLevel]![selectedIndex]['space_id'],
                                          widget.datetimeSelected,
                                          widget.reservationDateFormat,
                                          widget.reservationLength,
                                          _setList);
                                    }
                                  }

                                }
                              }},
                              margin: getMargin(left: 32,top: 24,right: 32)
                          ),
                          CustomButton(
                            width: 316,
                            text: "Cancel",
                            onTap:() async {
                              Navigator.of(context).pop();
                              reservationDialog.dismiss();
                            },
                            margin: getMargin(left: 32,top: 12,right: 32,bottom: 20),
                            variant: ButtonVariant.FillBlue50,
                            fontStyle: ButtonFontStyle.UrbanistRomanBold16Blue800,
                          )
                        ]
                    ),
                ]
            ),

          ),
        ),
      ),
    );
  }

  _renderParkingDetailsPage(sectionDetails,parkingSpaces,userImei,spaceId,datetimeSelected,reservationDateTime,reservationLength,firstOddThenEven)async{
    var secDetails=await _getResvervationSectionsList(sectionDetails['section_id']);
    if(sectionDetails['business_id']!=null){
      secDetails['data']['business_id']=sectionDetails['business_id'];
    }
    if(secDetails!=null){
      reservationDialog.dismiss();
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              ParkingPage(
                  widget.accessToken,
                  widget.locationDetails,
                  secDetails['data'],
                  parkingSpaces,
                  userImei,
                  widget.userDetails,
                  spaceId,
                  'false',
                  datetimeSelected,
                  reservationDateTime,
                  0,
                  reservationLength,
                  0,firstOddThenEven)),
        );
      }
    }

  }
  _getResvervationSectionsList(sectionId) async{
    var queryParams ='&section_id=$sectionId';
    var jsonResponse = await apiHelper.get(context,'get_sections', widget.accessToken, queryParams);
    return jsonResponse;
  }
  _getLevels() async {
    var queryParams ='?section_id=${widget.sectionDetails['section_id']}&isActive=true';
    var jsonResponse = await apiHelper.get(context,'get_levels', widget.accessToken, queryParams);
    return jsonResponse;
  }
  // To update XMLDocument of svg - remove car icons from empty spaces
  Future<List> loadSvgImage(type,svgstring) async {
    var resList=[];
    var parkedList=[];
    var notAvailableList=[];
    var spacesStatusList=[];
    /*String generalString = await _getSpacesLayout(id).then((r){
      return r['data'][0]['layout_svg'];
    });*/
    XmlDocument document = XmlDocument.parse(svgstring);//Fetch svg xml from the file
    final paths = document.findAllElements('path');//Find all path elements

    //Fetch all spaces and return lists of spaces with status for Reserved or Not available spaces.
    if(_setList != null){
      for (int i = 0; i < _setList.length; i++) {
        if(_setList[i]['availability']==true ){
          if(_setList[i]['status']==false){
            //Status false from backend
            notAvailableList.add(_setList[i]['space_number']);
          }else{
            //Empty
          }
        }else if(_setList[i]['status']==false){ // If space not available
          //Reserved
          notAvailableList.add(_setList[i]['space_number']);
        }else{
          //Parked
          parkedList.add(_setList[i]['space_number']);
        }
      }
    }
    spacesStatusList.add(parkedList); // Spaces Parked
    spacesStatusList.add(notAvailableList);// Spaces Not available

    //Once the list of  spaces with status is fetched, do following for each path that is a space
    for (var element in paths) {
      var eltType = element.getAttribute('type');
      if(eltType!=null && eltType!="" && eltType=="space") { // If path is a space
        String spaceid = element.getAttribute('id').toString();

        //Update svg's xml string based on status

        if (spacesStatusList[0].contains(int.parse(spaceid))) {  // If parked spaces list has  this space id, make it non-selectable

          element.setAttribute('id', 'ns');
          //Remove unavailable icon
          var pathChanged = document.findAllElements('path').where((line) => (line.getAttribute('space_id') == "na_"+spaceid || line.getAttribute('space_id') == spaceid)).toList();
          if(pathChanged.isNotEmpty){
            pathChanged[0].remove();
            if(pathChanged.length==2){
              pathChanged[1].remove();
            }
          }
        }else if(spacesStatusList[1].contains(int.parse(spaceid))){  // If unavailable spaces list has  this space id, make it non-selectable and hide parked icon
          element.setAttribute('id', 'ns');
          //Remove parked  icon
          var pathChanged = document.findAllElements('path').where((line) => (line.getAttribute('space_id') == "p_$spaceid" || line.getAttribute('space_id') == spaceid)).toList();
          if(pathChanged.isNotEmpty){
            pathChanged[0].remove();
            if(pathChanged.length==2){
              pathChanged[1].remove();
            }
          }

        } else { // Empty-Remove car associated with that space
          //Remove car icon
          var pathChanged = document.findAllElements('path').where((line) => (line.getAttribute('space_id') == "p_$spaceid" || line.getAttribute('space_id') == "na_$spaceid")).toList();
          if(pathChanged.isNotEmpty){
            pathChanged[0].remove();
            if(pathChanged.length==2){
              pathChanged[1].remove();
            }
          }

        }
      }
    }
    resList.add(document.toString()); //svg string
    resList.add(spacesStatusList[1]); //Reserved spaces
    return resList;
  }

  _decoration(imgtype,hint){
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: ColorConstant.gray900,
        fontSize: getFontSize(
          18,
        ),
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          getHorizontalSize(
            12.00,
          ),
        ),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          getHorizontalSize(
            12.00,
          ),
        ),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          getHorizontalSize(
            12.00,
          ),
        ),
        borderSide: BorderSide.none,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          getHorizontalSize(
            12.00,
          ),
        ),
        borderSide: BorderSide.none,
      ),
      fillColor: ColorConstant.gray51,
      filled: true,
      isDense: true,
      contentPadding:getPadding(left: 15,top: 15,right: 15,bottom: 15,
      ),
      prefixIcon : Container(
          margin: getMargin(left: 21,top: 19,right: 13,bottom: 19),
          child: CommonImageView(svgPath: imgtype)
      ),
      prefixIconConstraints: BoxConstraints(
          minWidth:getSize(16.00),
          minHeight: getSize(16.00)),
    );
  }

}
