import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:candlesticks/widgets/aabb/aabb_widget.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/treedlist.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';


const ZERO = 0.00000001;

abstract class AABBState extends State<AABBWidget>
    with TickerProviderStateMixin {
  TreedListMin<double> candlesMaxY = TreedListMin(null, reverse: -1);
  TreedListMin<double> candlesMinY = TreedListMin(null);
  StreamSubscription<CandleData> subscription;
  CandlesticksContext candlesticksContext;
  StreamController<ExtCandleData> exdataStreamController;
  Stream<ExtCandleData> exdataStream;


  AABBState() : super();


  onCandleData(ExtCandleData candleData) {
    if (candleData.first) {
      this.candlesMaxY.add(double.negativeInfinity);
      this.candlesMinY.add(double.infinity);
    }
    exdataStreamController.sink.add(candleData);
  }

  onAABBChange(ExtCandleData candleData, UIORect aabb) {
    this.candlesMinY.update(candleData.index, aabb.min.y);
    this.candlesMaxY.update(candleData.index, aabb.max.y);
    candlesticksContext.onCandleDataFinish(candleData);
  }

  int getCandleIndexByX(double x) {
    var candlesX = candlesticksContext.candlesX;

    var baseX = candlesX.first;
    int xIndex = (x - baseX) ~/ widget.durationMs;
    if (xIndex >= candlesX.length) {
      xIndex = candlesX.length - 1;
    }
    if(xIndex < 0) {
      xIndex = 0;
    }
    return xIndex;
  }

  UIOPoint getMinPoint() {
    if ((widget.rangeX == null) || (widget.rangeX.maxX == null) || (widget.rangeX.minX == null)) {
      return null;
    }
    var startIndex = getCandleIndexByX(widget.rangeX.minX);
    var endIndex = getCandleIndexByX(widget.rangeX.maxX);
    var minIndex = this.candlesMinY.minIndex(startIndex, endIndex);
    return UIOPoint(minIndex * widget.durationMs + widget.durationMs / 2, candlesMinY.get(minIndex));
  }

  UIOPoint getMaxPoint() {
    if ((widget.rangeX == null) || (widget.rangeX.maxX == null) || (widget.rangeX.minX == null)) {
      return null;
    }
    var startIndex = getCandleIndexByX(widget.rangeX.minX);
    var endIndex = getCandleIndexByX(widget.rangeX.maxX);
    var minIndex = this.candlesMaxY.minIndex(startIndex, endIndex);
    return UIOPoint(minIndex * widget.durationMs + widget.durationMs / 2, candlesMinY.get(minIndex));
  }

  UICamera calUICamera(double minX, double maxX, double paddingY) {
    var candlesX = candlesticksContext.candlesX;

    if ((candlesX.length <= 0) || (minX == null) || (maxX == null)) {
      return UICamera(UIORect(UIOPoint(0, 0), UIOPoint(0, 0)));
    }
    if (widget.durationMs <= 0) {
      return UICamera(UIORect(UIOPoint(0, 0), UIOPoint(0, 0)));
    }

    int startIndex = getCandleIndexByX(minX);
    int endIndex = getCandleIndexByX(maxX);

    var minY = this.candlesMinY.min(startIndex, endIndex);
    if (minY == null) {
      return null;
    }
    var maxY = this.candlesMaxY.min(startIndex, endIndex);
    if (maxY == null) {
      return null;
    }

    var realHeight = (maxY - minY) / (1 - 2 * paddingY);
    var realMinY = minY - realHeight * paddingY;
    var realMaxY = realMinY + realHeight;

    return UICamera(
        UIORect(UIOPoint(minX, realMinY), UIOPoint(maxX, realMaxY)));
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState(); //插入监听器
    subscription = widget.extDataStream.listen(onCandleData);
    exdataStreamController = new StreamController<ExtCandleData>();
    exdataStream = exdataStreamController.stream.asBroadcastStream();
  }

  @override void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    candlesticksContext = CandlesticksContext.of(context);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  void dispose() {
    subscription.cancel();
    exdataStreamController.close();

    super.dispose(); //删除监听器
  }
}
