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
      this.candlesMaxY.add(candleData.high);
      this.candlesMinY.add(candleData.low);
    }
    exdataStreamController.sink.add(candleData);
  }

  onAABBChange(ExtCandleData candleData, UIORect aabb) {
    this.candlesMaxY.update(candleData.index, aabb.max.y);
    this.candlesMinY.update(candleData.index, aabb.min.y);
  }


  UICamera calUICamera(double minX, double maxX) {
    var candlesX = candlesticksContext.candlesX;

    if ((candlesX.length <= 0) || (minX == null) || (maxX == null)) {
      return UICamera(UIORect(UIOPoint(0, 0), UIOPoint(0, 0)));
    }

    var baseX = candlesX.first;
    if (widget.durationMs <= 0) {
      return UICamera(UIORect(UIOPoint(0, 0), UIOPoint(0, 0)));
    }

    int startIndex = (minX - baseX) ~/ widget.durationMs;
    if (startIndex >= candlesX.length) {
      startIndex = candlesX.length - 1;
    }
    int endIndex = (maxX - baseX) ~/ widget.durationMs;
    if (endIndex >= candlesX.length) {
      endIndex = candlesX.length - 1;
    }

    var minY = this.candlesMinY.min(startIndex, endIndex);
    if(minY == null) {
      return null;
    }
    var maxY = this.candlesMaxY.min(startIndex, endIndex);
    if(maxY == null) {
      return null;
    }

    return UICamera(UIORect(UIOPoint(minX, minY), UIOPoint(maxX, maxY)));
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState(); //插入监听器
    subscription = widget.extdataStream.listen(onCandleData);
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
