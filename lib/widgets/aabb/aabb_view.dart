import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/aabb/aabb_state.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';

class AABBView extends AABBState {
  AABBView() : super();


  @override
  Widget build(BuildContext context) {
    var uiCamera = calUICamera(widget.rangeX.minX, widget.rangeX.maxX);
    if(uiCamera == null) {
      return Container();
    }

    return AABBContext(
        onAABBChange: onAABBChange,
        uiCamera: uiCamera,
        durationMs: widget.durationMs,
        child:
        Container(
            decoration: BoxDecoration(
              color: widget.candlesticksStyle.backgroundColor,
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                    child: CandlesWidget(
                      dataStream: exdataStream,
                      style: widget.candlesticksStyle.candlesStyle,
                    )
                ),
                Positioned.fill(
                  child: MaWidget(
                    dataStream: exdataStream,
                    style: widget.candlesticksStyle.maStyle,
                  ),
                ),
              ],
            )
        ));
  }
}
