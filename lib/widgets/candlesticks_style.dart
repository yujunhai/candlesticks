import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/ma/ma_style.dart';
import 'package:candlesticks/widgets/candles/candles_style.dart';

class CandlesticksStyle {
  final Duration cameraDuration;
  final int initAfterNData;
  final int defaultViewPortX;
  final Color backgroundColor;
  //标线
  final int fractionDigits;
  final double paddingY;
  final int nX;
  final int nY;

  final CandlesStyle candlesStyle;
  final MaStyle maStyle;

  CandlesticksStyle(
      {this.candlesStyle, this.maStyle, this.cameraDuration, this.initAfterNData, this.backgroundColor, this.defaultViewPortX,
        this.fractionDigits, this.paddingY, this.nX, this.nY});
}
