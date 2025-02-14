import 'dart:async';
import 'package:flutter/services.dart';
import 'package:interactable_svg/interactable_svg/interactable_svg.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:ParkVip/core/app_export.dart';
import '../helper/api_base_helper.dart';
import 'login.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import '../helper/utils.dart';
class ParkingLayoutPage extends StatefulWidget {
  final userDetails;
  final accessToken;
  const ParkingLayoutPage(this.accessToken,this.userDetails);
  @override
  _ParkingLayoutPageState createState() => _ParkingLayoutPageState();
}
final GlobalKey<InteractableSvgState> mapKey = GlobalKey();
class _ParkingLayoutPageState extends State<ParkingLayoutPage> {
  Region? selectedRegion;
  var svgString = "";
  late Future<List> _bar;
  var _spaceStatus;
  final apiHelper = ApiBaseHelper();
  var utils = Utils();
  @override
  void initState() {
    super.initState();
    _bar = loadSvgImage("assets/GALLERIAWAY.svg");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        title: Text("GalleriaWay Parking Layout",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
            InteractiveViewer(
              constrained: true,
              scaleEnabled: true,
              panEnabled: true,

              child:SizedBox(
                width: double.infinity,//MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.40,
                child: FutureBuilder<List<dynamic>>(
                  future: _bar,
                  builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    List<dynamic> data = snapshot.data!;
                    return InteractableSvg.string(
                        key: mapKey,
                        svgAddress: "${data[0]}",//"${snapshot.data}",
                        onChanged: (region) {
                          String? sid = region?.id;
                          if (sid != null) {
                            if(data[1].contains(int.parse(sid))){ //If Not available
                              _spaceStatus = "na";
                              utils.toast('Space:$sid is not available.');
                            }else{
                              _spaceStatus = "available";
                              utils.toast('Space:$sid is available.');
                            }

                          }
                          setState(() {
                            selectedRegion = region;
                          });
                        },
                        width: 300,
                        height: double.infinity,
                        toggleEnable: true,
                        isMultiSelectable: false,
                        dotColor: Colors.black,
                        selectedColor: _spaceStatus =='na'? const Color.fromRGBO(189, 195, 199,1.0) :const Color.fromRGBO(47,111,182,1.0).withOpacity(0.5),//Colors.red.withOpacity(0.5),
                        strokeColor: const Color.fromRGBO(47,111,182,1.0),
                        unSelectableId: "ns",
                        centerDotEnable: false,
                        centerTextEnable: true,
                        strokeWidth: 5.0,
                        centerTextStyle:const TextStyle(
                            fontSize: 72,
                            color: Color.fromRGBO(47,111,182,1.0),
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w900,height: .07)         //AppStyle.txtUrbanistRomanBoldBlue48.copyWith(),
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
          CustomButton(
              width: 380,
              text: "Last Selected Space",
              margin: getMargin(left: 24,right: 24,bottom: 20,top:20),
              alignment: Alignment.center,
              onTap : (){
                if (selectedRegion != null) {
                  mapKey.currentState?.toggleButton(selectedRegion!);
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No space Selected!")));
                }
              }
          )
        ],
      ),

    );
  }

  // To update XMLDocument of svg - remove car icons from empty spaces
  Future<List> loadSvgImage(String svgImage) async {
    //Fetch svg xml from the file
    String generalString = await rootBundle.loadString(svgImage);
    XmlDocument document = XmlDocument.parse(generalString);
    var resList=[];
    //Find all path elements
    final paths = document.findAllElements('path');

    //Find all space Ids which are not empty
    var spacesStatusList=[];
    var fromDate= DateTime.now();

    int hour = int.parse('1');
    int mins = int.parse('0');
    var toDate = fromDate.add(
        Duration(hours: hour, minutes: mins)
    );

    //Fetch all spaces and return lists of spaces with status for Reserved or Not available spaces.
    spacesStatusList = await _getReservationSpace(41,38,fromDate.toUtc().toIso8601String(),toDate.toUtc().toIso8601String()).then((s){
      var parkedList=[];
      var notAvailableList=[];

      var spaceWithStatusList=[];
      if(s['data'] != null){
        for (int i = 0; i < s['data'].length; i++) {

          if(s['data'][i]['availability']==true ){
            if(s['data'][i]['status']==false){
              //Status false from backend
              notAvailableList.add(s['data'][i]['space_number']);
            }else{
              //Empty
            }
          }else if(s['data'][i]['status']==false){ // If space not available
            //Reserved
            notAvailableList.add(s['data'][i]['space_number']);
          }else{
            //Parked
            parkedList.add(s['data'][i]['space_number']);
          }
        }
      }
      spaceWithStatusList.add(parkedList); // Spaces Parked
      spaceWithStatusList.add(notAvailableList);// Spaces Not available
      return spaceWithStatusList;
    });

    //Once the list of  spaces with status is fetched, do following for each path that is a space
    for (var element in paths) {
      var eltType = element.getAttribute('type');
      if(eltType!=null && eltType!="" && eltType=="space") { // If path is a space
        String spaceid = element.getAttribute('id').toString();


        //Update svg's xml string based on status
        if (spacesStatusList[0].contains(int.parse(spaceid)) ) {  // If parked spaces list has  this space id, make it non-selectable

          element.setAttribute('id', 'ns');
          //Remove unavailable icon
          var pathChanged = document.findAllElements('path').where((line) => line.getAttribute('space_id') == "na_$spaceid").toList();

          if(pathChanged.isNotEmpty){
            pathChanged[0].remove();
          }

        }else if(spacesStatusList[1].contains(int.parse(spaceid))){

          element.setAttribute('id', 'ns');
          //Remove unavailable icon
          var pathChanged = document.findAllElements('path').where((line) => line.getAttribute('space_id') == spaceid).toList();

          if(pathChanged.isNotEmpty){
            pathChanged[0].remove();
          }

        }
        else{ // Empty-Remove car associated with that space
          //Remove car icon
          /*var pathChanged = document.findAllElements('path').where((line) => line.getAttribute('space_id') == spaceid).toList();
          if(pathChanged!=null && pathChanged.length>0){
            print("found empty");
            pathChanged[0].remove();
          }*/

          var pathChanged = document.findAllElements('path').where((line) => (line.getAttribute('space_id') == spaceid || line.getAttribute('space_id') == "na_$spaceid")).toList();
          if(pathChanged.isNotEmpty){
            pathChanged[0].remove();
            pathChanged[1].remove();
          }


        }
      }
    }

    resList.add(document.toString()); //svg string
    resList.add(spacesStatusList[1]); //Reserved spaces

    //return document.toString();
    return resList;
  }

  // Fetch all spaces list  with details for a particular location's section .
  _getReservationSpace(locationId,sectionId,fromdate,toDate) async {
    String queryParams;
    var loggedInUserID = widget.userDetails['user_id'];
    queryParams='&location_id=$locationId&section_id=$sectionId&toDate=$toDate&fromDate=$fromdate&stay_length=01:00&user_id=$loggedInUserID';

    var jsonResponse = await apiHelper.get(context,'get_section_spaces', widget.accessToken, queryParams);
    if(jsonResponse['response_code']==401){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => true,
      );
    }

    return jsonResponse;
  }
}
