import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:twilio_chat_conversation/twilio_chat_conversation.dart';
import 'package:ParkVip/chat/bloc/chat_bloc.dart';
import 'package:ParkVip/chat/bloc/chat_events.dart';
import 'package:ParkVip/chat/bloc/chat_states.dart';
import 'package:ParkVip/chat/common/providers/chats_provider.dart';
import 'package:ParkVip/chat/common/providers/models_provider.dart';
import 'package:ParkVip/chat/common/widgets/bubble_widget.dart';
import 'package:ParkVip/chat/common/widgets/chat_text_widget.dart';
import 'package:ParkVip/core/app_export.dart';
import 'dart:async';
import 'package:ParkVip/helper/api_base_helper.dart';
import 'package:ParkVip/chat/screens/conversation_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/locations.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String conversationName;
  final String conversationSid;
  final String author;
  final userDetails;
  final bool messageInit;
  final bool isDirect;
  final accessToken;

  const ChatDetailsScreen(
      {Key? key,
      required this.conversationName,
      required this.conversationSid,
      required this.author,
      required this.userDetails,
      required this.messageInit,
      required this.isDirect,
      this.accessToken,
    })
      : super(key: key);

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  ChatBloc? chatBloc;
  final msgController = TextEditingController();
  final msgCountController = TextEditingController();
  Timer? timer;
  bool? isFromChatGpt = false;
  String typeMessages = "";
  List allMessageList = [];
  List messageList = [];
  Map<String, dynamic> attributesList ={} ;
  final ScrollController _controller = ScrollController(initialScrollOffset: 0);
  final twilioChatConversationPlugin = TwilioChatConversation();
  final apiHelper = ApiBaseHelper();
  var _setAdminList;

  @override
  void initState() {
    
    super.initState();
    setScreenData(true);
    if(widget.messageInit){
      initializeDate();
    }
    if(_setAdminList == null){
      _getAdminList().then(
        (s) => setState(() {
          if(s!=null){
            _setAdminList = s;
          }
        })
      );
    }
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => initializeDate());
    if(attributesList.isEmpty){
      if(widget.author!='' && (widget.author!= widget.userDetails['username'] )){
        _getConversationCreatedByDetails(widget.author).then(
              (s) => setState(() {
              if(s!=null){
                attributesList['email'] = s['data'][0]['email'];
                attributesList['contactno'] = s['data'][0]['mobile_no'];
                attributesList['full_name'] = s['data'][0]['full_name']!=null?s['data'][0]['full_name']:s['data'][0]['username'];
                attributesList['username'] = s['data'][0]['username'];
              }
            })
        );
      }else{
        setState(() {
          attributesList['email'] = widget.userDetails['email'];
          attributesList['contactno'] = widget.userDetails['mobile_no'];
          attributesList['full_name'] = widget.userDetails['full_name']!=null?widget.userDetails['full_name']:widget.userDetails['username'];
          attributesList['username'] =  widget.userDetails['username'];
        });
      }
    }
  }

  setScreenData(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isChatScreen", value);
  }

  void initializeDate() {
      chatBloc = BlocProvider.of<ChatBloc>(context);
      chatBloc!.add(
          ReceiveMessageEvent(conversationId: widget.conversationSid));
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _controller.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      });

  }

  @override
  void dispose() {
    setScreenData(false);
    // TODO: implement dispose
    //unSubscribeToMessageUpdate();
    _controller.dispose();
    msgController.dispose();
    msgCountController.dispose();
    timer!.cancel();
    super.dispose();
  }

  void unSubscribeToMessageUpdate() {
    twilioChatConversationPlugin.unSubscribeToMessageUpdate(conversationSid: widget.conversationSid);
  }

  void subscribeToMessageUpdate() {
    twilioChatConversationPlugin.subscribeToMessageUpdate(conversationSid: widget.conversationSid);
    twilioChatConversationPlugin.onMessageReceived.listen((event) {
      if (mounted) {
        setState(() {
          messageList.add(event);
          messageList.sort((a, b) => (b['dateCreated']).compareTo(a['dateCreated']));
          allMessageList=messageList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return SafeArea(
      child: Scaffold(
          backgroundColor: ColorConstant.whiteA700,
          appBar: AppBar(
              backgroundColor: const Color(0xffffffff),
              title: Text((attributesList.isNotEmpty)? (attributesList['full_name']!=null) ? attributesList['full_name'] : attributesList['username'] : '',
                style: AppStyle.txtUrbanistRomanBold24.copyWith()),
              iconTheme: const IconThemeData(color: Colors.black),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState((){
                    if(widget.isDirect){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>LocationsPage(widget.accessToken,widget.userDetails)));
                    }else{
                      if(widget.userDetails['is_twilio_admin']){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) =>ConversationListScreen(userDetails: widget.userDetails,accessToken:widget.accessToken,is_twilio_admin:widget.userDetails['is_twilio_admin'])),
                        );
                      }else{
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>LocationsPage(widget.accessToken,widget.userDetails)));
                      }

                    }
                  });
                },
              ),
          ),
          body: BlocConsumer<ChatBloc, ChatStates>(
              builder: (BuildContext context, ChatStates state) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView.separated(
                        controller: _controller,
                        itemCount: allMessageList.length,
                        reverse: true,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final message = allMessageList[index];
                          var isMe = ( (message['author'] == widget.userDetails['full_name'] || message['author'] == widget.userDetails['username']) && message['attributes'] != "true") ? true : false;
                          print(message['fullname']);
                          if(message['fullname']!=null){
                            return BubbleWidget(messageMap: message, isMe: isMe);
                          }

                        },
                        separatorBuilder: (BuildContext context, int index) =>const Padding(padding: EdgeInsets.only(bottom: 4)),
                      )
                    ),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    ChatTextWidget(
                      hintText: "Type here..",
                      msgController: msgController,
                      haveValidation: true,
                      onSend: (typeMessage) {
                        List<String>? substrings = typeMessage.split(",");
                        if (substrings[0].contains("ChatGPT")) {
                          chatBloc!.add(SendMessageEvent(enteredMessage: typeMessage,conversationName: widget.conversationSid,isFromChatGpt: false));
                          chatBloc!.add(SendMessageToChatGptEvent(modelsProvider: modelsProvider,chatProvider: chatProvider,typeMessage: typeMessage));
                        } else {
                          chatBloc!.add(SendMessageEvent(enteredMessage: typeMessage,conversationName: widget.conversationSid,isFromChatGpt: false));
                        }

                       /* _sendMessage(typeMessage);
                        msgController.text = "";
                        chatBloc!.add(ReceiveMessageEvent(conversationId: widget.conversationSid));*/
                        _sendNotification();
                        _updateTwilioConversation(widget.conversationSid);

                      },
                    ),
                  ],
                ),
              ),
            );
          }, listener: (BuildContext context, ChatStates state) {
            if (state is ReceiveMessageLoadedState) {
              for(var i=0;i<state.messagesList.length;i++) {
                var isMe = ( (state.messagesList[i]['author'] == widget.userDetails['full_name'] || state.messagesList[i]['author'] == widget.userDetails['username']) && state.messagesList[i]['attributes'] != "true") ? true : false;
                if(isMe){
                  state.messagesList[i]['fullname'] = widget.userDetails['full_name']!=null?widget.userDetails['full_name']:widget.userDetails['username'];
                }else{
                  if(state.messagesList[i]['author']== attributesList['username']){
                    state.messagesList[i]['fullname'] = attributesList['full_name'];
                  }else{
                    if(_setAdminList!=null){
                      var adminfound = _setAdminList.firstWhere((element) => element['username'] == state.messagesList[i]['author'], orElse: () => null);
                      if(adminfound!=null){
                        state.messagesList[i]['fullname'] = adminfound['full_name']!=null?adminfound['full_name']:adminfound['username'];
                      }
                    }
                  }
                }
              }
              if (mounted) {
                setState(() {
                  print("MESSAGES FETCHED=here============================");
                  allMessageList=[];
                  allMessageList.addAll(state.messagesList);
                  allMessageList.sort((a, b) => (b['dateCreated']).compareTo(a['dateCreated']));
                  print(allMessageList);
                });
              }
            }
            if (state is SendMessageLoadedState) {
              msgController.text = "";
              // Provide messageCount to control the number of messages to be displayed in a conversation
              chatBloc!.add(ReceiveMessageEvent(conversationId: widget.conversationSid));
            }
            if (state is SendMessageToChatGptLoadedState) { 
              chatBloc!.add(SendMessageEvent(enteredMessage: state.chatGptListList[0].msg,conversationName: widget.conversationSid,isFromChatGpt: true));
            }
          })),
    );
  }

  _sendNotification() async{
    String queryParams ='?is_twilio_admin='+widget.userDetails['is_twilio_admin'].toString()+'&senderName='+widget.userDetails['full_name'];
    if(widget.userDetails['is_twilio_admin']){
      queryParams += '&username='+widget.author;
    }

    var jsonResponse = await apiHelper.get(context,'send_notification', widget.accessToken, queryParams);
    return jsonResponse;
  }

  _updateTwilioConversation (conversationId) async{
    print("UPDATE***********************************************************");
    var dataPost = <String, dynamic>{};
    dataPost['email'] = attributesList['email'];
    dataPost['contactno'] = attributesList['contactno'];
    dataPost['username'] = widget.userDetails['username'];
    dataPost['fullname'] =  attributesList['full_name'];
    print(dataPost);
    dataPost['conversationSid'] = conversationId;
    if(dataPost['email']!='' && dataPost['fullname']!=''){
      await apiHelper.post(context,'update_twilio_conversation', widget.accessToken, dataPost,'');
    }
  }

  _sendMessage(messagetext) async{
    print("SEND MSG***********************************************************");
    var dataPost = <String, dynamic>{};
    dataPost['message'] = messagetext;
    dataPost['conversationSid'] = widget.conversationSid;
    dataPost['author'] = widget.userDetails['full_name']!=null?widget.userDetails['full_name']:widget.userDetails['username'];
    print(dataPost);
    var result = await apiHelper.post(context,'send_twilio_message', widget.accessToken, dataPost,'');
    print(result);
  }

  _getConversationCreatedByDetails(username) async{
    String queryParams ='?username=$username';
    var jsonResponse = await apiHelper.get(context,'get_user_by_username', widget.accessToken, queryParams);
    return jsonResponse;
  }

  void popToParticularScreen() {
    Navigator.popUntil(
      context,
      ModalRoute.withName('/particular_screen_route_name'), // Replace with the route name of the particular screen
    );
  }

  _getAdminList() async{
    var jsonResponse = await apiHelper.get(context,'get_twilio_admin', widget.accessToken, "");
    if(jsonResponse['response_code']==200){
      return jsonResponse['data'];
    }else{
      return null;
    }
  }
}
