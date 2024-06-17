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

    signal clicked

    property bool activated: false
    property alias text: txt.text
    property int hMargin: dp_18

    implicitWidth: Math.ceil(txt.width) + hMargin * 2
    implicitHeight: dp_30
    radius: dp_40
    color: "#3c83ff"

    Text {
        id: txt
        anchors.centerIn: parent
        color: "#ffffff"
        width: Math.ceil(implicitWidth)
        font.family: robotoBold.name
        font.bold: true
        font.pixelSize: dp_13
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: false
        onClicked: root.clicked()
    }
}
