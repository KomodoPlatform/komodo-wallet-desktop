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

import QtQuick 2.9

Flipable {
    id: flipable
    width: 240
    height: 240

    property alias flipAngle: rotation.angle
    property real opacityFront: 1
    property real opacityBack: 1
    property int xAxis: 0
    property int yAxis: 1

    Binding {
        target: flipable.front
        value: opacityFront
        property: "opacity"
        when: flipable.front !== undefined
    }

    Binding {
        target: flipable.back
        value: opacityBack
        property: "opacity"
        when: flipable.back !== undefined
    }

    property bool flipped: false


    Component.onCompleted: {
        flipable.front = flipable.children[0]
        flipable.back = flipable.children[1]
    }

    transform: Rotation {
        id: rotation
        origin.x: flipable.width/2
        origin.y: flipable.height/2
        axis.x: flipable.xAxis; axis.y: flipable.yAxis; axis.z: 0
        angle: 0    // the default angle
    }
}
