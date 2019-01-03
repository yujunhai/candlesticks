
class CandleData {
    final int timeMs;
    final int durationMs;
    final double open;
    final double close;
    final double high;
    final double low;
    final double volume;

    CandleData({
        this.timeMs,
        this.durationMs,
        this.open,
        this.close,
        this.high,
        this.low,
        this.volume,
    });

    CandleData.fromArray(final List<dynamic> item, this.durationMs) :
            timeMs = int.parse(item[0]),
            open = double.parse(item[1]),
            high = double.parse(item[2]),
            low = double.parse(item[3]),
            close = double.parse(item[4]),
            volume = double.parse(item[5]);
}

class ExtCandleData extends CandleData {
    final int index;

    ExtCandleData(CandleData candleData, {this.index}) : super(
        timeMs:candleData.timeMs,
        durationMs:candleData.durationMs,
        open:candleData.open,
        close:candleData.close,
        high:candleData.high,
        low:candleData.low,
        volume:candleData.volume,
    );
}

