import 'package:flutter/material.dart';
import '../pages/settings.dart';
import '../helper/utils.dart';
import 'package:ParkVip/core/app_export.dart';

var utils = Utils();
var appBarLogoDimension = {'height':50.0,'width':40.0};

//My profile page
class LanguagesPage extends StatefulWidget {
  final userDetails;
  final accessToken;
  const LanguagesPage(this.accessToken,this.userDetails, {Key? key}) : super(key: key);
  @override
  _LanguagesPageState createState() => _LanguagesPageState();
}


class _LanguagesPageState extends State<LanguagesPage> {
  // var allLanguages = ['English','Hindi','Chinese','Spanish'];
  var _setList;

  @override
  void initState() {
    super.initState();
    if(_setList == null){
        _getLanguageList().then(
          (s) => setState(() {_setList = s;})
       );
    }
  }
  @override
  Widget build(BuildContext context) {
    var allLanguages = _setList;
    final allLangaugesList = <Widget>[];

    if(allLanguages == null){
      return Scaffold(
        appBar: utils.customizedAppBarColor(context,appBarLogoDimension,widget.accessToken,widget.userDetails),
        body: Container(
          padding:const EdgeInsets.all(16),
          alignment: Alignment.center,
          child:const Text('Loading...',style: TextStyle(fontSize: 20))
        )
      );
    }else{
      for (var i = 0; i < allLanguages['data'].length; i++) {
        allLangaugesList.add(Column(
          children:[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage(widget.accessToken,allLanguages['data'][i]['name'],widget.userDetails)),
                );
              },
              child:Container(
                height: 50,
                alignment: Alignment.centerLeft,
                child: Text(allLanguages['data'][i]['name'],style: const TextStyle(fontSize: 20)),
              ),
            ),
            const Divider(color: Colors.grey,)
          ]
          )      
        );
      }
    }
    
    return Scaffold(
      //appBar: utils.customizedAppBarColor(context,appBarLogoDimension,widget.access_token,widget.userDetails),
        appBar: AppBar(
          backgroundColor: const Color(0xff0071bc),
          title: Text("Languages",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
        ),
      body: Container(
        padding: const EdgeInsets.only(top:10,bottom:10,left: 10,right: 10),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
           // children: (allLanguages == null)?Column():allLangaugesList,
            children: allLangaugesList,
          ),
        )
      )
    );
  }
  _getLanguageList() async {
    var apiHelper;
    var jsonResponse = await apiHelper.get(context,'get_languages', widget.accessToken, '');
    return jsonResponse;
  }
}