import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ParkVip/chat/bloc/chat_bloc.dart';
import 'package:ParkVip/chat/bloc/chat_events.dart';
import 'package:ParkVip/chat/bloc/chat_states.dart';
import 'package:ParkVip/chat/common/progress_bar.dart';
import 'package:ParkVip/chat/common/shared_preference.dart';
import 'package:ParkVip/chat/repository/chat_repository.dart';
import 'package:ParkVip/chat/screens/chat_details_screen.dart';
import 'package:ParkVip/core/app_export.dart';
import 'package:ParkVip/chat/common/widgets/common_text_button_widget.dart';
import 'package:ParkVip/helper/api_base_helper.dart';
import 'package:twilio_chat_conversation/twilio_chat_conversation.dart';
import '../../helper/api_base_helper.dart';
import '../../helper/utils.dart';
import '../../pages/locations.dart';
class ConversationListScreen extends StatefulWidget {
  //final List conversationList;
  final userDetails;
  final accessToken;
  final bool is_twilio_admin;
  const ConversationListScreen(
      {Key? key, required this.userDetails,this.accessToken,required this.is_twilio_admin})
      : super(key: key);

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  ChatBloc? chatBloc;
  String loggedInUserIdentity = "";
  List conversationListNew=[];
  List conversationListWithUser=[];
  var _setAdminList;
  String author="";
  final apiHelper = ApiBaseHelper();
  final TwilioChatConversation twilioChatConversationPlugin = TwilioChatConversation();
  var conversationList=[];
  bool isConversationFetched=false;
  late Timer timer;
  var utils = Utils();
  @override
  void initState() {
    super.initState();
    chatBloc = BlocProvider.of<ChatBloc>(context);
    getLoggedInUser();
    print(_setAdminList);
      if(_setAdminList == null){
        _getAdminList().then(
          (s) => setState(() {
            if(s!=null){
              _setAdminList = s;
            }
          })
        );
        _getConversationList();
        timer = Timer.periodic(const Duration(seconds: 7), (Timer t) => _getConversationList());
    }
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }
  void getLoggedInUser() async {
    loggedInUserIdentity = await SharedPreference.getIdentity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstant.whiteA700,
        appBar: AppBar(
            backgroundColor: const Color(0xffffffff),
            title: Text("Live Support",style: AppStyle.txtUrbanistRomanBold24.copyWith()),
            iconTheme: const IconThemeData(color: Colors.black),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState((){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>LocationsPage(widget.accessToken,widget.userDetails)));
                });
              },
            ),
        ),
        body: BlocConsumer<ChatBloc, ChatStates>(
          builder: (BuildContext context, ChatStates state) {
            if(!widget.is_twilio_admin){
                return Center(
                  child : CommonTextButtonWidget(
                    isIcon: false,
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.82,
                    title: "Start Conversation",
                    titleFontSize: 14.0,
                    bgColor: Colors.blueGrey,
                    borderColor: Colors.white,
                    titleFontWeight: FontWeight.w600,
                    onPressed: () {
                      chatBloc!.add(CreateConversationEvent(
                        conversationName: widget.userDetails['username']!+' Support',
                        identity: widget.userDetails['username']));
                    },
                  ) ,
                );
            }else{
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (conversationList.isEmpty) ?
                  (isConversationFetched)?
                  Container(
                      margin: getMargin(left: 24, top: 24, right: 24),
                      alignment: Alignment.center,
                      child:Text('No Conversation available',style: AppStyle.txtUrbanistSemiBold20.copyWith(letterSpacing:0.20))
                  )  :
                  Container(
                    margin: getMargin(left: 24, top: 24, right: 24),
                    alignment: Alignment.center,
                    child:Text('Loading...',style: AppStyle.txtUrbanistSemiBold20.copyWith(letterSpacing:0.20))
                  ) :
                  Center(
                    child:ListView.builder(
                        itemCount:conversationList.length,
                        itemBuilder: (BuildContext context, int index){
                          return conversationList[index].length!=0 ? InkWell(
                            onTap: () {
                              setState(() {
                                author=conversationList[index]["createdBy"];
                              });
                              chatBloc!.add(JoinConversionEvent(
                                  conversationId: conversationList[index]["conversationSid"],
                                  conversationName:conversationList[index]["friendlyName"]));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                color: Colors.blueGrey,
                                elevation: 10,
                                child: ListTile(
                                  title: Text(
                                    (json.decode(conversationList[index]["attributes"]).length!=0 && json.decode(conversationList[index]["attributes"])['full_name']!=null)?json.decode(conversationList[index]["attributes"])['full_name']:conversationList[index]["createdBy"],
                                    style: const TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    (json.decode(conversationList[index]["attributes"]).length!=0 && json.decode(conversationList[index]["attributes"])['email']!=null && json.decode(conversationList[index]["attributes"])['contactno']!=null) ?
                                    json.decode(conversationList[index]["attributes"])['email']  +"\n" +json.decode(conversationList[index]["attributes"])['contactno'] : '',
                                    style: const TextStyle(fontSize: 12.0, color: Colors.white),
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                          _deleteConversation(conversationList[index]["createdBy"]);

                                           /* setState(() {
                                              author=conversationList[index]["createdBy"];                                            });
                                              chatBloc!.add(JoinConversionEvent(
                                                conversationId: conversationList[index]["conversationSid"],
                                                conversationName:conversationList[index]["friendlyName"]));*/
                                          },
                                          icon: const Icon(Icons.delete,color: Colors.greenAccent, )
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ) : Container();
                        },
                      ),
                  ),
                );
            } 
        }, listener: (BuildContext context, ChatStates state) {
          if (state is CreateConversionLoadingState) { 
            ProgressBar.show(context);
          }
          if (state is CreateConversionLoadedState) { 
            ProgressBar.dismiss(context);
            if(state.conversationAddedStatus=='Conversation created successfully.'){
             // Navigator.of(context).pop();
              _updateTwilioConversation();
              chatBloc!.add(SeeMyConversationsEvent());  
            }
          }
          if (state is SeeMyConversationsLoadingState) {
            ProgressBar.show(context);
          }
          if (state is SeeMyConversationsLoadedState) { 
            ProgressBar.dismiss(context);
            conversationListNew=state.conversationList;
            if(_setAdminList!=null){
              for (int i = 0; i < _setAdminList.length; i++) {
                chatBloc!.add(AddParticipantEvent(participantName: _setAdminList[i]['username'],conversationName: state.conversationList[0]["sid"]));
              }
            }
            chatBloc!.add(JoinConversionEvent(conversationId: conversationListNew[0]["sid"],conversationName: conversationListNew[0]["conversationName"]));
          }
          
          if (state is AddParticipantLoadingState) {
            //ProgressBar.show(context);
          }
          if (state is AddParticipantLoadedState) { 
           // ProgressBar.dismiss(context);
            //chatBloc!.add(JoinConversionEvent(conversationId: conversationListNew[0]["sid"],conversationName: conversationListNew[0]["conversationName"]));
          }

          if (state is JoinConversionLoadedState) { 
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                    create: (context) =>ChatBloc(chatRepository: ChatRepositoryImpl()),
                    child: ChatDetailsScreen(
                      conversationName: state.conversationName,
                      conversationSid: state.result,
                      author:author,
                      userDetails: widget.userDetails,
                      messageInit: (widget.is_twilio_admin==true) ? true : false ,
                      isDirect:false ,
                      accessToken: widget.accessToken,
                    )),
              ),
            ).then((value) => setState(() {}));
          }
        }));
  }
  _getAdminList() async{
    var jsonResponse = await apiHelper.get(context,'get_twilio_admin', widget.accessToken, "");
    if(jsonResponse['response_code']==200){
      return jsonResponse['data'];
    }else{
      return null;
    }
  }
  _updateTwilioConversation () async{
    var dataPost = <String, dynamic>{};
    dataPost['username'] =widget.userDetails['username'];
    dataPost['email'] = widget.userDetails['email'];
    dataPost['contactno'] = widget.userDetails['mobile_no'];
    dataPost['fullname'] = widget.userDetails['full_name']!=null?widget.userDetails['full_name']:widget.userDetails['username'];
    var jsonResponse = await apiHelper.post(context,'update_twilio_conversation', widget.accessToken, dataPost,'');
    return jsonResponse;
  }

  _getConversationList() async{
    print("called to refresh list****************************");
    String queryParams ='?username='+widget.userDetails['username'];
    var jsonResponse = await apiHelper.get(context,'fetch_twilio_conversation_list', widget.accessToken, queryParams);
    if(jsonResponse!=null){
      setState(() {
        conversationList = jsonResponse['data'].toList();
        isConversationFetched = true;
      });
    }
  }

  _deleteConversation (createdByUsername) async{
    var dataPost = <String, dynamic>{};
    dataPost['username'] = createdByUsername ;
    var jsonResponse = await apiHelper.post(context,'delete_twilio_conversation', widget.accessToken, dataPost,'');
    utils.longToast(jsonResponse['message']);
  }
}
