import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobject.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';

class CandlesticksContext extends InheritedWidget {
  final List<double> candlesX;
  final Function(ExtCandleData candleData) onCandleDataFinish;

  CandlesticksContext({
    Key key,
    @required this.candlesX,
    @required Widget child,
    @required this.onCandleDataFinish,
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
