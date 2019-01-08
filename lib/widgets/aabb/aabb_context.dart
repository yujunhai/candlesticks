import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';

class AABBContext extends InheritedWidget {
  final UICamera uiCamera;
  final double durationMs;
  final Stream<ExtCandleData> extDataStream;
  final UIOPoint minPoint;
  final UIOPoint maxPoint;

  final Function(ExtCandleData candleData, UIORect aabb) onAABBChange;

  AABBContext({
    Key key,
    @required this.uiCamera,
    @required this.onAABBChange,
    @required this.durationMs,
    @required Widget child,
    @required this.extDataStream,
    @required this.minPoint,
    @required this.maxPoint,
  }) : super(key: key, child: child);

  static AABBContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AABBContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(AABBContext oldWidget) {
    return uiCamera != oldWidget.uiCamera || durationMs != oldWidget.durationMs;
  }
}
