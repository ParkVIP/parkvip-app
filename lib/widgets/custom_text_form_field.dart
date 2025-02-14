import 'package:flutter/material.dart';
import 'package:ParkVip/core/app_export.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
      this.shape,
      this.padding,
      this.variant,
      this.fontStyle,
      this.alignment,
      this.width,
      this.margin,
      this.controller,
      this.focusNode,
      this.isObscureText = false,
      this.readOnly = false,
      this.textInputAction = TextInputAction.next,
      this.textInputType = TextInputType.text,
      this.hintText,
      this.prefix,
      this.prefixConstraints,
      this.suffix,
      this.suffixConstraints,
      this.validator,
      this.errorColor = false,
    });

  TextFormFieldShape? shape;

  TextFormFieldPadding? padding;

  TextFormFieldVariant? variant;

  TextFormFieldFontStyle? fontStyle;

  Alignment? alignment;

  double? width;

  EdgeInsetsGeometry? margin;

  TextEditingController? controller;

  FocusNode? focusNode;

  bool? isObscureText;
  bool? errorColor;

  bool? readOnly;

  TextInputAction? textInputAction;
  TextInputType ? textInputType;

  String? hintText;

  Widget? prefix;

  BoxConstraints? prefixConstraints;

  Widget? suffix;

  BoxConstraints? suffixConstraints;

  FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: _buildTextFormFieldWidget(),
          )
        : _buildTextFormFieldWidget();
  }

  _buildTextFormFieldWidget() {
    return Container(
      width: getHorizontalSize(width ?? 0),
      margin: margin,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: _setFontStyle(),
        obscureText: isObscureText!,
        textInputAction: textInputAction,
        decoration: _buildDecoration(),
        validator: validator,
        readOnly:readOnly!,
        keyboardType: textInputType,
      ),
    );
  }

  _buildDecoration() {
    return InputDecoration(
      hintText: hintText ?? "",
      hintStyle: _setFontStyle(),
      errorStyle: TextStyle(color: errorColor==true ? ColorConstant.whiteA700 : Colors.red, fontSize: getFontSize(18),fontFamily:'Urbanist',fontWeight: FontWeight.w400),
      border: _setBorderStyle(),
      enabledBorder: _setBorderStyle(),
      focusedBorder: _setBorderStyle(),
      disabledBorder: _setBorderStyle(),
      prefixIcon: prefix,
      prefixIconConstraints: prefixConstraints,
      suffixIcon: suffix,
      suffixIconConstraints: suffixConstraints,
      fillColor: _setFillColor(),
      filled: _setFilled(),
      isDense: true,
      contentPadding: _setPadding(),
    );
  }

  _setFontStyle() {
    switch (fontStyle) {
      case TextFormFieldFontStyle.UrbanistSemiBold16:
        return TextStyle(
          color: ColorConstant.blue800,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w600,
        );
      case TextFormFieldFontStyle.UrbanistRomanMedium14:
        return TextStyle(
          color: ColorConstant.gray900,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w500,
        );
      case TextFormFieldFontStyle.UrbanistRomanMedium18:
        return TextStyle(
          color: Colors.grey[600],
          fontSize: getFontSize(
            18,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w500,
        );
      default:
        return TextStyle(
          color: ColorConstant.gray500,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w400,
        );
    }
  }

  _setOutlineBorderRadius() {
    switch (shape) {
      case TextFormFieldShape.CircleBorder19:
        return BorderRadius.circular(
          getHorizontalSize(
            19.00,
          ),
        );
      default:
        return BorderRadius.circular(
          getHorizontalSize(
            12.00,
          ),
        );
    }
  }

  _setBorderStyle() {
    switch (variant) {
      case TextFormFieldVariant.OutlineBlue800:
        return OutlineInputBorder(
          borderRadius: _setOutlineBorderRadius(),
          borderSide: BorderSide(
            color: ColorConstant.blue800,
            width: 2,
          ),
        );
      default:
        return OutlineInputBorder(
          borderRadius: _setOutlineBorderRadius(),
          borderSide: BorderSide.none,
        );
    }
  }

  _setFillColor() {
    switch (variant) {
      default:
        return ColorConstant.gray51;
    }
  }

  _setFilled() {
    switch (variant) {
      case TextFormFieldVariant.OutlineBlue800:
        return false;
      default:
        return true;
    }
  }

  _setPadding() {
    switch (padding) {
      case TextFormFieldPadding.PaddingTB21:
        return getPadding(
          left: 20,
          top: 20,
          right: 20,
          bottom: 21,
        );
      case TextFormFieldPadding.PaddingT22:
        return getPadding(
          left: 18,
          top: 22,
          right: 18,
          bottom: 18,
        );
      case TextFormFieldPadding.PaddingT13:
        return getPadding(
          left: 8,
          top: 13,
          right: 8,
          bottom: 8,
        );
      default:
        return getPadding(
          left: 22,
          top: 23,
          right: 22,
          bottom: 22,
        );
    }
  }
}

enum TextFormFieldShape {
  RoundedBorder12,
  CircleBorder19,
}

enum TextFormFieldPadding {
  PaddingTB21,
  PaddingT23,
  PaddingT22,
  PaddingT13,
}

enum TextFormFieldVariant {
  FillGray51,
  OutlineBlue800,
}

enum TextFormFieldFontStyle {
  UrbanistRegular14,
  UrbanistSemiBold16,
  UrbanistRomanMedium14,
  UrbanistRomanMedium18
}
