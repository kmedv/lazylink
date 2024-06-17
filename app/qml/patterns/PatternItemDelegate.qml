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
import net.lazylink 1.0

Rectangle {
    id: clipItem

    signal editMe(var pattern)
    signal deleteMe(var pattern)

    implicitHeight: dp_40
    color: (hoverInterceptor.containsMouse || itemMenuMouseArea.containsMouse)
           ? "#14295cb5"
           : "transparent"

    Image {
        id: favicon
        x: dp_24
        anchors.verticalCenter: parent.verticalCenter
        width: dp_16
        height: dp_16
        source: "qrc:/icon/placeholder-link.png"
        smooth: false
        Component.onCompleted: {
            // Load avatar
            if (modelData && !modelData.includes('*')) {
                var split = modelData.split('://');
                var domain = (split.length === 1) ? split[0]
                        : split.length === 2 ? split[1]
                        : undefined;
                if (domain !== undefined)
                    source = "http://www.google.com/s2/favicons?domain=" + domain;
            }
        }
    }

    Text {
        id: urlText
        anchors {
            left: favicon.right
            leftMargin: dp_11
            right: itemMenu.right
            rightMargin: dp_31
            verticalCenter: parent.verticalCenter
        }
        z: 1
        text: modelData
        color: "#394c6d"
        font.family: robotoRegular.name
        font.pixelSize: dp_15
    }

    Image {
        id: itemMenu
        anchors {
            right: parent.right
            rightMargin: dp_8
            verticalCenter: parent.verticalCenter
        }
        width: dp_24
        height: dp_24
        z: 1
        source: itemMenuMouseArea.containsMouse
                ? "qrc:/icon/i-drop-menu-hover.png"
                : "qrc:/icon/i-drop-menu.png"
        smooth: false
        visible: hoverInterceptor.containsMouse || itemMenuMouseArea.containsMouse
    }

    MouseArea {
        id: itemMenuMouseArea
        anchors.fill: itemMenu
        hoverEnabled: true
        z: 2
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var pnt = mapToItem(appWnd.contentItem, 0, 0);
            popupMenu.x = appWnd.x + pnt.x + width - popupMenu.width;
            popupMenu.y = appWnd.y + pnt.y;
            popupMenu.show();
        }
    }

    PopupMenu {
        id: popupMenu
        onEditLink: editMe(modelData)
        onDeleteItem: deleteMe(modelData)
    }

    MouseArea {
        id: hoverInterceptor
        anchors.fill: parent
        hoverEnabled: true
    }
}
