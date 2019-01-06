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
import 'package:candlesticks/2d/uiobjects/uio_path.dart';

const ZERO = 0.00000001;
/*
class ViewPortRange {
  final double minIndex;
  final double maxIndex;

  UIOCullingRange(this.minIndex, this.maxIndex);

  UIOCullingRange operator -(UIOCullingRange other) {
    return UIOCullingRange(this.minIndex - other.minIndex, this.maxIndex - other.maxIndex);
  }
  UIOCullingRange operator +(UIOCullingRange other) {
    return UIOCullingRange(this.minIndex + other.minIndex, this.maxIndex - other.maxIndex);
  }

  UIOCullingRange operator *(double process) {
    return UIOCullingRange(this.minIndex * process, this.maxIndex * process);
  }
}
*/

abstract class CandlesticksState extends State<CandlesticksWidget>
    with TickerProviderStateMixin {
  StreamController<ExtCandleData> exdataStreamController;
  Stream<ExtCandleData> exdataStream;

  AnimationController uiCameraAnimationController;
  Animation<UICamera> uiCameraAnimation;

  List<double> candlesX = List<double>();
  TreedListMin<double> candlesMaxY = TreedListMin(null, reverse: -1);
  TreedListMin<double> candlesMinY = TreedListMin(null);
  StreamSubscription<CandleData> subscription;

  CandlesticksState({Stream<CandleData> dataStream})
      : super();

  bool isWaitingForInitData() {
    return this.candlesX.length < widget.candlesticksStyle.viewPortX;
  }

  CandleData firstCandleData;
  double durationMs;

  _onCandleData(CandleData candleData) {
    if ((candlesX.length <= 0) || (candleData.timeMs > candlesX.last)) {
      candlesX.add(candleData.timeMs.toDouble());
      this.candlesMaxY.add(candleData.high);
      this.candlesMinY.add(candleData.low);
    }

    var extCandleData = ExtCandleData(
        candleData, index: this.candlesX.length - 1,
        durationMs: this.durationMs);

    this.exdataStreamController.sink.add(extCandleData);

    if (isWaitingForInitData()) {
      setState(() {

      });
    }
  }

  onCandleData(CandleData candleData) {
    if(firstCandleData == null) {
      firstCandleData = candleData;
      return;
    }

    if(this.durationMs == null) {
      this.durationMs = (candleData.timeMs - firstCandleData.timeMs).toDouble();
      _onCandleData(firstCandleData);
    }

    _onCandleData(candleData);
  }

  onAABBChange(ExtCandleData candleData, UIORect aabb) {
    this.candlesMaxY.update(candleData.index, aabb.max.y);
    this.candlesMinY.update(candleData.index, aabb.min.y);

    //开始计算camera
    if (uiCameraAnimationController == null) {
      return;
    }
    if (!isWaitingForInitData()) {
      var lastX = this.candlesX.last + durationMs;
      if (uiCameraAnimation != null) {
        var currentUICamera = uiCameraAnimation.value;
        if ((currentUICamera.viewPort.max.x - lastX).abs() > 0) { //自动贴合的距离
          return;
        }
      }

      var uiCamera = calUICamera(
          lastX - durationMs * widget.candlesticksStyle.viewPortX, lastX);

      if (uiCameraAnimation == null) {
        uiCameraAnimation = Tween(begin: uiCamera, end: uiCamera).animate(
            uiCameraAnimationController);
        uiCameraAnimationController.reset();
      } else {
        uiCameraAnimation =
            Tween(begin: uiCameraAnimation.value, end: uiCamera).animate(
                uiCameraAnimationController);
        uiCameraAnimationController.reset();
        uiCameraAnimationController.forward();
      }
      setState(() {

      });
    }
  }


  UICamera calUICamera(double minX, double maxX) {
    if ((this.candlesX.length <= 0) || (minX == null) || (maxX == null)) {
      return UICamera(UIORect(UIOPoint(0, 0), UIOPoint(0, 0)));
    }

    var baseX = this.candlesX.first;
    if (durationMs <= 0) {
      return UICamera(UIORect(UIOPoint(0, 0), UIOPoint(0, 0)));
    }

    int startIndex = (minX - baseX) ~/ durationMs;
    if (startIndex >= this.candlesX.length) {
      startIndex = this.candlesX.length - 1;
    }
    int endIndex = (maxX - baseX) ~/ durationMs;
    if (endIndex >= this.candlesX.length) {
      endIndex = this.candlesX.length - 1;
    }

    var minY = this.candlesMinY.min(startIndex, endIndex);
    var maxY = this.candlesMaxY.min(startIndex, endIndex);
    return UICamera(UIORect(UIOPoint(minX, minY), UIOPoint(maxX, maxY)));
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    //区间的最大值， 最小值。
    if (uiCameraAnimation == null) {
      return;
    }

    var uiCamera = uiCameraAnimation.value;
    var viewPortDx = uiCamera.worldToViewPortDX(durationMs);
    var screenDx = uiCamera.viewPortToScreenDx(context.size, viewPortDx);

    double a = screenDx * 200;
    double speed = details.primaryVelocity.abs();
    double durationSecond = speed / a;
    double targetDx = speed * durationSecond + a * durationSecond * durationSecond / 2;
    if(details.primaryVelocity < 0) {
      targetDx = -targetDx;
    }

    double worldDx = uiCamera.viewPortToWorldDX(uiCamera.screenToViewPortDx(context.size, targetDx));
    double minX = uiCamera.viewPort.min.x - worldDx;
    double maxX = uiCamera.viewPort.max.x - worldDx;

    if(minX < this.candlesX.first) {
      minX = this.candlesX.first;
    }
    if(minX > this.candlesX.last - durationMs * (this.widget.candlesticksStyle.viewPortX - 1)) {
      minX = this.candlesX.last - durationMs * (this.widget.candlesticksStyle.viewPortX - 1);
    }
    if(maxX > this.candlesX.last + durationMs) {
      maxX = this.candlesX.last + durationMs;
    }
    if(maxX < this.candlesX.first + durationMs * this.widget.candlesticksStyle.viewPortX) {
      maxX = this.candlesX.first + durationMs * this.widget.candlesticksStyle.viewPortX;
    }

    var newUICamera = calUICamera(minX, maxX);
    uiCameraAnimation =
        Tween(begin: uiCamera, end: newUICamera)
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
    var dx = uiCameraAnimation.value.viewPort.width * dr;
    var uiCamera = uiCameraAnimation.value;
    var minX = uiCamera.viewPort.min.x;
    var maxX = uiCamera.viewPort.max.x;
    minX -= dx;
    maxX -= dx;

    var baseX = this.candlesX.first;
    var startIndex = (minX - baseX) ~/ this.durationMs;
    if(startIndex < 0) {
      startIndex =0;
    }
    if(startIndex >= this.candlesX.length) {
      startIndex = this.candlesX.length - 1;
    }
    var endIndex = (maxX - baseX) ~/ this.durationMs;
    if(endIndex < 0) {
      endIndex =0;
    }
    if(endIndex >= this.candlesX.length) {
      endIndex = this.candlesX.length - 1;
    }

    var minY = this.candlesMinY.min(startIndex, endIndex);
    if (minY == null) {
      minY = 0;
    }
    var maxY = this.candlesMaxY.min(startIndex, endIndex);
    if (maxY == null) {
      maxY = 0;
    }

    var newCamera = UICamera(
        UIORect(UIOPoint(minX, minY), UIOPoint(maxX, maxY)));

    uiCameraAnimation =
        Tween(begin: newCamera, end: newCamera).animate(
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
