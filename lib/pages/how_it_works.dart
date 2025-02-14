import 'package:flutter/material.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
//import 'package:flutter/services.dart';


class HowItWorksScreen extends StatefulWidget {
  static String tag = 'how-it-works-screen';

  const HowItWorksScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return  _HowItWorksScreenState();
  }
}

class _HowItWorksScreenState extends State<HowItWorksScreen>  {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            children:[
              Padding(
                padding:getPadding(top:140,left:75,right:75),
                child:CommonImageView(
                  color:false,
                  svgPath: ImageConstant.splashScreen2,
                  height:getVerticalSize(277.00),
                  width: getHorizontalSize(277.00)),
              ),
              Padding(
                padding:getPadding(top:80,left:15,right:15),
                child:SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child:Text("Sign Up", textAlign:TextAlign.center,style:AppStyle.txtUrbanistRomanBold30.copyWith())
                ),
              ),
              Padding(
                padding:getPadding(top:40,left:15,right:15),
                child:Container(
                  padding:getPadding(left:20,right:20),
                  width: MediaQuery.of(context).size.width,
                  child:Text("Enter some basic info and click on the link emailed to you.",textAlign:TextAlign.center,style:AppStyle.txtUrbanistgray500Regular18.copyWith())
                ),
              ),
              Padding(
                padding:getPadding(top:24,left:75,right:75),
                child:CommonImageView(
                  color:false,
                  svgPath: ImageConstant.carousel1,
                ),
              ),
              CustomButton(
                  width: 380,
                  text: "Next",
                  margin: getMargin(left: 24, right: 24,top:24,),
                  alignment: Alignment.center,
                  onTap : () async {
                    Navigator.pushReplacement(context,MaterialPageRoute(builder:(context) => const SecondScreen()));
                  }
              ),
              CustomButton(
                  width: 380,
                  text: "Skip",
                  margin: getMargin(left: 24, right: 24,top:24,),
                  variant:ButtonVariant.FillLightBlue,
                  fontStyle:ButtonFontStyle.UrbanistRomanBold18Blue800,
                  alignment: Alignment.center,
                  onTap : () async {
                    Navigator.pop(context);
                  }
              ),
            ]
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            children:[
              Padding(
                padding:getPadding(top:140,left:75,right:75),
                child:CommonImageView(
                    color:false,
                    svgPath: ImageConstant.splashScreen3,
                    //height:getVerticalSize(277.00),
                    //width: getHorizontalSize(277.00)
                  ),
              ),
              Padding(
                padding:getPadding(top:100,left:15,right:15),
                child:SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child:Text("Park now or RSVP for later.", textAlign:TextAlign.center,style:AppStyle.txtUrbanistRomanBold30.copyWith())
                ),
              ),
              Padding(
                padding:getPadding(top:40,left:15,right:15),
                child:Container(
                    padding:getPadding(left:20,right:20),
                    width: MediaQuery.of(context).size.width,
                    child:Text("Activate a VIP Parking spot right away or reserve your space in the future.",textAlign:TextAlign.center,style:AppStyle.txtUrbanistgray500Regular18.copyWith())
                ),
              ),
              Padding(
                padding:getPadding(top:24,left:75,right:75),
                child:CommonImageView(
                  color:false,
                  svgPath: ImageConstant.carousel2,
                ),
              ),
              CustomButton(
                  width: 380,
                  text: "Next",
                  margin: getMargin(left: 24, right: 24,top:24,),
                  alignment: Alignment.center,
                  onTap : () async {
                    Navigator.pushReplacement(context,MaterialPageRoute(builder:(context) => const ThirdScreen()));
                  }
              ),
              CustomButton(
                  width: 380,
                  text: "Skip",
                  margin: getMargin(left: 24, right: 24,top:24,),
                  variant:ButtonVariant.FillLightBlue,
                  fontStyle:ButtonFontStyle.UrbanistRomanBold18Blue800,
                  alignment: Alignment.center,
                  onTap : () async {
                    Navigator.pop(context);
                  }
              ),
            ]
        ),
      ),
    );
  }
}
class ThirdScreen extends StatelessWidget {
  const ThirdScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            children:[
              Padding(
                padding:getPadding(top:140,left:75,right:75),
                child:CommonImageView(
                    color:false,
                    svgPath: ImageConstant.splashScreen4,
                  ),
              ),
              Padding(
                padding:getPadding(top:140,left:15,right:15),
                child:SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child:Text("Stay as long as you like", textAlign:TextAlign.center,style:AppStyle.txtUrbanistRomanBold30.copyWith())
                ),
              ),
              Padding(
                padding:getPadding(top:40,left:15,right:15),
                child:Container(
                    padding:getPadding(left:20,right:20),
                    width: MediaQuery.of(context).size.width,
                    child:Text("No need to worry about extending your time. Your session will end once you leave your spot.",textAlign:TextAlign.center,style:AppStyle.txtUrbanistgray500Regular18.copyWith())
                ),
              ),
              Padding(
                padding:getPadding(top:24,left:75,right:75),
                child:CommonImageView(
                  color:false,
                  svgPath: ImageConstant.carousel3,
                ),
              ),
              CustomButton(
                  width: 380,
                  text: "Done",
                  margin: getMargin(left: 24, right: 24,top:24,),
                  alignment: Alignment.center,
                  onTap : () async {
                    Navigator.pop(context);
                  }
              ),
            ]
        ),
      ),
    );
  }
}