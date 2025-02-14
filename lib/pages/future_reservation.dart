import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:ParkVip/core/app_export.dart';

class FutureReservationPage extends StatefulWidget {
  final locationsData ;
  final listOfSections;
  final String title;
  static String tag = 'future-reservation-page';
  const FutureReservationPage(this.title,this.locationsData,this.listOfSections, {Key? key}) : super(key: key);
  @override
  _FutureReservationPageState createState() => _FutureReservationPageState();
}

class _FutureReservationPageState extends State<FutureReservationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text(widget.title,style: AppStyle.txtUrbanistRomanBold24.copyWith()),
          iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _setHeaderImage(widget.locationsData['image']),
              const SizedBox(height: 10.0),
              _selectParkingTime(context),
              const SizedBox(height: 10.0),
              // _setSectionsHeaderView(),
              _setTableView(),
              const SizedBox(height: 20.0),
          ]),
        ),
      );
  }
  _setHeaderImage(imageName){    
    return Image(
      image: AssetImage("images/" + imageName),
      height: 200,
      width: 500, 
      fit: BoxFit.fill
    );
  }
  _setTableView(){
    List listOfSections = widget.listOfSections;
    //  DataTableWidget(this.listOfSections);     // Getting the data from outside, on initialization
    return DataTable(
      columnSpacing: 30,
      columns: const [
        DataColumn(label: Text('Sections',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Total Spaces',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold))),
        DataColumn(label: Text('')),
      ],
      rows:
        listOfSections // Loops through dataColumnText, each iteration assigning the value to element
          .map(
            ((element) => DataRow(
              cells: <DataCell>[
                DataCell(Text(element["section_name"],style: const TextStyle(fontSize: 15.0))),
                DataCell(Text(element["total_spaces"],style: const TextStyle(fontSize: 15.0))),
                DataCell(Container(
                  alignment: Alignment.center,
                  height: 45,
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(47,111,182,1.0),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: (){_renderOnReserveBtnClick();},
                    child: Column(
                      children: [
                        Text("Reserve",
                          style: const TextStyle(fontSize: 16.0).copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          )
        ),
      )
      .toList()
    );
  }

  _selectParkingTime(BuildContext context){
    final format = DateFormat("MMMM d, y h:m a");
    return Column(children: <Widget>[
      const Text('Select Time For Parking',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
      DateTimeField(
        scrollPadding: const EdgeInsets.all(20),
        format: format,
        enabled: true,
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(2019),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
      )
    ]);
  }
  _renderOnReserveBtnClick(){

  }
}