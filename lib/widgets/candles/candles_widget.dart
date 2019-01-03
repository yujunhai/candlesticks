import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/widgets/candles/candles_view.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candles/candles_style.dart';

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

    final List<ExtCandleData> initData;
    final Stream<ExtCandleData> dataStream;
    final UICamera uiCamera;
    final CandlesStyle style;
    final Function(ExtCandleData candleData, UIOCandle candle) onUpdate;
    final Function(ExtCandleData candleData, UIOCandle candle) onAdd;

    @override
    CandlesView createState() => CandlesView();
}
