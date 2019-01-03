import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobject.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiwidget.dart';
import 'package:candlesticks/2d/candle_data.dart';

const ZERO = 0.00000001;

abstract class UIAnimatedState<T extends UIObjects<TT,
    T>, TT extends UIAnimatedObject<
    TT>> extends State<UIAnimatedWidget<T, TT>>
    with TickerProviderStateMixin {

    T fixedUIObject;
    AnimationController uiObjectAnimationController;
    Animation<T> uiAnimatedObject;

    TT calUIObject(CandleData candleData, bool update);

    T calUIObjects(List<TT> uiObjects);

    T calAnimationBegin(TT uiObject);

    T calAnimationEnd(TT uiObject);

    bool needUpdate(CandleData candleData, TT uiObject);

    UIAnimatedState() : super();

    void onData(CandleData candleData) {
        var removedPoint;
        uiObjectAnimationController.value = 1;
        var currentUIPathData = this.uiAnimatedObject?.value;

        for (; currentUIPathData != null &&
            currentUIPathData.uiObjects.isNotEmpty;) {
            if (this.needUpdate(candleData, currentUIPathData.uiObjects.last)) {
                removedPoint = currentUIPathData.uiObjects.removeLast();
            } else {
                break;
            }
        }

        T beginPath;
        T endPath;
        TT point;
        if (removedPoint != null) {
            beginPath = currentUIPathData.clone();
            endPath = currentUIPathData.clone();
            point = calUIObject(candleData, true);
            if (point == null) {
                return;
            }
            beginPath.uiObjects.add(removedPoint);
            endPath.uiObjects.add(point);
        } else {
            if (uiAnimatedObject != null) {
                uiObjectAnimationController.value = 1;
                fixedUIObject.uiObjects.add(
                    uiAnimatedObject.value.uiObjects.last);
            }
            point = calUIObject(candleData, false);
            if (point == null) {
                return;
            }
            beginPath = calAnimationBegin(point);
            endPath = calAnimationEnd(point);
        }
        if (widget.onUpdate != null) {
            widget.onUpdate(fixedUIObject.uiObjects.length, point);
        }

        bool inView = false;
        for (var i = 0; i < endPath.uiObjects.length; i++) {
            if (this.widget.uiCamera.viewPort.cross(
                endPath.uiObjects[i].aabb())) {
                inView = true;
                break;
            }
        }

        if (inView) {
            uiAnimatedObject = Tween(begin: beginPath, end: endPath).animate(
                uiObjectAnimationController);
            uiObjectAnimationController.reset();
            uiObjectAnimationController.forward();
            setState(() {

            });
        } else {
            uiAnimatedObject = Tween(begin: endPath, end: endPath).animate(
                uiObjectAnimationController);
            uiObjectAnimationController.reset();
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
        widget.dataStream.listen(onData);

        List<TT> uiPointList = [];
        widget.initData?.forEach((CandleData candleData) {
            var point = calUIObject(candleData, false);
            if (point != null) {
                if (widget.onUpdate != null) {
                    widget.onUpdate(uiPointList.length, point);
                }
                uiPointList.add(point);
            }
        });

        TT lastObject;
        if (uiPointList.length > 0) {
            lastObject = uiPointList.removeLast();
        }
        this.fixedUIObject = calUIObjects(uiPointList);
        uiObjectAnimationController = AnimationController(
            duration: this.widget.duration, vsync: this);
        if (lastObject != null) {
            uiAnimatedObject = Tween(
                begin: calUIObjects([uiPointList.last.clone(), lastObject]),
                end: calUIObjects([uiPointList.last.clone(), lastObject]))
                .animate(
                uiObjectAnimationController);
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

abstract class UIAnimatedView<T extends UIObjects<TT,
    T>, TT extends UIAnimatedObject<
    TT>> extends UIAnimatedState<T, TT> {
    UIAnimatedView() : super();

    @override
    Widget build(BuildContext context) {
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
        this.initData,
        this.dataStream,
        this.uiCamera,
        this.onUpdate,
        this.duration,
        this.state,
    }) :super(key: key);

    final List<CandleData> initData;
    final Stream<CandleData> dataStream;
    final UICamera uiCamera;
    final Function(int index, TT point) onUpdate;
    final Function() state;
    final Duration duration;

    @override
    createState() => this.state();
}
