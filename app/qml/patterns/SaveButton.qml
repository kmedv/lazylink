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
 
import QtQuick 2.0
import "../components"

BasicButton {
    id: root

    property string text

    property int horizontalMargin: dp_10    
    property real hoverFactor : 0.

    opacity: enabled ? 1.0 : 0.4
    state: hovered ? "hovered" : ""

    Rectangle {
        id: bg
        border {
            width: dp_2
            color: Qt.rgba(60/255., 131/255., 1., 1.)
        }
        width: text.width + root.horizontalMargin * 2
        height: dp_24
        radius: dp_40
        color: Qt.rgba(60/255., 131/255., 1., hoverFactor)

        Text {
            id: text
            anchors.centerIn: parent
            width: Math.ceil(implicitWidth)
            text: root.text
            color: Qt.rgba(
                       (60 + 195 * hoverFactor)/255.,
                       (131 + 124 * hoverFactor)/255.,
                       1., 1.)
            font.family: robotoBold.name
            font.weight: Font.Bold
            font.pixelSize: dp_13
        }
    }

    states: [
        State {
            name: "hovered"
            PropertyChanges {
                target: root
                hoverFactor: 1.0
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation {
                properties: "hoverFactor"
                duration: 150
            }
        }
    ]
}
