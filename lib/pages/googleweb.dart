import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;


/// Renders a web-only SIGN IN button.
Widget buildSignInButton(context) {
  double pageWidth = MediaQuery.of(context).size.width;
  final googlebtnconfig = web.GSIButtonConfiguration(
    shape: web.GSIButtonShape.rectangular ,
    size: web.GSIButtonSize.large,
    theme : web.GSIButtonTheme.outline ,
    logoAlignment:web.GSIButtonLogoAlignment.center,
    //type : web.GSIButtonType.icon,
    text:web.GSIButtonText.continueWith,
    minimumWidth:pageWidth >450 ?450:pageWidth-30,

  );
  return web.renderButton(configuration: googlebtnconfig);
}
