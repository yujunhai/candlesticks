import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/widgets/candles/candles_view.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candles/candles_style.dart';

class CandlesWidget extends StatefulWidget {

    CandlesWidget({
        Key key,
        this.dataStream,
        this.style,
    }) :super(key: key);

    final Stream<ExtCandleData> dataStream;
    final CandlesStyle style;

    @override
    CandlesView createState() => CandlesView();
}
