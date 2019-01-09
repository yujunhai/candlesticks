import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uicamera.dart';

class TopFloatingPainter extends CustomPainter {

  final bool left;
  final ExtCandleData extCandleData;

  TopFloatingPainter({
    this.left,
    this.extCandleData
  });


  double paintLabel(Canvas canvas, Size size, double x, String text) {
    TextPainter currentTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.0,
          ),
        )
    );
    currentTextPainter.layout();
    currentTextPainter.paint(canvas, Offset(x, 0));
    return currentTextPainter.width + 3;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (extCandleData == null) {
      return;
    }
    double x = paintLabel(canvas, size, 0, "Current:");
  }

  @override
  bool shouldRepaint(TopFloatingPainter oldPainter) {
    return this.left != oldPainter.left ||
        this.extCandleData != oldPainter.extCandleData;
  }
}

class MaFloatingState extends State<TopFloatingWidget> {
  ExtCandleData extCandleData;

  @override
  void initState() {
    super.initState();
  }
  onTapUp(TapUpDetails details) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    var touchOnLeft = false;
    if (details.globalPosition.dx <= context.size.width / 2) {
      touchOnLeft = true;
    }

    var worldPoint = uiCamera.viewPortToWorldPoint(
        uiCamera.screenToViewPortPoint(context.size, details.globalPosition));
    extCandleData = aabbContext.getExtCandleDataIndexByX(worldPoint.x);

    var candlesticksContext = CandlesticksContext.of(context);
    candlesticksContext.onTouchCandle(extCandleData);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapUp: onTapUp,
        behavior: HitTestBehavior.translucent,
    );
  }
}

class TopFloatingWidget extends StatefulWidget {
  TopFloatingWidget({
    Key key,
    this.left,
    this.candle
  }) : super(key: key);

  final bool left;
  final UIOCandle candle;

  @override
  MaFloatingState createState() => MaFloatingState();
}
