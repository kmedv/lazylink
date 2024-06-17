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
import QtGraphicalEffects 1.0

Rectangle {
    id: root

    readonly property alias hovered: mouseArea.containsMouse

    property url icon
    property url iconHovered
    property string label

    property int paddingTop: dp_8
    property int paddingBottom: dp_8
    property int paddingLeft: dp_16
    property int paddingRight: dp_40
    property int spacing: dp_12

    signal clicked

    implicitWidth: paddingLeft + img.width + spacing + Math.ceil(txt.width) + paddingRight
    implicitHeight: paddingTop + img.height + paddingBottom
    color: hovered ? Qt.rgba(0, 0, 0, 0.1) : "transparent"

    Image {
        id: img
        x: paddingLeft
        y: paddingTop
        width: dp_24
        height: dp_24
        source: (root.iconHovered.toString().length > 0 && root.hovered)
                ? root.iconHovered
                : root.icon
        smooth: false
    }

    Text {
        id: txt
        anchors {
            left: img.right
            leftMargin: root.spacing
            verticalCenter: img.verticalCenter
        }
        width: Math.ceil(implicitWidth)
        text: root.label
        font.family: robotoMedium.name
        font.pixelSize: dp_15
        horizontalAlignment: Text.AlignLeft
        color: "#ffffff"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
