import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_state.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/top/top_widget.dart';
import 'package:candlesticks/widgets/middle/middle_widget.dart';

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
      onHorizontalDragStart: (x) {
        touching = true;
      },
      onVerticalDragCancel: () {
        touching = false;
      },
      onHorizontalDragEnd: onHorizontalDragEnd,
      onHorizontalDragUpdate: onHorizontalDragUpdate,


      onScaleUpdate: onScaleUpdate,
      onScaleStart: handleScaleStart,

      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onLongPress: onLongPress,

      child: AnimatedBuilder(
          animation: Listenable.merge([
            uiCameraAnimation,
          ]),
          builder: (BuildContext context, Widget child) {
            return CandlesticksContext(
              onTouchCandle: onTouchCandle,
              onCandleDataFinish: onCandleDataFinish,
              candlesX: candlesX,
              extCandleData: extCandleData,
              touchPoint: touchPoint,
              child: Column(
                  children: <Widget>[
                    Expanded(
                        flex: 6,
                        child: TopWidget(
                          durationMs: durationMs,
                          rangeX: uiCameraAnimation?.value,
                          candlesticksStyle: widget.candlesticksStyle,
                          extDataStream: exdataStream,
                        )),
                    Expanded(
                        flex: 1,
                        child: MiddleWidget(
                          durationMs: durationMs,
                          rangeX: uiCameraAnimation?.value,
                          candlesticksStyle: widget.candlesticksStyle,
                          extDataStream: exdataStream,
                        )
                    )
                  ]),
            );
          }
      ),
    );
  }
}
