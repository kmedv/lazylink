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

    // Virtual background pane to calculate DropShadow correctly (+1 px left and right)
    Rectangle {
        id: backroundPane
        x: -1
        width: parent.width + 2     // + 2px for border
        height: parent.height
        color: "#f5f6fc"
        layer.enabled: true
        layer.effect: InnerShadow {
            source: backroundPane
            verticalOffset: -dp_1
            color: Qt.rgba(0, 0, 0, 0.2)
        }
    }

    DropShadow {
        anchors.fill: backroundPane
        source: backroundPane
        verticalOffset: dp_2
        color: Qt.rgba(0, 0, 0, 0.16)
        radius: dp_8
        samples: radius * 2 + 1
        transparentBorder: true
    }
}
