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
import QtQuick.Timeline 1.0
import QtQuick.Shapes 1.0

Shape {
    width: 200
    height: 200

    property alias gradient: shape.fillGradient
    property alias strokeStyle: shape.strokeStyle
    property alias strokeWidth: shape.strokeWidth
    property alias strokeColor: shape.strokeColor
    property alias dashPattern: shape.dashPattern
    property alias joinStyle: shape.joinStyle
    property alias fillColor: shape.fillColor
    property alias path: pathSvg.path
    property alias dashOffset: shape.dashOffset
    property alias capStyle: shape.capStyle

    property bool antialiasing: false
    layer.enabled: antialiasing
    layer.smooth: antialiasing
    layer.textureSize: Qt.size(width * 2, height * 2)

    id: svgPathItem

    ShapePath {
        id: shape
        strokeWidth: 4
        strokeColor: "red"

        PathSvg {
            id: pathSvg

            path: "M91,70.6c4.6,0,8.6,2.4,10.9,6.3l19.8,34.2c2.3,3.9,2.3,8.7,0,12.6c-2.3,3.9-6.4,6.3-10.9,6.3H71.2 c-4.6,0-8.6-2.4-10.9-6.3c-2.3-3.9-2.3-8.7,0-12.6l19.8-34.2C82.4,72.9,86.4,70.6,91,70.6 M91,69.6c-4.6,0-9.2,2.3-11.8,6.8l-19.8,34.2c-5.2,9.1,1.3,20.4,11.8,20.4h39.5c10.5,0,17-11.3,11.8-20.4l-19.8-34.2C100.2,71.9,95.6,69.6,91,69.6L91,69.6z"
        }
    }
}
