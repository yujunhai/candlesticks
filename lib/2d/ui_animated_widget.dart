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

    T initCandleLIst(List<ExtCandleData> candleDataList);

    TT updateLastCandle(ExtCandleData candleData);

    TT addCandle(ExtCandleData candleData);

    T addCandleBegin(ExtCandleData candleData);

    T addCandleEnd(ExtCandleData candleData);

    bool needUpdate(ExtCandleData candleData, TT uiObject);

    UIAnimatedState() : super();

    void onData(ExtCandleData candleData) {
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
        if (removedPoint != null) {
            beginPath = currentUIPathData.clone();
            endPath = currentUIPathData.clone();
            TT point = updateLastCandle(candleData);
            if (point == null) {
                return;
            }
            beginPath.uiObjects.add(removedPoint);
            endPath.uiObjects.add(point);
            if (widget.onUpdateLastCandle != null) {
                widget.onUpdateLastCandle(candleData, point);
            }
        } else {
            if (uiAnimatedObject != null) {
                uiObjectAnimationController.value = 1;
                fixedUIObject.uiObjects.add(
                    uiAnimatedObject.value.uiObjects.last);
            }
            TT point = addCandle(candleData);
            if (point == null) {
                return;
            }
            beginPath = addCandleBegin(candleData);
            endPath = addCandleEnd(candleData);
            if (widget.onAddCandle != null) {
                widget.onAddCandle(candleData, endPath.uiObjects.last);
            }
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

        this.fixedUIObject = initCandleLIst(widget.initData);
        if(this.widget.onInitCandles != null) {
            this.widget.onInitCandles(widget.initData, this.fixedUIObject);
        }

        uiObjectAnimationController = AnimationController(
            duration: this.widget.duration, vsync: this);


        if (widget.initData.length >= 2) {
            this.fixedUIObject.uiObjects.removeLast();
            var endPath = addCandleEnd(widget.initData.last);

            uiAnimatedObject = Tween(begin: endPath, end: endPath).animate(
                uiObjectAnimationController);
        }

        for(var i = 0; i < this.fixedUIObject.uiObjects.length; i++) {
            this.widget.onAddCandle(widget.initData[i], this.fixedUIObject.uiObjects[i]);
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
        this.onAddCandle,
        this.onUpdateLastCandle,
        this.duration,
        this.state,
        this.onInitCandles,
    }) :super(key: key);

    final List<ExtCandleData> initData;
    final Stream<ExtCandleData> dataStream;
    final UICamera uiCamera;
    final Function(List<ExtCandleData> initData, T uiobject) onInitCandles;
    final Function(ExtCandleData candleData, TT point) onAddCandle;
    final Function(ExtCandleData candleData, TT point) onUpdateLastCandle;
    final Function() state;
    final Duration duration;

    @override
    createState() => this.state();
}
