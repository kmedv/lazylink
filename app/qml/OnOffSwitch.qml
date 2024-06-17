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
import QtGraphicalEffects 1.0

Switch {
    id: control
    implicitWidth: dp_36
    implicitHeight: dp_20
    focusPolicy: Qt.NoFocus

    indicator: Rectangle {
        id: groove
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        implicitWidth: dp_36
        implicitHeight: dp_20
        radius: dp_40
        color: control.checked ? "#ffffff" : Qt.rgba(1.0, 1.0, 1.0, 0.6)

        Rectangle {
            id: handle
            x: control.checked ? parent.width - width - dp_4 : dp_4
            y: dp_3
            width: dp_14
            height: dp_14
            radius: width / 2
            color: control.checked ? "#3c83ff" : Qt.rgba(60/255.0, 131/255.0, 1.0, 0.4)
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }
}

