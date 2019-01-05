
class CandleData {
    final int timeMs;
    final double open;
    final double close;
    final double high;
    final double low;
    final double volume;

    CandleData({
        this.timeMs,
        this.open,
        this.close,
        this.high,
        this.low,
        this.volume,
    });

    CandleData.fromArray(final List<dynamic> item) :
            timeMs = int.parse(item[0]),
            open = double.parse(item[1]),
            high = double.parse(item[2]),
            low = double.parse(item[3]),
            close = double.parse(item[4]),
            volume = double.parse(item[5]);
}

class ExtCandleData extends CandleData {
    final int index;
    final int durationMs;

    ExtCandleData(CandleData candleData, {this.index, this.durationMs}) : super(
        timeMs:candleData.timeMs,
        open:candleData.open,
        close:candleData.close,
        high:candleData.high,
        low:candleData.low,
        volume:candleData.volume,
    );
}

