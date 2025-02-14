import 'dart:convert';
import 'package:ParkVip/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'dart:async';
import '../helper/utils.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../helper/api_base_helper.dart';
import 'package:pay/pay.dart' as payPlugin;
import 'package:ndialog/ndialog.dart';
import '../helper/endpoints.dart';
import 'login.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pages/payment_configurations.dart' as payment_configurations;
import 'package:ParkVip/core/app_export.dart';


class CardDetailsPage extends StatefulWidget {
  final accessToken;
  final title;
  final userDetails;
  final locationDetails;
  final amounForPayment;
  final paymentList;
  const CardDetailsPage(this.accessToken,this.title,this.userDetails,this.locationDetails,this.amounForPayment,this.paymentList, {Key? key}) : super(key: key);
  static String tag = 'card-details-page';
  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  final controller = CardEditController();
  var appBarLogoDimension = {'height':50.0,'width':40.0};
  var utils = Utils();
  var endpoints = Endpoints();
  var isDefaultCard = true;
  final apiHelper = ApiBaseHelper();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool cardButtonClicked = false;
  // var _paymentItems = [];
  var paymentAmount;
  late ProgressDialog pr;
  @override
  void initState() {
    controller.addListener(update);
    super.initState();
    setState((){
    });
  }
  void update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text("Add card details",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
          iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
          child:
            !kIsWeb ?
            SingleChildScrollView(
              child:Column(
                children: <Widget>[
                  _setHeader(),
                   const SizedBox(height: 40,),
                    ((widget.paymentList==null) || (widget.paymentList['response_code']==404) || (widget.paymentList['data']['external_app_payment'] == false || widget.paymentList['data']['is_selected']==false))
                    ? Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              CardField(
                                controller: controller,
                              ),
                              const SizedBox(height: 20),
                              LoadingButton(
                                text: 'Save',
                                onPressed: controller.complete ? _handlePayPress : null,
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                          ),
                          const SizedBox(height: 30),
                          ]
                        )
                    ) : Container(),
                    (Platform.isIOS) ? payPlugin.ApplePayButton(
                      paymentConfiguration: PaymentConfiguration.fromJsonString(payment_configurations.defaultApplePay),
                      //paymentConfiguration: PaymentConfiguration.fromJsonString('apple_pay_payment_profile.json'),
                      width:230,
                      height:51,
                      paymentItems: [
                        payPlugin.PaymentItem(
                          label: 'ParkVIP',
                          amount: (double.parse(widget.amounForPayment)).toString(),
                          status: payPlugin.PaymentItemStatus.pending,
                        )
                      ],
                      style: payPlugin.ApplePayButtonStyle.black,
                      type: payPlugin.ApplePayButtonType.setUp,
                      margin: const EdgeInsets.only(top: 15.0),
                      onPaymentResult: onApplePayResult,
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ) : payPlugin.GooglePayButton(
                      paymentConfiguration: PaymentConfiguration.fromJsonString(payment_configurations.defaultGooglePay),
                      paymentItems: [
                        payPlugin.PaymentItem(
                          label: 'ParkVIP',
                          amount:  (double.parse(widget.amounForPayment)).toString(),
                          status: payPlugin.PaymentItemStatus.pending,
                        )
                      ],
                      type: payPlugin.GooglePayButtonType.pay,
                      margin: const EdgeInsets.only(top: 15.0),
                      onPaymentResult: onGooglePayResult,
                      loadingIndicator: const Center(child: CircularProgressIndicator()),
                    ),
                    
                ],
              )
          )
              :
          SingleChildScrollView(
            child:Column(
              children: <Widget>[
                  _setHeader(),
              const SizedBox(height: 40,),
              Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                CardField(
                                  controller: controller,
                                ),
                                const SizedBox(height: 20),
                                LoadingButton(
                                  text: 'Save',
                                  onPressed: controller.complete ? _handlePayPress : null,
                                ),
                                const SizedBox(height: 20),
                              ],
                            )
                        ),
                        const SizedBox(height: 30),
                      ]
                  )
              )
            ],
          )
          )
      ),
    );
  }
  _setHeader(){
    return Stack(
        children:[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.25,
            decoration: BoxDecoration(
              color: const Color(0xff0071bc),
              image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: utils.appColorFilter(),
                image: const ExactAssetImage('images/test.jpeg'),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.23,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  SizedBox(
                    width: double.infinity,
                    child:Text('Hello ${widget.userDetails['username']}',textAlign:TextAlign.center,style:const TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold,color: Colors.white)),
                  ),
                  const SizedBox(height: 10.0,),
                  const Text("Add your card details for payment",textAlign:TextAlign.center,style:TextStyle(fontSize: 15.0,color: Colors.white)),
                ]
            ),
          ),
        ]
    );
  }

  void onGooglePayResult(paymentResult) async {  
    pr = ProgressDialog(context,
        message:const Text("Please wait...."),
        dismissable: false,
        title: const Text("Loading..."),
        backgroundColor: Colors.blue.withOpacity(.5)
    );
    pr.show();   
    final token = paymentResult['paymentMethodData']['tokenizationData']['token'];
    final tokenJson = Map.castFrom(json.decode(token));
    if(tokenJson.isNotEmpty){
      final paymentMethod = await Stripe.instance.createPaymentMethod(params :PaymentMethodParams.cardFromToken(
        paymentMethodData: PaymentMethodDataCardFromToken(
          token: tokenJson['id'].toString(), 
        ),
      ));
      if(paymentMethod.id.isNotEmpty){
         await  _createCustomer(paymentMethod.id,paymentMethod.card.brand,paymentMethod.card.last4,paymentMethod.card.expYear,paymentMethod.card.expMonth,'true','gpay');
         pr.dismiss();
      }    
    } else{
      utils.toast('Token not created.');
      pr.dismiss();
    }
  }
  void onApplePayResult(paymentResult) async {
    final token = await Stripe.instance.createApplePayToken(paymentResult);
     pr = ProgressDialog(context,
         message:const Text("Please wait...."),
         dismissable: false,
         title: const Text("Loading..."),
         backgroundColor: Colors.blue.withOpacity(.5)
     );
    pr.show();
    if(token!=null){
       var paymentMethod = await Stripe.instance.createPaymentMethod(params :PaymentMethodParams.cardFromToken(paymentMethodData: PaymentMethodDataCardFromToken(
         token: token.id,
       ),));

       if(paymentMethod.id.isNotEmpty){
          await  _createCustomer(paymentMethod.id,paymentMethod.card.brand,paymentMethod.card.last4,paymentMethod.card.expYear,paymentMethod.card.expMonth,'true','apay');
          pr.dismiss();
       }
       else{
         utils.toast('Token incorrect.');
         pr.dismiss();
       }
    } else{
       utils.toast('Token not created.');
       pr.dismiss();
    }
  }

  Future<void> _handlePayPress() async {
    pr = ProgressDialog(context,
        message:const Text("Please wait...."),
        dismissable: false,
        title: const Text("Loading..."),
        backgroundColor: Colors.blue.withOpacity(.5)
    );
    pr.show();   
    if (!controller.complete) {
      return;
    }
    try {
      final billingDetails = BillingDetails(
        email:  widget.userDetails['email'],
      ); // mocked data for tests
      final paymentMethodData = PaymentMethodData( billingDetails: billingDetails);

      // final paymentMethod = await Stripe.instance.createPaymentMethod(PaymentMethodParams.card(
      // paymentMethodData: paymentMethodData,
      // ));
      final paymentMethod = await Stripe.instance.createPaymentMethod(params :PaymentMethodParams.card(
        paymentMethodData: paymentMethodData,
      ));

      if(paymentMethod.id.isNotEmpty){
	      return kIsWeb? _createCustomerWeb(paymentMethod.id,paymentMethod.card.brand,paymentMethod.card.last4,paymentMethod.card.expYear,paymentMethod.card.expMonth,'false','card',''):_createCustomer(paymentMethod.id,paymentMethod.card.brand,paymentMethod.card.last4,paymentMethod.card.expYear,paymentMethod.card.expMonth,'false','card');
	    }

    } catch (e) {
      var err = json.encode(e);
      var d = jsonDecode(err);
      if(d.isNotEmpty){
        if(d['error']['localizedMessage'] !=null){
          utils.longToast(d['error']['localizedMessage']);
          pr.dismiss();
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        return ;
      }
    }
  }

  _createCustomer(paymentId,cardType,last4,expYear,expMonth,usingExternalApp,paymentUsing) async {
    bool status = false;
    var wasGpay = 'false';
    var wasApay = 'false';
    var formData = <String, dynamic>{};
    formData['user_id'] = widget.userDetails['user_id'].toString();
    formData['payment_method_id'] = paymentId.toString();
    formData['last4'] = last4.toString();
    formData['exp_year']=expYear.toString();
    formData['exp_month']=expMonth.toString();
    formData['card_type'] = cardType.toString();
    formData['is_selected']='true';
    formData['external_app_payment'] = usingExternalApp.toString();
    formData['payment_app'] = paymentUsing.toString();
 
    if(paymentUsing.toString()=='gpay'){
      wasGpay = 'true';
    }
    if(paymentUsing.toString()=='apay'){
      wasApay = 'true';
    }
    formData['was_gpay']=wasGpay;
    formData['was_apay']=wasApay;
    var jsonResponse = await apiHelper.post(context,'post_payment_method', widget.accessToken,formData,'');
    if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
      status = true;
      utils.toast('Card Details saved successfully');
      pr.dismiss();
      Navigator.pop(context, status); 
      return jsonResponse;
    }else if(jsonResponse['response_code']==401){
      utils.longToast(jsonResponse['message']);         
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => LoginPage()),(Route<dynamic> route) => true,);
    } else{
      utils.toast(jsonResponse['message']);
      pr.dismiss();
      Navigator.pop(context, status); 
    }
  }

  _createCustomerWeb(paymentId,cardType,last4,expYear,expMonth,usingExternalApp,paymentUsing,paymentIntentId) async {
    bool status = false;
    var wasGpay = 'false';
    var wasApay = 'false';
    var formData = <String, dynamic>{};
    formData['user_id'] = widget.userDetails['user_id'].toString();
    formData['payment_method_id'] = paymentId.toString();
    formData['last4'] = last4.toString();
    formData['exp_year']=expYear.toString();
    formData['exp_month']=expMonth.toString();
    formData['card_type'] = cardType.toString();
    formData['external_app_payment'] = usingExternalApp.toString();
    formData['payment_app'] = paymentUsing.toString();
    formData['payment_intent_id'] = paymentIntentId;
    formData['is_selected']='true';
    if(paymentUsing.toString()=='gpay'){
      wasGpay = 'true';
    }
    if(paymentUsing.toString()=='apay'){
      wasApay = 'true';
    }
    formData['was_gpay']=wasGpay;
    formData['was_apay']=wasApay;
    var jsonResponse = await apiHelper.post(context,'post_payment_method', widget.accessToken,formData,'');
    if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
      utils.toast('Card Details saved successfully');
      pr.dismiss();
      Navigator.pop(context, status);
      return jsonResponse;
    }else if(jsonResponse['response_code']==401){
      utils.longToast(jsonResponse['message']);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => true,
      );
    } else{
      utils.toast(jsonResponse['message']);
      pr.dismiss();
      Navigator.pop(context, status);
    }
  }
}
