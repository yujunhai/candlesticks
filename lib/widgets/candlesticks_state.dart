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
  bool touching = false;


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
    if ((uiCameraAnimation == null) && (!touching)) {
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
    touching = false;
    //区间的最大值， 最小值。
    if (uiCameraAnimation == null) {
      return;
    }

    var currentRangeX = this.uiCameraAnimation.value;
    var width = currentRangeX.width;
    double a = width * 3;
    var viewPortDx = details.primaryVelocity.abs() / context.size.width;
    var worldDx = width * viewPortDx;

    double speed = worldDx; //per second
    double durationSecond = speed / a;
    double targetDx = speed * durationSecond +
        a * durationSecond * durationSecond / 2;
    if (details.primaryVelocity < 0) {
      targetDx = -targetDx;
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
    var width = maxX - minX;

    if (minX < this.candlesX.first) {
      minX = this.candlesX.first;
      maxX = minX + width;
    }

    /*
    if (maxX > this.candlesX.last + this.durationMs + 100) {
      maxX = this.candlesX.last + this.durationMs + 100;
      minX = maxX - width;
    }
    */

    var newRangeX = AABBRangeX(minX, maxX);

    uiCameraAnimation =
        Tween(begin: newRangeX, end: newRangeX).animate(
            uiCameraAnimationController);
    uiCameraAnimationController.reset();
    extCandleData = null;
    touchPoint = null;
    setState(() {

    });
  }

  double startX;
  AABBRangeX startRangeX;

  void handleScaleStart(ScaleStartDetails details) {
    startRangeX = uiCameraAnimation.value;

    RenderBox getBox = context.findRenderObject();
    startX = startRangeX.minX + (getBox.globalToLocal(details.focalPoint).dx / context.size.width) * startRangeX.width;
    touching = true;
  }

  onScaleUpdate(ScaleUpdateDetails details) {
    double scale = details.scale;
    var originWidth = startRangeX.width * scale;
    var width = originWidth * scale;
    if (width > this.durationMs * widget.candlesticksStyle.maxViewPortX) {
      width = this.durationMs * widget.candlesticksStyle.maxViewPortX;
    }
    if (width < this.durationMs * widget.candlesticksStyle.minViewPortX) {
      width = this.durationMs * widget.candlesticksStyle.maxViewPortX;
    }

    var dx = (startX - startRangeX.minX) * scale;

    double minX = startX - dx;
    if (minX < this.candlesX.first) {
      minX = this.candlesX.first;
    }
    var maxX = minX + width;
    if (maxX > this.candlesX.last + this.durationMs) {
      maxX = this.candlesX.last + this.durationMs;
    }
    var newRangeX = AABBRangeX(minX, maxX);

    uiCameraAnimation =
        Tween(begin: newRangeX, end: newRangeX).animate(
            uiCameraAnimationController);
    uiCameraAnimationController.reset();
    extCandleData = null;
    touchPoint = null;
    setState(() {

    });
  }

  ExtCandleData extCandleData;
  Offset touchPoint;

  onTouchCandle(Offset touchPoint, ExtCandleData candleData) {
    extCandleData = candleData;
    this.touchPoint = touchPoint;
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
    extCandleData = null;
    touchPoint = null;
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
