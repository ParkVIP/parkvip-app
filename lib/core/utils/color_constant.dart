import 'dart:ui';
import 'package:flutter/material.dart';

class ColorConstant {
  static Color blueGray1003f = fromHex('#3fd3d1d8');
  static Color lightBlue=fromHex('2f6fb68f');
  static Color gray700 = fromHex('#616161');

  static Color gray51 = fromHex('#f9f9f9');

  static Color gray400 = fromHex('#bdbdbd');

  static Color gray500 = fromHex('#9e9e9e');

  static Color blue800 = fromHex('#2f6fb6');

  static Color gray90099 = fromHex('#9909101d');

  static Color gray800 = fromHex('#424242');

  static Color gray900 = fromHex('#212121');

  static Color red500 = fromHex('#f54336');

  static Color blue7003f = fromHex('#3f3c88c8');

  static Color black9000c = fromHex('#0c04060f');

  static Color gray200 = fromHex('#eeeeee');

  static Color gray300 = fromHex('#e0e0e0');

  static Color blue50 = fromHex('#ebf6ff');

  static Color gray50 = fromHex('#f6fafd');

  static Color gray100 = fromHex('#f5f5f5');

  static Color indigo300 = fromHex('#75a1c6');

  static Color black900 = fromHex('#000000');

  static Color bluegray400 = fromHex('#888888');
  static Color green = fromHex('#008000');
  static Color greenGrey = fromHex('#b9f6ca');

  static Color whiteA700 = fromHex('#ffffff');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
