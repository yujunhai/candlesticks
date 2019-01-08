import 'package:flutter/material.dart';

import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_widget.dart';

class MiddleWidget extends StatelessWidget {

  MiddleWidget({
    Key key,
    Stream<ExtCandleData> extDataStream,
    this.candlesticksStyle,
    this.rangeX,
    this.durationMs,
  }) :super(key: key) {
    this.volumeDataStream = extDataStream.map((ExtCandleData extCandleData) {
      double open = extCandleData.volume;
      double close = 0;
      if(extCandleData.open <= extCandleData.close) {
        close = extCandleData.volume;
        open = 0;
      }
      CandleData candleData = CandleData(timeMs: extCandleData.timeMs,
          open: open,
          close: close,
          high: extCandleData.volume,
          low: 0,
          volume: extCandleData.volume
      );
      return ExtCandleData(candleData,
          durationMs: extCandleData.durationMs,
          first: extCandleData.first,
          index: extCandleData.index,
          getValue: (candleData) => candleData.volume,
      );
    });
  }

  Stream<ExtCandleData> volumeDataStream;
  final CandlesticksStyle candlesticksStyle;
  final AABBRangeX rangeX;
  final double durationMs;

  @override
  Widget build(BuildContext context) {
    var widget = this;
    return AABBWidget(
        extDataStream: volumeDataStream,
        durationMs: durationMs,
        rangeX: rangeX,
        candlesticksStyle: widget.candlesticksStyle,
        paddingY: widget.candlesticksStyle.maStyle.cameraPaddingY,
        child: Container(
            decoration: BoxDecoration(
              color: widget.candlesticksStyle.backgroundColor,
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                    child: CandlesWidget(
                      dataStream: widget.volumeDataStream,
                      style: widget.candlesticksStyle.candlesStyle,
                    )
                ),
                Positioned.fill(
                  child: MaWidget(
                    dataStream: widget.volumeDataStream,
                    style: widget.candlesticksStyle.maStyle,
                  ),
                ),
              ],
            )
        )
    );
  }
}
