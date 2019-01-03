import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/candle_data.dart';

class MaView extends UIAnimatedView<UIOPath, UIOPoint> {
    List<double> _sum;
    int count;
    Paint painter;
    Color color;

    MaView(this.count, this.color) : super() {
        this._sum = List<double>();

        painter = new Paint()
            ..color = color
            ..style = PaintingStyle.stroke;
    }

    double movingAverage(int index, int ma) {
        if ((this._sum == null) || (index - ma < 0) ||
            (index >= this._sum.length)) {
            return null;
        }

        double last = this._sum[index];
        double before = 0;
        if (index - ma >= 0) {
            before = this._sum[index - ma];
        }

        var y = (last - before) / ma;
        return y;
    }

    @override
    bool needUpdate(CandleData candleData, UIOPoint uiObject) {
        if (candleData.timeMs + candleData.durationMs / 2 <= uiObject.x) {
            return true;
        } else {
            return false;
        }
    }

    @override
    UIOPoint updateLastObject(CandleData candleData) {
        double last = 0;
        if (this._sum.length - 2 > 0) {
            last = this._sum[this._sum.length - 2];
        }
        if (this._sum.length - 1 > 0) {
            this._sum[this._sum.length - 1] = last + candleData.close;
        }
        var y = movingAverage(this._sum.length - 1, count);
        if (y != null) {
            var point = UIOPoint(candleData.timeMs.toDouble() +
                candleData.durationMs.toDouble() / 2.0, y);
            return point;
        }
        return null;
    }

    @override
    UIOPoint addCandle(CandleData candleData) {
        double last = 0;
        if (this._sum.length > 0) {
            last = this._sum.last;
        }
        this._sum.add(last + candleData.close);
        var y = movingAverage(this._sum.length - 1, count);
        if (y != null) {
            var point = UIOPoint(candleData.timeMs.toDouble() +
                candleData.durationMs.toDouble() / 2.0, y);
            return point;
        }
        return null;
    }

    @override
    UIOPath initCandleLIst(List<CandleData> candleDataList) {
        List<UIOPoint> uiPointList = [];
        candleDataList?.forEach((CandleData candleData) {
            var point = addCandle(candleData);
            if (point != null) {
                uiPointList.add(point);
            }
        });
        return UIOPath(uiPointList, painter: painter);
    }

    @override
    UIOPath updateLastCandleBegin(CandleData candleData) {
        return UIOPath(
            [
                fixedUIObject.uiObjects.last.clone(),
                fixedUIObject.uiObjects.last.clone()
            ],
            painter: painter);
    }

    @override
    UIOPath updateLastCandleEnd(CandleData candleData) {
        var point = updateLastObject(candleData);
        return UIOPath(
            [fixedUIObject.uiObjects.last.clone(), point], painter: painter);
    }

    @override
    @mustCallSuper
    void initState() {
        super.initState();
    }
}

class MaWidgetState extends State<MaWidget> {
    @override
    Widget build(BuildContext context) {
        return Stack(
            children: <Widget>[
                Positioned.fill(
                    child: UIAnimatedWidget<UIOPath, UIOPoint>(
                        initData: widget.initData,
                        dataStream: widget.dataStream,
                        uiCamera: widget.uiCamera,
                        onUpdateLastCandle: widget.onUpdate,
                        onAddCandle: widget.onAdd,
                        duration: widget.style.duration,
                        state: () =>
                            MaView(
                                widget.style.shortCount, widget.style.maShort),
                    )
                ),
                Positioned.fill(
                    child: UIAnimatedWidget<UIOPath, UIOPoint>(
                        initData: widget.initData,
                        dataStream: widget.dataStream,
                        uiCamera: widget.uiCamera,
                        onUpdateLastCandle: widget.onUpdate,
                        onAddCandle: widget.onAdd,
                        duration: widget.style.duration,
                        state: () =>
                            MaView(widget.style.middleCount,
                                widget.style.maMiddle),
                    )
                ),
                Positioned.fill(
                    child: UIAnimatedWidget<UIOPath, UIOPoint>(
                        initData: widget.initData,
                        dataStream: widget.dataStream,
                        uiCamera: widget.uiCamera,
                        onUpdateLastCandle: widget.onUpdate,
                        onAddCandle: widget.onAdd,
                        duration: widget.style.duration,
                        state: () =>
                            MaView(widget.style.longCount, widget.style.maLong),
                    )
                ),
            ],
        );
    }
}


class MaStyle {
    Color maLong;
    int longCount;

    Color maMiddle;
    int middleCount;

    Color maShort;
    int shortCount;

    Duration duration;

    MaStyle(this.shortCount, this.maShort,
        this.middleCount, this.maMiddle,
        this.longCount, this.maLong,
        this.duration);
}

class MaWidget extends StatefulWidget {

    MaWidget({
        Key key,
        this.initData,
        this.dataStream,
        this.uiCamera,
        this.onUpdate,
        this.onAdd,
        this.style,
    }) : super(key: key);

    final List<CandleData> initData;
    final Stream<CandleData> dataStream;
    final UICamera uiCamera;
    final Function(UIOPoint point) onUpdate;
    final Function(UIOPoint point) onAdd;
    final MaStyle style;

    @override
    MaWidgetState createState() => MaWidgetState();
}
