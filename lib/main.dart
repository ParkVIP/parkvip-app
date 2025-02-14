import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'pages/push_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import '.env.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:twilio_chat_conversation/twilio_chat_conversation.dart';
import 'package:ParkVip/chat/bloc/chat_bloc.dart';
import 'package:ParkVip/chat/common/providers/chats_provider.dart';
import 'package:ParkVip/chat/common/providers/models_provider.dart';
import 'package:ParkVip/chat/repository/chat_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb){
    await Firebase.initializeApp();
  } 
  runApp(const MyApp()); 

Stripe.publishableKey =stripePublishableKey;
Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
Stripe.urlScheme = 'flutterstripe';
await Stripe.instance.applySettings();

runApp(BlocProvider(
  create: (context) => ChatBloc(
    chatRepository: ChatRepositoryImpl(),
  ),
  child: const MyApp(),
));

}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final routes = <String, WidgetBuilder>{
    PushNotification.tag: (context) => PushNotification(),
  };

  TwilioChatConversation twilioChatConversationPlugin =TwilioChatConversation();
  ChatBloc? chatBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ModelsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            child: child!,
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          );
        },
        title: 'ParkVIP',
        theme: ThemeData(
          useMaterial3: false,
          primaryColor: Colors.transparent,
          fontFamily: 'Urbanist',
        ),
        home: BlocProvider(
          create: (context) => ChatBloc(
            chatRepository: ChatRepositoryImpl(),
          ),
          child: PushNotification(),
        ),
        routes: routes,
      ),
    );
  }
}

