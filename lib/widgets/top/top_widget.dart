import 'package:flutter/material.dart';

import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_widget.dart';
import 'package:candlesticks/widgets/graticule/graticule_widget.dart';
import 'package:candlesticks/widgets/floating/floating_widget.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';

class TopWidget extends StatelessWidget {

  TopWidget({
    Key key,
    this.extDataStream,
    this.candlesticksStyle,
    this.rangeX,
    this.durationMs,
  }) :super(key: key);

  final Stream<ExtCandleData> extDataStream;
  final CandlesticksStyle candlesticksStyle;
  final AABBRangeX rangeX;
  final double durationMs;

  Widget getText(String text, String data, TextStyle textStyle,
      [TextStyle textStyleColor,]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Text(text,
            style: textStyleColor is TextStyle ? textStyleColor : textStyle,
            textAlign: TextAlign.left,),
        ),
        new Expanded(
          flex: 8,
          child: new Text(
            data, style: textStyle, textAlign: TextAlign.right,),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var widget = this;
    double tapTextHeight = 1.4;
    double tapTextSize = 8.0;
    Color tapTextFontColor = Colors.white.withOpacity(0.5);
    TextStyle textStyle = new TextStyle(
        color: tapTextFontColor, fontSize: tapTextSize, height: tapTextHeight);
    var candlesticksContext = CandlesticksContext.of(context);

    return AABBWidget(
        extDataStream: extDataStream,
        durationMs: durationMs,
        rangeX: rangeX,
        candlesticksStyle: widget.candlesticksStyle,
        paddingY: widget.candlesticksStyle.candlesStyle.cameraPaddingY,
        child: Container(
            decoration: BoxDecoration(
              color: widget.candlesticksStyle.backgroundColor,
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: GraticuleWidget(
                    candlesticksStyle: this.candlesticksStyle,
                    paddingY: 0.1,
                  ),
                ),
                Positioned.fill(
                    child: CandlesWidget(
                      dataStream: widget.extDataStream,
                      style: widget.candlesticksStyle.candlesStyle,
                    )
                ),
                Positioned.fill(
                  child: MaWidget(
                    dataStream: widget.extDataStream,
                    style: widget.candlesticksStyle.maStyle,
                  ),
                ),
                Positioned.fill(
                    child: Offstage(
                        offstage: !candlesticksContext.visible,
                        child: Container(
                            width: 10.0,
                            height: 10.0,
                            padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
                            decoration: new BoxDecoration(
                              border: new Border.all(
                                width: 0.5,
                                color: Colors.white.withOpacity(0.4),
                              ),
                              color: Color(0xff21232e).withOpacity(0.9),
                            ),
                            child: new Column(
                              children: [
                                getText("asdf", "123.123", textStyle)
                              ],
                            )
                        ))
                ),
                Positioned.fill(
                    child: TopFloatingWidget(
                      candle: null,
                      left: null,
                    )
                ),
              ],
            )
        ));
  }
}

