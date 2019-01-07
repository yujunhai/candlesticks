import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/ma/ma_style.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';

class MaView extends UIAnimatedView<UIOPath, UIOPoint> {
  List<double> _sum;
  int count;
  Paint painter;
  Color color;

  MaView(this.count, this.color) : super(animationCount:2) {
    this._sum = List<double>();

    painter = new Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
  }

  double movingAverage(int index, int ma) {
    if ((this._sum == null) || (index + 1 < ma) ||
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
  UIOPoint getCandle(ExtCandleData candleData) {
    double last = 0;
    if (this._sum.length > 0) {
      last = this._sum.last;
    }
    while (this._sum.length <= candleData.index) {
      this._sum.add(last);
    }
    this._sum[candleData.index] =
        (candleData.index > 0 ? this._sum[candleData.index - 1] : 0) +
            candleData.close;

    var y = movingAverage(candleData.index, count);
    if (y != null) {
      var point = UIOPoint(candleData.timeMs.toDouble() +
          candleData.durationMs.toDouble() / 2.0, y, index: candleData.index);
      return point;
    }
    return null;
  }

  @override
  UIOPath getCandles() {
    return UIOPath([], painter: painter);
  }

  @override
  UIOPath getBeginAnimation(UIOPath lastAnimationUIObject, UIOPoint point) {
    var path = lastAnimationUIObject.clone();
    path.uiObjects.add(path.uiObjects.last.clone());
    return path;
  }
  @override
  UIOPath getEndAnimation(UIOPath lastAnimationUIObject, UIOPoint point) {
    var path = lastAnimationUIObject.clone();
    path.uiObjects.add(point);
    return path;
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
  }
}

class MaWidgetState extends State<MaWidget> {

  AABBContext candlesticksContext;

  @override void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    candlesticksContext = AABBContext.of(context);
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = candlesticksContext?.uiCamera;
    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.duration,
              state: () =>
                  MaView(
                      widget.style.shortCount, widget.style.maShort),
            )
        ),
        Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.duration,
              state: () =>
                  MaView(widget.style.middleCount,
                      widget.style.maMiddle),
            )
        ),
        Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.duration,
              state: () =>
                  MaView(widget.style.longCount, widget.style.maLong),
            )
        ),
      ],
    );
  }
}


class MaWidget extends StatefulWidget {
  MaWidget({
    Key key,
    this.dataStream,
    this.style,
  }) : super(key: key);

  final Stream<ExtCandleData> dataStream;
  final MaStyle style;

  @override
  MaWidgetState createState() => MaWidgetState();
}
