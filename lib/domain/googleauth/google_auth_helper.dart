import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../.env.dart';

class GoogleAuthHelper {
  /// Handle Google Signin to authenticate user
  Future<GoogleSignInAccount?> googleSignInProcess() async {

    /*const List<String> scopes = <String>[
      'email',
      'profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/user.phonenumbers.read',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/user.birthday.read'
    ];

    GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: 'your-client_id.apps.googleusercontent.com',
    scopes: scopes,
    );*/
    GoogleSignIn googleSignInObj = GoogleSignIn();
    GoogleSignInAccount? googleUser = await googleSignInObj.signIn();
    print("here");
    print(googleUser);
    if(googleUser!=null){
      return googleUser;
    }else{
      return null;
    }
  }


  /// To Check if the user is already signedin through google
  alreadySignIn() async{
    GoogleSignIn googleSignInObj = GoogleSignIn();
    bool alreadySignIn = await googleSignInObj.isSignedIn();
    return alreadySignIn;
  }

  /// To signout from the application if the user is signed in through google
  Future<GoogleSignInAccount?> googleSignOutProcess() async {
    GoogleSignIn googleSignInObj = GoogleSignIn();
    GoogleSignInAccount? googleUser = await googleSignInObj.signOut();

    return googleUser;
  }

  Future<UserCredential?> signInWithGoogle() async {
    GoogleSignIn googleSignInObj = GoogleSignIn(clientId:google_client_id);
    final GoogleSignInAccount? googleUser = await googleSignInObj.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
