import 'package:flutter/material.dart';

const double DefaultMinWidth = 60;

class FloatingStyle {
  final double frontSize;
  final Color frontColor;
  final Color crossColor;
  final Color borderColor;
  final Color backGroundColor;
  final double minWidth;

  FloatingStyle({this.frontSize, this.frontColor, this.crossColor, this.backGroundColor, this.borderColor, this.minWidth = DefaultMinWidth});
}
