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

import QtQuick 2.9
import QtGraphicalEffects 1.0

Item {
    id: control

    property alias contentWidth: contentItem.width
    property alias contentHeight: contentItem.height

    readonly property bool textMode: textLabel.text.length > 0
    readonly property alias hovered: ma.containsMouse
    property alias image: imageItem.source
    property alias hoveredImage: hoveredImageItem.source

    property alias text: textLabel.text
    property color textColor: "#ffffff"
    property alias textFont: textLabel.font
    property color textBackgroundColor: "transparent"
    property int textHorizontalPadding: 0
    property int textVerticalPadding: 0

    property bool shadowed: false
    property color shadowColor: "#000000"
    property int shadowWidth: 0
    property int shadowHeight: 0
    property int shadowVerticalOffset: 0
    property int shadowHorizontalOffset: 0
    property int shadowBlurRadius: 0

    property int radius: 0
    property alias cursorShape: ma.cursorShape

    property real opacity_: 1.0

    QtObject {
        id: m
        readonly property int horizontalOffset: !shadowed ? 0
            : Math.abs(shadowHorizontalOffset) + shadowWidth + shadowBlurRadius;
        readonly property int verticalOffset: !shadowed ? 0
            : Math.abs(shadowVerticalOffset) + shadowHeight + shadowBlurRadius
    }

    signal clicked

    implicitWidth: Math.ceil(Math.max(contentItem.width, m.horizontalOffset))
    implicitHeight: Math.ceil(Math.max(contentItem.height, m.verticalOffset))

    Component.onCompleted: {
        if (opacity != 1.0) {
            opacity_ = opacity;
            opacity = 1.0;
        }
    }

    Rectangle {
        id: shadow
        x: control.shadowHorizontalOffset
        y: control.shadowVerticalOffset
        z: 0
        width: control.shadowWidth
        height: control.shadowHeight        // transparent border
        visible: control.shadowed
        color: control.shadowColor
        opacity: control.opacity_
        radius: control.radius
        layer.enabled: visible
        layer.effect: GaussianBlur {
            source: shadow
            radius: control.shadowBlurRadius
            deviation: 4
            transparentBorder: true
            samples: radius * 2 + 1
            cached: true
        }
    }

    Item {
        id: contentItem
        x: 0
        y: 0
        z: 1
        implicitWidth: textMode ? Math.ceil(textItem.implicitWidth) : imageItem.implicitWidth
        implicitHeight: textMode ? Math.ceil(textItem.implicitHeight) : imageItem.implicitHeight

        layer.enabled: control.radius > 0
        layer.effect: OpacityMask {
            source: contentItem
            maskSource: Rectangle {
                width: contentItem.width
                height: contentItem.height
                radius: control.radius
            }
        }

        Image {
            id: imageItem
            anchors.fill: parent
            visible: !control.textMode && !hoveredImage.visible
            opacity: control.opacity_
            smooth: false
        }

        Image {
            id: hoveredImageItem
            anchors.fill: imageItem
            visible: !control.textMode
                     && (source !== undefined && source.toString().length > 0)
                     && control.hovered
            opacity: control.opacity_
            smooth: false
        }

        Rectangle {
            id: textItem
            anchors.fill: parent
            visible: control.textMode
            implicitWidth: Math.ceil(textLabel.width) + control.textHorizontalPadding * 2
            implicitHeight: Math.ceil(textLabel.height) + control.textVerticalPadding * 2
            color: Qt.rgba(textBackgroundColor.r, textBackgroundColor.g, textBackgroundColor.b,
                           textBackgroundColor.a * control.opacity_)

            Text {
                id: textLabel
                width: Math.ceil(implicitWidth)
                anchors.centerIn: parent
                color: Qt.rgba(textColor.r, textColor.g, textColor.b,
                               textColor.a * control.opacity_)
            }
        }


        MouseArea {
            id: ma
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: control.clicked()
        }
    }
}
