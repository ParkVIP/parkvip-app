import 'dart:convert';
import 'package:pay/pay.dart';
import 'dart:io' show Platform;
import '../helper/utils.dart';
import 'package:flutter/material.dart';
import '../helper/api_base_helper.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../pages/locations.dart';
import 'package:ndialog/ndialog.dart';
import 'package:pay/pay.dart' as payPlugin;
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/widgets/custom_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pages/payment_configurations.dart' as payment_configurations;

var utils = Utils();
var appBarLogoDimension = {'height':50.0,'width':40.0};

class PaymentsPage extends StatefulWidget {
  final accessToken;
  final userDetails;
  final fromNotification;
  const PaymentsPage(this.accessToken,this.userDetails,this.fromNotification);
  
  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final apiHelper = ApiBaseHelper();
  final controller = CardEditController();
  bool cardButtonClicked = false;
  var noOfCardButtonClicked = 0;
  bool checkedValue = false;
  List _getListOfSavedCards = [];
  var usercreditpoint=0;
  var cardButtonClickedCount = 0;
  var defaultCard = '';
  var loggedInUserId = 0;
  bool isLoading = true;
  bool reverseChildParam = false;
  late ProgressDialog pr;
  bool addGPayOrAPayToList= kIsWeb?true:false;
  var noOfElementsInCardsList = 0;
  bool checkBoxValue = false;


  @override
  void initState() {
    controller.addListener(update);
    super.initState();
    setState(() {
      loggedInUserId = widget.userDetails['user_id'];
    });

    _getUserCredits().then(
        (s) => setState(() {
          if(s['response_code']==200){
            usercreditpoint=(s['data'][0]['credit_point']!=null) ? s['data'][0]['credit_point'] : 0;
          }
        })
    ); 

    if(_getListOfSavedCards.isEmpty){
      _getCustomerDetails(true,addGPayOrAPayToList).then(
        (s) => setState(() {
          _getListOfSavedCards = s['data'];
          noOfElementsInCardsList = _getListOfSavedCards.length;
          addGPayOrAPayToList= kIsWeb?(s['gpay_apay_added']==null) ? false : s['gpay_apay_added']:s['gpay_apay_added'];
          isLoading=false; 
        })
      );
    }

  }
  void update() => setState(() {});

