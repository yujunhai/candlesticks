import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_state.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/main/main_widget.dart';

class CandlesticksView extends CandlesticksState {
  CandlesticksView({Stream<CandleData> dataStream})
      : super(dataStream: dataStream);


  @override
  Widget build(BuildContext context) {
    if (isWaitingForInitData()) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GestureDetector(
      onHorizontalDragEnd: onHorizontalDragEnd,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      child: AnimatedBuilder(
          animation: Listenable.merge([
            uiCameraAnimation,
          ]),
          builder: (BuildContext context, Widget child) {
            return CandlesticksContext(
                onCandleDataFinish: onCandleDataFinish,
                candlesX: candlesX,
                child: AABBWidget(
                  extDataStream: exdataStream,
                  durationMs: durationMs,
                  rangeX: uiCameraAnimation?.value,
                  candlesticksStyle: widget.candlesticksStyle,
                  child: MainWidget(
                    candlesticksStyle: widget.candlesticksStyle,
                    extdataStream: exdataStream,
                  ),
                ));
          }
      ),
    );
  }
}
