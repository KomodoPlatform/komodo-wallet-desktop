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

    property int pLineXStart
    property int pLineXEnd
    property int pLineYStart
    property int pLineYEnd

    property point topIntersection1
    property point topIntersection2
    property point leftIntersection1
    property point leftIntersection2
    property point rightIntersection1
    property point rightIntersection2

    property int radius: 5
    property real arcRadius: radius

    property real leftMargin: 0
    property real topMargin: 0

    property real rightMargin: 0
    property real bottomMargin: 0

    property bool antiAlias: false
    layer.enabled: antiAlias
    layer.smooth: antiAlias
    layer.textureSize: Qt.size(width * 2, height * 2)

    ShapePath {
        id: path

        property real __width: root.width - root.strokeWidth - root.leftMargin - root.rightMargin
        property real __height: root.height - root.strokeWidth - root.topMargin - root.bottomMargin
        property real xOffset: root.strokeWidth / 2 + root.leftMargin
        property real yOffset: root.strokeWidth / 2 + root.topMargin

        strokeColor: Qt.transparent
        strokeWidth: 1
        capStyle: ShapePath.FlatCap

        startX: root.topIntersection1.x + path.xOffset
        startY: root.topIntersection1.y + path.yOffset

        PathArc {
            radiusX: root.arcRadius
            radiusY: root.arcRadius

            x: root.topIntersection2.x + path.xOffset
            y: root.topIntersection2.y + path.yOffset

        }

        PathLine {
            x: root.rightIntersection1.x + path.xOffset
            y: root.rightIntersection1.y + path.yOffset
        }

        PathArc {
            radiusX: root.arcRadius
            radiusY: root.arcRadius

            x: root.rightIntersection2.x + path.xOffset
            y: root.rightIntersection2.y + path.yOffset
        }

        PathLine {
            x: root.leftIntersection1.x + path.xOffset
            y: root.leftIntersection1.y + path.yOffset
        }

        PathArc {
            radiusX: root.arcRadius
            radiusY: root.arcRadius

            x: root.leftIntersection2.x + path.xOffset
            y: root.leftIntersection2.y + path.yOffset
        }

        PathLine {
            x: root.topIntersection1.x + path.xOffset
            y: root.topIntersection1.y + path.yOffset
        }



    }

    onWidthChanged: calc()

    onHeightChanged: calc()

    onRadiusChanged: calc()
    onArcRadiusChanged: calc()

    onTopMarginChanged: calc()
    onBottomMarginChanged: calc()
    onLeftMarginChanged: calc()
    onRightMarginChanged: calc()

    Component.onCompleted: root.calc()

    function normalize(x, y)
    {
        var length = Math.sqrt(x*x+y*y)

        return {
            x: x / length,
            y: y / length
        }
    }

    function dotProduct(x1, y1, x2, y2)
    {
        return x1 * x2 + y1 * y2;
    }

    function project(x1, y1, x2, y2)
    {
        var normalized = normalize(x1, y1)

        var dot = dotProduct(normalized.x, normalized.y, x2, y2)

        return {
            x: normalized.x * dot,
            y: normalized.y * dot
        }
    }

    function intersect(x1, y1, x2, y2, x3, y3, x4, y4)
    {
        var denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)

        var ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denom
        var ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denom
        return {
            x: x1 + ua * (x2 - x1),
            y: y1 + ua * (y2 - y1)
        };
    }

    function moveLine(startX, startY, endX, endY)
    {
        var angle = Math.atan2(endY - startY, endX - startX)
        var xOffset = Math.sin(angle) * root.radius
        var yOffset = -Math.cos(angle) * root.radius

        return {
            startX: startX + xOffset,
            startY: startY + yOffset,
            endX: endX + xOffset,
            endY: endY + yOffset
        };
    }

    function calc() {
        var movedLine1 = moveLine(path.__width / 2, 0, 0, path.__height)

        var movedLine2 = moveLine(path.__width, path.__height, path.__width / 2, 0)

        var movedLine3 = moveLine(0, path.__height, path.__width, path.__height)

        var intersectionTop = intersect(movedLine1.startX, movedLine1.startY, movedLine1.endX, movedLine1.endY,
                                        movedLine2.startX, movedLine2.startY, movedLine2.endX, movedLine2.endY)

        var intersectionLeft = intersect(movedLine1.startX, movedLine1.startY, movedLine1.endX, movedLine1.endY,
                                         movedLine3.startX, movedLine3.startY, movedLine3.endX, movedLine3.endY)

        var intersectionRight = intersect(movedLine2.startX, movedLine2.startY, movedLine2.endX, movedLine2.endY,
                                          movedLine3.startX, movedLine3.startY, movedLine3.endX, movedLine3.endY)

        var leftBottom = project(1, 0, intersectionLeft.x, intersectionLeft.y)

        var rightBottom = project(1, 0, intersectionRight.x, intersectionRight.y)

        root.leftIntersection1 = Qt.point(leftBottom.x, leftBottom.y + path.__height)
        root.rightIntersection2 = Qt.point(rightBottom.x, rightBottom.y + path.__height)

        var leftTop = project(-path.__width / 2 , path.__height, intersectionTop.x - path.__width / 2, intersectionTop.y)

        leftBottom = project(-path.__width / 2 , path.__height, intersectionLeft.x - path.__width / 2, intersectionLeft.y)

        root.leftIntersection2 = Qt.point(leftBottom.x + path.__width / 2, leftBottom.y)
        root.topIntersection1 = Qt.point(leftTop.x + path.__width / 2, leftTop.y)

        var rightTop = project(path.__width / 2 , path.__height, intersectionTop.x - path.__width / 2, intersectionTop.y)

        rightBottom = project(path.__width / 2 , path.__height, intersectionRight.x - path.__width / 2, intersectionRight.y)

        root.topIntersection2 = Qt.point(rightTop.x + path.__width / 2, rightTop.y)
        root.rightIntersection1 = Qt.point(rightBottom.x + path.__width / 2, rightBottom.y)
    }

}
