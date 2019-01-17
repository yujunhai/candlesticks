import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/ma/ma_style.dart';
import 'package:candlesticks/widgets/candles/candles_style.dart';
import 'package:candlesticks/widgets/floating/floating_style.dart';


CandlesticksStyle DefaultDarkCandleStyle = CandlesticksStyle(
  backgroundColor: Color(0xFF060827),
  cameraDuration: Duration(milliseconds: 500),
  initAfterNData: 50,
  defaultViewPortX: 50,
  minViewPortX: 20,
  maxViewPortX: 128,
  fractionDigits:4,
  lineColor: Colors.white.withOpacity(0.2),
  nX: 5,
  nY: 4,
  floatingStyle: FloatingStyle(
    backGroundColor: Colors.black.withOpacity(0.8),
    frontSize: 10,
    borderColor: Colors.white,
    frontColor: Colors.white,
    crossColor: Colors.white,
  ),
  candlesStyle: CandlesStyle(
      positiveColor: Colors.redAccent,
      negativeColor: Colors.greenAccent,
      paddingX: 0.5,
      cameraPaddingY: 0.1,
      duration: Duration(milliseconds: 200)),
  maStyle: MaStyle(
      currentColor:Colors.white.withOpacity(0.85),
      cameraPaddingY: 0.2,
      shortCount: 5,
      shortColor: Colors.yellowAccent,
      middleCount: 15,
      middleColor: Colors.greenAccent,
      longCount: 30,
      longColor: Colors.deepPurpleAccent,
      duration: Duration(milliseconds: 200)),
);

CandlesticksStyle DefaultLightCandleStyle = CandlesticksStyle(
  backgroundColor: Color(0xffffffff),
  cameraDuration: Duration(milliseconds: 500),
  initAfterNData: 50,
  defaultViewPortX: 50,
  minViewPortX: 20,
  maxViewPortX: 128,
  fractionDigits:4,
  lineColor: Colors.white.withOpacity(0.2),
  nX: 5,
  nY: 4,
  floatingStyle: FloatingStyle(
    backGroundColor: Colors.black.withOpacity(0.8),
    frontSize: 10,
    borderColor: Colors.white,
    frontColor: Colors.white,
    crossColor: Colors.white,
  ),
  candlesStyle: CandlesStyle(
      positiveColor: Colors.redAccent,
      negativeColor: Colors.greenAccent,
      paddingX: 0.5,
      cameraPaddingY: 0.1,
      duration: Duration(milliseconds: 200)),
  maStyle: MaStyle(
      currentColor:Colors.white.withOpacity(0.85),
      cameraPaddingY: 0.2,
      shortCount: 5,
      shortColor: Colors.yellowAccent,
      middleCount: 15,
      middleColor: Colors.greenAccent,
      longCount: 30,
      longColor: Colors.deepPurpleAccent,
      duration: Duration(milliseconds: 200)),
);

class CandlesticksStyle {
  final Duration cameraDuration;
  final int initAfterNData;
  final int defaultViewPortX;
  final int minViewPortX;
  final int maxViewPortX;
  final Color backgroundColor;
  final Color lineColor;
  //标线
  final int fractionDigits;
  final double paddingY;
  final int nX;
  final int nY;

  final FloatingStyle floatingStyle;
  final CandlesStyle candlesStyle;
  final MaStyle maStyle;

  CandlesticksStyle(
      {this.minViewPortX, this.maxViewPortX, this.floatingStyle, this.lineColor, this.candlesStyle, this.maStyle, this.cameraDuration, this.initAfterNData, this.backgroundColor, this.defaultViewPortX,
        this.fractionDigits, this.paddingY, this.nX, this.nY});
}
