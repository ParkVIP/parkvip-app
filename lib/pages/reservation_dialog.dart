import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import '../helper/utils.dart';
import '../model/HourDownItems.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import '../pages/pick_space.dart';
import '../helper/api_base_helper.dart';

class ReservationDialog extends StatefulWidget {
  final locationDetails;
  final sectionDetails;
  final accessToken;
  final userDetails;
  final type;
  const ReservationDialog(this.accessToken,this.locationDetails,this.sectionDetails,this.userDetails,this.type, {Key? key}) : super(key: key);

  @override
  _ReservationDialogState createState() => _ReservationDialogState();

}

class _ReservationDialogState extends State<ReservationDialog> {
  var utils = Utils();
  final apiHelper = ApiBaseHelper();
  String currentValSelected ="";
  String futureValSelected ="";
  late TimeOfDay selectedTime;
  String reservationTime ="";
  String reservationDate ="";
  var datetimeSelected;
  var cancelReservation = 0;
  late ProgressDialog reservationDialog;
 

  final List<HourDownItems> _dropDownItems =  <HourDownItems>[const HourDownItems('01:00','1 Hour'),const HourDownItems('02:00','2 Hours'),const HourDownItems('03:00','3 Hours'),const HourDownItems('04:00','4 Hours'),const HourDownItems('05:00','5 Hours'),const HourDownItems('06:00','6 Hours'),const HourDownItems('07:00','7 Hours'),const HourDownItems('08:00','8 Hours'),const HourDownItems('09:00','9 Hours'),const HourDownItems('10:00','10 Hours'),const HourDownItems('11:00','11 Hours'),const HourDownItems('12:00','12 Hours'),const HourDownItems('13:00','13 Hours'),const HourDownItems('14:00','14 Hours'),const HourDownItems('15:00','15 Hours'),const HourDownItems('16:00','16 Hours'),const HourDownItems('17:00','17 Hours'),const HourDownItems('18:00','18 Hours'),const HourDownItems('19:00','19 Hours'),const HourDownItems('20:00','20 Hours'),const HourDownItems('21:00','21 Hours'),const HourDownItems('22:00','22 Hours'),const HourDownItems('23:00','23 Hours')];

