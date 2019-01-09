import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uicamera.dart';

class TopFloatingPainter extends CustomPainter {

  final bool left;
  final ExtCandleData extCandleData;

  TopFloatingPainter({
    this.left,
    this.extCandleData
  });


  double paintLabel(Canvas canvas, Size size, double x, String text) {
    TextPainter currentTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.0,
          ),
        )
    );
    currentTextPainter.layout();
    currentTextPainter.paint(canvas, Offset(x, 0));
    return currentTextPainter.width + 3;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (extCandleData == null) {
      return;
    }
    double x = paintLabel(canvas, size, 0, "Current:");
  }

  @override
  bool shouldRepaint(TopFloatingPainter oldPainter) {
    return this.left != oldPainter.left ||
        this.extCandleData != oldPainter.extCandleData;
  }
}

class MaFloatingState extends State<TopFloatingWidget> {

  bool touchOnLeft;
  ExtCandleData extCandleData;

  @override
  void initState() {
    super.initState();
    print("asdf");
  }
  onTapUp(TapUpDetails details) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (details.globalPosition.dx <= context.size.width / 2) {
      touchOnLeft = true;
    } else {
      touchOnLeft = false;
    }

    var worldPoint = uiCamera.viewPortToWorldPoint(
        uiCamera.screenToViewPortPoint(context.size, details.globalPosition));
    extCandleData = aabbContext.getExtCandleDataIndexByX(worldPoint.x);

    var candlesticksContext = CandlesticksContext.of(context);
    candlesticksContext.onTouchCandle(extCandleData);
  }

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
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if(uiCamera == null) {
      return Container();
    }
    var candlesticksContext = CandlesticksContext.of(context);

    /// 选中K线 字体颜色
    Color tapTextFontColor = Colors.white.withOpacity(0.5);

    /// 选中K线 文本框边框颜色
    Color tapTextBorderColor = Colors.white.withOpacity(0.4);
    double tapTextHeight = 1.4;
    double tapTextSize = 8.0;
    TextStyle textStyle = new TextStyle(
        color: tapTextFontColor, fontSize: tapTextSize, height: tapTextHeight);
    print("rebuild ${candlesticksContext.visible}");
    print(candlesticksContext.visible);

    return GestureDetector(
        onTapUp: onTapUp,
        behavior: HitTestBehavior.translucent,
        /*
        child: Container()Offstage(
            offstage: !candlesticksContext.visible,
            child: SizedBox(
                width: 10,
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
                    )))
        )
        */
    );
  }
}

class TopFloatingWidget extends StatefulWidget {
  TopFloatingWidget({
    Key key,
    this.left,
    this.candle
  }) : super(key: key);

  final bool left;
  final UIOCandle candle;

  @override
  MaFloatingState createState() => MaFloatingState();
}
