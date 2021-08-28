import QtQuick 2.15

DexFadebehavior {
    fadeProperty: "opacity"
    fadeDuration: 200
    exitAnimation.duration: targetValue ? 0 : fadeDuration
    enterAnimation.duration: targetValue ? fadeDuration : 0
}