  @override
  Widget build(BuildContext context){
    var formatDate = DateFormat("yyyy-MM-dd");
    var startDateOfDatePicker = DateTime.now();
    var endDateOfDatePicker = DateTime(startDateOfDatePicker.year, startDateOfDatePicker.month + 6, startDateOfDatePicker.day);
    var newdt;
    DateTime newdatetime=DateTime.now();
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

    if(widget.locationDetails['activateon']!=null && dateLocal > DateTime.now().millisecondsSinceEpoch){
      newdt=formatDate.format((DateTime.parse(widget.locationDetails['activateon'])).toLocal());
      newdatetime=DateTime.parse(newdt);
    }
    var newenddt;
    if(widget.locationDetails['end_date']!=null){
      newenddt=formatDate.format((DateTime.parse(widget.locationDetails['end_date'])).toLocal());
      endDateOfDatePicker=DateTime.parse(newenddt);
    }
    return (widget.type=='Park Later') ? AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(getHorizontalSize(24.50,),)),
        title: Column(
          children:[
            Padding(
              padding: getPadding( left: 20,top: 0,right: 20),
              child: Text("Select date / time for reservation",textAlign:TextAlign.center,style: AppStyle.txtUrbanistRomanBold24.copyWith())
            ),
            Container(
             height:getVerticalSize(1.00),
             width: 333,
             margin: getMargin(left: 20,right: 20,top:24),
             decoration: BoxDecoration(color: ColorConstant.gray200)
            ),
          ]
        ),
        contentPadding: const EdgeInsets.only(left:32,top:5,right:32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 333,
              margin: getMargin(left: 10,top: 24,right: 10),
              child: DateTimeField(
                format: DateFormat("yyyy-MM-dd"),
                onShowPicker: (context, currentValue) async{
                  var pickDate =  await showDatePicker(
                    context: context,
                    firstDate: newdatetime,
                    initialDate: currentValue ?? newdatetime,
                    lastDate: endDateOfDatePicker,
                  );
                   if(pickDate !=null){
                      setState(() {
                        reservationDate = DateFormat('yyyy-MM-dd').format(pickDate);
                      });
                    }
                  return pickDate;
                },
                style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20),
                decoration: _decoration(ImageConstant.imgCalendar,'Select date'),
              ),  
            ),
            Container(
              width: 333,
              margin: getMargin(left: 10,top: 24,right: 10),
              child: DateTimeField(
                format: DateFormat("hh:mm a"),
                onShowPicker: (context, currentValue) async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );
                  if(time !=null){
                    setState(() {
                    reservationTime = time.format(context);
                    selectedTime = time;
                  });
                  }
                  return DateTimeField.convert(time);
                },
                style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20),
                decoration: _decoration(ImageConstant.imgTimecircle,'Select time'),
              ),
            ),
            Container(
              width: 333,
              margin: getMargin(left: 10,top: 24,right: 10),
              child:DropdownButtonFormField<String>(
                decoration:_decoration('','Length of stay (hh:mm)'),
                style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20),
                value: (futureValSelected.isEmpty) ?null :futureValSelected ,
                items: _dropDownItems.map((HourDownItems hourDownItems) => DropdownMenuItem(
                  value: hourDownItems.value,
                  child: Text(hourDownItems.label,style:AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20),),
                  )).toList(),
                  onChanged: (value) {
                    setState((){ 
                     futureValSelected = value!;
                   });
                },
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CustomButton(
                width: 333,
                text: "Select",
                onTap:() async {
                    reservationDialog = ProgressDialog(context,
                      message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),backgroundColor: Colors.blue.withOpacity(.5),
                    );
                    reservationDialog.show();
                    if(reservationDate.isEmpty){
                      utils.toast('Please select Date.');
                      reservationDialog.dismiss();
                    }
                    else if(reservationTime.isEmpty){
                      utils.toast('Please select time.');
                      reservationDialog.dismiss();
                    }
                    else if(futureValSelected.isEmpty){
                      utils.toast('Please select length.');
                      reservationDialog.dismiss();
                    }
                   else{
                      setState((){
                      DateFormat dateFormat = DateFormat("yyyy-MM-dd hh:mm a");
                      var currentDateTime=DateTime.now().toLocal().millisecondsSinceEpoch;
                      var selectedReservationDateTime = dateFormat.parse('$reservationDate $reservationTime').toLocal().millisecondsSinceEpoch;
                      if(selectedReservationDateTime < currentDateTime){
                        utils.toast('Time must be in the future.');
                        reservationDialog.dismiss();
                      }
                      else{
                        if(reservationTime.isNotEmpty && reservationDate.isNotEmpty && futureValSelected.isNotEmpty){
                          datetimeSelected = 1;
                          cancelReservation = 1;
                        }
                        DateTime reservationDateFormat = DateTime.now();
                        if(datetimeSelected==1){
                          DateFormat dateFormat = DateFormat("yyyy-MM-dd hh:mm a");
                          reservationDateFormat = dateFormat.parse('$reservationDate $reservationTime');
                        }
                        _pickASpace(datetimeSelected,reservationDateFormat,futureValSelected);
                      }
                    });
                  }
                },
                margin: getMargin(left: 15,top: 22,right: 15)
              ),
              CustomButton(
                  width: 333,
                  text: "Cancel",
                  onTap:() async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    var datetimeSelected =prefs.getInt("datetimeSelected");
                    if (datetimeSelected!=0){
                      //var cancelReservation = prefs.getInt("cancelReservation");
                      //var reservationDate = prefs.getString("reservationDate");
                      //var futureValSelected = prefs.getString("futureValSelected");
                      Navigator.of(context)
                        ..pop()
                        ..pop()
                        ..pop(); 
                    }else {
                      Navigator.pop(context);
                    }
                  },
                  margin: getMargin(
                      left: 15,
                      top: 12,
                      right: 15,
                      bottom: 24),
                  variant: ButtonVariant
                      .FillBlue50,
                  fontStyle: ButtonFontStyle
                      .UrbanistRomanBold16Blue800,
                )
            ]
          ),
        ],
      ): AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(getHorizontalSize(24.50,),)),
        title: Column(
          children:[
            Padding(
              padding: getPadding( left: 30,top: 0,right: 30),
              child: Text("How long is your visit?",textAlign:TextAlign.center,style: AppStyle.txtUrbanistRomanBold24.copyWith())
            ),
            Container(
             height:getVerticalSize(1.00),
             width: getHorizontalSize(316.00),
             margin: getMargin(left: 28,right: 28,top:24),
             decoration: BoxDecoration(color: ColorConstant.gray200)
            ),
          ]
        ),
        contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 330,
              margin: getMargin(left: 10,top: 26,right: 10),
              child:DropdownButtonFormField<String>(
                decoration:_decoration('','Length of stay (hh:mm)'),
                style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20),
                value: (futureValSelected.isEmpty) ?null :futureValSelected ,
                items: _dropDownItems.map((HourDownItems hourDownItems) => DropdownMenuItem(
                  value: hourDownItems.value,
                  child: Text(hourDownItems.label,style:AppStyle.txtUrbanistRegular18.copyWith(letterSpacing:0.20),),
                  )).toList(),
                  onChanged: (value) {
                    setState((){ 
                     currentValSelected = value!;
                   });
                },
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CustomButton(
                width: 330,
                text: "Select",
                onTap:() async {
                  reservationDialog = ProgressDialog(context,
                    message:const Text("Please wait...."),dismissable: false,title: const Text("Loading..."),backgroundColor: Colors.blue.withOpacity(.5),
                  );
                  reservationDialog.show();
                  if(currentValSelected.isEmpty){
                    utils.toast('Please select length.');
                    reservationDialog.dismiss();
                  }else{
                      DateTime reservationDateFormat = DateTime.now();
                      //var reservationFormattedData ='';
                      if(datetimeSelected==1){
                        DateFormat dateFormat = DateFormat("yyyy-MM-dd hh:mm a");
                        reservationDateFormat = dateFormat.parse('$reservationDate $reservationTime');
                        //reservationFormattedData = DateFormat('yMMMMd').format(reservationDateFormat);
                      }
                      setState((){
                       _pickASpace(datetimeSelected,reservationDateFormat,currentValSelected);
                    });
                  }
                },
                margin: getMargin(left: 15,right: 15)
              ),
              CustomButton(
                width: 330,
                text: "Cancel",
                onTap:() async {
                  Navigator.pop(context);
                },
                margin: getMargin(top: 12,bottom: 24,left: 15,right: 15),
                  variant: ButtonVariant.FillBlue50,
                  fontStyle: ButtonFontStyle.UrbanistRomanBold16Blue800,
                )
            ]
          ),
        ],
      );
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
      contentPadding:getPadding(left: 15,top: 15,right: 5,bottom: 15,
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
  _pickASpace(datetimeSelected,reservationDateFormat,reservationLength) async {
    Future.delayed(Duration.zero, () async {
      var setSpacesList;
      var uri;
      DateTime utcFormatDateTime;
      if (datetimeSelected == 1) {
        utcFormatDateTime = reservationDateFormat;
      }
      else {
        utcFormatDateTime = DateTime.now();
      }

      List<String> hourMin = reservationLength.split(":");
      int hour = int.parse(hourMin[0]);
      int mins = int.parse(hourMin[1]);
      var toDate = utcFormatDateTime.add(
        Duration(hours: hour, minutes: mins)
      );
      if(widget.type=='Park Later'){
        uri = '&section_id=${widget.sectionDetails['section_id']}&fromDate=${utcFormatDateTime.toUtc().toIso8601String()}&location_id=${widget.locationDetails['location_id']}&toDate=${toDate.toUtc().toIso8601String()}&stay_length=$reservationLength';
      }else{
        uri = '&section_id=${widget.sectionDetails['section_id']}&fromDate=${utcFormatDateTime.toUtc().toIso8601String()}&location_id=${widget.locationDetails['location_id']}&toDate=${toDate.toUtc().toIso8601String()}&stay_length=$reservationLength&user_id=${widget.userDetails['user_id']}';
      }
      var jsonResponse = await apiHelper.get(context,'get_section_spaces',widget.accessToken, uri);
      reservationDialog.dismiss();
      if(jsonResponse['response_code']==200){
        if(jsonResponse['data'].length!=0){
          setSpacesList = jsonResponse;
          List firstOddThenEven = [];
          
          if(setSpacesList != null){
            firstOddThenEven=setSpacesList['data'];
          }
          (firstOddThenEven == '') ?  Container() :
            await showDialog<String>(
              context: context,
                builder:(context) =>PickSpace(firstOddThenEven,widget.locationDetails,widget.sectionDetails,widget.accessToken,widget.userDetails,datetimeSelected,reservationDateFormat,reservationLength),
            );
            }else{
              utils.toast("No space available");
            } 
      }else{
        utils.toast(jsonResponse['message']);
      }
    });
  }
}
