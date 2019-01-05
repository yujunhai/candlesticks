import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_state.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';

class CandlesticksView extends CandlesticksState {
  CandlesticksView({Stream<CandleData> dataStream})
      : super(dataStream: dataStream);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: onHorizontalDragEnd,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      child: AnimatedBuilder(
          animation: Listenable.merge([
            uiCameraAnimation,
          ]),
          builder: (BuildContext context, Widget child) {
            return CandlesticksContext(
                onAABBChange: onAABBChange,
                uiCamera: uiCameraAnimation?.value,
                child: Container(
                    decoration: new BoxDecoration(
                      /*
                                    border: new Border.all(
                                        width: 1.0, color: Colors.white),
                                        */
                      color: const Color(0xff21232e),
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
                            uiCamera: uiCameraAnimation?.value,
                            style: widget.candlesticksStyle.maStyle,
                          ),
                        ),
                      ],
                    )
                ));
          }
      ),
    );
  }
}
