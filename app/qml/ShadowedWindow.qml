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
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

Window {
    id: wnd

    property color backgroundColor: "transparent"
    property int radius: 0

    property alias backX: backgroundItem.x
    property alias backY: backgroundItem.y
    property alias backWidth: backgroundItem.width
    property alias backHeight: backgroundItem.height

    property bool shadowEnabled: false
    property color shadowColor: "#000000"
    property int shadowHorizontalOffset: 0
    property int shadowVerticalOffset: 0
    property int shadowBlurRadius: 0

    readonly property int recommendedFlags: shadowEnabled ? Qt.NoDropShadowWindowHint : 0
    property var content;

    width: shadowEnabled ? (content.width + shadowBlurRadius * 2) : content.width
    height: shadowEnabled ? (content.height + shadowBlurRadius * 2) : content.height
    color: "transparent"

    Component {
        id: cornersCropComponent
        OpacityMask {
            source: content
            anchors.fill: content
            maskSource: Rectangle {
                width: content.width
                height: content.height
                radius: wnd.radius
            }
        }
    }

    Rectangle {
        id: backgroundItem
        x: shadowEnabled ? (shadowBlurRadius - shadowHorizontalOffset) : 0
        y: shadowEnabled ? (shadowBlurRadius - shadowVerticalOffset) : 0
        width: content.width
        height: content.height
        // Radius is enlarged because OpacityMask produces a little bit different results
        // with rounded corners comparing to Rect.round
        radius: wnd.radius * 2
        color: wnd.backgroundColor
        layer.enabled: shadowEnabled && (shadowBlurRadius > 0)
        layer.effect: DropShadow {
            anchors.fill: backgroundItem
            color: wnd.shadowColor
            horizontalOffset: wnd.shadowHorizontalOffset
            verticalOffset: wnd.shadowVerticalOffset
            radius: wnd.shadowBlurRadius
            transparentBorder: true
            samples: radius * 2 + 1
            cached: true
        }
    }

    Component.onCompleted: {
        content.x = backgroundItem.x;
        content.y = backgroundItem.y;
        content.z = 1
        if (radius > 0) {
            content.layer.enabled = true;
            content.layer.effect = cornersCropComponent;
        }
    }
}
