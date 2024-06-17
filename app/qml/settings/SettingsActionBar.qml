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
import "../"

ActionBar {
    id: root

    signal back()

    Item {
        id: backButton
        anchors.fill: parent

        Image {
            id: img
            anchors {
                left: parent.left
                leftMargin: dp_24
                verticalCenter: parent.verticalCenter
            }
            width: dp_16
            height: dp_16
            source: "qrc:/icon/i-back.png"
            smooth: false
        }

        Text {
            anchors {
                left: img.right
                leftMargin: dp_11
                verticalCenter: parent.verticalCenter
            }
            width: Math.ceil(implicitWidth)
            text: qsTr("Settings")
            color: "#384c6f"
            font.family: robotoBold.name
            font.weight: Font.Bold
            font.pixelSize: dp_15
            font.letterSpacing: 0.4 * dp_1
            font.capitalization: Font.AllUppercase
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.back()
        }
    }
}
