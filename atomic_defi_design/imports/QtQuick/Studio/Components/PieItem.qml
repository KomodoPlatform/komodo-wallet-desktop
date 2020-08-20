/****************************************************************************
**
** Copyright (C) 2019 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of Qt Quick Designer Components.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Shapes 1.0

Shape {
    id: root

    implicitWidth: 100
    implicitHeight: 100

    property alias gradient: path.fillGradient
    property alias strokeStyle: path.strokeStyle
    property alias strokeWidth: path.strokeWidth
    property alias strokeColor: path.strokeColor
    property alias dashPattern: path.dashPattern
    property alias joinStyle: path.joinStyle
    property alias fillColor: path.fillColor
    property alias dashOffset: path.dashOffset
    property alias capStyle: path.capStyle

    property real begin: 0
    property real end: 90

    property real alpha: end - begin

    property bool antialiasing: false
    layer.enabled: antialiasing
    layer.smooth: antialiasing
    layer.textureSize: Qt.size(width * 2, height * 2)

    property bool hideLine: {
        if (alpha <= 0)
            return true
        if (alpha >= 360)
            return true
        return false
    }

    function polarToCartesianX(centerX, centerY, radius, angleInDegrees) {
        var angleInRadians = angleInDegrees * Math.PI / 180.0;
        var x = centerX + radius * Math.cos(angleInRadians)
        return x
    }

    function polarToCartesianY(centerX, centerY, radius, angleInDegrees) {
        var angleInRadians = angleInDegrees * Math.PI / 180.0;
        var y = centerY + radius * Math.sin(angleInRadians);
        return y
    }

    ShapePath {
        id: path

        property real __xRadius: width / 2 - strokeWidth / 2
        property real __yRadius: height / 2 - strokeWidth / 2

        property real __Xcenter: width / 2
        property real __Ycenter: height / 2

        strokeColor: Qt.transparent
        capStyle: ShapePath.FlatCap

        strokeWidth: 1

        startX: root.hideLine ? root.polarToCartesianX(path.__Xcenter, path.__Ycenter, path.__xRadius, root.begin - 180)
                              : __Xcenter
        startY: root.hideLine ? root.polarToCartesianY(path.__Xcenter, path.__Ycenter, path.__yRadius, root.begin - 180)
                              : __Ycenter
        //startX: __Xcenter
        //startY: __Ycenter

        PathLine {
            x: root.polarToCartesianX(path.__Xcenter, path.__Ycenter, path.__xRadius, root.begin - 180)
            y: root.polarToCartesianY(path.__Xcenter, path.__Ycenter, path.__yRadius, root.begin - 180)
        }

        PathArc {
            id: arc

            x: root.polarToCartesianX(path.__Xcenter, path.__Ycenter, path.__xRadius, root.end - 180)
            y: root.polarToCartesianY(path.__Xcenter, path.__Ycenter,  path.__yRadius, root.end - 180)

            radiusY: path.__yRadius;
            radiusX: path.__xRadius;

            useLargeArc: root.alpha > 180
        }

        PathLine {
            x: root.hideLine ? root.polarToCartesianX(path.__Xcenter, path.__Ycenter, path.__xRadius, root.end - 180)
                             : path.__Xcenter
            y: root.hideLine ? root.polarToCartesianY(path.__Xcenter, path.__Ycenter,  path.__yRadius, root.end - 180)
                             : path.__Ycenter
        }
    }
}

