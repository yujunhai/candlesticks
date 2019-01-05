
import 'package:candlesticks/widgets/ma/ma_style.dart';
import 'package:candlesticks/widgets/candles/candles_style.dart';

class CandlesticksStyle {
    Duration cameraDuration;
    int viewPortX;
    int durationMs;

    CandlesStyle candlesStyle;
    MaStyle maStyle;

    CandlesticksStyle({this.candlesStyle, this.maStyle, this.cameraDuration, this.viewPortX, this.durationMs});
}
