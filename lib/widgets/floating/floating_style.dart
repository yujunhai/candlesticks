import 'package:flutter/material.dart';

const double DefaultMinWidth = 60;

class FloatingStyle {
  final double frontSize;
  final Color frontColor;
  final Color borderColor;
  final double minWidth;

  FloatingStyle({this.frontSize, this.frontColor, this.borderColor, this.minWidth = DefaultMinWidth});
}
