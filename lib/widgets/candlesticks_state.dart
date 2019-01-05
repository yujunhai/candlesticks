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

abstract class CandlesticksState extends State<CandlesticksWidget>
    with TickerProviderStateMixin {
  Stream<ExtCandleData> exdataStream;

  AnimationController uiCameraAnimationController;
  Animation<UICamera> uiCameraAnimation;

  List<double> candlesX = List<double>();
  TreedListMin<double> candlesMaxY = TreedListMin(null, reverse: -1);
  TreedListMin<double> candlesMinY = TreedListMin(null);

  CandlesticksState({Stream<CandleData> dataStream})
      : super();

  ExtCandleData onCandleData(CandleData candleData) {
    if ((candlesX.length <= 0) || (candleData.timeMs > candlesX.last)) {
      candlesX.add(candleData.timeMs.toDouble());
      this.candlesMaxY.add(candleData.high);
      this.candlesMinY.add(candleData.low);
    }
    return ExtCandleData(candleData, index: candlesX.length - 1, durationMs: this.widget.candlesticksStyle.durationMs);
  }

  onAABBChange(ExtCandleData candleData, UIORect aabb) {
    this.candlesMaxY.update(candleData.index, aabb.max.y);
    this.candlesMinY.update(candleData.index, aabb.min.y);

    //开始计算camera
    if(uiCameraAnimationController == null) {
      return;
    }
    if(candleData.index >= widget.candlesticksStyle.viewPortX) {
      if(uiCameraAnimation != null) {
        var currentUICamera = uiCameraAnimation.value;
        if(!currentUICamera.viewPort.cross(aabb)) {
          return;
        }
      }

      var viewPort = calViewPort(
          candlesX.length - widget.candlesticksStyle.viewPortX,
          candlesX.length - 1);
      var uiCamera = UICamera(viewPort);
      uiCameraAnimation = Tween(begin: uiCamera, end: uiCamera).animate(
          uiCameraAnimationController);
      setState(() {

      });
    }
  }


  UIORect calViewPort(int from, int to) {
    if (this.candlesX.length <= 0) {
      return UIORect(UIOPoint(0, 0), UIOPoint(0, 0));
    }

    if (from < 0) {
      from = 0;
    }
    if (to > this.candlesX.length) {
      to = this.candlesX.length - 1;
    }
    var minY = this.candlesMinY.min(from, to);
    if (minY == null) {
      minY = 0;
    }
    var maxY = this.candlesMaxY.min(from, to);
    if (maxY == null) {
      maxY = 0;
    }
    var durationMs = widget.candlesticksStyle.durationMs;
    if (from < 0) {
      return null;
    }
    var minX = this.candlesX[from];
    var maxX = this.candlesX[to] + durationMs;
    return UIORect(UIOPoint(minX, minY), UIOPoint(maxX, maxY));
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    return;
    //区间的最大值， 最小值。
    var uiCamera = uiCameraAnimation.value;
    var baseX = this.candlesX.first;
    var startIndex = (uiCamera.viewPort
        .aabb()
        .min
        .x - baseX) ~/ (60 * 1000);
    var endIndex = (uiCamera.viewPort
        .aabb()
        .max
        .x - baseX) ~/ (60 * 1000);

    var viewPort = calViewPort(startIndex, endIndex);
    print("{${viewPort.min.x}, ${viewPort.min.y}} {${viewPort.max
        .x}, ${viewPort.max.y}}");
    var newUICamera = UICamera(viewPort);
    uiCameraAnimation =
        Tween(begin: uiCamera, end: newUICamera)
            .animate(uiCameraAnimationController);
    uiCameraAnimationController.reset();
    uiCameraAnimationController.forward();
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    var dr = details.primaryDelta / context.size.width;
    var dx = uiCameraAnimation.value.viewPort.width * dr;
    var uiCamera = uiCameraAnimation.value;
    var minX = uiCamera.viewPort.min.x;
    var maxX = uiCamera.viewPort.max.x;
    minX -= dx;
    maxX -= dx;

    var baseX = this.candlesX.first;
    var startIndex = (minX - baseX) ~/ widget.candlesticksStyle.durationMs;
    var endIndex = (maxX - baseX) ~/ widget.candlesticksStyle.durationMs;
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

    uiCameraAnimationController.reset();
    uiCameraAnimation =
        Tween(begin: newCamera, end: newCamera).animate(
            uiCameraAnimationController);
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState(); //插入监听器
    exdataStream = widget.dataStream.map(onCandleData).asBroadcastStream();
    uiCameraAnimationController = AnimationController(
        duration: widget.candlesticksStyle.cameraDuration, vsync: this);


    /*
        var viewPort = UIORect(UIOPoint(0, 0), UIOPoint(0, 0));
        var uiCamera = UICamera(viewPort);
        uiCameraAnimation = Tween(begin: uiCamera, end: uiCamera).animate(
            uiCameraAnimationController);
            */

    /*
    var viewPort = calViewPort(
        candlesX.length - widget.candlesticksStyle.viewPortX,
        candlesX.length - 1);
    var uiCamera = UICamera(viewPort);
    uiCameraAnimation = Tween(begin: uiCamera, end: uiCamera).animate(
        uiCameraAnimationController);
        */
    /*
        var minX = double.infinity;
        var maxX = double.negativeInfinity;
        var minY = double.infinity;
        var maxY = double.negativeInfinity;


        extInitData.forEach((ExtCandleData extCandleData) {
            if(extCandleData.)
        }
        );
        */
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose(); //删除监听器
  }
}
