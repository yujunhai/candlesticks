import 'package:flutter/material.dart';

class MaStyle {
    Color maLong;
    int longCount;

    Color maMiddle;
    int middleCount;

    Color maShort;
    int shortCount;

    Duration duration;

    double cameraPaddingY;

    MaStyle({this.shortCount, this.maShort,
        this.middleCount, this.maMiddle,
        this.longCount, this.maLong,
        this.duration, this.cameraPaddingY});
}

