import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:candlesticks/widgets/candlesticks_widget.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/treedlist.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';

const ZERO = 0.00000001;

abstract class CandlesticksState extends State<CandlesticksWidget>
    with TickerProviderStateMixin {
  CandleData firstCandleData;
  double durationMs;
  StreamController<ExtCandleData> exdataStreamController;
  Stream<ExtCandleData> exdataStream;
  List<double> candlesX = List<double>();
  AnimationController uiCameraAnimationController;
  Animation<AABBRangeX> uiCameraAnimation;
  StreamSubscription<CandleData> subscription;


  CandlesticksState({Stream<CandleData> dataStream})
      : super();

  bool isWaitingForInitData() {
    return this.candlesX.length < widget.candlesticksStyle.initAfterNData;
  }

  _onCandleData(CandleData candleData) {
    var first = false;
    if ((candlesX.length <= 0) || (candleData.timeMs > candlesX.last)) {
      candlesX.add(candleData.timeMs.toDouble());
      first = true;
    }

    var extCandleData = ExtCandleData(
        candleData, index: this.candlesX.length - 1,
        durationMs: this.durationMs, first: first);

    this.exdataStreamController.sink.add(extCandleData);
    if (isWaitingForInitData()) {
      setState(() {

      });
    }
  }

  onCandleData(CandleData candleData) {
    if (firstCandleData == null) {
      firstCandleData = candleData;
      return;
    }

    if (this.durationMs == null) {
      this.durationMs = (candleData.timeMs - firstCandleData.timeMs).toDouble();
      _onCandleData(firstCandleData);
    }

    _onCandleData(candleData);
  }

  onCandleDataFinish(ExtCandleData candleData) {
    if (uiCameraAnimation == null) {
      var maxX = candlesX.last + durationMs;
      var minX = maxX -
          durationMs * widget.candlesticksStyle.defaultViewPortX;
      var rangeX = AABBRangeX(minX, maxX);
      uiCameraAnimation =
          Tween(begin: rangeX, end: rangeX).animate(
              uiCameraAnimationController);
      uiCameraAnimationController.reset();
      setState(() {

      });
    }
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    return;
    /*
    //区间的最大值， 最小值。
    if (uiCameraAnimation == null) {
      return;
    }

    var currentRangeX = this.uiCameraAnimation.value;
    var width = currentRangeX.width;
    double a =  width * 3;
    var viewPortDx = details.primaryVelocity.abs() / context.size.width;
    var worldDx = width * viewPortDx;

    double speed = worldDx;//per second
    double durationSecond = speed / a;
    double targetDx = speed * durationSecond +
        a * durationSecond * durationSecond / 2;
    if(details.primaryVelocity < 0) {
      targetDx = - targetDx;
    }

    double minX = currentRangeX.minX - targetDx;

    if (minX < this.candlesX.first) {
      minX = this.candlesX.first;
    }
    if (minX > this.candlesX.last + durationMs - width) {
      minX = this.candlesX.last + durationMs - width;
    }
    double maxX = minX + width;

    var newUICamera = AABBRangeX(minX, maxX);
    uiCameraAnimation =
        Tween(begin: currentRangeX, end: newUICamera)
            .animate(CurvedAnimation(
            parent: uiCameraAnimationController,
            curve: Curves.decelerate
        ));
    uiCameraAnimationController.reset();
    uiCameraAnimationController.forward();
    */
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (uiCameraAnimation == null) { //还没有初始化完成。
      return;
    }

    var dr = details.primaryDelta / context.size.width;
    var dx = uiCameraAnimation.value.width * dr;
    var rangeX = uiCameraAnimation.value;
    var minX = rangeX.minX;
    var maxX = rangeX.maxX;
    minX -= dx;
    maxX -= dx;

    var baseX = this.candlesX.first;
    var startIndex = (minX - baseX) ~/ this.durationMs;
    if (startIndex < 0) {
      startIndex = 0;
    }
    if (startIndex >= this.candlesX.length) {
      startIndex = this.candlesX.length - 1;
    }
    var endIndex = (maxX - baseX) ~/ this.durationMs;
    if (endIndex < 0) {
      endIndex = 0;
    }
    if (endIndex >= this.candlesX.length) {
      endIndex = this.candlesX.length - 1;
    }

    var newRangeX = AABBRangeX(minX, maxX);

    uiCameraAnimation =
        Tween(begin: newRangeX, end: newRangeX).animate(
            uiCameraAnimationController);
    uiCameraAnimationController.reset();
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState(); //插入监听器
    firstCandleData = null;
    durationMs = null;
    exdataStreamController = new StreamController<ExtCandleData>();
    exdataStream = exdataStreamController.stream.asBroadcastStream();
    subscription = widget.dataStream.listen(onCandleData);
    uiCameraAnimationController = AnimationController(
        duration: widget.candlesticksStyle.cameraDuration, vsync: this);
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
    uiCameraAnimationController.dispose();

    super.dispose(); //删除监听器
  }
}
