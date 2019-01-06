import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_view.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_view.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';


class AABBWidget extends StatefulWidget {

  AABBWidget({
    Key key,
    this.extdataStream,
    this.durationMs,
    this.rangeX,
    this.candlesticksStyle,
  }) :super(key: key);

  final Stream<ExtCandleData> extdataStream;
  final double durationMs;
  final AABBRangeX rangeX;
  final CandlesticksStyle candlesticksStyle;

  @override
  AABBView createState() => AABBView();
}