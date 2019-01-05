import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candles/candles_state.dart';
import 'package:candlesticks/2d/uiobjects/uio_candles.dart';
import 'package:candlesticks/2d/uiwidget.dart';
import 'package:candlesticks/widgets/uigesture_detector.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';

class CandlesView extends CandlesState {

  CandlesView() : super();


  @override
  Widget build(BuildContext context) {
    var uiCamera = CandlesticksContext
        .of(context)
        .uiCamera;
    if(uiCamera == null){
      return Container(

      );
    }

    return UIGestureDetector(
        onTap: () {
          print("tap candles");
        },
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: AnimatedBuilder(
                  animation: Listenable.merge([
                    uiPainterDataAnimationController
                  ]),
                  builder: (BuildContext context, Widget child) {
                    return UIWidget<UIOCandles>(
                      uiCamera: uiCamera,
                      uiPainterData: uiPainterDataAnimation
                          ?.value,
                    );
                  }
              ),
            ),
            Positioned.fill(
                child: UIWidget<UIOCandles>(
                  uiCamera: uiCamera,
                  uiPainterData: uiPainterData,
                )
            ),
          ],
        )
    );
  }
}
