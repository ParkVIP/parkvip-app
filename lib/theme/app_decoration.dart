import 'package:flutter/material.dart';
import 'package:ParkVip/core/app_export.dart';

class AppDecoration {
  static BoxDecoration get outlineBluegray1003f1 => BoxDecoration(
        color: ColorConstant.whiteA700,
        boxShadow: [
          BoxShadow(
            color: ColorConstant.blueGray1003f,
            spreadRadius: getHorizontalSize(
             1,
            ),
            blurRadius: getHorizontalSize(
              1,
            ),
            offset: const Offset(
             0,
              0,
            ),
          ),
        ],
      );
  static BoxDecoration get txtOutlineBlue7003f => const BoxDecoration();
  static BoxDecoration get fillLightBlue => BoxDecoration(
        color: ColorConstant.lightBlue,
      );
  static BoxDecoration get fillGray51 => BoxDecoration(
        color: ColorConstant.gray51,
      );
  static BoxDecoration get outlineGray100 => BoxDecoration(
        color: ColorConstant.whiteA700,
        border: Border.all(
          color: ColorConstant.gray100,
          width: getHorizontalSize(
            1.00,
          ),
        ),
      );
  static BoxDecoration get fillGray50 => BoxDecoration(
        color: ColorConstant.gray50,
      );
  static BoxDecoration get fillBlue50 => BoxDecoration(
        color: ColorConstant.blue50,
      );
  static BoxDecoration get outlineBlack9000c => BoxDecoration(
        color: ColorConstant.whiteA700,
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            spreadRadius: getHorizontalSize(
              2.00,
            ),
            blurRadius: getHorizontalSize(
              2.00,
            ),
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      );
  static BoxDecoration get outlineTrans9000c => BoxDecoration(
        color: ColorConstant.whiteA700,
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            spreadRadius: getHorizontalSize(
              2.00,
            ),
            blurRadius: getHorizontalSize(
              2.00,
            ),
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      );
  static BoxDecoration get fillBlue800 => BoxDecoration(
        color: ColorConstant.blue800,
      );
  static BoxDecoration get fillGray90099 => BoxDecoration(
        color: ColorConstant.gray90099,
      );
  static BoxDecoration get fillWhiteA70012 => BoxDecoration(
        color: ColorConstant.whiteA700,
      );
  static BoxDecoration get fillWhiteA700 => BoxDecoration(
        color: ColorConstant.whiteA700,
      );
}

class BorderRadiusStyle {
  static BorderRadius roundedBorder16 = BorderRadius.circular(
    getHorizontalSize(
      16.00,
    ),
  );

  static BorderRadius roundedBorder12 = BorderRadius.circular(
    getHorizontalSize(
      12.00,
    ),
  );

  static BorderRadius roundedBorder24 = BorderRadius.circular(
    getHorizontalSize(
      24.50,
    ),
  );

  static BorderRadius circleBorder9 = BorderRadius.circular(
    getHorizontalSize(
      9.30,
    ),
  );

  static BorderRadius circleBorder29 = BorderRadius.circular(
    getHorizontalSize(
      29.00,
    ),
  );

  static BorderRadius circleBorder90 = BorderRadius.circular(
    getHorizontalSize(
      90.00,
    ),
  );

  static BorderRadius circleBorder27 = BorderRadius.circular(
    getHorizontalSize(
      27,
    ),
  );
}
