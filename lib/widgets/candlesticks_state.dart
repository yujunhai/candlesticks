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

  Offset _startingFocalPoint;
  Offset _previousOffset;
  Offset _offset = Offset.zero;
  double _previousZoom;
  double _zoom = 1.0;

  void handleScaleStart(ScaleStartDetails details) {
    setState(() {
      _startingFocalPoint = details.focalPoint;
      _previousOffset = _offset;
      _previousZoom = _zoom;
    });
  }

  void handleScaleReset() {
    setState(() {
      _zoom = 1.0;
      _offset = Offset.zero;
    });
  }

  onScaleUpdate(ScaleUpdateDetails details) {
    _zoom = _previousZoom * details.scale;

    // Ensure that item under the focal point stays in the same place despite zooming
    final Offset normalizedOffset = (_startingFocalPoint - _previousOffset) /
        _previousZoom;
    _offset = details.focalPoint - normalizedOffset * _zoom;

    RenderBox getBox = context.findRenderObject();
    var focalPoint = getBox.globalToLocal(details.focalPoint);
    var rangeX = uiCameraAnimation.value;
    var width = rangeX.width * _zoom;


    if(width > this.durationMs * 100) {
      width = this.durationMs * 100;
    }
    if(width < this.durationMs * 10) {
      width = this.durationMs * 10;
    }
    var rateX = (focalPoint.dx / context.size.width);
    var x = (rangeX.minX + rangeX.maxX) * rateX;
    var minX = x - width * rateX;
    var maxX = minX + width;
    var newRangeX = AABBRangeX(minX, maxX);
    print(rangeX.width);
    print(details.scale);
    print(width);

    if (minX < this.candlesX.first) {
      minX = this.candlesX.first;
      maxX = minX + width;
    }

    if (maxX > this.candlesX.last + this.durationMs) {
      maxX = this.candlesX.last + this.durationMs;
      minX = maxX - width;
    }
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
