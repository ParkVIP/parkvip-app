import 'package:flutter/material.dart';
import '../pages/login.dart';
import 'dart:async';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SplashScreen extends StatefulWidget {
  static String tag = 'splash-screen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _controller = VideoPlayerController.asset('assets/video/video.mp4');
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    loadVideoPlayer();
     _timer = Timer(const Duration(seconds: 5) ,()=>
    //Timer(Duration(seconds: 5),()=>
     kIsWeb==false 
    ? Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const SecondScreen()))
    : Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()))
    );
  }
  loadVideoPlayer(){
    // _controller = VideoPlayerController.asset('assets/video/video.mp4');
     _controller.addListener(() {
        setState(() {});
     });
    _controller.initialize().then((value){
      _controller.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
       // backgroundColor: ColorConstant.blue800,
        body: Center(
          child: _controller.value.isInitialized ? 
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller)
            ) 
            : Container(),
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
              svgPath: ImageConstant.splashScreen2,
              height:getVerticalSize(277.00),
              width: getHorizontalSize(277.00)
             ),
            ),
            Padding(
              padding:getPadding(top:137,left:15,right:15),
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
                  margin: getMargin(left: 24, right: 24,top:30,),
                  alignment: Alignment.center,
                  onTap : () async {
                    Navigator.pushReplacement(context,MaterialPageRoute(builder:(context) => const ThirdScreen()));
                  }
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                  height: 45,
                  margin: getMargin(left: 24, right: 24,top:20,bottom:24),
                  width: 380,
                  child:ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(47,111,182,1.0), backgroundColor: const Color.fromRGBO(240, 248, 255,1.0),
                      shape: const StadiumBorder(),
                      shadowColor: Colors.transparent,
                    ),
                    child:Container(
                      decoration: AppDecoration.txtOutlineBlue7003f,
                      child: Text("Skip",textAlign: TextAlign.center,style: AppStyle.txtUrbanistBlueRomanBold18.copyWith(letterSpacing: 0.20)))
                  ),
              ),
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
              svgPath: ImageConstant.splashScreen3,
              height:getVerticalSize(277.00),
              width: getHorizontalSize(277.00)),
            ),
            Padding(
              padding:getPadding(top:137,left:15,right:15),
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
                  margin: getMargin(left: 24, right: 24,top:30,),
                  alignment: Alignment.center,
                  onTap : () async {
                    Navigator.pushReplacement(context,MaterialPageRoute(builder:(context) => const FourScreen()));
                  }
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                  height: 45,
                  margin: getMargin(left: 24, right: 24,top:20,bottom:24),
                  width: 380,
                  child:ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(47,111,182,1.0), backgroundColor: const Color.fromRGBO(240, 248, 255,1.0),
                      shape: const StadiumBorder(),
                      shadowColor: Colors.transparent,
                    ),
                    child:Container(
                      decoration: AppDecoration.txtOutlineBlue7003f,
                      child: Text("Skip",textAlign: TextAlign.center,style: AppStyle.txtUrbanistBlueRomanBold18.copyWith(letterSpacing: 0.20)))
                  ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}
class FourScreen extends StatelessWidget {
  const FourScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children:[
            Padding(
              padding:getPadding(top:140,left:25,right:25),
              child:CommonImageView(
              color:false,
              svgPath: ImageConstant.splashScreen4,
              //height:getVerticalSize(220.00),
              //width: getHorizontalSize(300.00)
             ),
            ),
            Padding(
              padding:getPadding(top:157,left:15,right:15),
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
              margin: getMargin(left: 24, right: 24,top:30,),
              alignment: Alignment.center,
              onTap : () async {
                Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()));
              }
            ),
          ]
        ),
      ),
    );
  }
}