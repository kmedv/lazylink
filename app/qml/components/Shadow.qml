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
import QtGraphicalEffects 1.0

Item {
    id: root

    default property var item

    property bool shadowEnabled: true
    property int horizontalOffset: 0
    property int verticalOffset: 0
    property int shadowWidth: item.width
    property int shadowHeight: item.height
    property int blurRadius: 0
    property color color: "black"
    property int radius: 0

    implicitWidth: Math.max(item.width, shadow.x + shadow.width)
    implicitHeight: Math.max(item.height, shadow.y + shadow.height)

    Rectangle {
        id: shadow
        x: root.horizontalOffset
        y: root.verticalOffset
        width: root.shadowWidth
        height: root.shadowHeight
        visible: root.shadowEnabled
        opacity: item.opacity
        radius: root.radius
        layer.enabled: true
        layer.effect: GaussianBlur {
            source: shadow
            radius: root.blurRadius
            deviation: 4
            transparentBorder: true
            samples: radius * 2 + 1
            cached: true
        }
    }
}
