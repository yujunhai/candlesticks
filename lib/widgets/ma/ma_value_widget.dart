import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/ma/ma_style.dart';

class MaValuePainter extends CustomPainter {

  final UICamera uiCamera;
  final double paddingY;
  final MaStyle maStyle;

  MaValuePainter({
    this.uiCamera,
    this.paddingY,
    this.maStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var worldY = 123.4312;
    var priceStr = worldY.toStringAsFixed(4);

    TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: priceStr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.0,
          ),
        )
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(0, 0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MaValueWidget extends StatelessWidget {
  MaValueWidget({
    Key key,
    this.maStyle,
    this.paddingY,
  }) : super(key: key);

  final double paddingY;
  final MaStyle maStyle;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: MaValuePainter(
          uiCamera: uiCamera,
          paddingY: paddingY,
          maStyle: this.maStyle,
        ),
        size: Size.infinite
    );
  }
}
