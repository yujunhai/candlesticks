import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobject.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';

class CandlesticksContext extends InheritedWidget {
  final List<double> candlesX;
  final Function(ExtCandleData candleData) onCandleDataFinish;
  final ExtCandleData extCandleData;
  final Offset touchPoint;
  final Function(Offset touchPoint, ExtCandleData candleData) onTouchCandle;

  CandlesticksContext({
    Key key,
    @required this.candlesX,
    @required Widget child,
    @required this.onCandleDataFinish,
    @required this.extCandleData,
    @required this.onTouchCandle,
    @required this.touchPoint,
  }) : super(key: key, child: child);

  static CandlesticksContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(CandlesticksContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(CandlesticksContext oldWidget) {
    return candlesX != oldWidget.candlesX;
  }
}
