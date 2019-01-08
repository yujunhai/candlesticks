import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_view.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_view.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';


class AABBWidget extends StatefulWidget {

  AABBWidget({
    Key key,
    this.extDataStream,
    this.durationMs,
    this.rangeX,
    this.candlesticksStyle,
    this.child,
    this.paddingY,
  }) :super(key: key);

  final Stream<ExtCandleData> extDataStream;
  final double durationMs;
  final AABBRangeX rangeX;
  final CandlesticksStyle candlesticksStyle;
  final Widget child;
  final double paddingY;

  @override
  AABBView createState() => AABBView();
}
