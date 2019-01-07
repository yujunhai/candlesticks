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
  }) :super(key: key);

  final Stream<ExtCandleData> extDataStream;
  final double durationMs;
  final AABBRangeX rangeX;
  final CandlesticksStyle candlesticksStyle;
  final Widget child;

  @override
  AABBView createState() => AABBView();
}
