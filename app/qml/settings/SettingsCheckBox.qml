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
import QtQuick.Controls 2.2

CheckBox {
    id: control

    implicitWidth: Math.ceil(indicator.width + contentItem.implicitWidth + spacing)
    implicitHeight: Math.ceil(Math.max(indicator.height, contentItem.implicitHeight))
    spacing: dp_8
    font.family: robotoRegular.name
    font.pixelSize: dp_15
    leftPadding: 0
    topPadding: 0
    rightPadding: 0
    bottomPadding: 0
    opacity: enabled ? 1.0 : 0.4

    indicator: Image {
        x: control.leftPadding
        y: control.topPadding
        width: dp_16
        height: dp_16
        source: control.checked
                ? "qrc:/icon/i-check-on.png"
                : "qrc:/icon/i-check-off.png"
        smooth: false

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    contentItem: Text {
        anchors {
            left: indicator.right
            leftMargin: control.spacing
            right: control.right
            rightMargin: control.rightPadding
            top: indicator.top
            topMargin: control.topPadding
        }
        text: control.text
        font: control.font
        color: Qt.rgba(57/255., 76/255., 109/255., 1.0)
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignLeft
    }
}
