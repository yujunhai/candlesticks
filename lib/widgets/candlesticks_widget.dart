import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_view.dart';
import 'package:candlesticks/2d/candle_data.dart';

class CandlesticksWidget extends StatefulWidget {

    CandlesticksWidget({
        Key key,
        this.initData,
        this.dataStream,
    }) :super(key: key);

    final List<CandleData> initData;
    final Stream<CandleData> dataStream;

    @override
    CandlesticksView createState() => CandlesticksView(initData:initData, dataStream:dataStream);
}

