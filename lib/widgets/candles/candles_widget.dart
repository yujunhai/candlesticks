import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candles/candles_style.dart';
import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/uiobjects/uio_candles.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/ma/ma_style.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';

class CandlesView extends UIAnimatedView<UIOCandles, UIOCandle> {
  final CandlesStyle style;
  Paint positivePainter;
  Paint negativePainter;


  CandlesView({this.positivePainter, this.negativePainter, this.style})
      : super(animationCount: 2);

  @override
  UIOCandle getCandle(ExtCandleData candleData) {
    var candleUIObject = UIOCandle.fromData(candleData, style.paddingX,
        candleData.open <= candleData.close
            ? positivePainter
            : negativePainter, index: candleData.index);
    return candleUIObject;
  }

  @override
  UIOCandles getCandles() {
    return UIOCandles([]);
  }

  @override
  UIOCandles getBeginAnimation(UIOCandles lastAnimationUIObject,
      UIOCandle candleUIObject) {
    var path = lastAnimationUIObject.clone();
    var currentCandle = UIOCandle(
        UIOPoint(candleUIObject.origin.x, candleUIObject.origin.y),
        UIOPoint(candleUIObject.r.x, 0), 0, 0, style.paddingX,
        painter: candleUIObject.painter, index: candleUIObject.index);
    path.uiObjects.add(currentCandle);

    return path;
  }

  @override
  UIOCandles getEndAnimation(UIOCandles lastAnimationUIObject,
      UIOCandle candleUIObject) {
    var path = lastAnimationUIObject.clone();
    path.uiObjects.add(candleUIObject);
    return path;
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
  }
}

class CandlesWidgetState extends State<CandlesWidget> {
  AABBContext aabbContext;
  Paint positivePainter;
  Paint negativePainter;

  @override void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    aabbContext = AABBContext.of(context);
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = aabbContext?.uiCamera;

    return Stack(
        children: <Widget>[
          Positioned.fill(child: UIAnimatedWidget<UIOCandles, UIOCandle>(
            dataStream: widget.dataStream,
            uiCamera: uiCamera,
            duration: widget.style.duration,
            state: () =>
                CandlesView(
                  positivePainter: positivePainter,
                  negativePainter: negativePainter,
                  style: widget.style,
                ),
          )),
          Positioned.fill(child: UIAnimatedWidget<UIOCandles, UIOCandle>(
            dataStream: widget.dataStream,
            uiCamera: uiCamera,
            duration: widget.style.duration,
            state: () =>
                CandlesView(
                  positivePainter: positivePainter,
                  negativePainter: negativePainter,
                  style: widget.style,
                ),
          ))
        ]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    positivePainter = new Paint()
      ..color = widget.style.positiveColor
      ..style = PaintingStyle.fill;
    negativePainter = new Paint()
      ..color = widget.style.negativeColor
      ..style = PaintingStyle.fill;
  }
}


class CandlesWidget extends StatefulWidget {
  CandlesWidget({
    Key key,
    this.dataStream,
    this.style,
  }) : super(key: key);

  final Stream<ExtCandleData> dataStream;
  final CandlesStyle style;

  @override
  CandlesWidgetState createState() => CandlesWidgetState();
}
