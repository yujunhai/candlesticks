import 'package:flutter/material.dart';
import 'dart:async';

import 'package:candlesticks/2d/uiobject.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiwidget.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';

const ZERO = 0.00000001;

abstract class UIAnimatedState<T extends UIObjects<TT,
    T>, TT extends UIAnimatedObject<
    TT>> extends State<UIAnimatedWidget<T, TT>>
    with TickerProviderStateMixin {

  final int animationCount;
  T fixedUIObject;
  AnimationController uiObjectAnimationController;
  Animation<T> uiAnimatedObject;
  StreamSubscription<ExtCandleData> subscription;
  AABBContext candlesticksContext;

  T getCandles();

  TT getCandle(ExtCandleData candleData);

  T getBeginAnimation(T lastAnimationUIObject, TT point);

  T getEndAnimation(T lastAnimationUIObject, TT point);

  UIAnimatedState({this.animationCount}) : super();

  void onData(ExtCandleData candleData) {
    if (fixedUIObject == null) {
      this.fixedUIObject = getCandles();
    }

    TT point = getCandle(candleData);
    if (point == null) {
      return;
    }
    candlesticksContext.onAABBChange(
        candleData, point.aabb());

    if (uiAnimatedObject == null) {
      T endPath = getCandles();
      endPath.uiObjects.add(point);
      uiAnimatedObject = Tween(begin: endPath, end: endPath).animate(
          uiObjectAnimationController);
      uiObjectAnimationController.reset();
      return;
    }

    var currentUIPathData = this.uiAnimatedObject?.value;
    if (currentUIPathData.uiObjects.length < this.animationCount) {
      T endPath = currentUIPathData.clone();
      endPath.uiObjects.add(point);
      uiAnimatedObject = Tween(begin: endPath, end: endPath).animate(
          uiObjectAnimationController);
      uiObjectAnimationController.reset();
      return;
    }
    bool inView = false;
    if ((this.widget.uiCamera != null) && (this.widget.uiCamera.viewPort.cross(point.aabb()))) {
      inView = true;
    }
    TT last = currentUIPathData.uiObjects.last;
    if (point.index <= last.index) {
      if (inView) {
        var beginPath = currentUIPathData.clone();
        var endPath = currentUIPathData.clone();
        endPath.uiObjects[endPath.uiObjects.length - 1] = point;
        uiAnimatedObject = Tween(begin: beginPath, end: endPath).animate(
            uiObjectAnimationController);
        uiObjectAnimationController.reset();
        uiObjectAnimationController.forward();
      } else {
        var endPath = currentUIPathData.clone();
        endPath.uiObjects[endPath.uiObjects.length - 1] = point;
        uiAnimatedObject = Tween(begin: endPath, end: endPath).animate(
            uiObjectAnimationController);
        uiObjectAnimationController.reset();
      }
    }else {
      var lastAnimationUIObject = uiAnimatedObject.value.clone();
      if(animationCount > 1) {
        uiObjectAnimationController.value = 1;
        if(fixedUIObject.uiObjects.isNotEmpty) {
          fixedUIObject.uiObjects.removeLast();
        }
        var first = lastAnimationUIObject.uiObjects.removeAt(0);
        fixedUIObject.uiObjects.add(first);
        fixedUIObject.uiObjects.add(lastAnimationUIObject.uiObjects.first);
      }else {
        var first = lastAnimationUIObject.uiObjects.removeAt(0);
        fixedUIObject.uiObjects.add(first);
      }

      if(inView) {
        var beginPath = getBeginAnimation(lastAnimationUIObject, point);
        var endPath = getEndAnimation(lastAnimationUIObject, point);
        uiAnimatedObject = Tween(begin: beginPath, end: endPath).animate(
            uiObjectAnimationController);
        uiObjectAnimationController.reset();
        uiObjectAnimationController.forward();
      }else {
        var endPath = getEndAnimation(lastAnimationUIObject, point);
        uiAnimatedObject = Tween(begin: endPath, end: endPath).animate(
            uiObjectAnimationController);
        uiObjectAnimationController.reset();
      }
    }
  }

  void onHorizontalDragStart(DragStartDetails details) {
    print("ma start");
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    print("ma end");
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
  }


  @override
  @mustCallSuper
  void initState() {
    // TODO: implement initState
    super.initState(); //插入监听器
    subscription = widget.dataStream.listen(onData);

    uiObjectAnimationController = AnimationController(
        duration: this.widget.duration, vsync: this);
  }

  @override void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    candlesticksContext = AABBContext.of(context);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  void dispose() {
    subscription?.cancel();
    uiObjectAnimationController.dispose();

    super.dispose(); //删除监听器
  }
}

abstract class UIAnimatedView<T extends UIObjects<TT, T>, TT extends UIAnimatedObject<TT>> extends UIAnimatedState<T, TT> {

  UIAnimatedView({animationCount}) : super(animationCount:animationCount);

  @override
  Widget build(BuildContext context) {
    if((this.widget.uiCamera == null) || (uiAnimatedObject == null)) {
      return Container();
    }
    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: UIWidget(
              uiCamera: this.widget.uiCamera,
              uiPainterData: fixedUIObject,
            )
        ),
        Positioned.fill(
          child: AnimatedBuilder(
              animation: Listenable.merge([
                uiObjectAnimationController
              ]),
              builder: (BuildContext context, Widget child) {
                return UIWidget(
                  uiCamera: this.widget.uiCamera,
                  uiPainterData: uiAnimatedObject.value,
                );
              }
          ),
        ),
      ],
    );
  }
}

class UIAnimatedWidget<T extends UIObjects<TT, T>, TT extends UIAnimatedObject<
    TT>> extends StatefulWidget {

  UIAnimatedWidget({
    Key key,
    this.dataStream,
    this.uiCamera,
    this.duration,
    this.state,
  }) :super(key: key);

  final Stream<ExtCandleData> dataStream;
  final UICamera uiCamera;
  final Function() state;
  final Duration duration;

  @override
  createState() => this.state();
}
