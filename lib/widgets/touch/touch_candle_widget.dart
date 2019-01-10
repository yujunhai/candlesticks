import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uicamera.dart';

class TouchCandleState extends State<TouchCandleWidget> {
  ExtCandleData extCandleData;

  @override
  void initState() {
    super.initState();
  }

  onTapUp(TapUpDetails details) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;

    var worldPoint = uiCamera.viewPortToWorldPoint(
        uiCamera.screenToViewPortPoint(context.size, details.globalPosition));
    extCandleData = aabbContext.getExtCandleDataIndexByX(worldPoint.x);

    var candlesticksContext = CandlesticksContext.of(context);
    candlesticksContext.onTouchCandle(details.globalPosition, extCandleData);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapUp: onTapUp,
        behavior: HitTestBehavior.translucent,
    );
  }
}

class TouchCandleWidget extends StatefulWidget {
  TouchCandleWidget({
    Key key,
    this.left,
    this.candle
  }) : super(key: key);

  final bool left;
  final UIOCandle candle;

  @override
  TouchCandleState createState() => TouchCandleState();
}
