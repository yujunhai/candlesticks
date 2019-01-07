import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_view.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_view.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';

class MainBoardWidget extends StatelessWidget {

  MainBoardWidget({
    Key key,
    this.extdataStream,
    this.candlesticksStyle,
  }) :super(key: key);

  final Stream<ExtCandleData> extdataStream;
  final CandlesticksStyle candlesticksStyle;

  @override
  Widget build(BuildContext context) {
    var widget = this;
    return Container(
        decoration: BoxDecoration(
          color: widget.candlesticksStyle.backgroundColor,
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: MaWidget(
                dataStream: widget.extdataStream,
                style: widget.candlesticksStyle.maStyle,
              ),
            ),
            Positioned.fill(
                child: CandlesWidget(
                  dataStream: widget.extdataStream,
                  style: widget.candlesticksStyle.candlesStyle,
                )
            ),
          ],
        )
    );
  }
}

