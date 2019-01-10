import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/ma/ma_style.dart';
import 'package:candlesticks/widgets/ma/ma_context.dart';
import 'package:candlesticks/widgets/ma/ma_value_widget.dart';
import 'package:candlesticks/widgets/ma/ma_value_data.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class MaValuePainter extends CustomPainter {

  final UICamera uiCamera;
  final double paddingY;
  final CandlesticksStyle style;

  MaValueData maValueData;

  MaValuePainter({
    this.uiCamera,
    this.paddingY,
    this.style,
    this.maValueData,
  });



  double paintLabel(Canvas canvas, Size size, double x, String text, Color color) {
    TextPainter currentTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
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
    double x = paintLabel(canvas, size, 0, "Current:" + maValueData.currentValue.toStringAsFixed(4), style.maStyle.currentColor);
    x += paintLabel(canvas, size, x, "MA${style.maStyle.shortCount}:" + maValueData.shortValue.toStringAsFixed(4), style.maStyle.shortColor);
    x += paintLabel(canvas, size, x, "MA${style.maStyle.middleCount}:" + maValueData.middleValue.toStringAsFixed(4), style.maStyle.middleColor);
    x += paintLabel(canvas, size, x, "MA${style.maStyle.longCount}:" + maValueData.longValue.toStringAsFixed(4), style.maStyle.longColor);
  }

  @override
  bool shouldRepaint(MaValuePainter oldPainter) {
    return true;
  }
}

class MaValueWidget extends StatelessWidget {
  MaValueWidget({
    Key key,
    this.maValueData,
    this.style,
    this.paddingY,
  }) : super(key: key);

  final MaValueData maValueData;
  final double paddingY;
  final CandlesticksStyle style;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: MaValuePainter(
          maValueData: this.maValueData,
          uiCamera: uiCamera,
          paddingY: paddingY,
          style: this.style,
        ),
        size: Size.infinite
    );
  }
}
