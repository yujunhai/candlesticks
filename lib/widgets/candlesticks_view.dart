import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_state.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/2d/candle_data.dart';

import 'package:candlesticks/widgets/candles/candles_style.dart';
import 'package:candlesticks/widgets/ma/ma_style.dart';

class CandlesticksView extends CandlesticksState {

    CandlesticksView(
        {final List<CandleData> initData, Stream<CandleData> dataStream})
        : super(initData: initData, dataStream: dataStream);


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
                    return Container(
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
                                        initData: initData,
                                        dataStream: dataStream,
                                        uiCamera: uiCameraAnimation.value,
                                        onUpdate: onCandleUpdate,
                                        onAdd: onCandleAdd,
                                        style: widget.candlesticksStyle.candlesStyle,
                                    )
                                ),
                                Positioned.fill(
                                    child: MaWidget(
                                        initData: initData,
                                        dataStream: dataStream,
                                        uiCamera: uiCameraAnimation.value,
                                        onUpdate: onMaUpdate,
                                        onAdd: onMaAdd,
                                        style: widget.candlesticksStyle.maStyle,
                                    ),
                                ),
                            ],
                        )
                    );
                }
            ),
        );
    }
}
