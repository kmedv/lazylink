/*  This file is part of Lazylink project (https://lazylink.net)
 *  Copyright (C) 2015-2019 Kirill Medvedev
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a
 *  copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.
 */

import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Templates 2.1 as T
import QtGraphicalEffects 1.0

T.Button {
    id: control

    property alias image: img.source
    property alias imageWidth: img.width
    property alias imageHeight: img.height
    property alias cursorShape: ma.cursorShape
    property alias backgroundColor: backgroundItem.color
    property int radius: 0

    implicitWidth: img.implicitWidth
    implicitHeight: img.implicitHeight

    layer.enabled: radius > 0
    layer.effect: OpacityMask {
        source: control
        maskSource: Rectangle {
            width: control.width
            height: control.height
            radius: control.radius
        }
    }

    contentItem: Image {
        id: img
        anchors.centerIn: control
        smooth: false
    }

    background: Rectangle {
        id: backgroundItem
        color: "transparent"

        MouseArea {
            id: ma
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }
}
