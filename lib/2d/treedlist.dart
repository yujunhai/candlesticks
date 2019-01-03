library treedlist;

class TreedListMin<T extends Comparable> {
    List<T> _data;
    List<T> _minData;
    final int reverse;

    TreedListMin(List<T> data, {this.reverse = 1}) {
        this._data = <T>[];
        this._minData = <T>[null];
        if (data != null) {
            for (var i = 0; i < data.length; i++) {
                this.add(data[i]);
            }
        }
    }

    int get length => _data.length;

    void add(T value) {
        _data.add(null);
        _minData.add(null);
        this.set(this._data.length - 1, value);
    }

    T get(int index) {
        if ((index < 0) || (index >= this._data.length)) {
            return null;
        }
        return this._data[index];
    }

    void update(int index, T value) {
        if ((index < 0) || (index >= this._data.length)) {
            return;
        }
        if (value.compareTo(this._data[index]) * reverse < 0) {
            this.set(index, value);
        }
    }

    void set(int index, T value) {
        if (index >= _data.length) {
            return;
        }
        _data[index] = value;
        for (int i = index + 1; i <= _data.length; i += i & -i) {
            _minData[i] = _data[i - 1];
            for (int j = 1; j < i & -i; j <<= 1) {
                if ((_minData[i - j]).compareTo(_minData[i]) * reverse < 0) {
                    _minData[i] = _minData[i - j];
                }
            }
        }
    }

    T min(int left, int right) {
        if (right < left) {
            var t = left;
            left = right;
            right = t;
        }
        if (left < 0) {
            left = 0;
        }
        if (right <= 0) {
            return null;
        }
        if ((_data == null) || (_data.length <= 0)) {
            return null;
        }
        if (right > _data.length - 1) {
            right = _data.length - 1;
        }
        right++;
        left++;
        T min = _data[right - 1];
        while (true) {
            if ((_data[right - 1]).compareTo(min) * reverse < 0) {
                min = _data[right - 1];
            }
            if (right == left) break;
            for (right -= 1; right - left >= right & -right;
            right -= right & -right) {
                if ((_minData[right]).compareTo(min) * reverse < 0) {
                    min = _minData[right];
                }
            }
        }
        return min;
    }
}

