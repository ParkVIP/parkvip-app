import 'package:flutter/material.dart';
import 'package:ParkVip/core/app_export.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {Key? key, this.shape,
      this.padding,
      this.variant,
      this.fontStyle,
      this.alignment,
      this.onTap,
      this.width,
      this.margin,
      this.text}) : super(key: key);

  ButtonShape? shape;

  ButtonPadding? padding;

  ButtonVariant? variant;

  ButtonFontStyle? fontStyle;

  Alignment? alignment;

  VoidCallback? onTap;

  double? width;

  EdgeInsetsGeometry? margin;

  String? text;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: _buildButtonWidget(),
          )
        : _buildButtonWidget();
  }

  _buildButtonWidget() {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: getHorizontalSize(width ?? 0),
        margin: margin,
        padding: _setPadding(),
        decoration: _buildDecoration(),
        child: Text(
          text ?? "",
          textAlign: TextAlign.center,
          style: _setFontStyle(),
        ),
      ),
    );
  }
  
  _buildDecoration() {
    return BoxDecoration(
      color: _setColor(),
      border: _setBorder(),
      borderRadius: _setBorderRadius(),
    );
  }

  _setPadding() {
    switch (padding) {
      case ButtonPadding.PaddingAll6:
        return getPadding(
          all: 6,
        );
      case ButtonPadding.PaddingAll10:
        return getPadding(
          all: 10,
        );
      case ButtonPadding.PaddingAll11:
        return getPadding(
          all: 11,
        );
      case ButtonPadding.PaddingAll22:
        return getPadding(
          all: 22,
        );
      case ButtonPadding.PaddingAll16:
        return getPadding(
          all: 16,
        );
      default:
        return getPadding(
          all: 18,
        );
    }
  }

  _setColor() {
    switch (variant) {
      case ButtonVariant.FillGray300:
        return ColorConstant.gray300;
      case ButtonVariant.FillGrayTwoSide300:
        return ColorConstant.gray300;
      case ButtonVariant.Gray300:
        return ColorConstant.gray300;
      case ButtonVariant.FillWhiteA700:
        return ColorConstant.whiteA700;
      case ButtonVariant.FillIndigo300:
        return ColorConstant.indigo300;
      case ButtonVariant.FillBlue50:
        return ColorConstant.blue50;
      case ButtonVariant.OutlineBlue8001_2:
        return ColorConstant.blue50;
      case ButtonVariant.OutlineGreen:
        return ColorConstant.blue800;
      case ButtonVariant.OutlineGray800:
        return ColorConstant.gray800;
      case ButtonVariant.OutlineBlue800:
        return null;
      case ButtonVariant.FillLightBlue:
        return const Color.fromRGBO(240, 248, 255,1.0);
      default:
        return ColorConstant.blue800;
    }
  }

  _setBorder() {
    switch (variant) {
      case ButtonVariant.OutlineBlue800:
        return Border.all(
          color: ColorConstant.blue800,
          width: getHorizontalSize(
            2.00,
          ),
        );
      case ButtonVariant.OutlineGray800:
        return Border.all(
          color: ColorConstant.gray800,
          width: getHorizontalSize(
            2.00,
          ),
        );
      case ButtonVariant.OutlineBlue8001_2:
        return Border.all(
          color: ColorConstant.blue800,
          width: getHorizontalSize(
            2.00,
          ),
        );
      case ButtonVariant.OutlineGreen:
        return Border.all(
          color: ColorConstant.blue50,
          width: getHorizontalSize(
            2.00,
          ),
        );
      case ButtonVariant.FillBlue800:
        return null;
      case ButtonVariant.FillGray300:
        return Border.all(
          color: ColorConstant.gray700,
          width: getHorizontalSize(
            2.00,
          ),
        );
      case ButtonVariant.FillGrayTwoSide300:
        return Border.symmetric(
          horizontal: BorderSide(
            color: ColorConstant.gray700,
            width: getHorizontalSize(2.00,),
          ),  
        );
      case ButtonVariant.FillWhiteA700:
      case ButtonVariant.FillIndigo300:
      case ButtonVariant.FillBlue50:
        return null;
      default:
        return null;
    }
  }

  _setBorderRadius() {
    switch (shape) {
      case ButtonShape.RoundedBorder6:
        return BorderRadius.circular(
          getHorizontalSize(
            6.00,
          ),
        );
      case ButtonShape.RoundedBorder20:
        return BorderRadius.circular(
          getHorizontalSize(
            20.50,
          ),
        );
      case ButtonShape.RoundedBorder16:
        return BorderRadius.circular(
          getHorizontalSize(
            16.00,
          ),
        );
      case ButtonShape.RoundedBorder12:
        return BorderRadius.circular(
          getHorizontalSize(
            12.00,
          ),
        );
      case ButtonShape.Square:
        return BorderRadius.circular(0);
      default:
        return BorderRadius.circular(
          getHorizontalSize(
            29.00,
          ),
        );
    }
  }

  _setFontStyle() {
    switch (fontStyle) {
      case ButtonFontStyle.UrbanistRomanMedium14:
        return TextStyle(
          color: ColorConstant.gray900,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w500,
        );

      case ButtonFontStyle.UrbanistRomanMedium18:
        return TextStyle(
          color: ColorConstant.gray900,
          fontSize: getFontSize(
            18,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w500,
        );
      
      case ButtonFontStyle.UrbanistRomanBold14:
        return TextStyle(
          color: ColorConstant.whiteA700,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w700,
        );
      case ButtonFontStyle.UrbanistRomanBold18:
        return TextStyle(
          color: ColorConstant.whiteA700,
          fontSize: getFontSize(
            18,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w700,
        );
      case ButtonFontStyle.UrbanistRomanBold18Blue800:
        return TextStyle(
          color: ColorConstant.blue800,
          fontSize: getFontSize(
            18,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w700,
        );
      case ButtonFontStyle.UrbanistRomanBold18Green:
        return TextStyle(
          color: ColorConstant.blue50,
          fontSize: getFontSize(
            18,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w700,
        );
      case ButtonFontStyle.UrbanistSemiBold16:
        return TextStyle(
          color: ColorConstant.blue800,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w600,
        );
      case ButtonFontStyle.UrbanistSemiBold16Gray:
        return TextStyle(
          color: ColorConstant.gray800,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w600,
        );
      case ButtonFontStyle.UrbanistRomanBold16Blue800:
        return TextStyle(
          color: ColorConstant.blue800,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w700,
        );
      default:
        return TextStyle(
          color: ColorConstant.whiteA700,
          fontSize: getFontSize(
            18,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w700,
        );
    }
  }
}

enum ButtonShape {
  Square,
  CircleBorder29,
  RoundedBorder20,
  RoundedBorder16,
  RoundedBorder12,
  RoundedBorder6
}

enum ButtonPadding {
  PaddingAll18,
  PaddingAll6,
  PaddingAll10,
  PaddingAll11,
  PaddingAll16,
  PaddingAll22,
}

enum ButtonVariant {
  FillBlue800,
  FillGray300,
  FillGrayTwoSide300,
  Gray300,
  FillWhiteA700,
  FillIndigo300,
  OutlineBlue800,
  OutlineGray800,
  FillBlue50,
  OutlineBlue8001_2,
  OutlineGreen,
  FillLightBlue,

}

enum ButtonFontStyle {
  UrbanistRomanBold16,
  UrbanistRomanMedium14,
  UrbanistRomanMedium18,
  UrbanistRomanBold14,
  UrbanistRomanBold18,
  UrbanistRomanBold18Blue800,
  UrbanistSemiBold16,
  UrbanistSemiBold16Gray,
  UrbanistRomanBold16Blue800,
  UrbanistRomanBold18Green,
}
