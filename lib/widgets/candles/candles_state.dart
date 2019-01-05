import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/uiobjects/uio_candles.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';


abstract class CandlesState extends State<CandlesWidget>
    with TickerProviderStateMixin<CandlesWidget> {
  UIOCandles uiPainterData;

  AnimationController uiPainterDataAnimationController;
  Animation<UIOCandles> uiPainterDataAnimation;

  Paint positivePainter;
  Paint negativePainter;

  CandlesState()
      : super();

  void onData(ExtCandleData candleData) {
    var uiCamera = CandlesticksContext
        .of(context)
        .uiCamera;

    var removedObject;
    var candleUIObject = UIOCandle.fromData(candleData, widget.style.paddingX,
        candleData.open <= candleData.close
            ? positivePainter
            : negativePainter, index: candleData.index);

    uiPainterDataAnimationController.value = 1;
    var currentUIPainterData = this.uiPainterDataAnimation?.value;
    for (; currentUIPainterData != null &&
        currentUIPainterData.uiObjects.isNotEmpty;) {
      UIOCandle last = currentUIPainterData.uiObjects.last;
      if (candleUIObject.origin.x <= last.origin.x) {
        removedObject = currentUIPainterData.uiObjects.removeLast();
      } else {
        break;
      }
    }

    UIOCandles begin;
    UIOCandles end;
    if (removedObject != null) {
      begin = currentUIPainterData.clone();
      end = currentUIPainterData.clone();
      begin.uiObjects.add(removedObject);
      end.uiObjects.add(candleUIObject);
    } else {
      if (uiPainterDataAnimation != null) {
        uiPainterDataAnimationController.value = 1;
        uiPainterData.uiObjects.addAll(
            uiPainterDataAnimation.value.uiObjects);
      }
      begin = UIOCandles(<UIOCandle>[UIOCandle(
          UIOPoint(candleUIObject.origin.x, candleUIObject.origin.y),
          UIOPoint(candleUIObject.r.x, 0), 0, 0, widget.style.paddingX,
          painter: candleUIObject.painter)
      ]);
      end = UIOCandles(<UIOCandle>[candleUIObject]);
    }

    CandlesticksContext.of(context).onAABBChange(candleData, candleUIObject.aabb());

    uiPainterDataAnimation = Tween(begin: begin, end: end).animate(
        uiPainterDataAnimationController);
    uiPainterDataAnimationController.reset();
    uiPainterDataAnimationController.forward();

    bool inView = false;
    for (var i = 0; i < end.uiObjects.length; i++) {
      if (uiCamera.viewPort.cross(end.uiObjects[i].aabb())) {
        inView = true;
        break;
      }
    }

    if (inView) {
      uiPainterDataAnimation = Tween(begin: begin, end: end).animate(
          uiPainterDataAnimationController);
      uiPainterDataAnimationController.reset();
      uiPainterDataAnimationController.forward();
      setState(() {

      });
    } else {
      uiPainterDataAnimation = Tween(begin: end, end: end).animate(
          uiPainterDataAnimationController);
      uiPainterDataAnimationController.reset();
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState(); //插入监听器
    widget.dataStream.listen(onData);
    positivePainter = new Paint()
      ..color = widget.style.positiveColor
      ..style = PaintingStyle.fill;
    negativePainter = new Paint()
      ..color = widget.style.negativeColor
      ..style = PaintingStyle.fill;


    List<UIOCandle> candleUIObjectList = [];
    widget.initData?.forEach((ExtCandleData candleData) {
      var candleUIObject = UIOCandle.fromData(candleData, widget.style.paddingX,
          candleData.open <= candleData.close
              ? positivePainter
              : negativePainter);
      UIOCandle last;
      if (candleUIObjectList.length > 0) {
        last = candleUIObjectList[candleUIObjectList.length - 1];
      }
      if ((last != null) && (candleUIObject.origin.x == last.origin.x)) {
        candleUIObjectList.removeLast();
      }
      candleUIObjectList.add(candleUIObject);
    });
    UIOCandle lastObject;
    if (candleUIObjectList.length > 0) {
      lastObject = candleUIObjectList.removeLast();
    }
    this.uiPainterData = UIOCandles(candleUIObjectList);
    uiPainterDataAnimationController = AnimationController(
        duration: widget.style.duration, vsync: this);
    if (lastObject != null) {
      uiPainterDataAnimation = Tween(
          begin: UIOCandles([lastObject]),
          end: UIOCandles([lastObject]))
          .animate(uiPainterDataAnimationController);
    }
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
