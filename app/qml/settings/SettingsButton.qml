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

Item {
    id: root

    property url icon
    property string label
    property int spacing: dp_8

    signal clicked

    implicitWidth: img.width + spacing +  Math.ceil(txt.width)
    implicitHeight: Math.max(img.height, Math.ceil(txt.height))

    Image {
        id: img
        x: 0
        y: 0
        width: dp_16
        height: dp_16
        source: root.icon
        smooth: false
    }

    Text {
        id: txt
        anchors {
            left: img.right
            leftMargin: root.spacing
            right: parent.right
            verticalCenter: img.verticalCenter
        }
        width: Math.ceil(implicitWidth)
        text: root.label
        font.family: robotoRegular.name
        font.pixelSize: dp_15
        color: "#394c6d"
        horizontalAlignment: Text.AlignLeft
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