  @override
  void dispose() {
    if(!kIsWeb){
     controller.removeListener(update);
     controller.dispose();
    }
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: Text("Payments",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if(kIsWeb){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)),
                );
              }else{
                setState((){
                  Navigator.pop(context);
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => LocationsPage(widget.accessToken,widget.userDetails)),);
                });
	            }
            },
          ),
      ),
      body: Container(
        margin:getMargin( top: 30),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            (usercreditpoint > 0) ? Container(
              padding:getPadding(top:15,bottom:20,left:10,right:10),
              color: const Color(0xFF299902),
              child: Column(
                  children:[
                    Center(
                      child: Text(
                      'CREDIT: \$$usercreditpoint',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white, 
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        '(Credit will always be used first on charges)',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]
              ),
            ) : Container(),
            Column(
              children: [
                _getListOfSavedCards.isNotEmpty ? Container(
                  decoration: AppDecoration.outlineTrans9000c.copyWith(borderRadius: BorderRadiusStyle.roundedBorder16),
                  height: usercreditpoint > 0 ?  100 : 150 ,
                  margin:getMargin(top:40,left:20,right: 20),
                  child: CardListView(),
                ) : Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: getPadding(left: 24, top: 56, right: 24,bottom:56),
                    child: Text("No card. Please add.",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtUrbanistRegular18.copyWith(letterSpacing: 0.20)
                    )
                  )
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () async {
                  setState(() {
                    cardButtonClicked = true;
                  });
                },
                child: Container(
                  width: getHorizontalSize(380),
                  margin: getMargin(top: 24,bottom:24),
                  padding:getPadding(top:18,bottom:18),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(240, 248, 255,1.0),
                    border: null,
                    borderRadius: BorderRadius.circular(
                      getHorizontalSize(
                        29.00,
                      ),
                    ),
                  ),
                  child:Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    crossAxisAlignment:CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding:getPadding(right:10),
                        child: CommonImageView(
                          svgPath: ImageConstant.imgClock,color:false,
                          height: getVerticalSize(15.00),
                          width: getHorizontalSize(16.00,)
                        )
                      ),
                      Text("Add card details",
                        textAlign: TextAlign.center,
                        style: AppStyle.txtUrbanistBlueRomanBold18.copyWith(letterSpacing: 0.20)
                      ),
                    ],
                  ),  
                ),
              ),
            ),
            (cardButtonClicked) ? AddCard() : Container(),
            !kIsWeb? (Platform.isIOS) ? (addGPayOrAPayToList) ? Container() : 
              payPlugin.ApplePayButton(
                //paymentConfiguration:PaymentConfiguration.fromJsonString('apple_pay_payment_profile.json') ,
                paymentConfiguration: PaymentConfiguration.fromJsonString(payment_configurations.defaultApplePay),
                 width:230,
                 height:51,
                 paymentItems: const [
                   payPlugin.PaymentItem(
                     label: 'ParkVIP',
                     amount: '0',
                     status: payPlugin.PaymentItemStatus.pending,
                   )
                 ],
                 style: payPlugin.ApplePayButtonStyle.black,
                // type: payPlugin.ApplePayButtonType.setUp,
                 type: payPlugin.ApplePayButtonType.setUp,
                 margin: const EdgeInsets.only(top: 15.0),
                 onPaymentResult: onApplePayResult,
                 loadingIndicator: const Center(
                   child: CircularProgressIndicator(),
                 ),
               ) : Container():Container(),
               !kIsWeb ? (Platform.isAndroid) ? (addGPayOrAPayToList) ? Container() : payPlugin.GooglePayButton(
                  //paymentConfiguration: PaymentConfiguration.fromJsonString('google_pay_payment_profile.json'),
                  paymentConfiguration: PaymentConfiguration.fromJsonString(payment_configurations.defaultGooglePay),
                  paymentItems: const [
                    payPlugin.PaymentItem(
                      label: 'ParkVIP',
                      amount: '0',
                      status: payPlugin.PaymentItemStatus.pending,
                    )
                  ],
                  type: payPlugin.GooglePayButtonType.pay,
                  margin: const EdgeInsets.only(top: 15.0),
                  onPaymentResult: onGooglePayResult,
                  loadingIndicator: const Center(child: CircularProgressIndicator()),
                ) : Container():Container(),
          ]
        ),
      ),
    );
  }

  Widget CardListView(){
    return ListView.builder(
      itemCount: _getListOfSavedCards.isNotEmpty ?  _getListOfSavedCards.length :1,
      itemBuilder: (context, int index) {
        return SizedBox(
          width: 40,
          child: CheckboxListTile(
            shape:RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: MaterialStateBorderSide.resolveWith(
                  (states) => const BorderSide(width: 2.5, color: Color.fromRGBO(47,111,182,1.0)),
              ),
            title:Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: kIsWeb?Text(
                      (_getListOfSavedCards[index]['wallet_type']=='google_pay' || _getListOfSavedCards[index]['brand']=='gpay_apay') ?'Google Pay${_getListOfSavedCards[index]['last4']!=''?"(${_getListOfSavedCards[index]['last4']})":''}':'.... .... .... .... ${_getListOfSavedCards[index]['last4']}',
                      style: AppStyle.txtUrbanistRomanBold18Gray900.copyWith()
                    ):Text(
                      (_getListOfSavedCards[index]['brand']=='gpay_apay')
                      ? (_getListOfSavedCards[index]['wallet_type']=='google_pay') ?  ".... .... .... .... ${_getListOfSavedCards[index]['last4']} ( Google Pay)"
                      : ".... .... .... .... ${_getListOfSavedCards[index]['last4']} ( Apple Pay)"
                      : '.... .... .... .... ${_getListOfSavedCards[index]['last4']}',
                      style: AppStyle.txtUrbanistRomanBold18Gray900.copyWith()
                    )
                  )
                ),
              ]
            ),
            secondary: SizedBox(
              width:40,
              height:30,
              child: _getListOfSavedCards[index]['default']==true ? Container() : TextButton(
                child: CommonImageView(
                  svgPath: ImageConstant.imgClose,
                  height:getSize(21.00),
                  width:getSize(21.00)),
                onPressed:  ()async {
                  setState((){
                    if(_getListOfSavedCards[index]['can_delete']==false){
                        _canNotDeletePayment(_getListOfSavedCards[index]['default']);
                      }else{
                        _deletePaymentMethod(_getListOfSavedCards[index]['id'],_getListOfSavedCards[index]['customer'],_getListOfSavedCards[index]['wallet_type']);
                      }
                  });
                }
              ),
            ),
            autofocus: false,
            activeColor: const Color.fromRGBO(47,111,182,1.0),
            checkColor: Colors.white,
            selected: checkedValue,
            value: _getListOfSavedCards[index]['default'],
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) async{
              if(_getListOfSavedCards[index]['can_delete']==false){
                var alertTitle = _getListOfSavedCards[index]['default']==true?'Default Card':'Session card';
                var alertContent = _getListOfSavedCards[index]['default']==true?'Cannot uncheck default card. At least one card should be selected.':'Please end your session/reservation before change this payment method';
                _showPopUp(context,alertTitle,alertContent);
              }else{
                if (value??false) {
                  setState(() {
                    updateDefaultCard(_getListOfSavedCards[index],'true');
                    _getListOfSavedCards[index]['default']=value;
                  });
                }else{
                  setState(() {
                    updateDefaultCard(_getListOfSavedCards[index],'false');
                    _getListOfSavedCards[index]['default']=value;
                  });
                }
              }
            },
          ),
        );
      }
    );
  }

  Widget AddCard(){
    return Form(
      child: SingleChildScrollView(
      reverse: true,
      child:Column(
        children: [
          CardField(
            controller: controller,
          ),
          CustomButton(
              width: getHorizontalSize(380),
              text: "Save",
              onTap : () async {
                controller.complete==true ? _handlePayPress() : null;
              },
              margin: getMargin( top: (usercreditpoint> 0) ? 148 : 148, bottom: 24,left:24,right:24),
              alignment: Alignment.center
          )
        ],
      ),
      )
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
      var paymentMethod = await Stripe.instance.createPaymentMethod(params :PaymentMethodParams.cardFromToken(paymentMethodData: PaymentMethodDataCardFromToken(
           token: tokenJson['id'].toString(),
         ),));
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

  _canNotDeletePayment(isDefault){
    pr = ProgressDialog(context,
        message:const Text("Please wait...."),
        dismissable: false,
        title: const Text("Loading..."),
        backgroundColor: Colors.blue.withOpacity(.5)
    );
    pr.show();
    var alertTitle = isDefault==true?'Default Card':'Session card';
    var alertContent = isDefault==true?'Cannot delete default card.':'Please end your session/reservation before deleting this payment method';
     pr.dismiss();
     _showPopUp(context,alertTitle,alertContent);
  }

  _showPopUp(context,alertTitle,alertContent){
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(alertTitle),
        content: Text(alertContent),
        actions: [
           TextButton(
            onPressed: () {
               Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  _deletePaymentMethod(paymentId,customerId,walletType) async {
    pr = ProgressDialog(context,
        message:const Text("Please wait...."),
        dismissable: false,
        title: const Text("Loading..."),
        backgroundColor: Colors.blue.withOpacity(.5)
    );
    pr.show();
    var queryParams='';
    if(paymentId!='gpay_apay'){
      if(walletType!=null){
        queryParams='?payment_id=$paymentId&customer_id=$customerId&cards_count=$noOfElementsInCardsList&gpay_apay_added=false&user_id=$loggedInUserId';
        }else{
          queryParams='?payment_id=$paymentId&customer_id=$customerId&cards_count=$noOfElementsInCardsList&gpay_apay_added=$addGPayOrAPayToList&user_id=$loggedInUserId';
        }
      
    }else{
      queryParams='?payment_id=$paymentId&cards_count=$noOfElementsInCardsList&gpay_apay_added=$addGPayOrAPayToList&user_id=$loggedInUserId';
    }

   
    var jsonResponse = await apiHelper.delete(context,'post_payment_method', widget.accessToken, queryParams);
    
    setState(() {
      utils.toast(jsonResponse['message']);
      _getCustomerDetails(true,addGPayOrAPayToList).then(
        (s) => setState(() {
          _getListOfSavedCards = s['data'];
          if(addGPayOrAPayToList==true){
            noOfElementsInCardsList = _getListOfSavedCards.length;
          }
          addGPayOrAPayToList= s['gpay_apay_added'];
          isLoading=false;
        })
      );
      pr.dismiss();
      if(kIsWeb){
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c) =>  PaymentsPage(widget.accessToken,widget.userDetails,false)),(route) => false);
      });
      }else{
            _refreshDAta();
      }
    });
  }

  _getCustomerDetails(list,addGPayOrAPayToList) async { 
      var requestFor = '';
      if(!kIsWeb){
        if (Platform.isAndroid) {
          requestFor = 'gpay';
        } else if (Platform.isIOS) {
          requestFor = 'apay';
        }
      }
      var queryParams ="&cus_id=0&platform=$requestFor&add_$requestFor=&user_id=${widget.userDetails['user_id']}";
      print('payment query---');
      print(queryParams);
      var jsonResponse = await apiHelper.get(context,'get_saved_cards', widget.accessToken, queryParams);
      return jsonResponse;
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
       if(kIsWeb){
          Navigator.push(context,MaterialPageRoute(builder: (context) => PaymentsPage(widget.accessToken,widget.userDetails,false)));
       }else{
         _refreshDAta();
      }
    }
    try {
      final billingDetails = BillingDetails(
        email:  widget.userDetails['email'],
      ); 
      final paymentMethodData =PaymentMethodData(billingDetails: billingDetails);
      final paymentMethod = await Stripe.instance.createPaymentMethod(params :PaymentMethodParams.card(paymentMethodData: paymentMethodData,));
      if(paymentMethod.id.isNotEmpty){
       await  _createCustomer(paymentMethod.id,paymentMethod.card.brand,paymentMethod.card.last4,paymentMethod.card.expYear,paymentMethod.card.expMonth,'false','card');
      }
    } catch (e) {
      var err = json.encode(e);
      var d = jsonDecode(err);
      if(d.isNotEmpty){
        if(d['error']['localizedMessage'] !=null){
           pr.dismiss(); 
          utils.longToast(d['error']['localizedMessage']);
        }        
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        rethrow;
      }
    }
  }

  _createCustomer(paymentId,cardType,last4,expYear,expMonth,usingExternalApp,paymentUsing,[paymentIntentId=""]) async {
    var formData = <String, dynamic>{};
    var wasGpay = 'false';
    var wasApay = 'false';
    formData['user_id'] = widget.userDetails['user_id'].toString();
    formData['payment_method_id'] = paymentId.toString();
    formData['last4'] = last4.toString();
    formData['exp_year']=expYear.toString();
    formData['exp_month']=expMonth.toString();
    formData['card_type'] = cardType.toString();
    formData['is_selected']='true';
    if(paymentUsing.toString()=='gpay'){
      wasGpay = 'true';
    }
    if(paymentUsing.toString()=='apay'){
      wasApay = 'true';
    }
    formData['external_app_payment'] = usingExternalApp;
    formData['payment_app'] = paymentUsing.toString();
    formData['was_gpay']=wasGpay;
    formData['was_apay']=wasApay;
    if(kIsWeb){
      formData['payment_intent_id'] = paymentIntentId;
    }

    var jsonResponse = await apiHelper.post(context,'post_payment_method', widget.accessToken, formData,'');
    if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
      var message='Card Details saved successfully';
      if(widget.fromNotification==true){
        var formNData = <String, dynamic>{};
        formNData['user_id'] = widget.userDetails['user_id'].toString();
        formNData['card_updated'] ='true';
        var response =await apiHelper.post(context,'update_failed_card',widget.accessToken,formNData,'');
        if(response['response_code']!=200){
          message='Error when update payment card status';
        }
      }
      utils.toast(message);
    }else{
      pr.dismiss();
      utils.toast(jsonResponse['message']);
    }
    pr.dismiss();
    if(kIsWeb){
        Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) =>  PaymentsPage(widget.accessToken,widget.userDetails,false)),
        (route) => false); 
    }else{
      _refreshDAta();
   }
  }

  updateDefaultCard(cardDetails,isSelected) async{
    var externalPayment = 'false';
    var paymentApp = 'card';
    var wasGpay = 'false';
    var wasApay = 'false';
    var formData = <String, dynamic>{};
    formData['user_id'] = widget.userDetails['user_id'].toString();
    formData['payment_method_id'] = cardDetails['id'].toString();
    formData['last4'] = cardDetails['last4'].toString();
    formData['exp_year']=cardDetails['exp_year'].toString();
    formData['exp_month']=cardDetails['exp_month'].toString();
    formData['card_type'] = cardDetails['brand'].toString();
    formData['customer_id']= cardDetails['customer'].toString();
    formData['is_selected']=isSelected;
    if(cardDetails['id']=='gpay_apay'){
      externalPayment = 'true';
      if(!kIsWeb){
        if (Platform.isAndroid) {
          paymentApp = 'gpay';
          wasGpay = 'true';
        } else if (Platform.isIOS) {
          paymentApp = 'apay';
          wasApay = 'true';
        }
      }
      formData['external_app_payment'] = externalPayment;
      formData['payment_app'] = paymentApp.toString();
      formData['was_gpay'] = wasGpay;
      formData['was_apay'] = wasApay;
    }
    var jsonResponse = await apiHelper.post(context,'post_payment_method', widget.accessToken, formData,'');
    if((!jsonResponse.isEmpty) && jsonResponse['response_code']==200){
      if(jsonResponse['data']['is_selected'] == true){
        var message='Payment Updated.';
        if(widget.fromNotification==true){
          var formNData = <String, dynamic>{};
          formNData['user_id'] = widget.userDetails['user_id'].toString();
          formNData['card_updated'] ='true';
          var jsonRes =await apiHelper.post(context,'update_failed_card',widget.accessToken,formNData,'');
          print('update_failed_card epose---------------');
          print(jsonRes['response_code']);
          if(jsonRes['response_code']!=200){
            message='Error when update payment card status';
          }
        }
        utils.toast(message);
      }else{
        utils.toast('Default payment card removed');
      }

      if(kIsWeb){
        Navigator.push(context,MaterialPageRoute(builder: (context) => PaymentsPage(widget.accessToken,widget.userDetails,false)));
      }else{
        _refreshDAta();
      }

    } else{
      utils.toast(jsonResponse['message']);
      if(kIsWeb){
        Navigator.push(context,MaterialPageRoute(builder: (context) => PaymentsPage(widget.accessToken,widget.userDetails,false)));
      }else{
        _refreshDAta();
      }
    }
  }

  _getUserCredits() async { 
      var queryParams ="?user_id=${widget.userDetails['user_id']}";
      var jsonResponse = await apiHelper.get(context,'get_credit', widget.accessToken, queryParams);
      return jsonResponse;
  }

  _refreshDAta(){
    cardButtonClicked = false;
    _getUserCredits().then(
        (s) => setState(() {
          if(s['response_code']==200){
            usercreditpoint=(s['data'][0]['credit_point']!=null) ? s['data'][0]['credit_point'] : 0;
          }
        })
    ); 

  _getCustomerDetails(true,addGPayOrAPayToList).then(
    (s) => setState(() {
          _getListOfSavedCards = s['data'];
          noOfElementsInCardsList = _getListOfSavedCards.length;
          addGPayOrAPayToList= s['gpay_apay_added']; 
          isLoading=false; 
        })
      );
  }
}
