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
          decoration: new BoxDecoration(
            border: new Border.all(width: 2.0, color: Colors.red),
            color: Colors.grey,
            borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
            image: new DecorationImage(
              image: new NetworkImage('http://h.hiphotos.baidu.com/zhidao/wh%3D450%2C600/sign=0d023672312ac65c67506e77cec29e27/9f2f070828381f30dea167bbad014c086e06f06c.jpg'),
              centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
            ),
          ),
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
