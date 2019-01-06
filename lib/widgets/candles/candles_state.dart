import 'package:flutter/material.dart';
import 'dart:async';

import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/uiobjects/uio_candles.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';


abstract class CandlesState extends State<CandlesWidget>
    with TickerProviderStateMixin<CandlesWidget> {
  UIOCandles uiPainterData;

  AnimationController uiPainterDataAnimationController;
  Animation<UIOCandles> uiPainterDataAnimation;

  Paint positivePainter;
  Paint negativePainter;
  StreamSubscription<ExtCandleData> subscription;
  AABBContext candlesticksContext;

  CandlesState()
      : super();

  void onData(ExtCandleData candleData) {
    var uiCamera = candlesticksContext?.uiCamera;

    var candleUIObject = UIOCandle.fromData(candleData, widget.style.paddingX,
        candleData.open <= candleData.close
            ? positivePainter
            : negativePainter, index: candleData.index);

    candlesticksContext.onAABBChange(
        candleData, candleUIObject.aabb());
    if(uiPainterData == null) {
      uiPainterData = UIOCandles([]);
      UIOCandles begin = UIOCandles([candleUIObject]);
      uiPainterDataAnimation = Tween(begin: begin, end: begin).animate(
          uiPainterDataAnimationController);
      return;
    }

    bool inView = false;
    if ((uiCamera != null) && (uiCamera.viewPort.cross(candleUIObject.aabb()))) {
      inView = true;
    }

    var currentUIPainterData = this.uiPainterDataAnimation.value;
    UIOCandle last = currentUIPainterData.uiObjects.last;
    if (candleUIObject.index <= last.index) {
      if(inView) {
        var begin = currentUIPainterData.clone();
        var end = currentUIPainterData.clone();
        end.uiObjects[end.uiObjects.length - 1] = candleUIObject;
        uiPainterDataAnimation = Tween(begin: begin, end: end).animate(
            uiPainterDataAnimationController);
        uiPainterDataAnimationController.reset();
        uiPainterDataAnimationController.forward();
        setState(() {

        });
      }else {
        uiPainterDataAnimationController.value = 1;
        var end = this.uiPainterDataAnimation.value.clone();
        uiPainterDataAnimation = Tween(begin: end, end: end).animate(
            uiPainterDataAnimationController);
        uiPainterDataAnimationController.reset();
      }
    }else {
      uiPainterDataAnimationController.value = 1;
      uiPainterData.uiObjects.addAll(uiPainterDataAnimation.value.uiObjects);

      if(inView) {
        var begin = UIOCandles(<UIOCandle>[UIOCandle(
            UIOPoint(candleUIObject.origin.x, candleUIObject.origin.y),
            UIOPoint(candleUIObject.r.x, 0), 0, 0, widget.style.paddingX,
            painter: candleUIObject.painter, index: candleData.index)
        ]);
        var end = UIOCandles(<UIOCandle>[candleUIObject]);
        uiPainterDataAnimation = Tween(begin: begin, end: end).animate(
            uiPainterDataAnimationController);
        uiPainterDataAnimationController.reset();
        uiPainterDataAnimationController.forward();
        setState(() {

        });
      }else {
        var end = UIOCandles(<UIOCandle>[candleUIObject]);
        uiPainterDataAnimation = Tween(begin: end, end: end).animate(
            uiPainterDataAnimationController);
        uiPainterDataAnimationController.reset();
      }
    }
  }

  void onHorizontalDragStart(DragStartDetails details) {
    print("candles begin");
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    print("candles end");
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
  }

  @override void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    candlesticksContext = AABBContext.of(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState(); //插入监听器
    positivePainter = new Paint()
      ..color = widget.style.positiveColor
      ..style = PaintingStyle.fill;
    negativePainter = new Paint()
      ..color = widget.style.negativeColor
      ..style = PaintingStyle.fill;

    uiPainterDataAnimationController = AnimationController(
        duration: widget.style.duration, vsync: this);
    subscription = widget.dataStream.listen(onData);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  void dispose() {
    uiPainterDataAnimationController.dispose();
    subscription?.cancel();

    super.dispose(); //删除监听器
  }
}
