import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class UIGestureDetector extends RawGestureDetector {
    final GestureTapCallback onTap;

    UIGestureDetector({this.onTap, child}) : super(
        gestures: {
            AllowMultipleGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                AllowMultipleGestureRecognizer>(
                    () => AllowMultipleGestureRecognizer(),
                    (AllowMultipleGestureRecognizer instance) {
                    instance.onTap = onTap;
                },
            )
        },
        behavior: HitTestBehavior.deferToChild,
        child:child
    );
}

class AllowMultipleGestureRecognizer extends TapGestureRecognizer {
    @override
    void rejectGesture(int pointer) {
        acceptGesture(pointer);
    }
}
