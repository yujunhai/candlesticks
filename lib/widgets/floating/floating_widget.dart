import 'package:flutter/material.dart';

import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';

class TopFloatingPainter extends CustomPainter {

  final ExtCandleData extCandleData;
  final UICamera uiCamera;

  TopFloatingPainter({
    this.uiCamera,
    this.extCandleData
  });


  TextPainter calLabel(Canvas canvas, Size size, bool alignLeft, String text) {
    TextPainter leftTextPainter = TextPainter(
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
    leftTextPainter.layout();
    return leftTextPainter;
  }
  Offset paintLabel(Canvas canvas, Size size, String key, String value, Offset origin, double width, {bool real = true}) {
    var leftLabel = calLabel(canvas, size, true, key);
    leftLabel.paint(canvas, origin);
    var rightLabel = calLabel(canvas, size, true, value);
    if(real) {
      rightLabel.paint(canvas, Offset(origin.dx + width - rightLabel.width, origin.dy));
    }
    return Offset(origin.dx, origin.dy + leftLabel.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (extCandleData == null) {
      return;
    }
    var sceneX = uiCamera.viewPortToScreenPoint(size, uiCamera.worldToViewPortPoint(UIOPoint(extCandleData.timeMs.toDouble(), 0))).dx;
    double width = size.width / 2.8;
    if(width < 60) {
      width = 60;
    }
    var leftTop = Offset(0, 20);
    if(sceneX < size.width / 2) {
      leftTop = Offset(0, 20);
    }else {
      leftTop = Offset(size.width - width, 20);
    }

    var time = new DateTime.fromMillisecondsSinceEpoch(extCandleData.timeMs);
    var timeStamp = time.toLocal().toString();
    var p = paintLabel(canvas, size, "时间", timeStamp, leftTop, width);
    p = paintLabel(canvas, size, "开", extCandleData.open.toStringAsFixed(4), p, width, real: false);
    p = paintLabel(canvas, size, "高", extCandleData.high.toStringAsFixed(4), p, width,real: false);
    p = paintLabel(canvas, size, "收", extCandleData.close.toStringAsFixed(4), p, width,real: false);
    p = paintLabel(canvas, size, "低", extCandleData.low.toStringAsFixed(4), p, width,real: false);
    p = paintLabel(canvas, size, "量", extCandleData.volume.toStringAsFixed(4), p, width,real: false);
    var rightBottom = Offset(p.dx + width, p.dy);
    var linePainter = Paint();
    linePainter.color=Colors.black.withOpacity(0.5);
    linePainter.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromPoints(leftTop, rightBottom), linePainter);

    p = paintLabel(canvas, size, "时间", timeStamp, leftTop, width);
    p = paintLabel(canvas, size, "开", extCandleData.open.toStringAsFixed(4), p, width);
    p = paintLabel(canvas, size, "高", extCandleData.high.toStringAsFixed(4), p, width);
    p = paintLabel(canvas, size, "收", extCandleData.close.toStringAsFixed(4), p, width);
    p = paintLabel(canvas, size, "低", extCandleData.low.toStringAsFixed(4), p, width);
    p = paintLabel(canvas, size, "量", extCandleData.volume.toStringAsFixed(4), p, width);

    var borderPainter = Paint();
    borderPainter.color=Colors.white;
    borderPainter.style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromPoints(leftTop, rightBottom), borderPainter);
  }

  @override
  bool shouldRepaint(TopFloatingPainter oldPainter) {
    return this.extCandleData != oldPainter.extCandleData;
  }
}


class FloatingWidget extends StatelessWidget {

  FloatingWidget({
    Key key,
    this.extCandleData,
    this.left,
  }) :super(key: key);

  final ExtCandleData extCandleData;
  final bool left;

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
    if (extCandleData == null) {
      return Container();
    }
    double tapTextHeight = 1.4;
    double tapTextSize = 8.0;
    Color tapTextFontColor = Colors.white.withOpacity(0.5);
    TextStyle textStyle = new TextStyle(
        color: tapTextFontColor, fontSize: tapTextSize, height: tapTextHeight);

    var uiCamera = AABBContext
        .of(context)
        .uiCamera;
    return CustomPaint(
      painter: TopFloatingPainter(
        uiCamera: uiCamera,
        extCandleData: extCandleData,
      ),
    );

    return SizedBox(
        height: 10,
        width: 10,
        child: Container(

            width: 10,
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
        ));
  }
}
