import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/widgets/candles/candles_view.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/candle_data.dart';

class CandlesStyle {
    Color positiveColor;
    Color negativeColor;
    double marginX;
    Duration duration;

    CandlesStyle(this.positiveColor, this.negativeColor, this.marginX, this.duration);
}

class CandlesWidget extends StatefulWidget {

    CandlesWidget({
        Key key,
        this.initData,
        this.dataStream,
        this.uiCamera,
        this.onUpdate,
        this.onAdd,
        this.style,
    }) :super(key: key);

    final List<CandleData> initData;
    final Stream<CandleData> dataStream;
    final UICamera uiCamera;
    final CandlesStyle style;
    final Function(CandleData candleData, UIOCandle candle) onUpdate;
    final Function(CandleData candleData, UIOCandle candle) onAdd;

    @override
    CandlesView createState() => CandlesView();
}
