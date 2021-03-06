import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_view.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class CandlesticksWidget extends StatefulWidget {

    CandlesticksWidget({
        Key key,
        this.dataStream,
        this.candlesticksStyle,
    }) :super(key: key);

    final Stream<CandleData> dataStream;
    final CandlesticksStyle candlesticksStyle;

    @override
    CandlesticksView createState() => CandlesticksView(dataStream:dataStream);
}

