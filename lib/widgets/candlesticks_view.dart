import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_state.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/2d/candle_data.dart';

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
                                        style: CandlesStyle(Colors.redAccent,
                                            Colors.greenAccent, 1,
                                            Duration(milliseconds: 200)),
                                    )
                                ),
                                Positioned.fill(
                                    child: MaWidget(
                                        initData: initData,
                                        dataStream: dataStream,
                                        uiCamera: uiCameraAnimation.value,
                                        onUpdate: onMaUpdate,
                                        style: MaStyle(
                                            5,
                                            Colors.yellowAccent,
                                            15,
                                            Colors.greenAccent,
                                            30,
                                            Colors.deepPurpleAccent,
                                            Duration(milliseconds: 200)),
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
