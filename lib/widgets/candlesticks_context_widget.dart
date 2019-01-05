import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobject.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';

class CandlesticksContext extends InheritedWidget {
  final UICamera uiCamera;

  final Function(ExtCandleData candleData, UIORect aabb) onAABBChange;

  CandlesticksContext({
    Key key,
    @required this.uiCamera,
    @required this.onAABBChange,
    @required Widget child,
  }) : super(key: key, child: child);

  static CandlesticksContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(CandlesticksContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(CandlesticksContext oldWidget) {
    return uiCamera != oldWidget.uiCamera;
  }
}
