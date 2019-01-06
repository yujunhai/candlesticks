import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/ma/ma_style.dart';
import 'package:candlesticks/widgets/candles/candles_style.dart';

class CandlesticksStyle {
  final Duration cameraDuration;
  final int viewPortX;
  final Color backgroundColor;

  final CandlesStyle candlesStyle;
  final MaStyle maStyle;

  CandlesticksStyle(
      {this.candlesStyle, this.maStyle, this.cameraDuration, this.viewPortX, this.backgroundColor});
}
