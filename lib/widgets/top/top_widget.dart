import 'package:flutter/material.dart';

import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_widget.dart';
import 'package:candlesticks/widgets/graticule/graticule_widget.dart';
import 'package:candlesticks/widgets/touch/touch_candle_widget.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/floating/floating_widget.dart';

class TopWidget extends StatelessWidget {

  TopWidget({
    Key key,
    this.extDataStream,
    this.candlesticksStyle,
    this.rangeX,
    this.durationMs,
  }) :super(key: key);

  final Stream<ExtCandleData> extDataStream;
  final CandlesticksStyle candlesticksStyle;
  final AABBRangeX rangeX;
  final double durationMs;

  @override
  Widget build(BuildContext context) {
    var widget = this;
    var candlesticksContext = CandlesticksContext.of(context);

    return AABBWidget(
        extDataStream: extDataStream,
        durationMs: durationMs,
        rangeX: rangeX,
        candlesticksStyle: widget.candlesticksStyle,
        paddingY: widget.candlesticksStyle.candlesStyle.cameraPaddingY,
        child: Container(
            decoration: BoxDecoration(
              color: widget.candlesticksStyle.backgroundColor,
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: GraticuleWidget(
                    candlesticksStyle: this.candlesticksStyle,
                    paddingY: 0.1,
                  ),
                ),
                Positioned.fill(
                    child: CandlesWidget(
                      dataStream: widget.extDataStream,
                      style: widget.candlesticksStyle.candlesStyle,
                    )
                ),
                Positioned.fill(
                  child: MaWidget(
                    dataStream: widget.extDataStream,
                    style: widget.candlesticksStyle.maStyle,
                  ),
                ),
                Positioned.fill(
                  child: FloatingWidget(
                    extCandleData: candlesticksContext.extCandleData,
                  ),
                ),
                Positioned.fill(
                    child: TouchCandleWidget(
                      candle: null,
                      left: null,
                    )
                ),
              ],
            )
        ));
  }
}

