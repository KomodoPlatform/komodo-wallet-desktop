/*
MIT License

Copyright (c) 2020 Pierre-Yves Siret

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import QtQuick 2.15
import QtQml 2.15

Behavior {
    id: root

    property QtObject fadeTarget: targetProperty.object
    property string fadeProperty: "scale"
    property int fadeDuration: 150
    property var fadeValue: 0
    property string easingType: "Quad"

    property alias exitAnimation: exitAnimation
    property alias enterAnimation: enterAnimation

    SequentialAnimation {
        NumberAnimation {
            id: exitAnimation
            target: root.fadeTarget
            property: root.fadeProperty
            duration: root.fadeDuration
            to: root.fadeValue
            easing.type: root.easingType === "Linear" ? Easing.Linear : Easing["In"+root.easingType]
        }
        PropertyAction { }
        NumberAnimation {
            id: enterAnimation
            target: root.fadeTarget
            property: root.fadeProperty
            duration: root.fadeDuration
            to: 1
            easing.type:  root.easingType === "Linear" ? Easing.Linear : Easing["Out"+root.easingType]
        }
    }
}
